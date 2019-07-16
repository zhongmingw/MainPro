--
-- Author:ohf 
-- Date: 2017-01-22 15:58:19
--
--商店协议
local ShopProxy = class("ShopProxy",base.BaseProxy)

function ShopProxy:init()
    self:add(5090101,self.add5090101)--返回随身商店
    self:add(5090102,self.add5090102)--请求购买道具
    self:add(5090103,self.add5090103)--请求商城道具信息返回
    self:add(5090104,self.add5090104)--请求购买商城道具返回
    self:add(5090105,self.add5090105)--请求坐骑时间购买
end

--请求商城
function ShopProxy:sendStore(reqType)
    local data = {reqType = reqType}
    self:send(1090103,data)
end
--请求购买商城道具
function ShopProxy:sendByItemsByStore( Type,index,amount )
    local data = {reqType = Type,index = index,amount = amount}
    self.index = index
    self.amount = amount
    --printt("send1090104",data)
    self:send(1090104,data)
end

function ShopProxy:add5090101(data)
    if data.status == 0 then
        local shopView = mgr.ViewMgr:get(ViewName.ShopBuyView)
        if shopView then
            shopView:setBuyCount(data.leftCount)
        end
        if data.items and #data.items > 0 then
            local packView = mgr.ViewMgr:get(ViewName.PackView)
            if packView then
                packView:setData()
            end
            GOpenAlert3(data.items)
            local view = mgr.ViewMgr:get(ViewName.BloodBuyView)
            if view then-- 弹框购买血包后自动使用
                local params = {
                    index = data.items[1].index,--背包的位置
                    amount = 1,--使用数量
                    ext_arg = 0,
                }
                proxy.PackProxy:sendUsePro(params)
                view:onCloseView()
            end
        end
    else
        GComErrorMsg(data.status)
    end 
end

function ShopProxy:add5090102(data)
    if data.status == 0 then
        if data.items and #data.items > 0 then
            local packView = mgr.ViewMgr:get(ViewName.PackView)
            if packView then--刷新背包
                packView:setData()
            end
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then--刷新锻造
                view:setData()
            end
            local view = mgr.ViewMgr:get(ViewName.AwakenView)
            if view then--刷新剑神
                view:setData()
            end
            --坐骑 伙伴
            local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.HuobanView)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.HuobanItemUse)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.HuobanSkillUp)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.HuobanEquipUp)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.ZuoQiEquipUp)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.ZuoQiSkillUp)
            if view then
                view:add5090102()
            end

            local view = mgr.ViewMgr:get(ViewName.ZuoQiItemUse)
            if view then
                view:add5090102()
            end

            GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function ShopProxy:add5090103(data)
    if data.status == 0 then
        local shopView = mgr.ViewMgr:get(ViewName.ShopMainView)
        if shopView then 
            shopView:initShopList()
            shopView:setData(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function ShopProxy:add5090104(data)
    if data.status == 0 then
        if data.items and #data.items > 0 then
            local packView = mgr.ViewMgr:get(ViewName.PackView)
            if packView then--刷新背包
                packView:setData()
            end
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then--刷新锻造
                view:setData()
            end
            local view = mgr.ViewMgr:get(ViewName.AwakenView)
            if view then--刷新剑神
                view:setData()
            end
            local shopView = mgr.ViewMgr:get(ViewName.ShopMainView)
            if shopView then --刷新商城
                shopView:refreshLeftNums(self.index, self.amount)
            end
            local weddingView = mgr.ViewMgr:get(ViewName.WeddingView)
            if weddingView then
                weddingView:setFireworks()
            end
            local weddingView = mgr.ViewMgr:get(ViewName.HomeSet)
            if weddingView then
                weddingView:add5090104()
            end
            local weddingView = mgr.ViewMgr:get(ViewName.HomeMainView)
            if weddingView then
                weddingView:addMsgCallBack(data)
            end
            mgr.HomeMgr:shopBuyCall()
            -- GOpenAlert3(data.items)
        end
    else
        GComErrorMsg(data.status)
    end 
end

function ShopProxy:add5090105(data)
    -- body
    if data.status == 0 then
        if data.reqType == 0 then
            local param = {}
            param.mId = 221041504
            param.index = 0
            param.restTimes = data.restTimes


            local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
            if view and view.zuoqiJie then
                param.isGuide = view.zuoqiJie.isGuide
            end

            GGoBuyItem(param)
        else
            -- local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
            -- if view then
            --     -- print("购买返回",data.restTimes)
            --     view.Panel1:refreshTime(data.amount)
            -- end
            -- local view = mgr.ViewMgr:get(ViewName.ZuoQiMain)
            -- if view then
            --     view.zuoqiJie:refreshTime(data.amount)
            -- end
        end
    else
        GComErrorMsg(data.status)
    end
end

return ShopProxy