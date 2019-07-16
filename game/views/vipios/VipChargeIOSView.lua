--
-- Author: EVE
-- Date: 2017-11-14 21:43:30
-- DESC: IOS审核专用充值界面

-- local VipAttributePanel = import(".VipAttributePanel")
--local VipChargePanel = import(".VipChargePanel")

local VipChargeIOSView = class("VipChargeIOSView", base.BaseView)

function VipChargeIOSView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheTime
end

function VipChargeIOSView:initData()
    -- body
    GSetMoneyPanel(self.window2,self:viewName())
    --请求一下列表
    proxy.VipChargeProxy:sendRechargeList()
end

function VipChargeIOSView:initView()
    -- body
    self.window2 = self.view:GetChild("n0")
    local closeBtn = self.window2:GetChild("btn_close") 
    closeBtn.onClick:Add(self.onClickClose,self)

    local panle = self.view:GetChild("n44")
    self.listView = panle:GetChild("n32")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onChargeCallBack,self)
end

function VipChargeIOSView:setData()
    -- body
    self.data = cache.VipChargeCache:getRechargeList()
    table.sort( self.data.czItemList, function(a,b) 
        return a.itemId < b.itemId
    end)

    table.remove(self.data.czItemList, 1)
    self.listView.numItems = 5--ios充值档位只要前8个
end

function VipChargeIOSView:celldata(index,obj)
    -- body
    local CzItemInfo = self.data.czItemList[index+1]
    if not CzItemInfo then
        return 0
    end
    obj.data = {price=CzItemInfo.rmb}

    local rmb = obj:GetChild("n4")
    rmb.text = CzItemInfo.rmb

    local moneyYb = obj:GetChild("n7")
    moneyYb.text = CzItemInfo.moneyYb

    local dec = obj:GetChild("n5")
    dec.text = ""
    local dec2 = obj:GetChild("n14")
    dec2.text = ""

    --元宝的背景图片
    local bg = obj:GetChild("n0")
    local url = ResPath.iconload("chongzhivip_2002" ,"vipios")
    if g_var.gameFrameworkVersion >= 18 then
        local imagePath = "res/images/vipios.png"
        local check = PathTool.CheckResExist(imagePath)
        if check then
            url = "@"..imagePath
        end 
    end
    bg.url = url

    --[[if tonumber(g_var.packId) > 2009 then
        local url = "res/bgs/login/vipios_"..g_var.packId
        local check = PathTool.CheckResDown(url..".unity3d")
        if not check then
            url = ResPath.iconload("chongzhivip_2002" ,"vipios")
        end
        bg.url = url
    else
        local url = ResPath.iconload("chongzhivip_"..g_var.packId ,"vipios")
        if url then
            bg.url = url
        else
            bg.url = ResPath.iconload("chongzhivip_2002" ,"vipios")
        end
    end]]
end

function VipChargeIOSView:onChargeCallBack(context)
    -- body
    local data = context.data.data
    mgr.SDKMgr:pay(data)
end

function VipChargeIOSView:onClickClose()
    -- body
    self:closeView()
end

return VipChargeIOSView