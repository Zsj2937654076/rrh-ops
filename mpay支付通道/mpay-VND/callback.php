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
include_once('queryOrder.php');
include_once('thirdService.php');
@header("content-Type: application/json; charset=utf-8");


//-----------------------------------------------------------------------------
// TODO: THIRD方向
//-----------------------------------------------------------------------------
// 【必改】 三方通道回调回来的参数集，bool值表示该字段是否必填。用法：
// 1. 左侧的key：只要有可能参与验签的字段都要写，绝对不参与验签的字段则不写
// 2. 左侧的顺序：如果不是按字母排序，则要按接口定义的顺序排写
// 3. 右侧的值：true表示必填字段，false表示非必填（注：非必填的字段也可能需要参与验签）
// 4. 如果数组为空，则不做参数检查
$T_callbackReqArg_forSign = array(
    // "version" => true,
    // "charset" => true,
    // 'signMethod' => true,
    // 'signature' => true,
    // "transType" => true,
    // "respCode" => true,
    // "merAbbr" => true,
    // "merId" => true,
    //"acqCode" => false,
    // "orderNumber" => true,
    // "qid" => true,
    // "orderAmount" => true,
    // "orderCurrency" => true,
    // "respTime" => true,
    // "settleDate" => true,
    // "cupReserved" => false
);

// 【参考】指定验签使用的key是否为支付平台的RSA公钥，默认为false
$T_useRSAPubkeyVerify = true;
// 【必改】 三方通道回调接口签名字段的key名
$T_callbackSignName = 'signature';
// 【必改】 签名的生成规则参数，如果使用默认值，则直接注释掉相关项即可
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
    'signType' => 'md5',
    // 大小写转换，默认lower
    'lettersCase' => 'upper',
    // 签名的加密方式，大写，支持：空、'RSA'、'HMAC'，默认为null
    'encryptType' => null,
    // 是否需要进行url编码，默认false
    'urlencode' => true,
    // 是否进行公钥验签
    'bRSAPubkeyVerifySign' => $T_useRSAPubkeyVerify,
);
$T_fnSignDeform = function ($s) {
    return base64_encode($s);
};

/**
 * THIRD >>> I, 解密从三方通道回调接口过来的参数
 * @param T_CallbackParams <array> 三方通道回调接口过来的参数
 * @return <array>
 */
function T2I_decryptCallbackReqArg($T_CallbackParams): array
{
    $arr_args = $T_CallbackParams;
    // 去掉signMethod参数
    unset($arr_args['_signature']);
    unset($arr_args['bizId']);
    unset($arr_args['chain']);
    unset($arr_args['signMethod']);
    unset($arr_args['custNo']);
    unset($arr_args['exAmount']);
    unset($arr_args['exRate']);
    unset($arr_args['orderAmount']);
    unset($arr_args['sign']);
    unset($arr_args['sourceCurrency']);
    unset($arr_args['uuid']);
    unset($arr_args['txid']);
    unset($arr_args['chain']);
    unset($arr_args['payAddress']);
    unset($arr_args['toAddress']);

    return $arr_args;
}

/**
 * THIRD >>> I, 对三方通道回调的参数进行检查，如果不合法则返回错误
 * @param T_CallbackParams <array> 三方通道回调过来的参数集
 * @return <int> 参数不合法则返回负数
 */
function T2I_checkParams($T_CallbackParams): int
{
    // 【参考】如果有需要才进行检查，默认不检查


    return 1;
}

/**
 * THIRD >>> I, 从三方通道回调的参数里，获取CRM系统定义的订单号
 * @param T_CallbackParams <array> 三方通道回调过来的参数集
 * @return <string> 当前回调中，对应的CRM系统的订单号
 */
function T2I_getCRMOrderID($T_CallbackParams): string
{
    // 【必改】 通道方定义的 'CRM订单' 的ID名称: CMR订单id
    $crmOrderIDName = 'orderId';

    return isset($T_CallbackParams[$crmOrderIDName]) ? $T_CallbackParams[$crmOrderIDName] : '';
}

/**
 * THIRD >>> I, 从三方通道回调的参数里，获取三方通道的订单号
 * @param T_CallbackParams <array> 三方通道回调过来的参数集
 * @return <string> 当前回调中，对应的三方通道的订单号
 */
function T2I_getThirdOrderID($T_CallbackParams): string
{
    // 【必改】 通道方定义的 '通道方订单' 的ID名称
    $thirdOrderIDName = 'orderId';

    return isset($T_CallbackParams[$thirdOrderIDName]) ? $T_CallbackParams[$thirdOrderIDName] : '';
}

/**
 * THIRD <<< I, 构造返回给三方通道的数据
 * @param code <int> 0表示成功，其它表示失败
 * @param msg <string> code对应的信息提示
 * @return <array | string>
 */
function I2T_makeCallbackRespon($code, $msg, $clientType = ClientType::ClientType_Unknown)
{
    // 【参考】
    switch ($code) {
        case 0:
            $data = 'success';
            break;
        case -2:
            $data = 'order status fail';
            break;
        case -3:
            $data = 'sign error';
            break;
        default:
            $data = 'fail';
    }

    switch ($clientType) {
        // 如果请求来自浏览器，则生成一个网页回去，并自动跳转
        case ClientType::ClientType_Mobile:
        case ClientType::ClientType_Browser:
            $data = Fun::genResultPage($msg, '<meta http-equiv="refresh" content="5;url=' . CRMConf::ReturnUrl . '">');
            break;

        default:
    }

    return $data;
}


//-----------------------------------------------------------------------------
// CRM方向
//-----------------------------------------------------------------------------
$callbackURL = CRMConf::callbackUrl;
$callbackMethod = 'POST';
// 【参考】请求参数数据类型，0表示key=value格式（默认）；1表示JSON格式；
$callbackParamFormat = 0;
$callbackCrmParamFormat = 1;
$callbackHeader = array(
    'Content-type: application/json'
);

// 使用默认值
$C_signOpt = null;

/**
 * THIRD >>> CRM, 回调接口参数转换：从三方通道转化成CRM
 * @param T_CallbackParams <array> 从三方通道回调过来的参数集
 * @return <array> 发送给CRM的参数集
 */
function T2C_makeCallbackParams($T_CallbackParams): array
{
    global $C_signOpt;

    // 【必改】 参数转换
    $C_callbackParams = array(
        'sign_type' => 'MD5',
        'order_id' => $T_CallbackParams['orderId'],
        'pay_order' => $T_CallbackParams['orderId'],
        'status' => ($T_CallbackParams['status'] == '0') ? 0 : -1
    );

    // 生成签名
    $C_callbackParams['sign'] = Fun::genSign2($C_callbackParams, CRMConf::PayKey, $C_signOpt);

    return $C_callbackParams;
}

/**
 * I <<< CRM, 判断从CRM返回的结果是否成功
 * @param C_callbackRespon <array> 从CRM返回的结果
 * @return <bool> true表示成功
 */
function C2I_isCallbackSuccess($C_callbackRespon): bool
{
    return $C_callbackRespon['code'] == 0 && $C_callbackRespon['msg'] == "success";
}

//-----------------------------------------------------------------------------
// 支付回调接口主流程
//-----------------------------------------------------------------------------
// 1. 参数接收
// 1.1 参数提取
$T_callbackParams = Fun::getParams();
if (GConf::G_OUT_LOG) {
    echo 'THIRD >>> I, getParams = ';
    var_dump($T_callbackParams);
}
// 1.2 客户端类型
$T_clientType = Fun::getClientType();

// 1.3 参数解密，可选
$T_decryptParams = T2I_decryptCallbackReqArg($T_callbackParams);
if (GConf::G_OUT_LOG) {
    echo 'THIRD >>> I, decrypt params = ';
    var_dump($T_decryptParams);
}

// 1.4 验签

$vsRes = Fun::verifySign($T_decryptParams, $T_callbackReqArg_forSign, ThirdConf::CallbackUrlKey . $T_callbackParams['uuid'], $T_callbackSignName, $T_signOpt, $T_fnSignDeform);

if ($vsRes >= 0) {
    // 1.5 验参
    $checkRes = T2I_checkParams($T_callbackParams);

    // 2. 检查订单支付状态
    // 2.1 调queryOrder.php
    if ($checkRes && ThirdConf::NeedQueryOrder) {
        // 订单状态检查
        $checkRes = I2T_checkOrderState(T2I_getCRMOrderID($T_callbackParams), T2I_getThirdOrderID($T_callbackParams), $T_callbackParams);
    }

    if ($checkRes) {
        // 3. 转达给CRM
        $C_callbackParams = T2C_makeCallbackParams($T_callbackParams);
        if (GConf::G_OUT_LOG) {
            echo 'I >>> CRM, callback params = ';
            var_dump($C_callbackParams);
        }

        $res = false;
        for ($i = 0; $i < 2 && !$res; $i++) {
            if ($i > 0) sleep(3);
            $sendRep = Fun::sendRequest($callbackURL, $callbackMethod, $C_callbackParams, $callbackCrmParamFormat, $callbackHeader);
            if (GConf::G_OUT_LOG) {
                echo "I <<< CRM, callback respon-{$i} = ";
                var_dump($sendRep);
            }
            $res = C2I_isCallbackSuccess($sendRep);
        }
        if ($res) {
            $T_callbackRespon = I2T_makeCallbackRespon(0, '成功', $T_clientType);
        } else {
            $T_callbackRespon = I2T_makeCallbackRespon(-1, '参数错误', $T_clientType);
        }
    } else {
        $T_callbackRespon = I2T_makeCallbackRespon(-2, '订单检查失败', $T_clientType);
    }
} else {
    $T_callbackRespon = I2T_makeCallbackRespon(-3, '验签失败', $T_clientType);
}

// 4. 返回数据给三方通道
Fun::writeRespon($T_callbackRespon);
if (GConf::G_OUT_LOG) {
    echo 'THIRD <<< I, respon = ';
    var_dump($T_callbackRespon);
}
?>
