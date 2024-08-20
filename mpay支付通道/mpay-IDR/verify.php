<?php
//-----------------------------------------------------------------------------
// 需要配置或修改的代码或变量会以 `[修改强烈程度]` 标识，分以下四种程度：
// 1. 【必改】：这是最高级别，必须修改
// 2. 【推荐】：除非不必要，否则要求修改
// 3. 【参考】：如有必要，才修改
// 4. 【禁止】：不允许被修改，默认不标记
//-----------------------------------------------------------------------------
include_once('config.php');
include_once('functions.php');
@header("content-Type: application/json; charset=utf-8");

//-----------------------------------------------------------------------------
// CRM请求参数项
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// TODO: 支付通道与CRM的参数映射（在此代码段中设定参数与请求配置）
//-----------------------------------------------------------------------------
// 【必改】 订单状态查询接口（如果域名不一样，就不能使用ThirdConf::accessUrl进行拼接）
$T_verifyUrl = ThirdConf::QueryBaseUrl . '/merchant/api/verify';
// 【必改】 请求方式
$T_verifyMethod = 'POST';
// 【参考】 请求头，无则不填
$T_verifyHeader = array(
    //'Content-type: application/json' //'Content-type: application/x-www-form-urlencoded'
);
// 【参考】 请求参数数据类型，0表示key=value格式（默认）；1表示JSON格式；
$T_verifyParamFormat = 0;
// 【参考】 请求的扩展参数设置，如无则不填
$T_verifyOpt = array(
    // 请求超时时间，默认为20秒
    //'timeout' => 30,
    // 是否递归到最终的重定向url，默认值为1，填0则不递归，会将重定向的url返回出来
    //'followLocation' => 0
);

// 【必改】 签名的生成规则参数，如果使用默认值，则直接注释掉相关项即可
$T_signOpt = array(
    // 加密key的名称，如key
    'secretKeyName' => '',
    // key-value对之间的分隔符，默认是'&'
    'sep' => '&',
    // key与value之间的分隔符，如果设置为null，则key不会被拼接，如'='
    'KVsep' => '=',
    // 是否对参数集进行ksort()，默认true
    'bSort' => true,
    // 是否跳过空值，这里指空字符串，默认为false
    'bOmitempty' => false,
    // 签名算法，小写，默认'md5'
    'signType' => 'sha512',
    // 是否需要进行url编码，默认false
    //'urlencode' => true
    // 是否需要转化成大写，默认false
    //'bUppercase' => true
);

function I2T_encryptVerifyReqArg($T_verifyParams) : array {
    // ThirdConf::RsaPublicKey;

    // 【推荐】 如果需要进行加密或格式转换，则在此处理，否则直接返回$T_verifyParams
	//rsa加密只需要传加密后的数据，参数名称是 crypted
	return $T_verifyParams;
}


/**
 * I >>> THIRD, 生成授权参数集
 * @param T_clientId <string> 未使用
 * @param T_clientSecret <string> 未使用
 * @return <array> 发送给三方通道的参数集
 */
function I2T_makeVerifyParams($T_clientId, $T_clientSecret) : array {
    global $T_signOpt;
    
    $now_time = time();
    // 【必改】 1. 参与验签的参数集，需按三方支付接口要求的顺序填写
	$verifyReqArgs = array(
        'client_id' => ThirdConf::MerchantUID,
        'client_secret' => ThirdConf::AccessKey
	);
    // 【推荐】 2. 再补上不参与验签的参数，需要添加的参数都在此添加
	//$verifyReqArgs['sign'] = genSign2($verifyReqArgs, ThirdConf::accessKey, $T_signOpt);

    return I2T_encryptVerifyReqArg($verifyReqArgs);
}

/**
 * I >>> THIRD, 获取授权
 * @param T_clientId <string> 未使用
 * @param T_clientSecret <string> 未使用
 * @return <string> 返回token
 */
function I2T_verify($T_clientId, $T_clientSecret) : string {
    global $T_verifyUrl;
    global $T_verifyMethod;
    global $T_verifyParamFormat;
    global $T_verifyHeader;
    global $T_verifyOpt;

    $args = I2T_makeVerifyParams($T_clientId, $T_clientSecret);
    if (GConf::G_OUT_LOG) {
        echo 'I >>> THIRD, verify params = ';
        var_dump($args);
    }

    $verifyRespon = Fun::sendRequest($T_verifyUrl, $T_verifyMethod, $args, $T_verifyParamFormat, $T_verifyHeader, $T_verifyOpt);
    if (GConf::G_OUT_LOG) {
        echo 'I <<< THIRD, verify respon = ';
        var_dump($verifyRespon);
    }
    // 【必改】 针对通道方订单查询接口的返回值，做相应的判断检查
    $data = isset($verifyRespon['data'])? $verifyRespon['data'] : NULL;
    if (!empty($data) && isset($data['access_token'])) {
        return $data['access_token'];
    }
    return NULL;
}


//-----------------------------------------------------------------------------
// 支付转发主流程
//-----------------------------------------------------------------------------
?>
