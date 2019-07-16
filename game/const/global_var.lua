--[[--
 游戏全局变量,
 在这里的只所以都是正式版本的值
]]

--游戏相关参数
g_var = {
    socketAddress       = "192.168.51.76",
    socketPort          = 7051,
    accountId           = "",
    accountName         = "",
    serverId            = 1,
    serverName          = "",
    areaId              = 0,  --
    tpId                = 0,  --渠道的id
    channelId           = 101,--登陆渠道
    flag                = "xxoomd5",
    time                = 123456789,
    deviceId            = "local_device_id",
    platform            = "win32", --平台标记，由android或者ios内部传出
    auth                = 0,  --权限
    --serverTime        = 0, --这个时间在NetMgr获取
    debugInput          = 0,--1为可以输入账号，0为不能输入账号
    firstLogin          = 0,
    msgCount            = 100,
    network             = 0,  -- 0-无网络， 1-3G， 2-wifi
    createTime          = 0, --创建时间
    chargeBack          = 0,
    shopId              = "",


--TODO:
    gameFrameworkVersion = 1,
    gameState = 0,
    packId = 0,--6900 7900
    ptName = "",
    ptId = 97,
    --整包版本
    pack_version = "1.1001.1",
    --打包时间
    build_time = 17052400,
    --最新版本
    version = 102,
    --资源版本
    res_version = 103,
    --msg版本
    msg_version = 1,
    --初始化服务器地址
    server_url          = "http://cn-testlogin.gjxy.gztfgame.com/getCurrentVersion/getVersionInfo",
    --服务器列表地址
    server_list_url     = "http://gjxy-login.gztfgame.com/api/server?c=101",
    --cdn更新地址
    cdn_url             = "http://192.168.8.207/gjxy_cn_pkg_update/test_pkg",
    --记录账号地址
    record_account_url  = "http://gjxy-login.gztfgame.com/RecordAccSer/index", --创号成功发送
    --公告地址
    gonggao_url         = "http://gjxy-login.gztfgame.com/upNotice/getNotice/?id=1",
    --客服信息地址
    kefu_info_url       = "http://gjxy-login.gztfgame.com/setFormal/getCustomInfo",
    --小头像域名
    photo_url           = "http://gjxy-image.gztfgame.com/image/",
    --充值返利连接
    charge_back_url     = "http://ffw-gjxy-login.gztfgame.com/SendAward/",

    --作弊参数
    channel_sign_bt         = 0,    --作弊渠道标识
    pkg_sign_bt             = 0,    --作弊包标识
    channel_bt              = 0,    --作弊渠道号
    server_bt               = 0,    --作弊服务器id
    account_bt              = 0,    --作弊账号
    platform_id_bt          = 0,    --作弊渠道id
    server_list_url_bt      = "",   --作弊使用URL(当作弊渠道id不等于0时,才生效)
}

g_state = {
    winTest = 0,  -- win版
    iosTest = 1,  -- ios审核
    mxTest = 2,   -- mx内部测试
    formal = 3,   -- 正式版
    tsTest = 4,   --
    nsTest = 5,   --
    bsTest = 6,   -- 版署
    ttFormal = 7,
    xxTest = 8,   -- win连外网模式
}

--UI加载模式配置，false=ab加载
g_ui_debug = false
--是否开启分包资源
g_extend_res = true
--是否显示作弊命令
g_debug_view = false
--是否显示log打印
g_show_log = false
--版署标记
g_is_banshu = false --版署
--是否显示系统配置
g_system_info = true
--是否开启后台下载
g_back_download = true
--是否走新手指导
g_is_guide = true -- 
--是否检测消息 版本号
g_ischeck_msg = true

g_ios_test = false

g_need_preload = false

--新宠物开始id
g_newpet_id = 10000

--仙童
g_xiantong_id = 100000000
--============================游戏全局对象====================================--
g_mapview_loaded = false
--主角对象
gRole = nil
gScreenSize = {
    width = GRoot.inst.width,
    height = GRoot.inst.height
}
gRolePoz = -1500