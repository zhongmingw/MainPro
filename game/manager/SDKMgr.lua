--
-- Author: yr
-- Date: 2017-05-16 17:36:44
--

local SDKMgr = class("SDKMgr")

local SUBMIT_TYPE_LOGIN = 3001 -- 登录
local SUBMIT_TYPE_CREATE = 3002 -- 创建角色
local SUBMIT_TYPE_LEVELUP = 3003 -- 升级
local SUBMIT_TYPE_SEVER = 3004  --选择服务器
local SUBMIT_TYPE_EXIT = 3005  --退出游戏

local SDK_LOGIN_RESULT = 4
local SDK_XFYUN_SPEECH = 10 --语音回调
local SDK_SWITCHLOGIN_SUC = 11 --切换账号成功回到登录界面
local SDK_EXIT = 12  --sdk退出
local SDK_LOGIN_TOKEN = 13   --cp登录中
local SDK_CPLOGIN_FAIL = 14
local SDK_PHOTO_SUC = 15  --头像处理完成

local SDK_YX_PHONE = 1001
local SDK_YX_ID = 1002
local SDK_YX_VIP = 1003
local SDK_YX_USERINFO = 1004


function SDKMgr:ctor()
    self.speechInfo = nil
    --注册回调
    XSDKMgr.RegisLuaFunc(function(jsonStr)
        --TODO java回调处理
        print("JavaCallBack"..jsonStr)
        local java = json.decode(jsonStr)
        local code = tonumber(java["code"])
        local data = java["data"]
        if code == SDK_LOGIN_RESULT then  --cp登录信息返回
            g_var.accountName = data.nick_name
            g_var.accountId   = data.account
            g_var.flag        = data.flag
            g_var.time        = data.time
            g_var.channelId   = data.channel
            g_var.areaId      = data.areaId
            g_var.tpId        = data.tpId
            g_var.deviceId    = data.device or "default"
            g_var.firstLogin  = data.first
            g_var.yx_game_param  = data.gameParam  -- 悠讯特权的game参数
            g_var.chargeBack  = tonumber(data.money) or 0
            --请求服务器列表
            local view = mgr.ViewMgr:get(ViewName.LoginView)
            if view then
                view:onSdkLoginSuc()
            end
            
            --self:enterGame()
        elseif code == SDK_XFYUN_SPEECH then  --语音回调
            --[[if data["errorCode"] == 0 then  -- 0表示成功
                local audioData = data.audioData  --语音数据base64字符串
                local audioTxt = data.audioTxt    --语音翻译的文字
            end]]
            data["errorCode"] = tonumber(data["errorCode"])
            self.speechInfo = data
            UnitySound:RecordData(function(str)
                self.speechInfo.audioData = str
                if self.audioFunc then
                    self.audioFunc(self.speechInfo)
                end
            end)
        elseif code == SDK_SWITCHLOGIN_SUC then
            mgr.SceneMgr:backToLoginScene(false)
        elseif code == SDK_EXIT then
            submitData(SUBMIT_TYPE_EXIT)
            XSDKMgr.ExtFunc(code, "")
        elseif code == SDK_LOGIN_TOKEN then  --sdk登录成功
            self:cpLogin()
        elseif code == SDK_CPLOGIN_FAIL then  --cp登录失败
            GComAlter("网络不佳，登录失败，请重试")
        elseif code == SDK_PHOTO_SUC then
            local ret = data["ret"]
            local msg = data["msg"]
            if self.takePhotoComplete then
                self.takePhotoComplete(ret, msg)
                self.takePhotoComplete = nil
            end
        elseif code == SDK_YX_PHONE then  -- 悠讯绑定手机成功
            
        elseif code == SDK_YX_ID then  -- 悠讯版本身份证成功
        
        end
    end)
end

function SDKMgr:initSDK()
    XSDKMgr.InitSDK()
end

function SDKMgr:login()
    XSDKMgr.Login()
end

function SDKMgr:cpLogin()
    XSDKMgr.CpLogin()
end

function SDKMgr:loginOut()
    g_var.accountId = ""  --清理账号
    pcall(function()
        XSDKMgr.LoginOut()
    end)
end

function SDKMgr:switchAccount()
    XSDKMgr.SwitchAccount()
end

function SDKMgr:submitData(t)
    local jsonObj
    --[[local ctime = UPlayerPrefs.GetInt("createRoleTime")
    if ctime == 0 then
        ctime = mgr.NetMgr:getServerTime()
        UPlayerPrefs.SetInt("createRoleTime", ctime)
    end]]
    local areaId = tonumber(string.sub(g_var.serverId.."", -3, -1))
    local ctime = g_var.createTime * 1000
    if t == SUBMIT_TYPE_SEVER then
        jsonObj = {
            roleId = "",
            roleName = "",
            roleLevel = 0,
            serverId = g_var.serverId,
            serverIp = g_var.socketAddress,
            serverPort = g_var.socketPort,
            serverName = g_var.serverName,
            money = 0,
            roleVip = 0,
            roleGuild = "0",
            createTime = ctime,
            upLevelTime = mgr.NetMgr:getServerTime(),
            areaId = areaId,
        }
    else
        jsonObj = {
            roleId = cache.PlayerCache:getRoleId(),
            roleName = cache.PlayerCache:getRoleName(),
            roleLevel = cache.PlayerCache:getRoleLevel(),
            serverId = g_var.serverId,
            serverIp = g_var.socketAddress,
            serverPort = g_var.socketPort,
            serverName = g_var.serverName,
            money = cache.PlayerCache:getTypeMoney(1),
            roleVip = cache.PlayerCache:getVipLv(),
            roleGuild = cache.PlayerCache:getGangId(),
            createTime = ctime,
            upLevelTime = mgr.NetMgr:getServerTime(),
            areaId = areaId,
        }
    end

    XSDKMgr.SubmitData(t, json.encode(jsonObj))
    if g_var.platform == Platform.ios and tonumber(g_var.packId) >= 3001 then
        XSDKMgr.ExtFunc(t, json.encode(jsonObj))
    end
end

-- local SDK_YX_PHONE = 1001
-- local SDK_YX_ID = 1002
-- local SDK_YX_VIP = 1003
-- local SDK_YX_USERINFO = 1004
function SDKMgr:yxsdk(t)
    XSDKMgr.ExtFunc(t, "")
end

function SDKMgr:pay(data)
    local wId = conf.ShopConf:getShangPinID(data.price) or "defult_10"
    local price = data.price or 0
    local jsonObj = {
        money = price,
        roleId = cache.PlayerCache:getRoleId(),
        roleName = cache.PlayerCache:getRoleName(),
        roleLevel = cache.PlayerCache:getRoleLevel(),
        serverId = g_var.serverId,
        serverIp = g_var.socketAddress,
        serverPort = g_var.socketPort,
        serverName = g_var.serverName,
        productName = (price*10).."元宝",
        productDesc = (price*10).."元宝",
        roleLeftMoney = 0,
        roleVip = cache.PlayerCache:getVipLv(),
        roleGuild = cache.PlayerCache:getGangId(),
        waresid = wId,
        areaId = "0",

    }
    print(json.encode(jsonObj))
    XSDKMgr.Pay(json.encode(jsonObj))
end

function SDKMgr:enterGame()
    local arr = string.split(g_var.pack_version, ".")
    local packId = tonumber(arr[2]..arr[3])
    local loginCall = function()
        local reqData = {
            accountId       = g_var.account_bt~=0 and g_var.account_bt or g_var.accountId,
            accountName     = g_var.accountName,
            serverId        = g_var.server_bt~=0 and g_var.server_bt or g_var.serverId,
            channelId       = g_var.channel_bt~=0 and g_var.channel_bt or g_var.channelId,
            pkgSign         = packId,
            channelSign     = tonumber(arr[2]) or 0,
            md5Time         = g_var.time,
            md5Flag         = g_var.flag,
            deviceId        = g_var.deviceId,
            deviceInfo      = self:getDeviceName(),
        }
        proxy.LoginProxy:reqLogin(reqData)
        --printt(reqData)
    end
    if mgr.NetMgr:isConnect() then
        mgr.NetMgr:onNetClose(function()
            mgr.NetMgr:connect(g_var.socketAddress,g_var.socketPort,loginCall)
        end)
    else
        mgr.NetMgr:connect(g_var.socketAddress,g_var.socketPort,loginCall)
    end
    
end

function SDKMgr:getDeviceName()
    if g_var.gameFrameworkVersion >= 14 then
        local name = ""
        local ok,errorInfo = pcall(function()
            name = UnityEngine.SystemInfo.deviceModel
        end)
        if ok then
            return name
        end
    end
    return ""
end

--t=1开始录音，2录音完成，3取消
function SDKMgr:recordAudio(t, func)
    XSDKMgr.AudioRecord(t, "")
    self.audioFunc = func
end

function SDKMgr:playAudio(str)
    UnitySound:PlayerSoundByByte(str)
end

function SDKMgr:sdkConfig()
    return XSDKMgr.SdkConfig()
end

--获取电池电量
function SDKMgr:getBatteryLevel()
    return XSDKMgr.GetBatteryLevel()
end

--上传头像 choose=0拍照， choose=1相册  onComplete(ret, msg)  ret==0成功，msg是具体的信息
function SDKMgr:takePhoto(choose, name, onComplete)
    self.takePhotoComplete = onComplete
    XSDKMgr.TakePhoto(choose, name)
end

-- 获取玩家头像 onComplete(ret)
function SDKMgr:downloadImage(name, onComplete)
    local serverId = string.sub(name,1,8)
    local url = g_var.photo_url..serverId.."/"..name
    UnityResMgr:LoadImageString(url, "jpg", function(data)
        if onComplete then
            onComplete(data)   -- data=="suc" 成功，  data=="fail" 失败 
        end
    end)
end

return SDKMgr