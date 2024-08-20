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
include_once('verify.php');
include_once('thirdService.php');
@header("content-Type: application/json; charset=utf-8");


//-----------------------------------------------------------------------------
// 【禁止】 临时全局变量区，不需要设置
//-----------------------------------------------------------------------------
$I_crmOrderID = '';
$I_thirdOrderID = '';


//-----------------------------------------------------------------------------
// CRM请求参数项
//-----------------------------------------------------------------------------
// CRM发起支付请求的参数集，bool值表示该字段是否必填
// 用法：
// 1. 左侧的key：只要有可能参与验签的字段都要写，绝对不参与验签的字段则不写
// 2. 左侧的顺序：如果不是按字母排序，则要按接口定义的顺序排写
// 3. 右侧的值：true表示必填字段，false表示非必填（注：非必填的字段也可能需要参与验签）
$C_payReqArg_forSign = array(
    'callback_url' => true, // 回调给CRM的地址
    'sign_type' => true, // 签名类型，默认 md5
    'order_id' => true, // 订单号，
    'amount' => true, // 订单金额，float
    'currency' => true, // 货币类型
    'user_name' => false, // 用户名
    'last_name' => false, // 用户姓氏
    'certiricate_type' => false, // 证件类型
    'certiricate_no' => false, // 证件号码
    'account' => true, // 入金账号或用户钱包，示 例：BCRCo-Demo/77779、F902K4/USD
    'email' => false,
    'phone' => false,
    'area_code' => false,
    'sign' => true
);

// CRM签名字段的key名
$C_signName = 'sign';

$C_signOpt = array(
    // 加密key的名称，如key
    'secretKeyName' => 'key',
    // key-value对之间的分隔符，如'&'
    'sep' => '&',
    // key与value之间的分隔符，如果设置为null，则key不会被拼接，如'='
    'KVsep' => '=',
    // 是否对参数集进行ksort()
    'bSort' => true,
    // 是否跳过空值，这里指空字符串，默认为false
    'bOmitempty' => true,
    // signType 签名算法，小写，默认'md5'
    'signType' => 'md5'
);


/**
 * CRM >>> I, 从CRM过来的请求参数进行格式转化
 * @param C_payReqParams <array> 从CRM过来的请求参数集
 * @return <array> 返回转化后的参数集
 */
function C2I_convertPayReqParam($C_payReqParams): array
{
    //$C_payReqParams['amount'] = sprintf('%.2f', $C_payReqParams['amount']);
    return $C_payReqParams;
}


//-----------------------------------------------------------------------------
// TODO: 支付通道与CRM的参数映射（在此代码段中设定参数与请求配置）
//-----------------------------------------------------------------------------
// 【必改】支付接口
$T_payUrl = ThirdConf::AccessBaseUrl;
// 【必改】请求方式，支持以下：
// 1. 标准的HTTP请求METHOD，包含：'GET'、'POST'等，这类都是要请求到外部服务器，由对方返回相应数据
// 2. 扩展的伪造METHOD，这类方式不会真实请求到外部服务器，而数据都由底层方法生成
//   2.1 'FORGE'方式，用于只拼接出请求URL，并将其做为payUrl返回给CRM
//   2.2 'FORPAGE'方式，会生成一个支付跳转页（），并把该跳转页的URL返回给CRM
$T_payMethod = 'POST';
// 【参考】请求参数数据类型，0表示key=value格式（默认）；1表示JSON格式；
$T_payParamFormat = 1;
// 【参考】请求的扩展参数设置，如无则不填
$T_payOpt = array(
    // 请求超时时间，默认为20秒
    //'timeout' => 30,
    // 是否递归到最终的重定向url，默认值为1，填0则不递归，会将重定向的url返回出来
    //'followLocation' => 0,
);
// 【必改】返回的数据类型，取值有：json、html，默认是'json'
$T_payResponType = 'json';

// 【必改】签名的生成规则参数，如果使用默认值，则直接注释掉相关项即可
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
    'lettersCase' => 'lower',
    // 签名的加密方式，大写，支持：空、'RSA'、'HMAC'，默认为null
    'encryptType' => 'RSA',
    // 是否需要进行url编码，默认false
    'urlencode' => false,
);


/**
 * I >>> THIRD, 加密请求到三方的参数
 * @param T_payParams <array> 三方通道的支付接口请求参数集（明文）
 * @return <array> 返回加密后的参数集
 */
function I2T_encryptPayReqArg($T_payParams): array
{
    // ThirdConf::RsaPublicKey;

    // 【推荐】 如果需要进行加密或格式转换，则在此处理，否则直接返回$T_payParams

    return $T_payParams;
}


/**
 * CRM >>> THIRD, 支付接口Header设置：添加一些动态header值
 * @param C_reqParams <array> 从CRM请求过来的参数集
 * @return <array> HTTP请求头数组
 */
function C2T_setPayHeaders($C_reqParams): array
{
    // 【参考】请求头(固定部分)，无则不填。数组的item类型是单一的字符串，而不是key => value形式
    $T_payHeader = array(
         'content-type:application/json'
//        '日期/orderTime' => $C_reqParams['time'],
//        '订单号/orderNumber' => $C_reqParams['order_id'],
//        '通道/channelType' => 'Internet',
//        '金额/orderAmount' => $C_reqParams['amount'],
//        '货币/orderCurrency' => $C_reqParams['currency']
    );

    // 【参考】请求头(动态部分)，无则不填
    //array_push($T_payHeader, 'Authorization: Bearer ' . I2T_verify('', ''));

    return $T_payHeader;
}


/**
 * CRM >>> THIRD, 支付接口参数转换：从CRM转化成三方通道
 * @param C_reqParams <array> 从CRM请求过来的参数集
 * @return <array> 发送给三方通道的参数集
 */
function C2T_makePayParams(&$C_reqParams): array
{
    global $T_signOpt;
    global $I_crmOrderID;

    $I_crmOrderID = $C_reqParams['order_id'];

    // 【必改】 1. 参与验签的参数集，需按三方支付接口要求的顺序填写
    // 商家ID，由xyz分配
    $params['bizId'] = ThirdConf::MerchantUID;
    // 客户的唯一标识(一个客户一个ID，切勿一个客户对应多个ID，ID必须唯一)（重要，重要，重要，一定要唯一）
    $params['custNo'] = $C_reqParams['account'];
    // 订单金额	2位小数，单位：元
    $params['amount'] = sprintf('%.2f', $C_reqParams['amount']);
    // 商家订单号	商家系统订单号，该订单号将作为xyz接口的返回数据。该值需在商家系统内唯一，xyz系统暂时不检查该值，是否唯一
    $params['orderNo'] = $C_reqParams['order_id'];
    // 通知地址	异步通知（业务订单状态修改）可保证到达率
    $params['noticeUrl'] = ThirdConf::CallbackUrl;
    // 回调地址	同步通知过程的返回地址(在支付完成后，xyz将会跳转到的商家回调地址)。注：若提交值无该参数，或者该参数值为空，则在支付完成后，xyz不会跳转到商家页面。
    $params['backUrl'] = '';
    // 用户在下单时的真实 IP(若ip不真实可能会导致支付失败的情况发生)
    $params['clientIp'] = $_SERVER['SERVER_ADDR'];
    // 币种：CNY，USDT，USDC。。
    $params['currency'] = $C_reqParams['currency'];
    // 订单时间	以时间戳方式，如：1540885799641
    $params['orderTime'] = time();
    // 0:APP app端; 1:MWEB mobile 页面; 2:PCWeb pc页面 3:Wechat 微信
    $params['devType'] = 3;
    $params['ext'] = '{"bank":{"user_name":"' . $C_reqParams['user_name'] . '","bank_card":"","bank_type":"","bank_tel":""}}';

    //  $T_payParams['signature'] = Fun::genSign2($T_payParams, $T_signOpt['sep'] . md5(ThirdConf::AccessKey), $T_signOpt, $fnSignDeform);
    $T_payParams['encryption'] = Fun::encryptRsa($params, ThirdConf::RsaPublicKey, $T_signOpt);
    // 商家ID，由xyz分配
    $T_payParams['bizId'] = ThirdConf::MerchantUID;

    return I2T_encryptPayReqArg($T_payParams);

}

// 根据三方支付请求返回的数据，转化为CRM支付接口的返回数据
/**
 * THIRD >>> CRM, 支付接口返回值转换：从三方通道转化给CRM
 * @param T_payRespon <array> 三方通道的返回值
 * @return <array> 返回给CRM
 */
function T2C_makePayRespon($T_payRespon): array
{
    global $T_payOpt;
    global $T_payResponType;

    // global $CRM_PPID_PRE;

    global $I_crmOrderID;

    $deal = false;

    // 返回给CRM时需要的几个变量
    $code = -1;
    $pu = NULL;
    $osn = NULL;
    // 这里有三种情况需要区分处理，只需根据前文的配置相应的选择其中一种情况进行处理
    switch ($T_payRespon['code']) {
        case 302:
            if (array_key_exists('followLocation', $T_payOpt) && $T_payOpt['followLocation'] == 0) {
                // 【推荐】 情况一：处理重定向的逻辑
                $deal = true;
                if (isset($T_payRespon['data'])) {
                    $pu = $T_payRespon['data'];
                    $code = 0;
                    //$res = preg_match('/' . ThirdConf::token . '\/([^\/]+)/', $pu, $matches);
                    //$osn = $res === false ? '' : $matches[1];
                }
            }
            break;

        case -1:
            if ($T_payResponType == 'html' && !empty($I_crmOrderID)) {
                // 【推荐】 情况二：处理返回html页面的逻辑
                $deal = true;
                if (isset($T_payRespon['data'])) {
                    // 提取通道方订单id
                    // $res = preg_match('/<label\s+id=\"order_id\"\s+[^>]*>([^<]+)/', $T_payRespon['data'], $matches);
                    $osn = $I_crmOrderID;

                    if (!empty($osn)) {
                        $page = $T_payRespon['data'];
                        $page = preg_replace('/="(?!http)\/?([^"]*\.(?:js|css|jpg|png|gif))/', '="' . ThirdConf::AccessBaseUrl . ' / $1', $page);

                        // 将html页面存入redis
                        $redis = phpiredis_connect(GConf::G_Redis_Host, GConf::G_Redis_Port);
                        $c = phpiredis_multi_command_bs($redis, array(
                            array('AUTH', GConf::G_Redis_Auth),
                            array('SELECT', GConf::G_Redis_Index)
                        ));
                        if (count($c) >= 2 && $c[0] == 'OK' && $c[1] == 'OK') {
                            $c = phpiredis_command_bs($redis, array('SET', CRMConf::PPID_PRE . $osn, $page, 'EX', 1800));
                            if ($c == 'OK') {
                                $code = 0;
                                $pu = CRMConf::PayPage . ' ? ' . CRMConf::PayPageIDName . ' = ' . $osn;
                            }
                        }
                    }
                }
            }
            break;

        default:
    }

    if (!$deal) {
        // 【推荐】 情况三：处理返回json数据的逻辑
        if ($T_payRespon['ec'] == 0) {
            $code = 0;
            $pu = $T_payRespon['dt']['lst'];
//            $osn = $I_crmOrderID;
        } else {
            $code = -1;
        }
    }
    $C_payRes = array(
        'code' => $code,
        'msg' => $T_payRespon['msg'],
        'data' => array(
            'url' => $pu,
            'pay_order' => ''
        )
    );

    return $C_payRes;
}


//-----------------------------------------------------------------------------
// 支付转发主流程
//-----------------------------------------------------------------------------
// 1. 读取来自CRM的请求
// 1.1 读取参数
$C_payReqParams = Fun::getParams();
// 特别地：需要要将float的金额转化为string
$C_payReqParams = C2I_convertPayReqParam($C_payReqParams);
if (GConf::G_OUT_LOG) {
    echo 'CRM >>> I, getParams = ';
//    var_dump($C_payReqParams);
}

// 1.2 验签
$res = Fun::verifySign($C_payReqParams, $C_payReqArg_forSign, CRMConf::PayKey, $C_signName, $C_signOpt);
if (GConf::G_OUT_LOG) {
    echo 'I >>> THIRD, res = ';
    var_dump($res);
}
if ($res >= 0) {
    // 2.1 请求参数
    $T_payParams = C2T_makePayParams($C_payReqParams);
    if (GConf::G_OUT_LOG) {
        echo 'I >>> THIRD, T_payParams = ';
        var_dump($T_payParams);
    }
    // 2.2 添加请求头
    $T_payHeader = C2T_setPayHeaders($C_payReqParams);

    // 3. 发送请求
    $T_payResponse = Fun::sendRequest($T_payUrl, $T_payMethod, $T_payParams, $T_payParamFormat, $T_payHeader, $T_payOpt);
    if (GConf::G_OUT_LOG) {
        echo 'I <<< THIRD, $T_payResponse = ';
        var_dump($T_payResponse);
    }

    $C_payRes = T2C_makePayRespon($T_payResponse);
} else {
    $C_payRes = array(
        'code' => -1,
        'msg' => ($res == -1) ? '参数缺失' : '验签失败',
        'data' => NULL
    );
}

// 4. 返回数据给CRM
Fun::writeRespon($C_payRes);
if (GConf::G_OUT_LOG) {
    echo 'CRM <<< I, C_payRes = ';
    var_dump($C_payRes);
}
?>
