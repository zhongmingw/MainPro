--[[--
游戏网络连接管理
]]

local NetMgr = class("NetMgr")

--////////////////////////////C#同步
local ProtocalConnect    = 101   --连接服务器
local ProtocalSendData   = 102   --发送数据
local ProtocolClose      = 103
local ProtocolFailure    = 104
--////////////////////////////
local NOT_PRINT_MSGIDS = {
  [1010901] = true,
  [501902] = true,
}
--///////////////////////////
local CONST_HEART_TIMEOUT     = 10  --socket心跳超时时间-网络延迟
local CONST_HEART_CHECK_TIME  = 8  --socket心跳检查时间
local CONST_HEART_SEND_DELAY  = 90 --90秒内没有发送心跳断线处理

local MSG_ID_S_HEART      = 1010901 --心跳包消息号
local MSG_ID_R_HEART      = 5010901


function NetMgr:ctor()
    self._isConnect = false
    self._msgs      = {}
    self._buf = message.MsgPacket.new()
    self.connectFunc = nil
    self.disConnectType = 0  -- 1-服务端主动断开连接回到主界面， 2-客户端连接timeout

    --心跳包处理
    self._lastTime = 0
    self:add(MSG_ID_R_HEART,handler(self,self._rHeartMsg))
    self.heartBeatTime = 0

    self._serverTime = 0 --服务器时间戳
    self._saveTime = 0 --服务器记录时间戳

    --等待消息返回列表
    self.waitMsg = {}
    --不加入等待列表
    self.notwaitmsg = {
        [1810201] = true,
        [1810202] = true,
        [1810204] = true,
        [1020102] = true,
        [1020103] = true,
        [1020101] = true,
        [1020104] = true,
        [1020401] = true,
        [1810301] = true,
        [1020105] = true,
        [1270105] = true,
        [1810302] = true,
        [1020302] = true,
        [1060101] = true,
        [1020106] = true,
        [1040404] = true,
        [1350104] = true,
        [1380101] = true,
        [1380102] = true,
        [1380103] = true,
        [1380104] = true,
        [1380105] = true,
        [1200105] = true,
        [1330301] = true,
        [1330302] = true,
        [1370101] = true,
        [1370102] = true,
        [1810206] = true,
        [1380106] = true,
        [1810105] = true,
        [1280102] = true,
        [1390101] = true,
        [1390102] = true,
        [1027102] = true,
        [1027103] = true,
        [1410101] = true,
        [1410102] = true,
        [1410104] = true,
        [1410201] = true,
        [1410202] = true,
        [1410203] = true,
        [1810303] = true,
        [1810502] = true,
        [1810501] = true,
        [1390301] = true,
        [1430101] = true,
        [1330201] = true,
        [1330304] = true,
        [1330101] = true,
        [1330204] = true,
        [1027204] = true,
        [1460108] = true,
        [1460111] = true,
        [1460110] = true,
        [1020421] = true,
        [1020423] = true,
        [1020424] = true,
        [1480101] = true,
        [1480106] = true,
        [1330501] = true,
        [1480203] = true,
        [1480204] = true,
        [1480205] = true,
        [1090104] = true,
        [1330701] = true,
        [1510101] = true,
        [1510102] = true,
        [1510104] = true,
        [1810601] = true,
        [1550101] = true,
        [1550102] = true,
        [1550103] = true,
        [1550104] = true,
        [1540101] = true,
        [1540102] = true,
        [1540103] = true,
        [1540104] = true,
        [1540105] = true,
        [1540106] = true,
        [1540107] = true,
        [1540108] = true,
        [1540109] = true,
        [1540110] = true,
        [1540111] = true,
        [1030212] = true,--天数寻主
        [1360201] = true,
        [1360202] = true,
        [1360203] = true,
        [1360204] = true,
        [1360205] = true,
        [1360206] = true,
        [1360207] = true,
        [1331201] = true,
        [1540201] = true,
        [1540202] = true,
        [1540203] = true,
        [1540204] = true,
        [1540205] = true,
        [1540206] = true,
        [1540207] = true,
        [1540208] = true,
        [1540209] = true,
        [1540210] = true,
        [1540211] = true,
        [1331303] = true,


    }
end

--是否已经连接
function NetMgr:isConnect()
    return self._isConnect
end

--连接
function NetMgr:connect(address,port,func,fail)
    mgr.ViewMgr:openView(ViewName.WaitView, function()
        UnityNetMgr:SendConnect(address, port, nil)
        self.connectFunc = func
        self.failFunc = fail
    end)
end

--添加消息监听
function NetMgr:add(msgId,target)
    self._msgs[msgId] = target
end

--发送
function NetMgr:send(msgId,data)
    if not self:isConnect() then
        return
    end
    if NOT_PRINT_MSGIDS[msgId] ~= true then
        --plog("发送数据>>>>>>"..msgId)
    end
    if not self.notwaitmsg[msgId] then
        if self.waitMsg[msgId+4000000] then
            plog("等待列表中 ",msgId+4000000)
            return
        end
        self.waitMsg[msgId+4000000] = true
    end

    local buf = message.MsgPacket.createPacket(msgId,data)
    -- UnityNetMgr:SendMessage(buf) --不带加密的
    UnityNetMgr:SendMessage2(buf) --带加密的
end

--连接成功
function NetMgr:_onConnect(event_)

end

--[[ **断线重连规则**
    step1：接受断线消息弹框提示 返回首页/重连
    step2：检查是否有版本更新
    step3：如果有更新则进入update_scene,并清理一切游戏事物
    step4：如果没有更新则进入登录界面，并清理相关事物
    step5：如果是重连则走重连流程
]]
--客户端socket触发断开连接
function NetMgr:_onError(event_)
    print("[NetMgr]连接关闭~~")
    self.waitMsg = {}
    cache.TimerCache:releaseTimer()
    if mgr.SceneMgr:getCurScene() == SceneRes.MAIN_SCENE then
        if not mgr.ViewMgr:get(ViewName.ReconnectView) then
            mgr.ViewMgr:openView2(ViewName.ReconnectView,{status=self.mNetError, type=self.disConnectType})
        end
    else
        if self.disConnectType ~= 3 then
            GComAlter("网络连接失败,请稍后重试")
        end
    end
    self.disConnectType = 0
    self.mNetError = 0
end

--服务端返回断开连接
function NetMgr:onNetError(status)
    print("@服务端返回断开连接")
    self.disConnectType = 1
    self.mNetError = status
    if gRole then gRole:stopAI() end
    --TODO 客户端关闭连接
    UnityNetMgr:DisConnect()
end
--客户端网络断开
function NetMgr:onNetTimeOut(status)
    print("@客户端超时连接")
    self.disConnectType = 2
    self.mNetError = status
    if gRole then gRole:stopAI() end
    --TODO 客户端关闭连接
    UnityNetMgr:DisConnect()
end
--从创建返回登录
function NetMgr:onNetClose(fail)
    print("@创建返回登录断开连接")
    self.disConnectType = 3
    self.failFunc = fail
    UnityNetMgr:DisConnect()
end

--每帧去C#获取消息
function NetMgr:update()
    local list = UnityNetMgr:GetBytes(100)
    local count = list.Count
    for i = 0, count - 1 do
        local buffer = list[i]
        if buffer.key == ProtocalConnect then
            self.mNetError = 0
            self._isConnect = true
            self:_onConnect(buffer.key)
            self._lastTime = os.time()
            self.heartBeatTime = Time.getTime()
            plog("服务器连接成功>>>>>>>>")
            if self.connectFunc then
                self.connectFunc()
            end
            self.failFunc = nil
            mgr.ViewMgr:closeView(ViewName.WaitView)
        elseif buffer.key == ProtocalSendData then  --登陆成功和接受数据
            mgr.DebugMgr:startMarkTime()
            local result = self._buf:splitPacket(buffer.value)
            buffer.value:Close()
            local __cback = self._msgs[result.msgId]
            self.waitMsg[tonumber(result.msgId)] = nil
            if g_msg_pint == true and NOT_PRINT_MSGIDS[result.msgId] ~= true then
                plog("---------------消息下行begin----------------")
                printt(result)
                plog("---------------消息下行end----------------")
            end
            if __cback ~= nil then
              __cback(result)
            end
            self.heartBeatTime = Time.getTime()
            mgr.DebugMgr:endMarkTime("耗时消息号-"..result.msgId)
        elseif buffer.key == ProtocolClose or buffer.key == ProtocolFailure then  --连接关闭
            self._isConnect = false
            self:_onError(buffer.key)
            mgr.ViewMgr:closeView(ViewName.WaitView)
            mgr.ViewMgr:closeView(ViewName.SitDownView)
            if self.failFunc then
                self.failFunc()
                self.failFunc = nil
            end
        end
    end

    --[[for i=1, g_var.msgCount do
        local check = UnityNetMgr:CheckBuffer()
        if check then
            local buffer = UnityNetMgr:GetByteBuffer()
            if buffer.key == ProtocalConnect then
                self.mNetError = 0
                self._isConnect = true
                self:_onConnect(buffer.key)
                self._lastTime = os.time()
                self.heartBeatTime = Time.getTime()
                plog("服务器连接成功>>>>>>>>")
                if self.connectFunc then
                    self.connectFunc()
                end
                mgr.ViewMgr:closeView(ViewName.WaitView)
            elseif buffer.key == ProtocalSendData then  --登陆成功和接受数据
                local t1 = Time.getTime()
                local result = self._buf:splitPacket(buffer.value)
                local __cback = self._msgs[result.msgId]
                self.waitMsg[tonumber(result.msgId)] = nil
                if g_msg_pint == true and NOT_PRINT_MSGIDS[result.msgId] ~= true then
                    plog("---------------消息下行begin----------------")
                    printt(result)
                    plog("---------------消息下行end----------------")
                end
                if __cback ~= nil then
                  __cback(result)
                end
                self.heartBeatTime = Time.getTime()
                local t2 = Time.getTime()
                if t2 - t1 > 0.03 then
                    print("消息耗时严重：", t2-t1, "消息号：", result.msgId)
                end
            elseif buffer.key == ProtocolClose or buffer.key == ProtocolFailure then  --连接关闭
                self._isConnect = false
                self:_onError(buffer.key)
                mgr.ViewMgr:closeView(ViewName.WaitView)
                mgr.ViewMgr:closeView(ViewName.SitDownView)
                if self.failFunc then
                    self.failFunc()
                end
            end
        else
            --如果没有消息，当前帧就不用提取
            break
        end
    end]]

    local nowTime = os.time()
    local delayTime = nowTime - self._lastTime
    if self._isConnect then
        --定时发送心跳包
        if delayTime > CONST_HEART_SEND_DELAY then  --检查是否停掉
            --TODO 心跳包发送延迟到20秒-断线重连
            self:onNetTimeOut(1)
        elseif delayTime > CONST_HEART_CHECK_TIME then  --发送心跳
            self:send(MSG_ID_S_HEART,{oneTime=nowTime})
            self._lastTime = nowTime
            --网络ping值
            UnityNetMgr:PingIP(g_var.socketAddress)
        end

        --TODO 主场景内，8秒内没有消息返回则断线处理
        local delay = Time.getTime() - self.heartBeatTime
        if delay > CONST_HEART_SEND_DELAY then
            self:onNetTimeOut(2)
            self.heartBeatTime = Time.getTime()
        end
    else
        --如果进入主场景了。断线了没有断线重连窗口则弹出来
        if mgr.SceneMgr:getCurScene() == SceneRes.MAIN_SCENE then
            if delayTime > 4 then
                self._lastTime = os.time()
                local view = mgr.ViewMgr:get(ViewName.ReconnectView)
                if not view then
                    mgr.ViewMgr:openView2(ViewName.ReconnectView,{status=3, type=1})
                end
            end
        end
    end
end

--发送心跳包(返回)
function NetMgr:_rHeartMsg(data)
    self._serverTime = data.serverTime --服务器时间
    self._saveTime = os.time()          --记录服务器时间点
end

--获取服务器时间，服务器真实时间
function NetMgr:getServerTime()
  return self._serverTime + (os.time()-self._saveTime)
end

return NetMgr