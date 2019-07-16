--
-- Author: 
-- Date: 2018-08-09 11:22:09
--

local XianTongGrowView = class("XianTongGrowView", base.BaseView)

function XianTongGrowView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongGrowView:initView()
    local btnclose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnclose)

    self.c1 = self.view:GetController("c1")

    local obj = self.view:GetChild("n1")
    self.frame = obj:GetChild("n0")
    self.icon = obj:GetChild("n3")

    
    self.imgCall = self.view:GetChild("n9")
    self.imgCall.text = ""
    self.imgCall.onClick:Add(self.onSelectCall,self)

    self.name = self.view:GetChild("n10")
    self.name.text = ""

    self.group = self.view:GetChild("n18")
    self.list3 = self.group:GetChild("n1")
    self.list3.itemRenderer = function(index,obj)
        self:celllistdata(index, obj)
    end
    self.list3.numItems = 0
    self.list3.onClickItem:Add(self.onSelectCallBack,self)

    self.curzz = self.view:GetChild("n12")
    self.curzz.text = language.pet28

    self.curzzrange = self.view:GetChild("n13")
    self.curzzrange.text = language.pet29

    self.item1 = self.view:GetChild("n2")
    self.cost1 = self.view:GetChild("n16")
    self.cost1.text = ""
    self.desc1 = self.view:GetChild("n14")
    self.desc1.text = ""
    self.btn1 = self.view:GetChild("n4")
    self.btn1.onClick:Add(self.onUseItem,self)

    self.item2 = self.view:GetChild("n3")
    self.cost2 = self.view:GetChild("n17")
    self.cost2.text = ""
    self.desc2 = self.view:GetChild("n15")
    self.desc2.text = ""
    self.btn2 = self.view:GetChild("n5")
    self.btn2.onClick:Add(self.onUseItem,self)
end

function XianTongGrowView:onSelectCall()
    -- body
    self.group.visible = not self.group.visible
end

function XianTongGrowView:onSelectCallBack(context)
    -- body
    self:onSelectCall()
    self.petData = context.data.data
    self:setData()
end
function XianTongGrowView:celllistdata( index,obj)
    -- body
    local data = self.data[index+1]
    local condata = conf.MarryConf:getXTlev(data.level)
    obj.title = data.name .. " " .. string.format(language.skill15,condata.jie,condata.xing)
    obj.data = data
end

function XianTongGrowView:initData(data)
    -- body
    self.data = cache.MarryCache:getXTData()
    self.list3.numItems = #self.data

    self.petData = data
    self:setData() 
end

function XianTongGrowView:setData(data_)
    local condata = conf.MarryConf:getPetItem(self.petData.xtId)
    self.grow_field = condata.grow_field

    self.frame.url = ResPath.iconRes("beibaokuang_00"..condata.color)
    self.icon.url = ResPath.iconRes(condata.src)

    local _condata_ = conf.MarryConf:getXTlev(self.petData.level)
    self.name.text = self.petData.name .. " " ..  string.format(language.skill15,_condata_.jie,_condata_.xing)
    self.curzz.text = language.pet28 .. string.format("%.2f",self.petData.growValue/100)

    local var = string.format("%.2f-%.2f",condata.grow_field[1]/100,condata.grow_field[2]/100)
    self.curzzrange.text = language.pet29 .. var 

    if self.grow_field[2] == self.petData.growValue then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end

    local cc = conf.MarryConf:getXTValue("xt_grow_drug_item")
    if self.c1.selectedIndex ==0 and cc[1] then
        local t = {mid = cc[1][1],amount = cc[1][2],bind = cc[1][3] or 0}
        GSetItemData(self.item1,t,true) 

        local packdata = cache.PackCache:getPackDataById(t.mid)
        self.cost1.text = packdata.amount .. "/" .. t.amount
        self.desc1.text = language.pet30
        self.btn1.data = t.mid
        self.btn1.visible = true
    else
        GSetItemData(self.item1,{}) 
        self.cost1.text = ""
        self.desc1.text = ""
        self.btn1.data = nil
        self.btn1.visible = false
    end

    if self.c1.selectedIndex == 0 and cc[2] then
        local t = {mid = cc[2][1],amount = cc[2][2],bind = cc[2][3] or 0}
        GSetItemData(self.item2,t,true) 

        local packdata = cache.PackCache:getPackDataById(t.mid)
        self.cost2.text = packdata.amount .. "/" .. t.amount
        self.desc2.text = language.pet31
        self.btn2.data = t.mid
        self.btn2.visible = true
    else
        GSetItemData(self.item2,{}) 
        self.cost2.text = ""
        self.desc2.text = ""
        self.btn2.data = nil
        self.btn2.visible = false
    end
end


function XianTongGrowView:onUseItem(context)
    -- body
    local data = context.sender.data
    if not data then
        return
    end
    if self.c1.selectedIndex == 1 then
        GComAlter(language.pet32)
        return
    end

    local param = {}
    param.xtRoleId = self.petData.xtRoleId
    param.mid = data
    printt("1390609 ",param)    
    proxy.MarryProxy:sendMsg(1390609,param) 
end

function XianTongGrowView:addMsgCallBack(data)
    -- body
    if data.msgId == 5390609 then
        if self.petData then
            self.petData.growValue = data.growValue
            self:setData(self.petData)
        end
    end
end
return XianTongGrowView