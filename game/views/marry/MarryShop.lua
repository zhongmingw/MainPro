--
-- Author: 
-- Date: 2017-07-24 15:55:59
--

local MarryShop = class("MarryShop",import("game.base.Ref"))

function MarryShop:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n6")
    self:initView()
end

function MarryShop:initView()
    -- body
    self.listView = self.view:GetChild("n0")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end

function MarryShop:celldata(index,obj)
    -- body
    local data = self.condata[index+1]
    local c1 = obj:GetController("c1")
    if not data.items or #data.items==0 then
        c1.selectedIndex = 2
        return
    end
    local iconze = obj:GetChild("n5") 

    local leftIcon = obj:GetChild("n1")
    leftIcon.url = UIPackage.GetItemURL("marry" , data.icon)

    local name = obj:GetChild("n16") 
    if not data.qm or data.qm == 0 then
        name.text = ""
    else
        name.text = string.format(language.kuafu74,data.qm)
    end

    if data.id == 4 then
        c1.selectedIndex = 1
        local _t = data.items[1]
        local t = {mid = _t[1],amount = _t[2] , bind = _t[3] }
        GSetItemData(obj:GetChild("n17"),t,true)
    else
        c1.selectedIndex = 0

        local leftlist = obj:GetChild("n7")
        leftlist.itemRenderer = function(key,cell)
            local _t = data.items[key+1]
            local t = {mid = _t[1],amount = _t[2] , bind = _t[3] }
            GSetItemData(cell,t,true)
        end
        if data.items then
            leftlist.numItems = #data.items
        else
            leftlist.numItems = 0
        end
        -- local rightlist = obj:GetChild("n8")
        -- rightlist.itemRenderer = function(key,cell)
        --     local _t = data.couple_item[key+1]
        --     local t = {mid = _t[1],amount = _t[2] , bind = _t[3] }
        --     GSetItemData(cell,t,true)
        -- end
        -- if data.couple_item then
        --     rightlist.numItems = #data.couple_item
        -- else
        --     rightlist.numItems = 0
        -- end
    end

    

    local leftcount = obj:GetChild("n15") 
    leftcount.text = string.format(language.kuafu76,self.data.buyLeftMap[data.id] or data.limit_count)

    local cost = obj:GetChild("n13") 
    cost.text = data.money

    local cost1 = obj:GetChild("n21")
    local img = obj:GetChild("n23")

    local dec = obj:GetChild("n14") 
    if self.data.marryDay == 1 then
        dec.text = language.kuafu75
        
        if data.id == 4 then
            cost.text = data.money_jia
        else
            cost.text = data.money
        end
        iconze.url = ResPath.ShopZe(data.ze)
        cost1.text = data.marry_day_cost
    else
        if data.id == 4 then
            iconze.url = ResPath.ShopZe(7)
            cost.text = data.money_jia
            img.visible = true
            cost1.text = data.money
        else
            iconze.url = nil--ResPath.ShopZe(data.ze)
            cost.text = data.money_jia
            img.visible = true
            cost1.text = data.money--""
        end
        dec.text = ""
    end

    local btnBuy = obj:GetChild("n9") 
    btnBuy.data = data
    btnBuy.onClick:Add(self.onBtnBuy,self)
end

function MarryShop:onBtnBuy(context)
    -- body
    if cache.PlayerCache:getCoupleName()== "" then
        GComAlter(language.marryiage20)
        return
    end

    if not self.data then
        return
    end
    local data = context.sender.data
    local amount = self.data.buyLeftMap[data.id] or data.limit_count
    if amount <= 0 then
        GComAlter(language.kuafu77)
        return
    end
    local param = {
        reqType = 2,
        itemId = data.id
    }   
    proxy.MarryProxy:sendMsg(1390106,param)
end

function MarryShop:addMsgCallBack(data)
    -- body
    if data.msgId == 5390106 then
        self.data = data
        self.condata = conf.MarryConf:getMarryAllShop()
        self.listView.numItems = #self.condata

        if data.reqType == 2 then
            GOpenAlert3(data.items)
        end
    end
end

return MarryShop