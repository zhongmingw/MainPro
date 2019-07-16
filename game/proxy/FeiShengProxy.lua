--
-- Author: 
-- Date: 2018-08-22 16:33:37
--

local FeiShengProxy = class("FeiShengProxy",base.BaseProxy)

function FeiShengProxy:init()
    self:add(5580101,self.add5580101)-- 请求飞升装备穿戴
    self:add(5580102,self.add5580102)-- 请求飞升装备分解
    self:add(5580103,self.add5580103)-- 请求飞升装备分解
    self:add(5580104,self.add5580104)-- 请求飞升神装拆解
    self:add(5580201,self.add5580201)-- 请求提升仙缘
    self:add(5580202,self.add5580202)-- 请求羽化飞升
    self:add(5100301,self.add5100301)-- 飞升装备合成

end

function FeiShengProxy:sendMsg(msgId,data)
    -- body
    if msgId == 1580101 then
        if not mgr.ModuleMgr:CheckView({id = 1325}) then
            --检测模块是否开启
            GComAlter(language.xiuxian08)
            return
        end
        if not cache.FeiShengCache:isCanWear(data) then
            return GComAlter(language.fs41)
        end
        --
    end

    self:send(msgId,data)
end
function FeiShengProxy:add5580101(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function FeiShengProxy:add5580102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.FSFenJieView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.PackView)
        if view then
            view:addMsgCallBack(data)
        end
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            self:sendMsg(1580201,{reqType = 0})
        end
    else
        GComErrorMsg(data.status)
    end
end

function FeiShengProxy:add5580103( data )
    -- body
    if data.status == 0 then
        cache.FeiShengCache:setIsSelect(data)
    else
        GComErrorMsg(data.status)
    end
end

function FeiShengProxy:add5580201( data )
    -- body
    if data.status == 0 then
        cache.FeiShengCache:setData(data)
        cache.PlayerCache:setAttribute(542,data.xy)
        cache.PlayerCache:setAttribute(543,data.xlLev)

        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:addMsgCallBack(data)
        end

        local view = mgr.ViewMgr:get(ViewName.FSXianYuanUp)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
function FeiShengProxy:add5580202( data )
    -- body
    if data.status == 0 then
        cache.PlayerCache:setAttribute(541,data.fsLev)
        cache.PlayerCache:setAttribute(542,data.xy)

        if gRole then
            gRole.data.skins[Skins.fsz] = data.fsLev
            gRole:setTitleName(gRole.data.roleName)
        end

        mgr.ViewMgr:openView2(ViewName.FSSuccesView)

        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FeiShengProxy:add5100301( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function FeiShengProxy:add5580104(data)
    if data.status == 0 then
        if data.reqType == 1 then
            mgr.ViewMgr:openView2(ViewName.DismantleView,data)
        else
            GOpenAlert3(data.items)
            local view = mgr.ViewMgr:get(ViewName.PackView)
            if view then--背包界面
                view:setData()
            end
            local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
            if view then--角色界面
                view:updateEquipMsg()
                view:updateEquipPro()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

return FeiShengProxy