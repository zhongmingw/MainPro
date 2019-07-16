--
-- Author: wx
-- Date: 2017-11-22 19:54:01
--

local HomePlantingChoose = class("HomePlantingChoose", base.BaseView)

function HomePlantingChoose:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomePlantingChoose:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onClickItemCall,self)


    local btnShop = self.view:GetChild("n2")
    btnShop.onClick:Add(self.onShop,self)

    local btnPlant = self.view:GetChild("n1")
    btnPlant.onClick:Add(self.onPlant,self)

    local btnGuize = self.view:GetChild("n5")
    btnGuize.onClick:Add(self.onGuize,self) 
end

function HomePlantingChoose:celldata( index, obj )
    -- body
    local key = self.key[index+1]
    local condata = conf.HomeConf:getSeedByid(key)
    local amount = cache.PackCache:getPackDataById(condata.item_mid).amount
    
    --print("key",key)
    obj.data = key

    local lanname = obj:GetChild("n7")
    lanname.text = condata.name

    local _itemdata = conf.ItemConf:getItem(condata.item_mid)

    local frame = obj:GetChild("n1")
    frame.url = ResPath.iconRes("beibaokuang_00".._itemdata.color)

    local imgjie = obj:GetChild("n4") 
    imgjie.url = UIItemRes.home2..condata.jie
   

    local imgbind = obj:GetChild("n3") 
    if condata.bind and condata.bind == 1 then
        imgbind.visible = true
    else
        imgbind.visible = false
    end

    local icon = obj:GetChild("n2") 
    icon.url = mgr.ItemMgr:getItemIconUrlByMid(condata.item_mid) --UIItemRes.home2..condata.icon

    local labcout = obj:GetChild("n6")
    labcout.text = amount
end

function HomePlantingChoose:onClickItemCall(context)
    -- body
    local data = context.data.data
    self.choose = data
    ---BUG #7066 选种子的时候要弹一下tips
    local _t = {}
    _t.mid = conf.HomeConf:getSeedByid(data).item_mid
    _t.amount = 1
    _t.bind = 0
    GSeeLocalItem(_t)
end

function HomePlantingChoose:initData(data)
    -- body
    self.tian =  data
    self.choose = nil 

    self.key = conf.HomeConf:getSeedKey()
    table.sort(self.key,function(a,b)
        -- body
        return a<b
    end)
    self.listView.numItems = #self.key

    --默认选择第一个
    if self.listView.numItems > 0 then
        for k ,v in pairs(self.key) do
            local condata = conf.HomeConf:getSeedByid(v)
            local amount = cache.PackCache:getPackDataById(condata.item_mid).amount
            if amount > 0 then
                self.choose = self.key[k]
                self.listView:AddSelection(k-1,false)
                break
            end
        end
    end
    --proxy.HomeProxy:sendMsg(1460113)
end

function HomePlantingChoose:setData(data_)

end

function HomePlantingChoose:onShop()
    -- body
    --家园商店
    GOpenView({id = 1159})
end

function HomePlantingChoose:onPlant()
    -- body
    --种植
    if not self.choose then
        GComAlter(language.home89)
        return
    end
    local condata = conf.HomeConf:getSeedByid(self.choose)
    local amount = cache.PackCache:getPackDataById(condata.item_mid).amount
    if amount <= 0 then
        GComAlter(language.home91)
        self:onShop()
        return
    end

    cache.HomeCache:setOsTye(1)
    cache.HomeCache:setPlantChoose(self.choose)
    local view = mgr.ViewMgr:get(ViewName.HomeMainView)
    if view then
        view:setonOSsure()
    end
    mgr.HomeMgr:doPlant(self.tian)
    self:closeView()
end

function HomePlantingChoose:onGuize()
    -- body
    GOpenRuleView(1062)
end

function HomePlantingChoose:add5460113(data)
    -- body
    self.data = data.seeds
    self.key = conf.HomeConf:getSeedKey()
    table.sort(self.key,function(a,b)
        -- body
        return a<b
    end)
    self.listView.numItems = #self.key

    --默认选择第一个
    if self.listView.numItems > 0 then
        for k ,v in pairs(self.key) do
            if self.data[v] and self.data[v] > 0 then
                self.choose = self.key[k]
                self.listView:AddSelection(k-1,false)
                break
            end
        end
    end
end

return HomePlantingChoose