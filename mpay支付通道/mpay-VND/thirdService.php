<?php 

class quickpay_service
{
    const VERIFY_HTTPS_CERT = false;

    // Q/R code
    const RESP_SUCCESS  = "00"; //response success
    const QUERY_SUCCESS = "0";  //inquiry success
    const QUERY_FAIL    = "1";
    const QUERY_WAIT    = "2";
    const QUERY_INVALID = "3";

    // service type
    const FRONT_PAY = 1;
    const BACK_PAY  = 2;
    const RESPONSE  = 3;
    const QUERY     = 4;
    const INAPP_PAY = 5;

    const CONSUME                = "01";
    const CONSUME_VOID           = "31";
    const PRE_AUTH               = "02";
    const PRE_AUTH_VOID          = "32";
    const PRE_AUTH_COMPLETE      = "03";
    const PRE_AUTH_VOID_COMPLETE = "33";
    const REFUND                 = "04";
    const REGISTRATION           = "71";

    // currency code mapping
    const CURRENCY = array(
        "AUD" => "036",
        "NZD" => "554"
    );


    var $args;
    var $api_url;

    var $signature;
    var $signMethod;

    /**
     * 合成参数
     * @param payUrl <string> 支付url
     * @param payArgs <array> 参数
     * @param serviceType <int> 请求服务类型，如：页面表单提交方式
     */
    function quickpay_service($payUrl, $payArgs, $serviceType)
    {
        $param_check    = array();
        switch($serviceType)
        {
            case self::FRONT_PAY:
                $trans_type = $payArgs['transType'];
                if ($trans_type != self::CONSUME && $trans_type != self::PRE_AUTH) {
                    //frontend transaction just supports purchase and pre-authorization
                    throw new Exception("Bad trans_type for front_pay. Use back_pay instead");
                }
                $this->api_url = $payUrl;
                $this->args = array_merge(self::$pay_params_empty, $payArgs);
                $param_check = self::$pay_params_check;
            break;

            case self::INAPP_PAY:
                $this->api_url = $payUrl;
                $this->args = array_merge(self::$pay_params_empty, $payArgs);
                $param_check = self::$pay_params_check;
            break;

            case self::BACK_PAY:
                $this->api_url = $payUrl;
                $this->args = array_merge(self::$pay_params_empty, $payArgs);
                $param_check = self::$pay_params_check;
                $trans_type = $this->args['transType'];
                if ($trans_type == self::CONSUME || $trans_type == self::PRE_AUTH) {
                    if (!isset($this->args['cardNumber']) && !isset($this->args['pan'])) {
                        throw new Exception('consume OR pre_auth transactions need cardNumber!');
                    }
                }
                else {
                    if (empty($this->args['origQid'])) {
                        throw new Exception('origQid is not provided');
                    }
                }
            break;

            case self::QUERY:
                $this->api_url = $payUrl;

                if (empty($payArgs['merId']) &&
                    empty($payArgs['acqCode']))
                {
                    throw new Exception('merId and acqCode can\'t be both empty');
                }

                //acqCode is used as reserved filed in inquiry request
                if (!empty($payArgs['acqCode'])) {
                    $acqCode = $payArgs['acqCode'];
                    $payArgs['merReserved'] = "{acqCode=$acqCode}";
                }
                else {
                    $payArgs['merReserved'] = '';
                }

                $this->args = $payArgs;
                $param_check = self::$query_params_check;

            break;

            case self::RESPONSE:
                $arr_args = array();
                $arr_args_sig = array();
                $arr_reserved = array();

                if (is_array($payArgs)) {
                    $arr_args       = $payArgs;
                    $cupReserved    = isset($arr_args['cupReserved']) ? $arr_args['cupReserved'] : '';
                    parse_str(substr($cupReserved, 1, -1), $arr_reserved); //remove {} at the both ends
                }
                else {
                    $cupReserved = '';
                    $pattern = '/cupReserved=(\%7B.*?\%7D)/';
                    if (preg_match($pattern, $payArgs, $match)) { //extract cupReserved first
                        $cupReserved = $match[1];
                    }

                    //remove the value of cupReserved (parse_str can't handle &)

                    $args_r         = preg_replace($pattern, 'cupReserved=', $payArgs);
                    parse_str($args_r, $arr_args);

                  $cupReserved = urldecode($cupReserved);


                    $arr_args['cupReserved'] = $cupReserved;
                   // parse_str(substr($cupReserved, 1, -1), $arr_reserved); //remove {} at the both ends

                }

                //extract signature of server
                if (!isset($arr_args['signature']) || !isset($arr_args['signMethod'])) {
                    throw new Exception('No signature Or signMethod set in notify data!');
                }
                $this->signature = $arr_args['signature'];
                $this->signMethod= $arr_args['signMethod'];
                unset($arr_args['signature']);
                unset($arr_args['signMethod']);

                //verify signature
                // $signature = self::sign($arr_args, $this->signMethod);

                // if ($signature != $this->signature) {
                //     throw new Exception('Bad signature returned!');
                // }

                $this->args = array_merge($arr_args, $arr_reserved);
                unset($this->args['cupReserved']);

                return; //do not need to process response parameters

            default:
                throw new Exception("Unknown service provided.");
        }

        if (isset($this->args['commodityUrl'])) {
            $this->args['commodityUrl'] = self::encodeURI($this->args['commodityUrl']);
        }

        //merReserved: frontend payment, inquiry
        $has_reserved = false;
        $arr_reserved = array();
        foreach (self::$mer_params_reserved as $key) {
            if (isset($this->args[$key])) {
                $value = $this->args[$key];
                unset($this->args[$key]);
                $arr_reserved[] = "$key=$value";
                $has_reserved = true;
            }
        }
        if ($has_reserved) {
            $this->args['merReserved'] = sprintf("{%s}", join("&", $arr_reserved));
        }
        else {
            //must set merReserved in request
            if (!isset($this->args['merReserved'])) {
                $this->args['merReserved'] = '';
            }
        }

        //param check
        foreach ($param_check as $key) {
            if (!isset($this->args[$key])) {
                throw new Exception("KEY [$key] not set in params given");
            }
        }

        //signature
        // $this->args['signature']    = self::sign($this->args, $payArgs['signMethod']);
        // $this->args['signMethod']   = $payArgs['signMethod'];

    } //end of constructor

    function get($key, $default = null)
    {
        if (isset($this->args[$key])) {
            return $this->args[$key];
        }
        return $default;
    }

    function get_args()
    {
        return $this->args;
    }

    static function encode($value, $output_charset, $input_charset)
    {
		if (strtolower($input_charset) == strtolower($output_charset) || empty($value)) {
			return $value;
		}
		if (function_exists("iconv")) {
			return iconv($input_charset, $output_charset, $value);
		}
		if (function_exists("mb_convert_encoding")) {
			return mb_convert_encoding($value, $output_charset, $input_charset);
		}
		throw new Exception("sorry, mbstring or iconv is needed for charset conversion.");
    }

    static function make_seed()
    {
        list($usec, $sec) = explode(' ', microtime());
        return (float) $sec + ((float) $usec * 100000);
    }

    static function encodeURI($url)
    {
        if (preg_match("/^(.*?)\?(.*)/", $url, $match)) {
            $prefix = preg_replace("/\?.*/", "", $url);
            $query_string = $match[2];
            $arr_keqv = explode('&', $query_string);
            $arr_encoded = array();
            foreach ($arr_keqv as $keqv) {
                list($key, $value) = explode('=', $keqv);
                $arr_encoded[] = sprintf("%s=%s", $key, urlencode($value));
            }
            $query_string = join('&', $arr_encoded);
            return $prefix . '?' . $query_string;
        }
        else {
            return $url;
        }
    }

    static function decodeURI($url)
    {
        if (preg_match("/^(.*?)\?(.*)/", $url, $match)) {
            $prefix = preg_replace("/\?.*/", "", $url);
            $query_string = $match[2];
            $arr_keqv = explode('&', $query_string);
            $arr_decoded = array();
            foreach ($arr_keqv as $keqv) {
                list($key, $value) = explode('=', $keqv);
                $arr_decoded[] = sprintf("%s=%s", $key, urldecode($value));
            }
            $query_string = join('&', $arr_decoded);
            return $prefix . '?' . $query_string;
        }
        else {
            return $url;
        }
    }

    // static function sign($params, $sign_method)
    // {
    //     if (strtolower($sign_method) == "md5") {
    //         ksort($params);
    //         $sign_str = "";
    //         foreach ($params as $key => $val) {
    //             if (in_array($key, self::$sign_ignore_params)) {
    //                 continue;
    //             }
    //             $sign_str .= sprintf("%s=%s&", $key, $val);
    //         }
    //         $skey = md5(self::$security_key);

    //         return md5($sign_str . $skey);
    //     }
    //     else {
    //         throw new Exception("Unknown sign_method set in self");
    //     }
    // }

    function create_query_string()
    {
        $query_string = '';
        foreach ($this->args as $key => $value) {
            $query_string .= sprintf("%s=%s&", $key, urlencode($value));
        }
        return $query_string;
    }

    function post()
    {
        return self::curl_call($this->api_url, $this->args, array(
                        CURLOPT_SSL_VERIFYPEER  => self::VERIFY_HTTPS_CERT,
                    ));
    }


    static function curl_call($url, $data = null, $is_post = true, $options = null)
    {
        if (function_exists("curl_init")) {
            $curl = curl_init();

            if (is_array($data)) {
                $data = http_build_query($data);
            }

            if ($is_post) {
                curl_setopt($curl, CURLOPT_POST, 1);
                curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
            }
            else { //GET
                if (!empty($data)) {
                    $sep = '?';
                    if (strpos($url, '?') !== false) {
                        $sep = '&';
                    }
                    $url .= $sep . $data;
                }
            }

            curl_setopt($curl, CURLOPT_URL, $url);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($curl, CURLOPT_HEADER, false);
            curl_setopt($curl, CURLOPT_TIMEOUT, 60); //seconds
						curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);

            if (is_array($options)) {
                foreach($options as $key => $value) {
                    curl_setopt($curl, $key, $value);
                }
            }

            $ret_data = curl_exec($curl);

            if (curl_errno($curl)) {
                printf("curl call error(%s): %s\n", curl_errno($curl), curl_error($curl));
                curl_close($curl);
                return false;
            }
            else {

                curl_close($curl);
                return $ret_data;
            }
        }

        else {
            throw new Exception("[PHP] curl module is required");
        }
    }

    //payment request fields could be null (but must complete)
    static $pay_params_empty = array(
        "origQid"           => "",
        "acqCode"           => "",
        "merCode"           => "",
        "commodityName"     => "",
        "transTimeout"      => "300000",
        "merReserved"       => "",
    );

    //required fields check of payment request
    static $pay_params_check = array(
        "version",
        "charset",
        "transType",
        "origQid",
        "merId",
        "merAbbr",
        "acqCode",
        "merCode",
        "commodityName",
        "orderNumber",
        "orderAmount",
        "orderCurrency",
        "orderTime",
        "customerIp",
        "transTimeout",
        "frontEndUrl",
        "backEndUrl",
        "merReserved",
    );

    //required fields check of inquiry request
    static $query_params_check = array(
        "version",
        "charset",
        "transType",
        "merId",
        "orderNumber",
        "orderTime",
        "merReserved",
    );

    //possible merchant reserved fields
    static $mer_params_reserved = array(
    //  NEW NAME            OLD NAME
        "cardNumber",       "pan",
        "cardPasswd",       "password",
        "credentialType",   "idType",
        "cardCvn2",         "cvn",
        "cardExpire",       "expire",
        "credentialNumber", "idNo",
        "credentialName",   "name",
        "phoneNumber",      "mobile",
        "merAbstract",

        //tdb only
        "orderTimeoutDate",
        "origOrderNumber",
        "origOrderTime",
    );

    static $notify_param_check = array(
        "version",
        "charset",
        "transType",
        "respCode",
        "respMsg",
        "respTime",
        "merId",
        "merAbbr",
        "orderNumber",
        "traceNumber",
        "traceTime",
        "qid",
        "orderAmount",
        "orderCurrency",
        "settleAmount",
        "settleCurrency",
        "settleDate",
        "exchangeRate",
        "exchangeDate",
        "cupReserved",
        "signMethod",
        "signature",
    );

    static $sign_ignore_params = array(
        "bank",
    );
}

?>