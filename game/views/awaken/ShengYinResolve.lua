--
-- Author: 
-- Date: 2018-09-14 16:25:44
--
local table = table
local pairs = pairs
local ShengYinResolve = class("ShengYinResolve", base.BaseView)
local ProId = {1311155001,1311156001,221043533}


function ShengYinResolve:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function ShengYinResolve:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n4")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    local levelBtn = self.view:GetChild("n8")--等阶筛选按钮
    levelBtn.onClick:Add(self.onClickLevCal,self)

    local colorBtn = self.view:GetChild("n7")--颜色筛选按钮
    colorBtn.onClick:Add(self.onClickColorCal,self)

    self.colorTxt = self.view:GetChild("n12")
    self.jieTxt = self.view:GetChild("n13")
    --筛选组件
    self.Panel = self.view:GetChild("n17")
    self.listPanel = self.view:GetChild("n16")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)

    local fenJieBtn = self.view:GetChild("n5")
    fenJieBtn.onClick:Add(self.onClickFenjie,self)

    local ruleBtn = self.view:GetChild("n21")
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.syScore = self.view:GetChild("n20")
    self.c1 = self.view:GetController("c1")
    self.proIcon = self.view:GetChild("n19")
    --材料2
    self.proIcon2 = self.view:GetChild("n23")
    self.proIcon3 = self.view:GetChild("n26")

end

function ShengYinResolve:initData(data)
    self.Panel.visible = false

    --八门元素
    self.isEightElE = data and data.isEightElE
    -- local roleLv = cache.PlayerCache:getRoleLevel()
    -- if roleLv >= 80 then
    --     self.color = 4
    -- else
    --     self.color = 3
    -- end
    if self.isEightElE then
        self.c1.selectedIndex = 1
        self.color = 3--蓝色开始
        self.jie = 0
        self.proIcon.url =ResPath.iconRes(conf.ItemConf:getSrc(ProId[3]))

        self.proIcon2.url = ResPath.iconRes(conf.ItemConf:getSrc(ProId[1]))
        self.proIcon3.url = ResPath.iconRes(conf.ItemConf:getSrc(ProId[2]))
        self.jieTxt.text = language.eightgates05[1][1]
        self.colorTxt.text = language.eightgates05[2][self.color-2]
    else
        self.c1.selectedIndex = 0
        self.color = 4--紫色开始
        self.jie = 0
        self.proIcon.url = UIPackage.GetItemURL("awaken","shengyin_005")
        self.jieTxt.text = language.shengyin05[1][1]
        self.colorTxt.text = language.shengyin05[2][self.color-3]
    end
    self:refeshList()
end

function ShengYinResolve:refeshList()
    self.packData = {}
    local data = {}
    if self.isEightElE then
        local temp = cache.PackCache:getElementPackData()
        local mData = {}
        for k,v in pairs(temp) do
            local isSub = conf.ItemConf:getSubType(v.mid)
            if isSub ~= 15 then
                table.insert(mData,v)
            end
        end
        data = mData
    else
        data = cache.PackCache:getShengYinData()
    end
    for k,v in pairs(data) do
        table.insert(self.packData,v)
    end
    table.sort(self.packData,function(a,b)
        local aconf = conf.ItemConf:getItem(a.mid)
        local bconf = conf.ItemConf:getItem(b.mid)
        
        local acolor = aconf.color
        local bcolor = bconf.color
        
        local apart = aconf.part
        local bpart = bconf.part

        local ajie = aconf.stage_lvl or 0
        local bjie = bconf.stage_lvl or 0

        if acolor ~= bcolor then
            return acolor > bcolor 
        elseif ajie ~= bjie then
            return ajie > bjie 
        elseif apart ~= bpart then
            return apart > bpart 
        end
    end)
    -- printt("分解背包数据",self.packData)
    
    self.selectData = self:getSelectShengYin()

    self:getEquipExp(self.selectData) --计算所选装备可加的经验

    self.listView.numItems = math.max((math.ceil(#self.packData/40)*40),40)
end

function ShengYinResolve:cellData( index,obj )
    local data = self.packData[index+1]
    local item = obj:GetChild("n5")
    if data then
        item.visible = true
        local mid = data.mid
        local info = {mid = mid,amount = amount,bind = data.bind,colorAttris = data.colorAttris,isquan = true}
        GSetItemData(item,info,false)
        
        local flag = false
        for k,v in pairs(self.selectData) do
            if v.index == data.index then
                flag = true
                break
            end
        end
        obj.selected = flag
        obj.touchable = true
        obj.data = {data = data}
        obj.onClick:Add(self.onClickSelect,self)
    else
        obj.selected = false
        obj.touchable = false
        item.visible = false
    end
end

function ShengYinResolve:onClickSelect(context)
    local cell = context.sender
    local data = cell.data

    local flag = true
    local key = 0
    for k,v in pairs(self.selectData) do
        if v.index == data.data.index and not cell.selected then
            flag = false
            key = k
            break
        end
    end
    if not flag then
        table.remove(self.selectData,key)
    else
        if cell.selected then
            table.insert(self.selectData,data.data)
        end
    end
    self:getEquipExp(self.selectData)
end
--获取选择的圣印
function ShengYinResolve:getSelectShengYin()
    local data = {}
    local t = clone(self.packData)
    for k,v in pairs(t) do
        local color = conf.ItemConf:getQuality(v.mid)
        local stageLvl = conf.ItemConf:getStagelvl(v.mid)
        if self.jie == 0 then--任意品阶
            if color <= self.color then
                table.insert(data,v)
            end
        else
            if stageLvl <= self.jie then
                if color <= self.color then
                    table.insert(data,v)
                end
            end
        end
    end
    return data
end

function ShengYinResolve:getEquipExp(equipData)
    local addExp = 0
    local addPro1 = 0
    local addPro2 = 0
    if self.isEightElE then
        for k,v in pairs(equipData) do
            local amount = 1
            if v.amount then
                amount = v.amount
            end
            local spltData = conf.EightGatesConf:getSplitExp(v.mid)
            local score = spltData and spltData.score or 0
            local subType = conf.ItemConf:getSubType(v.mid)
            local strengScoreConfData = conf.EightGatesConf:getStrengInfo(subType,v.level)
            local strengScore = strengScoreConfData.fanhuan
            if not spltData then
                print("分解表没有",v.mid)
            end
            addExp = addExp + (score + strengScore)*amount
            addPro1 = addPro1 + self:getStepMateialNum1(conf.ItemConf:getStagelvl(v.mid))
            addPro2 = addPro2 + self:getStepMateialNum2(conf.ItemConf:getStagelvl(v.mid))
        end
        self.view:GetChild("n20").text = addExp
        self.view:GetChild("n24").text = addPro1
        self.view:GetChild("n27").text = addPro2
    else
        for k,v in pairs(equipData) do
            local amount = 1
            if v.amount then
                amount = v.amount
            end
            local spltData = conf.ShengYinConf:getSplitExp(v.mid)
            local partnerNum = spltData.items[1][2]
            addExp = addExp + partnerNum*amount
        end
        self.view:GetChild("n20").text = addExp
    end
end
--八门分解获取进阶材料
function ShengYinResolve:getStepMateialNum1(stage)
    local num = 0
    local confData = conf.EightGatesConf:getStep()
    for k,v in pairs(confData) do
        if stage == v.level then
            if v.fanhuan and v.fanhuan[1] then
                num = num + v.fanhuan[1][2]
            end
        end
    end
    return num
end
function ShengYinResolve:getStepMateialNum2(stage)
    local num = 0
    local confData = conf.EightGatesConf:getStep()
    for k,v in pairs(confData) do
        if stage == v.level then
            if v.fanhuan  and v.fanhuan[2]  then
                num = num + v.fanhuan[2][2]
            end
        end
    end
    return num
end


function ShengYinResolve:cellPanelData(index,obj)
    obj.data = index + 1
    if self.isEightElE then
        obj.title = language.eightgates05[self.call][index+1]
    else
        obj.title = language.shengyin05[self.call][index+1]
    end
end

function ShengYinResolve:onlistPanel(context)
    local data = context.data.data
    if self.call == 1 then
        self.jie = data - 1
    elseif self.call == 2 then
        if self.isEightElE then
            self.color = data + 2
        else
            self.color = data + 3
        end
    end
    if self.isEightElE then
        self.jieTxt.text = language.eightgates05[1][self.jie+1]
        self.colorTxt.text = language.eightgates05[2][self.color-2]
    else
        self.jieTxt.text = language.shengyin05[1][self.jie+1]
        self.colorTxt.text = language.shengyin05[2][self.color-3]
    end
    self:refeshList()
    self.Panel.visible = false
end

--等阶筛选
function ShengYinResolve:onClickLevCal(context)
    local btn = context.sender 
    if self.call and self.call == 1 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 1
    self:callset(btn)
end

--品质筛选
function ShengYinResolve:onClickColorCal(context)
    local btn = context.sender 
    if self.call and self.call == 2 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 2
    self:callset(btn)
end

function ShengYinResolve:callset(btn)
    self.Panel.x = btn.x - self.Panel.width + btn.width + 8
    self.Panel.y = btn.y - self.Panel.height
    self.Panel.visible = true
    local temp = 0
    if self.isEightElE then
        temp = 3
        self.listPanel.numItems = #language.eightgates05[self.call]
    else
        temp = 4
        self.listPanel.numItems = #language.shengyin05[self.call]
    end
    if self.call == 1 then
        self.listPanel:AddSelection(self.jie,false)
    else
        self.listPanel:AddSelection(self.color-temp,false)
    end
end

--确认分解
function ShengYinResolve:onClickFenjie(context)
    local data = {}
    local flag = false
    for k,v in pairs(self.selectData) do
        table.insert(data,v.index)
    end
    local msgId = self.isEightElE and 1610104 or 1600104
    local str = self.isEightElE and language.eightgates08 or language.shengyin06
    if #data > 0 then
        proxy.AwakenProxy:sendMsg(msgId,{indexs = data})
    else
        GComAlter(str)
    end
end

function ShengYinResolve:setData(data)

end

function ShengYinResolve:onClickRule()
    if self.isEightElE then
        GOpenRuleView(1156)
    else
        GOpenRuleView(1143)
    end
end


return ShengYinResolve