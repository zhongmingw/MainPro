--
-- Author: 
-- Date: 2017-03-10 20:05:58
--

local BangPaiBoxInfo = class("BangPaiBoxInfo", base.BaseView)

function BangPaiBoxInfo:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function BangPaiBoxInfo:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.icon = self.view:GetChild("n3")
    self.labname = self.view:GetChild("n7")
    self.listView1 =  self.view:GetChild("n4")
    self.listView1.itemRenderer = function(index,obj)
        self:celldata1(index, obj)
    end
    self.listView1.numItems = 0

    self.listView2 =  self.view:GetChild("n11")
    self.listView2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.listView2.numItems = 0

    self.listView3 =  self.view:GetChild("n13")
    self.listView3.itemRenderer = function(index,obj)
        self:celldata3(index, obj)
    end
    self.listView3.numItems = 0

    self:initDec()
end

function BangPaiBoxInfo:initDec()
    -- body
    self.view:GetChild("n9").text = language.bangpai96
    self.view:GetChild("n10").text = language.bangpai97
    self.view:GetChild("n12").text = language.bangpai121
    
    
end

function BangPaiBoxInfo:setItemMsg(obj,data)
    -- body
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj:GetChild("n0"),t,true)
end

function BangPaiBoxInfo:celldata1( index, obj )
    -- body
    local data = self.confData.box_items[index+1]
    self:setItemMsg(obj,data)

    --local t = {mid = data[1],amount = data[2]}
end

function BangPaiBoxInfo:celldata2( index, obj )
    -- body
    local data = self.confData.rand_items[index+1]
    self:setItemMsg(obj,data)
end

function BangPaiBoxInfo:celldata3( index, obj )
    -- body
    local data = self.confData.assist_items[index+1]
    self:setItemMsg(obj,data)
end

function BangPaiBoxInfo:setData(data)
    self.confData = conf.BangPaiConf:getBoxItem(data)
    self.icon.url = UIItemRes.bangpai02[data]
    self.labname.text = self.confData.name


    self.listView1.numItems = self.confData.box_items and #self.confData.box_items or 0
    self.listView2.numItems = self.confData.rand_items and #self.confData.rand_items or 0
    self.listView3.numItems = self.confData.assist_items and #self.confData.assist_items or 0
end

function BangPaiBoxInfo:onBtnClose()
    -- body
    self:closeView()
end

return BangPaiBoxInfo