--
-- Author: Your Name
-- Date: 2018-06-28 11:51:59
--

local ShenQiProxy = class("ShenQiProxy",base.BaseProxy)

function ShenQiProxy:init()
    self:add(5520101,self.add5520101)--请求神器系统
    self:add(5520102,self.add5520102)--请求神器强化升级激活
    self:add(5520103,self.add5520103)--请求神器附灵升级
    self:add(5520104,self.add5520104)--请求神器升星
    self:add(5520105,self.add5520105)--请求神器材料分解
    self:add(8020205,self.add8020205)--广播自己的神器强化石数值
    self:add(8020206,self.add8020206)--广播神器战力
end

function ShenQiProxy:sendMsg(msgId,param)
    self:send(msgId,param)
end

--请求神器系统
function ShenQiProxy:add5520101(data)
    if data.status == 0 then
        -- printt("神器系统信息",data)
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:setShenQiData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神器强化升级激活
function ShenQiProxy:add5520102(data)
    if data.status == 0 then
        -- local var = cache.PlayerCache:getRedPointById(attConst.A20179)
        -- cache.PlayerCache:setRedpoint(attConst.A20179, var-1)
        -- mgr.GuiMgr:refreshRedBottom()
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenQiPanel(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.StrengthenView)
        if view2 then
            view2:refreshQh(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神器附灵升级
function ShenQiProxy:add5520103(data)
    if data.status == 0 then
        -- local var = cache.PlayerCache:getRedPointById(attConst.A20181)
        -- cache.PlayerCache:setRedpoint(attConst.A20181, var-1)
        -- mgr.GuiMgr:refreshRedBottom()
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshShenQiPanel(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.StrengthenView)
        if view2 then
            view2:refreshFl(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神器升星
function ShenQiProxy:add5520104(data)
    if data.status == 0 then
        -- local var = cache.PlayerCache:getRedPointById(attConst.A20180)
        -- cache.PlayerCache:setRedpoint(attConst.A20180, var-1)
        -- mgr.GuiMgr:refreshRedBottom()
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshSx(data.sxLev)
        end
        local view2 = mgr.ViewMgr:get(ViewName.StrengthenView)
        if view2 then
            view2:refreshSx(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求神器材料分解
function ShenQiProxy:add5520105(data)
    if data.status == 0 then
        printt("神器材料分解返回 >>>>>>>>>>>>>",data)
        -- local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        -- if view then
        --     view:refreshQhsMap(data.gotQhsMap)
        -- end
        local view2 = mgr.ViewMgr:get(ViewName.ShenQiFenjie)
        if view2 then
            view2:initListview()
        end
    else
        GComErrorMsg(data.status)
    end
end

--广播自己的神器强化石数值
function ShenQiProxy:add8020205(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshQhsMap2(data)
        end
        local view2 = mgr.ViewMgr:get(ViewName.ShenQiFenjie)
        if view2 then
            view2:initListview()
        end
        local view2 = mgr.ViewMgr:get(ViewName.StrengthenView)
        if view2 then
            view2:refreshQhsMap(data)
        end
        mgr.GuiMgr:refreshRedBottom()
    else
        GComErrorMsg(data.status)
    end
end
--广播神器战力
function ShenQiProxy:add8020206(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ShenQiView)
        if view then
            view:refreshPower(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

return ShenQiProxy