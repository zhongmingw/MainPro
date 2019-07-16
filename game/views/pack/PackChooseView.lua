--
-- Author: 
-- Date: 2017-04-24 16:10:37
--

local PackChooseView = class("PackChooseView", base.BaseView)

local min = 1

function PackChooseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function PackChooseView:initData(data)
    self.choosKey = nil
    self.listView.numItems = 0
    self:setData(data)
end

function PackChooseView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.listView = self.view:GetChild("n4")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellItemData(index, obj)
    end

    local lessBtn = self.view:GetChild("n8")
    lessBtn.onClick:Add(self.onClickLess,self)
    local addBtn = self.view:GetChild("n7")
    addBtn.onClick:Add(self.onClickAdd,self)

    self.countText = self.view:GetChild("n9")
    self.countText.onChanged:Add(self.onChangeInput,self)

    self.proText = self.view:GetChild("n11")
    self.proText.text = 0

    local btn = self.view:GetChild("n12")
    btn.onClick:Add(self.onClickBtn,self)

    local maxBtn = self.view:GetChild("n14")
    maxBtn.onClick:Add(self.onClickMax,self)
end

function PackChooseView:onChangeInput()
    if self.countText.text == "" then
        self.count = 0
    else
        self.count = tonumber(self.countText.text)
    end
    self:setCount()
end

function PackChooseView:setData(data)
    self.mData = data
    self.count = 1
    self:setCount()
    self.proText.text = self.mData.amount
    self.argsItems = conf.ItemConf:getArgsItem(data.mid)
    self.listView.numItems = #self.argsItems
end

function PackChooseView:cellItemData(index,cell)
    local key = index + 1
    local item = self.argsItems[key]
    local mId = item[1]
    local data = {mid = mId,amount = item[2],bind = item[3],isquan = true}
    --plog("data.mid",data.mid,cache.PlayerCache:getIsNeed(data.mid) )
    data.isdone  = cache.PlayerCache:getIsNeed(data.mid) 
    if data.isdone and data.isdone > 1 then
        if cache.PackCache:getPackDataById(data.mid).amount > 0 then 
            data.isdone = nil 
        end
    end
    local itemObj = cell:GetChild("n1")
    GSetItemData(itemObj, data)
    cell.data = {data = data,key = key,isClick = false}
    local name = conf.ItemConf:getName(mId)
    local color = conf.ItemConf:getQuality(mId)
    cell:GetChild("n3").text = mgr.TextMgr:getQualityStr1(name, color)
    cell.onClick:Add(self.onClickPro,self)
end
--设置数量
function PackChooseView:setCount()
    if self.count > self.mData.amount then
        self.count = self.mData.amount
        GComAlter(language.pack17)
    elseif self.count < 1 then
        self.count = min
        GComAlter(language.pack18)
    end
    self.countText.text = self.count
end

function PackChooseView:onClickPro(context)
    local myCell = context.sender
    local data = myCell.data
    local isClick = data.isClick
    local itemData = data.data
    self.choosKey = data.key
    for k,v in pairs(self.argsItems) do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            if v[1] == itemData.mid then
                cell.data.isClick = true
            else
                cell.data.isClick = false
            end
        end
    end
    -- plog("isClickisClick",isClick)
    if isClick then
       GSeeLocalItem(itemData) 
    end
end
--减
function PackChooseView:onClickLess()
    if not self.mData then return end
    self.count = self.count - 1
    self:setCount()
end
--加
function PackChooseView:onClickAdd()
    if not self.mData then return end
    self.count = self.count + 1
    self:setCount()
end

function PackChooseView:onClickBtn()
    if self.choosKey then
        local params = {
            index = self.mData.index,--背包的位置
            amount = self.count,--使用数量
            ext_arg = self.choosKey,
        }
        proxy.PackProxy:sendUsePro(params)
        self:closeView()
    else
        GComAlter(language.pack16)
    end
end

function PackChooseView:onClickMax()
    if not self.mData then return end
    if self.count == self.mData.amount then
        GComAlter(language.pack17)
        return
    end
    self.count = self.mData.amount
    self:setCount()
end

return PackChooseView