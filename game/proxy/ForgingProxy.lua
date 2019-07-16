--
-- Author: ohf
-- Date: 2017-02-07 10:52:30
--
--装备锻造
local ForgingProxy = class("ForgingProxy",base.BaseProxy)


function ForgingProxy:init()
    self:add(5100101,self.add5100101)--返回装备部位额外信息
    self:add(5100102,self.add5100102)--返回装备部位强化
    self:add(5100103,self.add5100103)--返回装备部位升星
    self:add(5100104,self.add5100104)--返回请求装备部位宝石
    self:add(5100105,self.add5100105)--返回装备打造
    self:add(5100106,self.add5100106)--返回装备合成
    self:add(5100107,self.add5100107)--返回装备套装
    self:add(5100108,self.add5100108)--请求装备套装数据
    self:add(5100110,self.add5100110)--请求一键镶嵌宝石
    self:add(5100111,self.add5100111)--请求打造石红点位置
    self:add(5100112,self.add5100112)--请求装备合成
    self:add(5100113,self.add5100113)--请求装备套装锻造
    self:add(5100114,self.add5100114)--请求装备升阶
    self:add(5100115,self.add5100115)--请求装备铸星
    self:add(5100116,self.add5100116)--请求装备觉醒
    self:add(5100117,self.add5100117)--请求宝石抛光

    self:add(5100401,self.add5100401)--请求神装合成
    self:add(5100402,self.add5100402)--请求神装合成
end
--返回装备部位额外信息
function ForgingProxy:add5100101( data )
    if data.status == 0 then
        if data.part == 0 then
            local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)--请求了别人的锻造信息
            if view then
                view:add5100101(data)
            end
        end
        if tonumber(data.roleId) > 0 and data.part > 0 then--单独请求了别人的锻造信息
            local view = mgr.ViewMgr:get(ViewName.EquipTipsView)
            if view then
                view:setForgPlayer(data.partInfos)
            end
            self:send(1100101, {part = data.part,roleId = 0,svrId = 0})--鍛造部位信息
        else--请求自己的锻造信息
            cache.PackCache:updataForg(data)
            local view = mgr.ViewMgr:get(ViewName.EquipTipsView)
            if view then
                view:setForgData()
            end
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then
                if view.mainController.selectedIndex ~= 4
                and view.mainController.selectedIndex ~= 3 
                and view.mainController.selectedIndex ~= 7 then
                    view:setData(true)
                end
            end
        end
    else
        if data.status == 21100001 then
            return
        end
        GComErrorMsg(data.status)
    end 
end
--返回装备部位强化
function ForgingProxy:add5100102( data )
    if data.status == 0 then
        cache.PackCache:setIsStreng(true)
        cache.PackCache:updataForg(data)
        self:refresh()
    else
        GComErrorMsg(data.status)
    end 
end

--返回装备部位升星
function ForgingProxy:add5100103( data )
    -- printt("返回装备部位升星",data)
    if data.status == 0 then
        if data.suc == 1 then--1升星成功,否则失败
            cache.PackCache:setIsStar(true)
            cache.PackCache:updataStar(data.partInfo)
        else
            GComAlter(language.forging7)
        end
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:setStarSuc(data.suc)
            view:setData()
        end
    else
        if data.status == 22020005 then--道具不足也要刷新一下
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then
                view:setStarSuc(data.suc)
                view:setData()
            end
        end
        GComErrorMsg(data.status)
    end 
end
--返回请求装备部位宝石
function ForgingProxy:add5100104( data )
    if data.status == 0 then
        cache.PackCache:updataCamo(data.partInfo)
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if data.reqType == 4 then
            if view then
                view:setOneKeySucc(data.gemList)
            end
        else
            if data.reqType ~= 2 then
                if view then
                    view:setGemHole(data.hole)
                end
            end
        end
        self:refresh()
    else
        GComErrorMsg(data.status)
    end 
end
--返回装备打造
function ForgingProxy:add5100105( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:updateMakeData(data)
            if data.reqType == 1 then
                -- if data.suc == 1 then
                --     GOpenAlert3(data.items)
                --     GComAlter(language.forging44)
                -- else
                --     GComAlter(language.forging8)
                -- end
                mgr.ViewMgr:openView2(ViewName.MakeDekaron, data)
                view:setMakeRef()
                view:setMakeData(data)
            elseif data.reqType == 2 then
                view:setMakeData(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end
--返回合成
function ForgingProxy:add5100106( data )
    if data.status == 0 then
        local items = {{mid = data.itemId,amount = data.hcNum}}
        GOpenAlert3(items)
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:setFuseData()
        end
    else
        GComErrorMsg(data.status)
    end 
end

function ForgingProxy:refresh()
    local view = mgr.ViewMgr:get(ViewName.ForgingView)
    if view then
        view:setData()
    end
end

--返回装备套装
function ForgingProxy:add5100107( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateSuitId(data.suiltEffectId)
        end

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function ForgingProxy:add5100108( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.JueSeMainView)
        if view then
            view:updateSuitData(data)
        end
        --锻造tips
        local view = mgr.ViewMgr:get(ViewName.ForgingTipsView)
        if view then
            view:setSuitData(data)
        end

        local view = mgr.ViewMgr:get(ViewName.AwakenView)
        if view then
            view:addMsgCallBack(data)
        end

    else
        GComErrorMsg(data.status)
    end 
end

function ForgingProxy:add5100110(data)
    if data.status == 0 then
        cache.PackCache:updataCamo(data.partInfo)
        if data.result == 1 then
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then
                view:setOneKeySucc(data.holeList)
            end
        end
        
        self:refresh()
    else
        GComErrorMsg(data.status)
    end
end

function ForgingProxy:add5100111(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:setFuseList(data.buildReds)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ForgingProxy:add5100112( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
        if data.status == 2204014 then
            --
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            view:addMsgCallBack(data)
        end
    end
end
--请求装备套装锻造
function ForgingProxy:add5100113(data)
    -- printt("请求装备套装锻造",data)
    if data.status == 0 then
        if data.reqType == 0 then--全部改变
            cache.PackCache:setSuitDzData(data.suits)
        else--单个改变
            cache.PackCache:updateSuitDzData(data.part,data.suits)
        end
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            if data.reqType == 0 then--请求数据
                view:setSuitDzData(data)
            else--诛仙或者诸神
                view:refreshSuitDz(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function ForgingProxy:add5100114( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:initData()
            view:addMsgCallBack(data)
        end
        mgr.GuiMgr:refreshRedBottom()
    else
        GComErrorMsg(data.status)
    end
end

function ForgingProxy:add5100115( data )
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
--请求装备觉醒
function ForgingProxy:add5100116(data)
    -- printt("返回装备觉醒",data)
    if data.status == 0 then
        if data.reqType == 0 then--全部改变
            cache.PackCache:setsuitAwakens(data.awakens)
        else--单个改变
            cache.PackCache:updateSuitAwakens(data.part,data.awakens)
        end
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            if data.reqType == 0 then--请求数据
                view:setSuitDzData(data)
            else--诛仙或者诸神
                view:refreshSuitDz(data)
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求宝石抛光
function ForgingProxy:add5100117(data)
    if data.status == 0 then
        cache.PackCache:updataCamo(data.partInfo)
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
            view:refreshRed()
        end
    else
        GComErrorMsg(data.status)
    end
end

-- 请求神装合成
function ForgingProxy:add5100401(data)
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.ForgingView)
        if view then
            view:addMsgCallBack(data)
        end
    else
        GComErrorMsg(data.status)
    end
end
-- 请求神装分解
function ForgingProxy:add5100402(data)
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


return ForgingProxy