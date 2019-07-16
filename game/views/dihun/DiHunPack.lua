--
-- Author: 
-- Date: 2018-11-26 21:07:24
--

local DiHunPack = class("DiHunPack", base.BaseView)

function DiHunPack:ctor()
    DiHunPack.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale

end

function DiHunPack:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)

    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    --材料
    self.materialList = self.view:GetChild("n14")
    self.materialList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    --种类
    self.typeTxt = self.view:GetChild("n17")
       --筛选组件
    self.Panel = self.view:GetChild("n7")
    self.listPanel = self.view:GetChild("n6")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)

    local btn = self.view:GetChild("n16")--筛选按钮
    btn.onClick:Add(self.onClickChooseBtn,self)

    self.resolveList = self.view:GetChild("n19")
    self.resolveList:SetVirtual()
    self.resolveList.itemRenderer = function(index,obj)
        self:cellResolveData(index, obj)
    end
    local fenjieBtn = self.view:GetChild("n20")
    fenjieBtn.onClick:Add(self.onFenjie,self)

end

function DiHunPack:initData(data)
    self.splitIdList = conf.DiHunConf:getValue("split_id")
    self.c1.selectedIndex = 0
    self.Panel.visible = false
    self.subType = data and data.subType and data.subType or 0--所有类型
    self.color = 3--蓝色开始
    self:onController1()
end

function DiHunPack:onController1()
    self.Panel.visible = false
    if self.c1.selectedIndex == 0 then--背包
        self.typeTxt.text = language.dihun01[self.subType+1]
    else--分解
        self.typeTxt.text = language.dihun02[self.color-2]
    end
    self:refeshList()
end
function DiHunPack:refeshList()
    -- printt("背包",cache.PackCache:getDiHunPackData())
    if self.c1.selectedIndex == 0 then--背包
        --筛选出的背包数据
        self.selectPackData = self:getSelectData()
        table.sort(self.selectPackData,function(a,b)
            local aconf = conf.ItemConf:getItem(a.mid)
            local bconf = conf.ItemConf:getItem(b.mid)
            
            local acolor = aconf.color
            local bcolor = bconf.color
            
            local apart = aconf.part
            local bpart = bconf.part

            if acolor ~= bcolor then
                return acolor > bcolor 
            elseif apart ~= bpart then
                return apart < bpart 
            end
        end)
        self.listView.numItems = conf.DiHunConf:getValue("pack_max")
  
    else
        self.packData = {}
        local t = cache.PackCache:getDiHunPackData()
        for k,v in pairs(t) do
            table.insert(self.packData,v)
        end
        table.sort(self.packData,function(a,b)
            local aconf = conf.ItemConf:getItem(a.mid)
            local bconf = conf.ItemConf:getItem(b.mid)
            
            local acolor = aconf.color
            local bcolor = bconf.color
            
            local apart = aconf.part
            local bpart = bconf.part

            if acolor ~= bcolor then
                return acolor > bcolor 
            elseif apart ~= bpart then
                return apart < bpart 
            end
        end)
        self.selectResolve = self:getResolveHunShi()
        self:getEquipExp(self.selectResolve) --计算所选装备可加的经验
        self.resolveList.numItems = math.max((math.ceil(#self.packData/40)*40),40)
    end
    self.score = cache.DiHunCache:getScore()
  
    self.materialList.numItems = table.nums(self.score)
end
--筛选背包
function DiHunPack:getSelectData()
    local mData = {}
    local data = cache.PackCache:getDiHunPackData()
    for k,v in pairs(data) do
        local sub_type = conf.ItemConf:getSubType(v.mid)
        if self.subType == 0 then
            table.insert(mData,v)
        elseif self.subType  ==  sub_type then
            table.insert(mData,v)
        end
    end
    return mData
end

--获取选择分解的魂饰
function DiHunPack:getResolveHunShi()
    local mData = {}
    local data = cache.PackCache:getDiHunPackData()
    local t = clone(data)
    for k,v in pairs(t) do
        local color = conf.ItemConf:getQuality(v.mid)
        if color <= self.color then
            table.insert(mData,v)
        end
    end
    return mData
end

--材料
function DiHunPack:cellData(index,obj)
    local data = self.score[index+3]--这个self.score下标是从3品质开始
    local icon = obj:GetChild("n9")
    local num = obj:GetChild("n10")
    if data then
        local src = conf.ItemConf:getSrc(self.splitIdList[index+1])
        icon.url = ResPath.iconRes(tostring(src))
        if self.c1.selectedIndex == 0 then
            num.text = data
        end
    end
    if self.c1.selectedIndex == 1 then
        local splitScore = self.splitScore[index+3] or 0
        local str = splitScore == 0 and "" or "+"..splitScore
        num.text = data..mgr.TextMgr:getTextColorStr(str,7)
    end
end

function DiHunPack:onClickChooseBtn(context)
    local btn = context.sender 
    self.Panel.x = btn.x - self.Panel.width + btn.width - 2
    self.Panel.y = btn.y - self.Panel.height
    self.Panel.visible = not self.Panel.visible
    if self.c1.selectedIndex == 0 then--背包
        self.listPanel.numItems = #language.dihun01
        self.listPanel:AddSelection(self.subType,false)
    else--分解
        self.listPanel.numItems = #language.dihun02
        self.listPanel:AddSelection(self.color-3,false)
    end
end
--筛选
function DiHunPack:cellPanelData(index,obj)
    obj.data = index + 1
    if self.c1.selectedIndex == 0 then--背包
        obj.title = language.dihun01[index+1]
    else
        obj.title = language.dihun02[index+1]
    end
end
--点击筛选
function DiHunPack:onlistPanel(context)
    local data = context.data.data
    if self.c1.selectedIndex == 0 then--背包
        self.subType = data -1
        -- print("self.subType",self.subType)    
        self.typeTxt.text = language.dihun01[data]
        self:refeshList()
    else
        self.color = data + 2
        -- print("self.color",self.color)    
        self.typeTxt.text = language.dihun02[data]
        self:refeshList()
    end
    self.Panel.visible = false
end
--背包
function DiHunPack:cellPackData(index,obj)
    local data = self.selectPackData[index+1]
    if data then
        local info = clone(data)
        info.isquan = true
        info.isArrow = true
        GSetItemData(obj:GetChild("n5"),info,true)
    else
        GSetItemData(obj:GetChild("n5"),{})
    end
end

--分解背包
function DiHunPack:cellResolveData(index,obj)
    local data = self.packData[index+1]
    local item = obj:GetChild("n5")
    if data then
        item.visible = true
        local mid = data.mid
        local info = {mid = mid,amount = amount,bind = data.bind,colorAttris = data.colorAttris,isquan = true}
        GSetItemData(item,info,false)
        
        local flag = false
        for k,v in pairs(self.selectResolve) do
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


function DiHunPack:onClickSelect(context)
    local cell = context.sender
    local data = cell.data
    local flag = true
    local key = 0
    for k,v in pairs(self.selectResolve) do
        if v.index == data.data.index and not cell.selected then
            flag = false
            key = k
            break
        end
    end
    if not flag then
        table.remove(self.selectResolve,key)
    else
        if cell.selected then
            table.insert(self.selectResolve,data.data)
        end
    end
    self:getEquipExp(self.selectResolve)
end

function DiHunPack:getEquipExp(equipData)
    local score = {}
    for k,v in pairs(self.splitIdList) do
        local quality = conf.ItemConf:getQuality(v)
        if not score[quality] then
            score[quality] = {}
        end
    end
    for k,v in pairs(equipData) do
        local splitConf = conf.DiHunConf:getSplitExp(v.mid)
        if splitConf then
            local quality = conf.ItemConf:getQuality(splitConf.items[1][1])
            table.insert(score[quality],splitConf.items[1][2])
        end
    end
    self.splitScore = {}
    for k,v in pairs(score) do
        self.splitScore[k]= self:addNum(v)
    end
    self.materialList.numItems = table.nums(self.score)
end

function DiHunPack:addNum(v)
    local add = 0
    for i,j in pairs(v) do
        add = add +j 
    end
    return add
end
function DiHunPack:onFenjie()
    local data = {}
    for k,v in pairs(self.selectResolve) do
        table.insert(data,v.index)
    end
    if #data > 0 then
        proxy.DiHunProxy:sendMsg(1620106,{indexs = data})
    else
        GComAlter(language.dihun08)
    end
end

return DiHunPack