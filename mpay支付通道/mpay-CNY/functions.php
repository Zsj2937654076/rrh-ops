<?php
error_reporting(0);


//-----------------------------------------------------------------------------
// 共用函数
//-----------------------------------------------------------------------------
/**
 * 数组过滤空字符串值的callback函数
 */
function filterEmpty($var) {
    return $var !== '';
}

class ClientType
{
    // client type enum
    const ClientType_Unknown = 0;
    const ClientType_Browser = 1;
    const ClientType_Mobile = 2;
}

class Fun
{
    // encryptType enum
    const EncryType_RSA = 'RSA';
    const EncryType_HMAC = 'HMAC';

    // signType enum
    const SignType_MD5 = 'MD5';
    
    // lettersCase enum
    const LetterCase_LOWER = 'lower';
    const LetterCase_UPPER = 'upper';

    // HTTP Method enum
    // 1. 标准的HTTP方法
    const Method_GET = 'GET';
    const Method_POST = 'POST';
    const Method_PUT = 'PUT';
    // 2. 扩展的伪造METHOD，这类方式不会真实请求到外部服务器，而数据都由底层方法生成
    const Method_FORGE = 'FORGE'; /// 用于只拼接出请求URL，并将其做为payUrl返回给CRM
    const Method_FORPAGE = 'FORPAGE'; /// 会生成一个支付跳转页（），并把该跳转页的URL返回给CRM



    /**
     * @Note 优化版生成签名
     * @param params 参数数组
     * @param appsecret 签名的key，如果设置为null，则加密key不会被拼接
     * @param opt <array>
     * @- secretKeyName 加密key的名称，默认为'key'
     * @- sep key-value对之间的分隔符，默认为'&'
     * @- KVsep key与value之间的分隔符，如果设置为null，则key不会被拼接，默认为'='
     * @- bSort 是否对参数集进行ksort()
     * @- bOmitempty 是否跳过空值，这里指空字符串，默认为false
     * @- signType 签名算法，默认'md5'
     * @- encryptType 签名对应的加密方式，可先值为：null、'RSA'、'HMAC'等，默认为null
     * @- bRSAPubkeyVerifySign 当encryptType为RSA，且用于进行公钥验签时，置为true，默认为false
     * @- urlencode 是否使用url编码
     * @- lettersCase 指定是否将签名字符串转换成大写或小写，可选值：'none'、'lower'、'upper'，默认为'lower'
     * @- verifySign [隐藏参数] 当bRSAPubkeyVerifySign为true时，需要将签名通过该参数带进来，结果成功直接返回'OK'，失败返回'ERROR'
     * 
     * opt = array(
     *   'secretKeyName' => 'key',
     *   'sep' => '&',
     *   'KVsep' => '=',
     *   'bSort' => true,
     *   'bOmitempty' => false,
     *   'signType' => 'md5',
     *   'encryptType' => null
     * );
     * @return <string>
     */
    static function genSign2(array $params, string $appsecret, $opt = array(), callable $fnSignDeform = null) : string {
        if ($opt == null) {
            $opt = array();
        }
        $secretKeyName = (array_key_exists('secretKeyName', $opt)) ? $opt['secretKeyName'] : 'key';
        $sep = (array_key_exists('sep', $opt)) ? $opt['sep'] : '&';
        $KVsep = (array_key_exists('KVsep', $opt)) ? $opt['KVsep'] : '=';
        $bSort = (array_key_exists('bSort', $opt)) ? $opt['bSort'] : true;
        $bOmitempty = (array_key_exists('bOmitempty', $opt)) ? $opt['bOmitempty'] : false;
        $signType = (array_key_exists('signType', $opt)) ? $opt['signType'] : 'md5';
        $encryptType = (array_key_exists('encryptType', $opt)) ? $opt['encryptType'] : null;
        $bUrlencode = array_key_exists('urlencode', $opt) && $opt['urlencode'];
        $lettersCase = (array_key_exists('lettersCase', $opt)) ? $opt['lettersCase'] : 'lower';

        // 隐藏参数
        $verifySign = (array_key_exists('verifySign', $opt)) ? $opt['verifySign'] : false;

        if ($bOmitempty) {
            $params = array_filter($params, "filterEmpty");
        }
        //签名步骤一：按字典序排序参数
        if ($bSort) {
            ksort($params);
        }
        $string_a = ''; // http_build_query($params);
        foreach ($params as $k => $v) {
            if ($string_a != '') {
                $string_a .= $sep;
            }
            if ($KVsep !== null) {
                $string_a .= $k;
                $string_a .= $KVsep;
            }
            $string_a .= ($bUrlencode) ? urlencode($v) : $v;
        }

        //签名步骤二：在string后加入mch_key
        if ($appsecret !== null && $encryptType === null) {
            $string_sign_temp = $string_a . (($secretKeyName == '') ? '' : ($sep . $secretKeyName . $KVsep)) . $appsecret;
        } else {
            $string_sign_temp = $string_a;
        }
        if (GConf::G_OUT_LOG) {
            echo 'origin string: ' . $string_sign_temp . PHP_EOL;
        }

        //签名步骤三：MD5加密
        switch ($encryptType) {
            case self::EncryType_RSA:
                if (empty($verifySign)) {
                    // 获取私钥文件的内容
                    $sslkey = openssl_get_privatekey($appsecret);
                    // 私钥生成签名
                    openssl_sign($string_sign_temp, $signature, $sslkey, $signType);
                    openssl_free_key($sslkey);
                    $sign = base64_encode($signature);
                } else {
                    $sslkey = openssl_get_publickey($appsecret);
                    $ok = openssl_verify($string_sign_temp, base64_decode($verifySign), $sslkey, $signType);
                    $signRes = $ok == 1 ? 'OK' : 'ERROR';
                    return $signRes;
                }
                break;

            case self::EncryType_HMAC:
                $sign = hash_hmac($signType, $string_sign_temp, $appsecret);
                break;

            default:
                $sign = hash($signType, $string_sign_temp);
        }

        if ($fnSignDeform != null) {
            $sign = $fnSignDeform($sign);
        }
        if (GConf::G_OUT_LOG) {
            echo 'hash string: ' . $sign . PHP_EOL;
        }

        // 签名步骤四：大小写转换
        switch ($lettersCase) {
            case self::LetterCase_UPPER:
                $result = strtoupper($sign);
                break;

            case self::LetterCase_LOWER:
                $result = strtolower($sign);
                break;

            default:
                $result = $sign;
        }
        

        return $result;
    }


    /**
     * @Note 验证签名
     * @param $params 参数数组
     * @param $appsecret
     * @return bool
     */
    private static function _verifySign($params, $appsecret, $signName = 'sign', $opt = null, callable $fnSignDeform = null) {
        // 验证参数中是否有签名
        if (!isset($params[$signName]) || !$params[$signName]) {
            return false;
        }
        // 要验证的签名串
        $sign = $params[$signName];
        unset($params[$signName]);

        // RSA公钥验签判断
        $verifyRSAPubkey = (array_key_exists('bRSAPubkeyVerifySign', $opt)) ? $opt['bRSAPubkeyVerifySign'] : false;
        if ($verifyRSAPubkey) {
            $opt['verifySign'] = $sign;
        } else {
            // 是否需要置false?
            //$opt['verifySign'] = false;
        }
        
        // 生成新的签名、验证传过来的签名
        $sign2 = self::genSign2($params, $appsecret, $opt, $fnSignDeform = null);
        if (GConf::G_OUT_LOG) {
            echo 'param sign: ' . $sign . ", hash sign: " . $sign2 . PHP_EOL;
        }
        if (($sign2 == 'OK') || ($sign == $sign2)) {
            return true;
        }

        return false;
    }

    /**
     * 使用curl发送http(s)请求
     *
     */
    private static function curlSend($url, $method = 'GET', $postData = array(), $header = array(), $reqOpt = array())
    {
        $data = '{"code":-1, "msg":"params error"}';
        // $user_agent = $_SERVER['HTTP_USER_AGENT'];
        // $header = array(
        //     "User-Agent: $user_agent"
        // );
        if (!empty($url)) {
            try {
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, $url);
                curl_setopt($ch, CURLOPT_HEADER, false);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                curl_setopt($ch, CURLOPT_TIMEOUT, (array_key_exists('timeout', $reqOpt)) ? $reqOpt['timeout'] : 20); //30秒超时
                curl_setopt($ch, CURLOPT_FOLLOWLOCATION, (array_key_exists('followLocation', $reqOpt)) ? $reqOpt['followLocation'] : 1);
                curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
                //curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);
                if (strstr($url, 'https://')) {
                    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); // https请求 不验证证书和hosts
                    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
                }

                if (strtoupper($method) == 'POST') {
                    $curlPost = is_array($postData) ? http_build_query($postData) : $postData;
                    curl_setopt($ch, CURLOPT_POST, 1);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $curlPost);
                }
                $data = curl_exec($ch);
                $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

                if ($code > 300 && $code < 310) {
                    $headers = curl_getinfo($ch);
                    $data = array(
                        'code' => 302,
                        'msg' => 'redirect',
                        'data' => $headers['redirect_url']
                    );
                }

                curl_close($ch);
            } catch (Exception $e) {
                $data = '{"code":-1, "msg":"' . $e . '"}';
            }
        }
        if (is_string($data)) {
            $x = json_decode($data, true);
        } else if (is_array($data)) {
            $x = $data;
        } else {
            $x = null;
        }
        if (empty($x)) {
            $x = array(
                'code' => -1,
                'msg' => 'respon data format error',
                'data' => $data
            );
        }
        //print_r($x);
        return $x;
    }

    /**
     * 发送http请求
     * @param url <string> 请求URL
     * @param method <string> 方式，GET或POST
     * @param params <array> 参数集
     * @param paramFormat <int>请求参数数据类型，0表示key=value格式（默认）；1表示JSON格式；
     * @param header <array> 扩展请求头
     */
    static function sendRequest($url, $method, $params = array(), $paramFormat = 0, $header = array(), $reqOpt = array())
    {
        $_METHOD = strtoupper($method);
        if (self::Method_FORGE == $_METHOD) {
            $pu = $url . http_build_query($params);
            return array(
                'code' => 0,
                'msg' => 'forge',
                'data' => array(
                    'url' => $pu,
                    'pay_order' => null
                )
            );
        } elseif (self::Method_FORPAGE == $_METHOD) {
            $html = self::genPayPage($url, $params, $header);

            return array(
                'code' => -1,
                'msg' => 'respon data format error',
                'data' => $html
            );
        }

        if (1 == $paramFormat) {
            $paramsJson = json_encode($params, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            return self::curlSend($url, $method, $paramsJson, $header, $reqOpt);
        } else {
            if (strtoupper($method) == 'GET' && !empty($params)) {
                $url .= http_build_query($params);
            }
            return self::curlSend($url, $method, $params, $header, $reqOpt);
        }
    }

    /**
     * 返回响应数据
     */
    private static function responJson($params, $jsonFlag = 0, $bOmitempty = false)
    {
        if ($bOmitempty) {
            $params = array_filter($params, "filterEmpty");
        }

        $rspJson = json_encode($params, $jsonFlag);
        echo $rspJson;
    }


    /**
     * rsa加密
     * @param str 明文
     * @param rsa_public 公钥
     */
    static function encryptRsa($str, $rsa_public, $opt = array())
    {
        if (!$str) {
            return ['code' => '-1', 'msg' => '缺少加密参数'];
        }
        if (!$rsa_public) {
            return ['code' => '-1', 'msg' => '缺少RSA公钥'];
        }

        $public_key = openssl_pkey_get_public($rsa_public);
        if (!$public_key) {
            return ['code' => '-1', 'msg' => 'RSA公钥不可用'];
        }

        $sep = (array_key_exists('sep', $opt)) ? $opt['sep'] : '&';
        $KVsep = (array_key_exists('KVsep', $opt)) ? $opt['KVsep'] : '=';
        $bSort = (array_key_exists('bSort', $opt)) ? $opt['bSort'] : true;
        $bUrlencode = array_key_exists('urlencode', $opt) && $opt['urlencode'];

        //签名步骤一：按字典序排序参数
        if ($bSort) {
            ksort($str);
        }
        $string_a = '';
        // http_build_query($params);
        foreach ($str as $k => $v) {
            if ($string_a != '') {
                $string_a .= $sep;
            }
            if ($KVsep !== null) {
                $string_a .= $k;
                $string_a .= $KVsep;
            }
            $string_a .= ($bUrlencode) ? urlencode($v) : $v;
        }

        $str = $string_a;

        $rstr = '';
        $bits = openssl_pkey_get_details($public_key)['bits'];
        $tmp_arr = str_split($str, ($bits / 8) - 11);
        foreach ($tmp_arr as $val) {
            openssl_public_encrypt($val, $encrypt_data, $public_key);
            $rstr .= $encrypt_data;
        }

        return base64_encode($rstr);
    }

    /**
     * rsa解密
     * @param str 密文
     * @param rsa_private 私钥
     */
    static function decryptRsa($str, $rsa_private)
    {
        if (!$str) {
            return ['code' => '-1', 'msg' => '缺少解密参数'];
        }
        if (!$rsa_private) {
            return ['code' => '-1', 'msg' => '缺少RSA私钥'];
        }
        $private_key = openssl_pkey_get_private($rsa_private);
        if (!$private_key) {
            return ['code' => '-1', 'msg' => 'RSA私钥不可用'];
        }
        $decrypted = '';
        $str = base64_decode($str);
        $bits = openssl_pkey_get_details($private_key)['bits'];
        $tmp_arr = str_split($str, $bits / 8);
        foreach ($tmp_arr as $val) {
            openssl_private_decrypt($val, $decrypt_data, $private_key);
            if ($decrypt_data) {
                $decrypted .= $decrypt_data;
            }
        }
        $decrypted = base64_decode($decrypted);
        $params = json_decode($decrypted, true);
        if (!$params) {
            $params = $decrypted;
        }
        return ['code' => '1', 'msg' => '解密成功', 'data' => $params, 'decrypted' => $decrypted];
    }

    /**
     * Triple DES 加密算法
     * @param data string 要加密的数据
     * @param key string 加密key
     * @param iv string 加密向量
     * @return string 加密后的十六进制字符串(大写)
     */
    static function encryptTripleDES($data, $key, $iv)
    {
        $cipher = "des-ede3-cbc";
        $options = OPENSSL_RAW_DATA;
        $encrypted = openssl_encrypt($data, $cipher, $key, $options, $iv);
        return strtoupper(bin2hex($encrypted));
    }

    /**
     * Triple DES 解密算法
     * @param encryptedData string 要解密的十六进制字符串(大写)
     * @param key string 加密key
     * @param iv string 加密向量
     * @return string 解密后的数据
     */
    static function decryptTripleDES($encryptedData, $key, $iv)
    {
        $cipher = "des-ede3-cbc";
        $options = OPENSSL_RAW_DATA;
        $encryptedData = hex2bin($encryptedData);
        return openssl_decrypt($encryptedData, $cipher, $key, $options, $iv);
    }

    /**
     * 获取http请求的参数，支持GET、POST等方法，也支持url参数与body中的json串
     */
    static function getParams(): array
    {
        if (empty($_REQUEST)) {
            $val = file_get_contents('php://input');
            $val = preg_replace('/:\s*(?!\B"[^"]*)(\-?\d+(\.\d+)?([e|E][\-|\+]\d+)?)(?![^"]*"\B)/', ': "$1"', $val);
            $val = preg_replace('/\s$/', '', $val);
            $params = json_decode($val, true);
            if (null == $params) {
                parse_str($val, $params);
            }
        } else {
            $params = $_REQUEST;
        }
        return $params;
    }

    static function getRealIp()
    {
        $ip = FALSE;

        //客户端IP 或 NONE
        if (!empty($_SERVER["HTTP_CLIENT_IP"])) {
            $ip = $_SERVER["HTTP_CLIENT_IP"];
        }

        //多重代理服务器下的客户端真实IP地址（可能伪造）,如果没有使用代理，此字段为空
        if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ips = explode(", ", $_SERVER['HTTP_X_FORWARDED_FOR']);
            if ($ip) {
                array_unshift($ips, $ip);
                $ip = FALSE;
            }
            for ($i = 0; $i < count($ips); $i++) {
                if (!preg_match("/^(10│172.16│192.168)./i", $ips[$i])) {
                    $ip = $ips[$i];
                    break;
                }
            }
        }

        //客户端IP 或 (最后一个)代理服务器 IP
        return ($ip ? $ip : $_SERVER['REMOTE_ADDR']);
    }

    static function getClientType(): int
    {
        if (!empty($_SERVER['HTTP_USER_AGENT'])) {
            $ua = strtolower($_SERVER['HTTP_USER_AGENT']);
            if (strpos($ua, 'mobile') !== false) {
                return ClientType::ClientType_Mobile;
            } else if (strpos($ua, 'mozilla') !== false) {
                return ClientType::ClientType_Browser;
            } else {
                // unknow
            }
        }

        return ClientType::ClientType_Unknown;
    }

    //---------------------------

    private static function flattenArray($params, &$newParams, $arrayStuct): bool
    {
        foreach ($arrayStuct as $k => $v) {
            if (is_array($v)) {
                if (self::flattenArray($params[$k], $newParams, $v) == null) {
                    return false;
                }
            } else {
                if (isset($params[$k])) {
                    $newParams[$k] = $params[$k];
                } else {
                    if ($v) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    /**
     * 通用的验签函数，可指定不同的规则
     * @param params <array> 请求中的参数集
     * @param argsForSign <array> 用于指定
     */
    static function verifySign($params, $argsForSign, $key, $signName, $opt = null, callable $fnSignDeform = null): int
    {
        $argsTmp = array();

        if (empty($argsForSign)) {
            $argsTmp = $params;
        } else {
            // 将参数转到临时对象，并验证必填参数
            if (!self::flattenArray($params, $argsTmp, $argsForSign)) {
                return -1;
            }
        }

        // 验签
        if (!self::_verifySign($argsTmp, $key, $signName, $opt, $fnSignDeform)) {
            return -2;
        }

        return 0;
    }

    static function writeRespon($rsp)
    {
        if (is_array($rsp)) {
            self::responJson($rsp, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        } else {
            header("Content-Type: text/html; charset='UTF-8'");
            echo $rsp;
        }
    }

    /**
     * genPayPage 生成中转服务的支付页面，以表单方式提交给第三方通道
     * @param payArgs <object> form表单数据结构，不会在页面上展示
     * @param showArgs <array> 页面上要展示的数据
     */
    static function genPayPage($postUrl, $payArgs, array $showArgs): string
    {
        $html = <<<eot
        <html>
        <head>
            <meta charset="UTF-8">
            <meta content="origin" name="referrer">
            <link href="/manifest?pwa=webhp" crossorigin="use-credentials" rel="manifest">
            <title>Pay now</title>
            <style>
                h1,
                ol,
                ul,
                li,
                button {
                    margin: 0;
                    padding: 0
                }

                button {
                    border: none;
                    background: none
                }

                body {
                    background: #fff
                }

                body,
                input,
                button {
                    font-size: 14px;
                    font-family: arial, sans-serif;
                    color: #4c4948
                }

                a {
                    color: #1a0dab;
                    text-decoration: none
                }

                a:hover,
                a:active {
                    text-decoration: underline
                }

                a:visited {
                    color: #609
                }

                html,
                body {
                    min-width: 400px
                }

                body,
                html {
                    height: 100%;
                    margin: 0;
                    padding: 0
                }
            </style>
        </head>
        <body>
        <style>
            .L3eUgb {
                display: flex;
                flex-direction: column;
                height: 100%
            }

            .o3j99 {
                flex-shrink: 0;
                box-sizing: border-box
            }

            .n1xJcf {
                height: 60px
            }

            .LLD4me {
                min-height: 150px;
                max-height: 290px;
                height: calc(100% - 560px)
            }

            .yr19Zb {
                min-height: 92px
            }

            .ikrT4e {
                max-height: 160px
            }

            .qarstb {
                flex-grow: 1
            }
        </style>
        <div class="L3eUgb" data-hveid="1">
            <div class="o3j99 n1xJcf Ne6nSd">
                <style>
                    .Ne6nSd {
                        display: flex;
                        align-items: center;
                        margin: 20px auto;
                        padding: 0px
                    }

                    .LX3sZb {
                        display: inline-block;
                        flex-grow: 1
                    }
                </style>
                <div class="LX3sZb">
                    <style>
                        .payTitle {
                            font-size: 34px;
                        }
                    </style>
                    <div class="payTitle">支付信息确认</div>
                </div>
            </div>
            <div class="o3j99 LLD4me yr19Zb LS8OJ">
                <style>
                    .LS8OJ {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        background-color: #f4f4f4;
                    }

                    .k1zIA {
                        height: 100%;
                    }
                </style>
                <div class="k1zIA rSk4se">
                    <style>
                        .rSk4se {
                            max-height: 92px;
                            position: relative;
                        }

                        .lnXdpd {
                            max-height: 100%;
                            max-width: 100%;
                            object-fit: contain;
                            object-position: center bottom;
                            width: auto
                        }

                        .tdName {
                            padding: 20px 5px 20px 40px;
                            text-align: right;
                            color: #333;
                        }

                        .tdValue {
                            color: #333;
                        }
                    </style>
                </div>
                <table border = "0">
        eot;

        $i = 0;
        foreach ($showArgs as $key => $value) {
            if ($i % 3 == 0) {
                $html .= "<tr>";
            }
            $html .= "<td class=\"tdName\">{$key}:</td><td class=\"tdValue\">{$value}</td>\n";
            if ($i % 3 == 2) {
                $html .= "</tr>";
            }
            $i++;
        }

        $html .= <<<eot
                    </table>
                </div>
                <div class="o3j99 ikrT4e om7nvf">
                    <style>
                        .om7nvf {
                            padding: 20px
                        }
                    </style>
                </div>
                <div class="o3j99 qarstb">
                    <style>
                        .vcVZ7d {
                            text-align: center
                        }
                        .ant-btn {
                            line-height: 1.499;
                            position: relative;
                            display: inline-block;
                            font-weight: 400;
                            white-space: nowrap;
                            text-align: center;
                            background-image: none;
                            border: 1px solid transparent;
                            -webkit-box-shadow: 0 2px 0 rgba(0,0,0,0.015);
                            box-shadow: 0 2px 0 rgba(0,0,0,0.015);
                            cursor: pointer;
                            -webkit-transition: all .3s cubic-bezier(.645, .045, .355, 1);
                            transition: all .3s cubic-bezier(.645, .045, .355, 1);
                            -webkit-user-select: none;
                            -moz-user-select: none;
                            -ms-user-select: none;
                            user-select: none;
                            -ms-touch-action: manipulation;
                            touch-action: manipulation;
                            height: 32px;
                            padding: 0 15px;
                            font-size: 14px;
                            border-radius: 4px;
                            color: rgba(0,0,0,0.65);
                            background-color: #fff;
                            border-color: #d9d9d9;
                        }

                        .ant-btn-primary {
                            color: #fff;
                            background-color: #1890ff;
                            border-color: #1890ff;
                            text-shadow: 0 -1px 0 rgba(0,0,0,0.12);
                            -webkit-box-shadow: 0 2px 0 rgba(0,0,0,0.045);
                            box-shadow: 0 2px 0 rgba(0,0,0,0.045);
                        }
                        .ant-btn-red {
                            color: #fff;
                            background-color: #FF5A44;
                            border-color: #FF5A44;
                            text-shadow: 0 -1px 0 rgba(0,0,0,0.12);
                            -webkit-box-shadow: 0 2px 0 rgba(0,0,0,0.045);
                            box-shadow: 0 2px 0 rgba(0,0,0,0.045);
                        }
                    </style>
                    <form id="pay_form" name="pay_form" class="vcVZ7d" action="{$postUrl}" method="post">
        eot;

        foreach ($payArgs as $key => $value) {
            $html .= "<input type='hidden' name=\"{$key}\" value=\"{$value}\" />\n";
        }

        $html .= <<<eot
                <button type="submit" class="ant-btn ant-btn-red">确&nbsp定</button>
            </form>
            </div>
            <div class="o3j99 c93Gbe">
                <style>
                    .c93Gbe {
                        background: #f2f2f2
                    }

                    .uU7dJb {
                        padding: 15px 30px;
                        border-bottom: 1px solid #dadce0;
                        font-size: 15px;
                        color: #70757a
                    }

                    .SSwjIe {
                        padding: 0 20px
                    }

                    .KxwPGc {
                        display: flex;
                        flex-wrap: wrap;
                        justify-content: space-between
                    }

                    @media only screen and (max-width:1200px) {
                        .KxwPGc {
                            justify-content: space-evenly
                        }
                    }

                    .pHiOh {
                        display: block;
                        padding: 15px;
                        white-space: nowrap
                    }

                    a.pHiOh {
                        color: #70757a
                    }
                </style>
            </div>
        </div>
        </body>

        </html>
        eot;

        header("Content-Type: text/html; charset='UTF-8'");
        return $html;
    }

    static function genResultPage(string $msg, string $meta): string
    {
        $html = <<<___
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            {$meta}
            <title>Result</title>
        </head>
        <body>
        {$msg}
        </body>
        </html>
        ___;

        header("Content-Type: text/html; charset='UTF-8'");
        return $html;
    }

    static function showPayPageError(string $msg)
    {
        $html = <<<___
        <!DOCTYPE html>
        <html lang=\"en\">
        <head>
            <meta charset=\"UTF-8\">
            <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
            <title>Request Error</title>
        </head>
        <body>
        {$msg}
        </body>
        </html>
        ___;

        echo $html;
    }

    static function genRandStr($length): string
    {
        $str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $len = strlen($str) - 1;
        $randstr = '';
        for ($i = 0; $i < $length; $i++) {
            $num = mt_rand(0, $len);
            $randstr .= $str[$num];
        }
        return $randstr;
    }

    static function microtime_int()
    {
        list($usec, $sec) = explode(" ", microtime());
        return (int)(((float)$usec + (float)$sec) * 1000);
    }
}

?>