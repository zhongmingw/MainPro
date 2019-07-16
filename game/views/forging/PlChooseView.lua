--
-- Author: 
-- Date: 2017-09-28 16:39:20
--
--可以批量选择的
local PlChooseView = class("ComposeChooseView", base.BaseView)

function PlChooseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.indexs = {}
    self.selectlist = {}
end

function PlChooseView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    local btnOk = self.view:GetChild("n6")
    btnOk.onClick:Add(self.onClickOk,self)
end

function PlChooseView:initData(data)
    self.indexs = {}--缓存勾选的条数<1 = index,2 = index>
    self.selectlist = {}--缓存已经勾选的条数<index,value>
    self.listData = data
    self.listView.numItems = #data
    if #data > 0 then
        self.listView:ScrollToView(0)
    end
end

function PlChooseView:cellData(index, obj)
    local key = index + 1
    local data = self.listData[key]
    local itemObj = obj:GetChild("n0")
    local t = clone(data)
    t.index = 0
    GSetItemData(itemObj,t,true)
    local condata = conf.ItemConf:getItem(data.mid)

    local name = obj:GetChild("n1")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local lab = obj:GetChild("n2")
    lab.text = string.format(language.equip01,condata.stage_lvl)

    local radio = obj:GetChild("n6") 
    radio.data = data
    radio.onClick:Clear()
    if self.selectlist[data.index] then
        radio.selected = true
    else
        radio.selected = false
    end
    radio.onClick:Add(self.onChooseSelect,self)
end

function PlChooseView:onChooseSelect(context)
    local radio = context.sender
    local data = radio.data
    if radio.selected then
        table.insert(self.indexs, data.index)
        self.selectlist[data.index] = 1
    else 
        table.remove(self.indexs, data.index)
        self.selectlist[data.index] = nil
    end
end

function PlChooseView:onClickOk()
    if #self.indexs <= 0 then
        GComAlter(language.bangpai151)
        return
    end
    local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.bangpai150, 6),sure = function()
        proxy.BangPaiProxy:send(1250408,{reqType = 1,tars = self.indexs})
        self:onClickClose()
    end}
    GComAlter(param)
end

function PlChooseView:onClickClose()
    self:closeView()
end

return PlChooseView