<?php
//-----------------------------------------------------------------------------
// 配置参数的命名上会按以下三个区分：
// 1. 全局基础配置：以 `G_` 开头
// 2. CRM方向的配置：以 `CRM_` 开头
// 3. 通道方的配置：发 `Third_` 开头
// 
// 需要配置或修改的代码或变量会以 `[修改强烈程度]` 标识，分以下四种程度：
// 1. 【必改】：这是最高级别，必须修改
// 2. 【推荐】：除非不必要，否则要求修改
// 3. 【参考】：如有必要，才修改
// 4. 【禁止】：不允许被修改，默认不标记
//-----------------------------------------------------------------------------
class GConf
{
    // 【参考】 调试日志的开关
    const G_OUT_LOG = true;

    // 【推荐】 Redis的配置项
    const G_Redis_Host = '127.0.0.1';
    const G_Redis_Port = 6379;
    const G_Redis_Auth = 'dsocredis';
    const G_Redis_Index = 0;
}

//-----------------------------------------------------------------------------
// TODO: CRM方向的参数配置，主要由CRM系统内的配置项决定
//-----------------------------------------------------------------------------
class CRMConf
{
    // 【必改】 通道名，与'third/'路径下的通道文件夹名相同  
    const PAY_CHANNEL = 'mpay-IDR';
    // 【参考】 用于redis中key的前缀，隔离不同服务，避免冲突
    const PPID_PRE = 'pay_' . self::PAY_CHANNEL . '_';


    // 【必改】 由CRM后台管理员分配一个三方支付自接接口的支付key   //////////////
    const PayKey = '44CDE0951389489BAD145B51E11B88DE';

    // 【必改】 CRM的baseURL，如：https://user.mybroker.com   //////////////
    const BaseUrl = 'https://crmuser.haame.com';

    // CRM向中转服务下发支付请求，从[CRM] => [中转服务]
    // 格式：http(s)://<中转服务域名>/thirdpay/<三方支付通道英文简称>/pay.php
    // 注：本文件中该项不需要配置，但需要配置在CRM的管理后台

    // 【参考】 三方支付完成后跳转的页面，从[支付通道方] => [CRM]
    // 格式：http(s)://<CRM域名>/payment-orders
    const ReturnUrl = self::BaseUrl . '/payment-orders';

    // 回调到CRM的url，从[中转服务] => [CRM]
    // 格式：http(s)://<CRM域名>/user/order/callback/out
    const callbackUrl = self::BaseUrl . '/user/order/callback/out';

    // 这是当通道方的支付接口返回的是 html 数据时，中转服务会将该html数据存入redis，
    // 再拼接出本地的支付页面的URL
    const PayPage = self::BaseUrl . '/thirdpay/' . self::PAY_CHANNEL . '/paypage.php';

    // 【参考】 本地的支付页面的URL后的ID的名称，默认为 `id`
    const PayPageIDName = 'id';
}


//-----------------------------------------------------------------------------
// TODO: 三方通道方向的参数配置，主要来自于三方通道方的商户后台，及其提供的文档
//-----------------------------------------------------------------------------
class ThirdConf
{
    // 【必改】 商户UID，在三方支付通道方的商户后台查看 APPID
    const MerchantUID = '1614826594074030082';  //////////////

    // 【必改】 接入密钥，AccessKey  //////////////
    const AccessKey = 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxZroZBaicKVOIOe/KiSxCIOmrCXsZJ6PhRldWqOYZplJvkchjpeYYri0+wCtgGSNtpZr7zX8rASYUqelCkeM7lbSX3YBy0nK1Qn636TlROdni3ln2Gcxq8SysuI1i5Etlow9RI2Y5+7ii/KMGsNi+BSD6FHV8AODFAt7HVAWe9QIDAQAB';

    // 【参考】 商户Token，有些场景才需要，如无必要，可不配置
    const Token = '';

    // 【参考】 商户地址
    const MerchantAddr = '';

    // 【参考】 回调密钥，CallbackKey，如果回调密钥与接入密钥是同一个，则此处值设为与AccessKey一样即可  /////////////////////
    const CallbackUrlKey = 'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxZroZBaicKVOIOe/KiSxCIOmrCXsZJ6PhRldWqOYZplJvkchjpeYYri0+wCtgGSNtpZr7zX8rASYUqelCkeM7lbSX3YBy0nK1Qn636TlROdni3ln2Gcxq8SysuI1i5Etlow9RI2Y5+7ii/KMGsNi+BSD6FHV8AODFAt7HVAWe9QIDAQAB';

    // 【必改】 接入url - AccessUrl，三方通道的支付url，从[中转服务] => [支付通道方]
    // 格式：由支付通道方提供，如：http://api.third-pay-platform.com/pay
    const AccessBaseUrl = 'https://pay.xagfgsm.com/order/post';  

    // 【参考】 考虑到有些三方通道的支付域名与查询域名不一样，所以定义两个baseUrl（如果相同则设置成同一个url）
    const QueryBaseUrl = 'https://pay.xagfgsm.com';

    // 【参考】 是否进行订单状态的检查，默认应设为true
    const NeedQueryOrder = true;

    // 【推荐】支付类型，不同的支付通道，支付类型所代表的意义不同，注意支付类型并不是银行代号
    const PayType = '';

    // 支付结果回调接口，从[支付通道方] => [中转服务]
    // 格式：http(s)://<中转服务域名>/thirdpay/<三方支付通道英文简称>/callback.php
    const CallbackUrl = CRMConf::BaseUrl . '/thirdpay/' . CRMConf::PAY_CHANNEL . '/callback.php';


    // 【参考】 客户端RSA私钥  ////////////// 
    const RsaPrivateKey = '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxZroZBaicKVOIOe/KiSxCIOmrCXsZJ6PhRldWqOYZplJvkchjpeYYri0+wCtgGSNtpZr7zX8rASYUqelCkeM7lbSX3YBy0nK1Qn636TlROdni3ln2Gcxq8SysuI1i5Etlow9RI2Y5+7ii/KMGsNi+BSD6FHV8AODFAt7HVAWe9QIDAQAB
-----END PUBLIC KEY-----';

    // 【参考】 支付平台的公钥  /////////////////////
    const RsaPublicKey = '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxZroZBaicKVOIOe/KiSxCIOmrCXsZJ6PhRldWqOYZplJvkchjpeYYri0+wCtgGSNtpZr7zX8rASYUqelCkeM7lbSX3YBy0nK1Qn636TlROdni3ln2Gcxq8SysuI1i5Etlow9RI2Y5+7ii/KMGsNi+BSD6FHV8AODFAt7HVAWe9QIDAQAB
-----END PUBLIC KEY-----';
}

?>