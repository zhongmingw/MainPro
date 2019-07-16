--
-- Author: 
-- Date: 2017-11-16 19:23:17
--

local AlertView18 = class("AlertView18", base.BaseView)

function AlertView18:ctor()
    AlertView18.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function AlertView18:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.useBtn = self.view:GetChild("n20")
    self.useBtn.onClick:Add(self.onUse,self)
    self.listView = self.view:GetChild("n21")
    self.btnPlus = self.view:GetChild("n17")
    self.btnPlus.onClick:Add(self.onPlus,self)
    self.btnReduce =self.view:GetChild("n16")
    self.btnReduce.onClick:Add(self.onReduce,self)
    self.labCount = self.view:GetChild("n18")
    self.neiDanAmount = self.view:GetChild("n13")  --拥有内丹个数
    self:initListView()

end
function AlertView18:initData(data)
    self.data = data
    self.count = 1
    self.labCount.text = tostring(self.count)
    self.neiDanAmount.text = tostring(self.data.amount)
    self.resList = conf.ItemConf:getArgsItem(self.data.mid)
    self.listView.numItems = #self.resList
    local index = 0
    if self.listView.numItems > 0 then 
        local data = self.resList[index+1]
        self:setInfo(data)
        self.listView:AddSelection(index,true)
     end
end

function AlertView18:setData(data_)
    --body
end

function AlertView18:initListView()
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
end

function AlertView18:cellData(index, obj)
    local key = index + 1
    local data = self.resList[key]
    local desTxt = obj:GetChild("n5")
    local desIcon = obj:GetChild("n6")
    local desAmount = obj:GetChild("n7")
    local url = data[1]
    local value = data[1]
    local amount = data[2]
    local resProId = UIItemRes.moneyIcons2[url]
    desIcon.url = ResPath.iconRes(resProId)
    desTxt.text = language.money[value]
    desAmount.text = tostring(amount)
    obj.data = data
    obj.data.ext = key
    obj.onClick:Add(self.onSelectInfo,self)
end

function AlertView18:onSelectInfo(context)
    local data = context.sender.data
    self:setInfo(data)    
end

function AlertView18:setInfo(data)
    self.useBtn.data = data 
end

--使用按钮
function AlertView18:onUse(context)
    local data = context.sender.data
    local param = {}
    param.index = self.data.index
    param.amount = self.count
    param.ext_arg = data.ext
    proxy.PackProxy:sendUsePro(param)
    self:closeView()
end

function AlertView18:onPlus()
    if self.count >= self.data.amount then
        self.count = self.data.amount 
        GComAlter(language.arena16)
    else
        self.count = self.count+1
    end
    self.labCount.text = tostring(self.count)
end

function AlertView18:onReduce()
    self.count = self.count-1 
    if self.count <=1 then
        self.count =1
    end
    self.labCount.text = tostring(self.count)
end

function AlertView18:onClickClose()
    self:closeView()
end

return AlertView18