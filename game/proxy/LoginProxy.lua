local LoginProxy = class("LoginProxy",base.BaseProxy)

function LoginProxy:init()

    self:add(5010101,self.resLogin)
    self:add(5010201,self.resCreateRole)
    self:add(5010104,self.rReconnect)

    self:add(501104,self.LoginRoleCallBack)

    self:add(5019902,self.resTestInt64)
    self:add(5019901,self.resTestCmd)
end


function LoginProxy:reqCreateRole(data)
    self:send(1010201,data)
end

---修改职业
function LoginProxy:sendChangeCarrer(carrer)
    self:send(101004,{career=carrer})
end

function LoginProxy:sReConnect()
    self:send(1010104, {loginSign=cache.PlayerCache:getLoginSign()})
end
function LoginProxy:rReconnect(data)
    if data.status == 0 then
        print("@断线重连成功")
        mgr.ViewMgr:closeView(ViewName.ReconnectView)
        local view = mgr.ViewMgr:get(ViewName.DoubleMajorView)
        if view then--双修状态变成单修
            view:setMajorBtnState(0)
            gRole:setMajorState(0)
        end
        local view = mgr.ViewMgr:get(ViewName.WeddingView)
        if view then
            view:closeView()
        end
        self:loginSuccess()
        mgr.SceneMgr:changeMap(data.sceneId, data.mapId, data.pox, data.poy)
    else
        --TODO 重连失败直接返回登录
        mgr.SceneMgr:backToLoginScene(false)
    end
end

function LoginProxy:resLoginRole()
    self:send(101104)
end

function LoginProxy:checkMsgVersion(data_)
    -- body
    if g_ischeck_msg then --是否检测消息版本号
        if data_.zz ~= 0 and data_.zz ~= g_msg_version then
            local param = {}
            param.type = 5
            param.richtext = language.gonggong59..data_.zz
            GComAlter(param)
            return true
        end
    end

    return false
end

function LoginProxy:LoginRoleCallBack( data_ )
    if data_.status == 0 then
        print("@登陆成功进入主场景")
        mgr.SceneMgr:loadScene(SceneName.MAINSCENE)
    else
        GComErrorMsg(data_.status)
        print("@创建角色")
    end
end

function LoginProxy:reqLogin(__reqdata)
    self:send(1010101,__reqdata)
end

function LoginProxy:reqTestCmd(cmdStr)
  self:send(1019901,{cmdStr=cmdStr})
end


--测试Int64
function LoginProxy:reqTestInt64(__reqdata)
  self:send(1019902,__reqdata)
end

function LoginProxy:resTestInt64(data__)
  printt(data__)
end

function LoginProxy:resTestCmd(data_)

  local dv = mgr.ViewMgr:get(ViewName.DebugTestView)
  if dv ~= nil then
    dv:setData(data_)
  end

end

function LoginProxy:resLogin(data_ )
    if self:checkMsgVersion(data_) then
        return
    end

    if data_.status == 0 then
        print("@登录成功")
        g_var.createTime = data_.createTime
        g_var.auth = data_.auth
        cache.PlayerCache:setLoginSign(data_.loginToken)
        self:loginSuccess()
        mgr.ViewMgr:closeView(ViewName.LoginView)
    else
        print("@进入创建角色")
        GComErrorMsg(data_.status)
    end
end

function LoginProxy:resCreateRole(data_)

    if data_.status == 0 then
        plog("创建角色成功~~~~",data_.status)
        g_need_preload = true
        g_var.createTime = data_.createTime
        printt(data_)
        cache.PlayerCache:setLoginSign(data_.loginSign)
        self:loginSuccess()
        mgr.ViewMgr:closeView(ViewName.CreateRoleView)

    else
        GComErrorMsg(data_.status)

        --EVE 用于控制是否可以发送创建角色的消息
        view = mgr.ViewMgr:get(ViewName.CreateRoleView)
        if view then
            view:setData(data_)
        end
        --EVE
    end
end

--登陆成功
function LoginProxy:loginSuccess()
    --清除缓存buff信息
    mgr.BuffMgr:init()
    cache.TeamCache:dispose()
    --断线重连强制判定
    if gRole then
        gRole:restoreBody()
    end


    if g_var.auth == 3 then --当时开发人员时
        GameUtil.LogInit(3)
        GameUtil.LogInit(2) --日志等级
    end

    --角色信息
    proxy.PlayerProxy:send(1010102)
    --角色头像信息
    proxy.PlayerProxy:send(1020202)
    --背包信息
    proxy.PackProxy:sendPackMsg()
    --锻造信息
    proxy.ForgingProxy:send(1100101, {part = 0,roleId = 0,svrId = 0})
    proxy.ForgingProxy:send(1100116,{reqType = 0, part = 0})
    proxy.TeamProxy:send(1300102)
    --请求10个成长系统对应的阶数
    proxy.PlayerProxy:send(1020502)
     --请求一次所有技能
    proxy.PlayerProxy:send(1020503)
    --角色首充信息缓存
    proxy.ActivityProxy:sendMsg(1030123,{reqType = 0})
    --请求每日首充档次信息
    proxy.ActivityProxy:sendMsg(1030121,{reqType = 0})
    --请求开服活动列表
    proxy.ActivityProxy:sendMsg(1030111,{actType = 1})
    --请求神兽系统信息并缓存
    proxy.ShenShouProxy:sendMsg(1590101)

    proxy.PlayerProxy:send(1020504)
    --请求双倍活动副本信息
    proxy.ActivityProxy:send(1030168)
    --请求一次剑灵装备强化信息
    local param = {}
    param.part = 0
    param.roleId =  cache.PlayerCache:getRoleId()
    param.svrId =  cache.PlayerCache:getServerId()
    proxy.AwakenProxy:send(1530101,param)

    proxy.FeiShengProxy:sendMsg(1580201,{reqType = 0})
    proxy.FeiShengProxy:sendMsg(1580103,{reqType = 1,type=0})
    -- 请求任务列表  最好是最后请求 主界面顶部按钮显示隐藏用的
    --向服务传递
    --圣印
    proxy.AwakenProxy:send(1600102)

    if g_var.yx_game_param then
        proxy.YouXunProxy:sendMsg(1020507,{game = g_var.yx_game_param})
    end
    --圣印
    proxy.AwakenProxy:send(1600102)

    proxy.TaskProxy:send(1050101)
    --八门
    proxy.AwakenProxy:send(1610103)
    --仙娃信息
    proxy.MarryProxy:sendMsg(1390601)
    --帝魂任务信息
    proxy.DiHunProxy:sendMsg(1620108,{reqType = 0,cid = 0})
    proxy.DiHunProxy:sendMsg(1620101)

    --请求面具信息
    proxy.MianJuProxy:sendMsg(1630101)

    -- 生肖信息
    proxy.ShengXiaoProxy:sendGetInfo()
end

return LoginProxy