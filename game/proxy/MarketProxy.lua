--
--寄售行
local MarketProxy = class("MarketProxy",base.BaseProxy)

function MarketProxy:init()
    self:add(5260101,self.add5260101) --请求市场物品信息返回
    self:add(5260102,self.add5260102) --请求道具上架返回
    self:add(5260103,self.add5260103) --请求道具下架返回
    self:add(5260104,self.add5260104) --请求市场记录信息返回
    self:add(5260105,self.add5260105) --请求成功出售后提取返回
    self:add(5260106,self.add5260106) --请求购买返回
    self:add(5260107,self.add5020207) --请求参考价格返回
    self:add(5260108,self.add5260108) --请求搜索道具列表
    self:add(5260109,self.add5260109) --请求宠物上架
end

--市场请求信息
function MarketProxy:sendMarketMsg(sendId,param,Type,sign) 
    --Type为true时则请求的是出售界面
    --sign为下架标记 1为出售界面下架 2为记录界面下架
    self.isSell = Type
    self.sign = sign
    self:send(sendId,param)
end

--请求市场物品信息返回
function MarketProxy:add5260101( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.MarketPanel:setData(data)
            view.MarketPanel:setSeetState(false)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求道具上架返回
function MarketProxy:add5260102( data )
    printt(data)
    -- body
    if data.status == 0 then
        local param = {reqLabel = 4}
        self:sendMarketMsg(1260104,param,true)
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.SellPanel:onClickPutAway()
        end
        local putView = mgr.ViewMgr:get(ViewName.PutAwayPanel)
        if putView then
            putView:refreshPanel()
            putView:setPassword(nil)
        end
    else
        local putView = mgr.ViewMgr:get(ViewName.PutAwayPanel)
        if putView then
            -- putView:refreshPanel()
        end
        GComErrorMsg(data.status)
    end
end
--请求宠物上架返回
function MarketProxy:add5260109( data )
    if data.status == 0 then
        local param = {reqLabel = 4}
        self:sendMarketMsg(1260104,param,true)
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.SellPanel:onClickPutPet()
        end
        local putView = mgr.ViewMgr:get(ViewName.PutAwayPanel)
        if putView then
            putView:refreshPanel()
            putView:setPassword(nil)
        end
    else
        local putView = mgr.ViewMgr:get(ViewName.PutAwayPanel)
        if putView then
            -- putView:refreshPanel()
        end
        GComErrorMsg(data.status)
    end
end

--请求道具下架返回
function MarketProxy:add5260103( data )
    -- body
    if data.status == 0 then
        if self.sign == 1 then
            local param = {reqLabel = 4}
            self:sendMarketMsg(1260104,param,true)
        elseif self.sign == 2 then
            --下架红点刷新
            -- local var = cache.PlayerCache:getRedPointById(attConst.A10225)
            -- cache.PlayerCache:setRedpoint(attConst.A10225,var-1)
            -- local mainview = mgr.ViewMgr:get(ViewName.MainView)
            -- if mainview then
            --     mainview:refreshRed()
            -- end
            mgr.GuiMgr:redpointByID(10225)
            local view = mgr.ViewMgr:get(ViewName.MarketMainView)
            if view then
                view:refreshRedPoint()
            end
            local param = {reqLabel = 2}
            self:sendMarketMsg(1260104,param,false)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求市场记录信息返回
function MarketProxy:add5260104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            if self.isSell then --出售界面
                view.SellPanel:setData(data)
            else                --记录界面
                if view.RecordPanel then
                    view.RecordPanel:setData(data)
                end
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求成功出售后提取返回
function MarketProxy:add5260105( data )
    -- body
    if data.status == 0 then
        --提取物品红点刷新
        -- local var = cache.PlayerCache:getRedPointById(attConst.A10226)
        -- cache.PlayerCache:setRedpoint(attConst.A10226,var-1)
        mgr.GuiMgr:redpointByID(10226)
        mgr.GuiMgr:updateRedPointPanels(10226)
        mgr.GuiMgr:refreshRedTop()

        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view:refreshRedPoint()
        end
        GComAlter(string.format(language.sell09,data.yb))
        local param = {reqLabel = 3}
        self:sendMarketMsg(1260104,param,false)
    else
        GComErrorMsg(data.status)
    end
end

--请求购买返回
function MarketProxy:add5260106( data )
    if data.status == 0 then
        if data.items and #data.items > 0 then
            GOpenAlert3(data.items)
        else
            GComAlter(language.gonggong99)
        end
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.MarketPanel:refreshPanel()
        end
    else
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.MarketPanel:refreshPanel()
        end
        GComErrorMsg(data.status)
    end
end

--请求参考单价返回
function MarketProxy:add5020207( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.PutAwayPanel)
        if view then
            view:setSellInfo(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求搜索道具列表返回
function MarketProxy:add5260108( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.MarketMainView)
        if view then
            view.MarketPanel:setData(data)
            view.MarketPanel:setSeetState(true)
        end
    else
        GComErrorMsg(data.status)
    end
end

return MarketProxy