--
-- Author: 
-- Date: 2017-03-08 11:12:38
--

local ItemShop = class("ItemShop",import("game.base.Ref"))

function ItemShop:ctor(param)
    self.view = param
    self:initView()
end

function ItemShop:initView()
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onBtnServerCallBack,self)

    self.listShop = self.view:GetChild("n2")
    self.listShop:SetVirtual()
    self.listShop.itemRenderer = function(index,obj)
        self:cellShop(index, obj)
    end
    self.listShop.numItems = 0

    self:initListView()
end

function ItemShop:initListView()
    -- body
    self.confData = conf.BangPaiConf:getAllGanglev()
    self.listView.numItems = #self.confData


end

function ItemShop:sendMsg(index)
    -- body
    local param = {}
    param.reqType = 1
    param.buyId = 0
    param.buyLev = index+1
    param.buyNum = 0
    proxy.BangPaiProxy:sendMsg(1250302,param)
end

function ItemShop:setSelect(index)
    -- body
    self.page = index + 1
    self.confShop = conf.BangPaiConf:getShopByGanglv(self.page) 

    self.listView:AddSelection(index,false)
    self:sendMsg(index)
end

function ItemShop:onBtnServerCallBack( context )
    -- body
    local index = context.data.data
    self:setSelect(index)
end

function ItemShop:celldata(index,obj)
    -- body
    local data = self.confData[index+1]
    local lab = obj:GetChild("title")
    lab.text = string.format(language.bangpai10,data.id)

    obj.data = index
end

function ItemShop:cellShop(index,obj)
    -- body
    local confData = self.confShop[index+1]
    local itemObj = obj:GetChild("n4") 
    local t = {mid = confData.items[1][1]}
    GSetItemData(itemObj,t,true)

    local img = obj:GetChild("n1")
    local labcout  = obj:GetChild("n10")
    local lab = obj:GetChild("n14") 
    lab.text = string.format(language.bangpai69,confData.gang_lev)

    if confData.is_limit and confData.is_limit == 1 then
        img.visible = true
        local var = confData.day_limit - (self.data.buyCountMap[confData.id] or 0)
        labcout.data = var
        labcout.text = string.format(language.bangpai60,var)
        
    else
        img.visible = false
        labcout.text = ""
        labcout.data = -1  
    end

    local labname = obj:GetChild("n9")
    labname.text = mgr.TextMgr:getQualityStr1(conf.ItemConf:getName(t.mid),conf.ItemConf:getQuality(t.mid)) 

    local c1 = obj:GetController("c1")
    if confData.gang_lev > cache.BangPaiCache:getBangLev() then
        c1.selectedIndex=0
        return
    end
    c1.selectedIndex = 1

    local money = obj:GetChild("n11") 
    money.text = confData.gx

    local btnBuy = obj:GetChild("n6")
    btnBuy:GetChild("title").text = language.bangpai61
    btnBuy.onClick:Add(self.onBtnBuy,self)
    btnBuy.data = {data = confData,count = labcout.data,mId = t.mid}
end

function ItemShop:setData(data_)
    self.data = data_
    local number = table.nums(self.confShop)
    self.listShop.numItems = number

    --购买陈宫
    if data_.reqType == 2 and #data_.items>0 then
        --GComAlter(param)
        GOpenAlert3(data_.items)
    end
end

function ItemShop:onBtnBuy(context)
    -- body
    local data = context.sender.data
    if data.count == 0 then
        GComAlter(language.bangpai62)
        return
    end

    mgr.ViewMgr:openView(ViewName.BagInOut,function(view)
        -- body
        view:setDataBuy()
    end, data)
end

return ItemShop