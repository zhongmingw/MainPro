--
-- Author: Your Name
-- Date: 2018-09-03 14:04:17
--
local ShenShouProxy = class("ShenShouProxy",base.BaseProxy)

function ShenShouProxy:init()
    self:add(5590101,self.add5590101)--请求神兽列表信息
    self:add(5590102,self.add5590102)--请求神兽装备穿脱
    self:add(5590103,self.add5590103)--请求神兽助战召回
    self:add(5590104,self.add5590104)--请求扩展神兽助战上限
    self:add(5590105,self.add5590105)--请求神兽装备强化
    self:add(5590106,self.add5590106)-- 请求神兽装备合成

end

function ShenShouProxy:sendMsg(msgId,param)
    self:send(msgId,param)
end

--请求神兽列表信息
function ShenShouProxy:add5590101(data)
    if data.status == 0 then
        cache.ShenShouCache:setShenShouCache(data.shenShouInfos)
        mgr.GuiMgr:updateRedPointPanels(attConst.A10265)
        local mainView = mgr.ViewMgr:get(ViewName.MainView)
        if mainView then
            mainView:refreshRedBottom()
        end
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:setShenShouData(data)
            view:refreshRed()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神兽装备穿脱
function ShenShouProxy:add5590102(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenShou()
        end
        local view2 = mgr.ViewMgr:get(ViewName.ShenShouEquip)
        if view2 then
            view2:refreshEquip(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神兽助战召回
function ShenShouProxy:add5590103(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenShou()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求扩展神兽助战上限
function ShenShouProxy:add5590104(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenShou()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神兽装备强化
function ShenShouProxy:add5590105(data)
    if data.status == 0 then
        printt("强化返回>>>>>>>>>>>>>",data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenShou()
        end
        local view2 = mgr.ViewMgr:get(ViewName.ShenShouStrength)
        if view2 then
            view2:refreshData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ShenShouProxy:add5590106(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return ShenShouProxy