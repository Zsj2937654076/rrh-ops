<?php
include_once('config.php');
include_once('functions.php');
@header("content-Type: text/html; charset=utf-8");


// 取参数
$C_paypageParams = Fun::getParams();
if (!isset($C_paypageParams[CRMConf::PayPageIDName])) {
    Fun::showPayPageError('id is null');
    exit(0);
}

// 查redis
$redis = phpiredis_connect(GConf::G_Redis_Host, GConf::G_Redis_Port);
$response = phpiredis_multi_command_bs($redis, array(
    array('AUTH', GConf::G_Redis_Auth),
    array('SELECT', GConf::G_Redis_Index)
));
if (count($response) < 2 || $response[0] != 'OK' || $response[1] != 'OK') {
    Fun::showPayPageError($response);
    exit(0);
}


$response = phpiredis_command($redis, 'GET ' . CRMConf::PPID_PRE . $C_paypageParams[CRMConf::PayPageIDName]);
if (empty($response)) {
    // 无则返回请求过期的默认页
    Fun::showPayPageError('Request Expired');
} else {
    // 有则返回支付页
    echo $response;
}
?>