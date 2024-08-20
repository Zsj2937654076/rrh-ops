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
// 【必改】 订单状态查询接口（如果域名不一样，就不能使用ThirdConf::AccessUrl进行拼接）
$T_OrderStateUrl = ThirdConf::QueryBaseUrl . '/channel/queryOrder';
// 【必改】 请求方式
$T_orderMethod = 'POST';

// 【参考】 请求参数数据类型，0表示key=value格式（默认）；1表示JSON格式；
$T_orderParamFormat = 1;
// 【参考】 请求的扩展参数设置，如无则不填
$T_payOpt = array(
    // 请求超时时间，默认为20秒
    //'timeout' => 30,
    // 是否递归到最终的重定向url，默认值为1，填0则不递归，会将重定向的url返回出来
    //'followLocation' => 0
);

// 【必改】 签名的生成规则参数，如果使用默认值，则直接注释掉相关项即可
$T_useRSAPubkeyVerify = false;

$T_signOpt = array(
    // 加密key的名称，默认是'key'
    'secretKeyName' => 'key',
    // key-value对之间的分隔符，默认是'&'
    'sep' => '&',
    // key与value之间的分隔符，如果设置为null，则key不会被拼接，默认是'='
    'KVsep' => '=',
    // 是否对参数集进行ksort()，默认true
    'bSort' => true,
    // 是否跳过空值，这里指空字符串，默认为false
    'bOmitempty' => false,
    // 签名算法，小写，默认'md5'
    'signType' => 'sha512',
    // 大小写转换，默认'lower'
    'lettersCase' => 'lower',
    // 签名的加密方式，大写，支持：空、'RSA'、'HMAC'，默认为null
    'encryptType' => null,
    // 是否进行公钥验签
    'bRSAPubkeyVerifySign' => $T_useRSAPubkeyVerify,
    // 是否需要进行url编码，默认false
    //'urlencode' => true
);

function I2T_encryptPayReqArg($T_payParams): array
{
    // ThirdConf::RsaPublicKey;

    // 【推荐】 如果需要进行加密或格式转换，则在此处理，否则直接返回$T_payParams
    //rsa加密只需要传加密后的数据，参数名称是 crypted
    return $T_payParams;
}

function I2T_setOrderHeaders($T_orderId): array
{
    // 【参考】请求头(固定部分)，无则不填。数组的item类型是单一的字符串，而不是key => value形式
    $T_orderHeader = array(
        'Content-type: application/json'
    );
    // 【参考】请求头(动态部分)，无则不填
    //array_push($T_orderHeader, 'Authorization: Bearer ' . I2T_verify('', ''));

    return $T_orderHeader;
}


/**
 * I >>> THIRD, 生成查询订单参数集
 * @param C_orderId <string> CRM的订单号
 * @param T_orderId <string> 三方通道的订单号
 * @return <array> 发送给三方通道的参数集
 */
function I2T_makeOrderParams($C_orderId, $T_orderId, $T_cbParams = null): array
{
    global $T_signOpt;

    // 【必改】 1. 参与验签的参数集，需按三方支付接口要求的顺序填写
    $checkReqArgs = array(
        'bizId' => ThirdConf::MerchantUID,
        'bizOrderNo' => $C_orderId
    );
    // 【推荐】 2. 再补上不参与验签的参数，需要添加的参数都在此添加
    // $checkReqArgs['_sign'] = Fun::genSign2($checkReqArgs, ThirdConf::AccessKey, $T_signOpt);
    return I2T_encryptPayReqArg($checkReqArgs);
}

/**
 * I >>> THIRD, 确认订单是否支付完成
 * @param C_orderId <string> CRM的订单号
 * @param T_orderId <string> 三方通道的订单号
 * @return <bool> true表示支付完成
 */
function I2T_checkOrderState($C_orderId, $T_orderId, $T_cbParams = null): bool
{
    global $T_payOpt;
    // global ThirdConf::mchUID;
    global $T_OrderStateUrl;
    global $T_orderMethod;
    global $T_orderParamFormat;

    $args = I2T_makeOrderParams($C_orderId, $T_orderId, $T_cbParams);
    if (GConf::G_OUT_LOG) {
        echo 'I >>> THIRD, order state params = ';
        var_dump($args);
    }

    $T_orderHeader = I2T_setOrderHeaders($T_orderId);

    $checkResponse = Fun::sendRequest($T_OrderStateUrl, $T_orderMethod, $args, $T_orderParamFormat, $T_orderHeader, $T_payOpt);

    if (GConf::G_OUT_LOG) {
        echo 'I <<< THIRD, order state respon = ';
        var_dump($checkResponse);
    }
    // 【必改】 针对通道方订单查询接口的返回值，做相应的判断检查

    if ($checkResponse['res'] == 1 && $checkResponse['ec'] == 0 && $checkResponse['dt']['lst'][0]['status'] == 1) {
        return true;
    }
    return false;
}

//-----------------------------------------------------------------------------
// 支付转发主流程
//-----------------------------------------------------------------------------
?>
