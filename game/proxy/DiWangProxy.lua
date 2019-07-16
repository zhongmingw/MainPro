--
-- Author: Your Name
-- Date: 2018-07-25 18:28:58
--
local DiWangProxy = class("DiWangProxy",base.BaseProxy)

function DiWangProxy:init()
    self:add(5550101,self.add5550101)--请求帝王将相信息
    self:add(5550102,self.add5550102)--请求帝王将相挑战
    self:add(5550103,self.add5550103)--请求帝王将相跳过战斗
    self:add(5550104,self.add5550104)--请求帝王将相时间恢复
    self:add(8100201,self.add8100201)--帝王将相广播进入场景
    self:add(8100202,self.add8100202)--帝王将相结束广播

end

function DiWangProxy:sendMsg(msgId,param)
    self.param = param
    self:send(msgId,param)
end

function DiWangProxy:add5550101(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DiWangView)
        if view then
            view:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function DiWangProxy:add5550102(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

function DiWangProxy:add5550103(data)
    if data.status == 0 then

    else
        GComErrorMsg(data.status)
    end
end

function DiWangProxy:add5550104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.DiWangView)
        if view then
            view:refreshCdTime(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.XianWeiDetails)
        if view2 then
            view2:refreshCdTime(data)
        end
        local view3 = mgr.ViewMgr:get(ViewName.DiWangHuiFuTips)
        if view3 then
            view3:closeView()
        end
    else
        GComErrorMsg(data.status)
    end
end

function DiWangProxy:add8100201(data)
    if data.status == 0 then
        print("进入场景>>>>>>>>>>>>>>>>>>")
        mgr.FubenMgr:gotoFubenWar(DiWangScene)
    else
        GComErrorMsg(data.status)
    end
end

function DiWangProxy:add8100202(data)
    if data.status == 0 then
        printt("结算广播>>>>>>>>>>>",data)
        mgr.ViewMgr:openView2(ViewName.DiWangFightEndView,data)
    else
        GComErrorMsg(data.status)
    end
end

return DiWangProxy