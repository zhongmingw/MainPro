--
-- Author: Your Name
-- Date: 2018-09-03 21:34:58
--神兽装备强化
local ShenShouStrength = class("ShenShouStrength", base.BaseView)

function ShenShouStrength:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ShenShouStrength:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    local guizeBtn = self.view:GetChild("n17")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    --当前神兽装备列表
    self.equipList = self.view:GetChild("n5")
    self.equipList.itemRenderer = function (index,obj)
        self:equipCell(index, obj)
    end
    self.equipList.numItems = 0
    self.equipList:SetVirtual()

    --强化材料列表
    self.materialsList = self.view:GetChild("n26")
    self.materialsList.itemRenderer = function (index,obj)
        self:materialsCell(index, obj)
    end
    self.materialsList.numItems = 0
    self.materialsList:SetVirtual()

    --当前选择装备强化属性列表
    self.attrisList = self.view:GetChild("n25")
    self.attrisList.itemRenderer = function (index,obj)
        self:attrisCell(index, obj)
    end
    self.attrisList.numItems = 0
    self.attrisList:SetVirtual()

    --进度条
    self.progressbar = self.view:GetChild("n33")
    self.decTxt = self.view:GetChild("n23")--下级属性
    --当前强化的装备icon
    self.equipItem = self.view:GetChild("n7")
    --当前装备等级
    self.nowLvTxt = self.view:GetChild("n9")
    --当前装备下一级等级
    self.nextLvTxt = self.view:GetChild("n10")
    --满级后显示等级
    self.fullLevelTxt = self.view:GetChild("n40")

    --强化按钮
    self.strengBtn = self.view:GetChild("n32")
    self.strengBtn.onClick:Add(self.onClickStrength,self)
    --双倍强化
    self.doubelBtn = self.view:GetChild("n27")
    self.doubelBtn.onChanged:Add(self.selelctCheck,self)
    self.ybIcon = self.view:GetChild("n38")
    self.ybNum = self.view:GetChild("n39")
    --筛选品质按钮
    self.filtrateBtn = self.view:GetChild("n21")
    self.filtrateBtn.onClick:Add(self.onClickColorCal,self)
    --筛选组件
    self.Panel = self.view:GetChild("n37")--等阶筛选
    self.listPanel = self.view:GetChild("n36")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)
    --全选复选按钮
    self.getAllBtn = self.view:GetChild("n18")
    self.getAllBtn.onClick:Add(self.onClickGetAll,self)
end

function ShenShouStrength:initData(data)
    self.data = data
    self.equipInfos = data.equipInfos
    self.Panel.visible = false
    
    --当前要强化的装备信息
    self.equipData = nil
    --当前选择的
    self.selectedIndex = 0
    
    --设置右侧信息
    self:setRightInfo()

    
    
    self.doubelBtn.selected = false
    self:selelctCheck()
end

function ShenShouStrength:setRightInfo()
    --当前选择的吞噬材料
    self.selectData = {}
    if self.equipInfos and #self.equipInfos > 0 then
        self.equipList.numItems = #self.equipInfos
        local cell = self.equipList:GetChildAt(self.selectedIndex)
        cell.onClick:Call()
    else
        self.equipList.numItems = 0
        self.equipData = nil
        self:initEquipInfo()
    end
    self.materialsData = self:getSwallowData()--所有可吞噬道具
    self.selectData = self:selectExpPill()
    local number = 12
    self.materialsList.numItems = math.max((math.ceil(#self.materialsData/number)*number),number)
end

--选中经验丹
function ShenShouStrength:selectExpPill()
    local data = {}
    local _t = conf.ShenShouConf:getValue("equip_exp_item")
    for k,v in pairs(self.materialsData) do
        for _,var in pairs(_t) do
            if v.mid == var then
                table.insert(data,v)
                break
            end
        end
    end
    return data
end

function ShenShouStrength:equipCell(index,obj)
    local data = self.equipInfos[index+1]
    if data then
        local confData = conf.ItemConf:getItem(data.mid)
        local item = obj:GetChild("n1")
        local nameTxt = obj:GetChild("n2")
        GSetItemData(item, data, true)
        nameTxt.text = mgr.TextMgr:getQualityStr1(confData.name,conf.ItemConf:getQuality(data.mid))
        data.selectedIndex = index
        obj.data = data
        obj.onClick:Add(self.onClickSelectEquip,self)
    end
end

--选择强化的装备
function ShenShouStrength:onClickSelectEquip(context)
    local data = context.sender.data
    self.selectedIndex = data.selectedIndex
    self.equipData = data
    self.materialsData = self:getSwallowData()
    self.selectData = self:selectExpPill()
    self.materialsList:RefreshVirtualList()
    self:selelctCheck()
    self:initEquipInfo()
    self:getEquipExp(self.selectData)
end
--初始化装备信息
function ShenShouStrength:initEquipInfo()
    if self.equipData then
        self.progressbar.visible = true
        self.equipItem.visible = true
        self.nowLvTxt.visible = true
        self.nextLvTxt.visible = true
        self.fullLevelTxt.visible = false
        self.view:GetChild("n8").visible = true
        local confData = conf.ItemConf:getItem(self.equipData.mid)
        GSetItemData(self.equipItem, self.equipData, true)
        local levelUpConf = conf.ShenShouConf:getEquipLevelUp(self.equipData)
        local nextLvl = self.equipData.level + 1
        local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,nextLvl)
        local nextConf = conf.ShenShouConf:getLevelDataById(qhId)
        if nextConf then
            self.nowLvTxt.text = self.equipData.level
            self.progressbar.value = self.equipData.exp
            self.progressbar.max = levelUpConf.need_exp
            self.nextLvTxt.text = nextLvl
        else
            self.nextLvTxt.visible = false
            self.nowLvTxt.visible = false
            self.progressbar.value = self.equipData.exp
            self.progressbar.max = self.equipData.exp
            local titleTxt = self.progressbar:GetChild("title")
            titleTxt.text = "MAX"
            self.view:GetChild("n8").visible = false
            self.fullLevelTxt.visible = true
            self.fullLevelTxt.text = self.equipData.level
        end
        self:setEquipAttr()
    else
        self.progressbar.visible = false
        self.equipItem.visible = false
        self.nowLvTxt.visible = false
        self.nextLvTxt.visible = false
        self.attrisList.numItems = 0
    end
end

--装备强化属性计算
function ShenShouStrength:setEquipAttr()
    --累计装备属性
    if self.equipData then
        local confData = conf.ItemConf:getItem(self.equipData.mid)
        local nextLvl = self.equipData.level + 1
        local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,nextLvl)
        local nextConf = conf.ShenShouConf:getLevelDataById(qhId)
        if nextConf then
            self.decTxt.text = language.shenshou12
        else
            self.decTxt.text = language.shenshou11
        end
        
        local _equipBase = self:getEquipPro(self.equipData)
        self.attris = mgr.PetMgr:changePercntToBase(_equipBase)
        self.attrisList.numItems = #self.attris
    end
end
--装备强化属性列表
function ShenShouStrength:attrisCell(index,obj)
    local data = self.attris[index+1]
    if data then
        local decTxt = obj:GetChild("n0")
        decTxt.text = conf.RedPointConf:getProName(data[1]) .. "+" .. GProPrecnt(data[1],data[2])
    end
end

function ShenShouStrength:getEquipPro(data)
    if not data then
        return {}
    end
    local t = {}
    if data.level >= 0 then
        local confData = conf.ItemConf:getItem(data.mid)
        local nextLvl = data.level + 1
        local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,nextLvl)
        local nextConf = conf.ShenShouConf:getLevelDataById(qhId)
        if nextConf then
            t = GConfDataSort(nextConf)
        else
            t = GConfDataSort(conf.ShenShouConf:getEquipLevelUp(data))
        end
    end
    
    local t1 = GConfDataSort(conf.ItemArriConf:getItemAtt(data.mid))
    G_composeData(t,t1)
    return t
end

--筛选列表
function ShenShouStrength:cellPanelData(index,obj)
    obj.data = index + 1
    obj.title = language.shenshou13[index+1]
end
function ShenShouStrength:onlistPanel(context)
    local data = context.data.data
    self.color = data + 1
    self.Panel.visible = false
    self.selectData = {}
    if self.color > 2 then
        for k,v in pairs(self.materialsData) do
            local confData = conf.ItemConf:getItem(v.mid)
            if confData.color <= self.color then
                table.insert(self.selectData,v)
            end
        end
        self.getAllBtn.selected = false
    else
        self.selectData = self.materialsData
        self.getAllBtn.selected = true
    end
    self:getEquipExp(self.selectData)
    self:selelctCheck()
    self.filtrateBtn:GetChild("n1").text = language.shenshou13[self.color-1]
    local number = 12
    self.materialsList.numItems = math.max((math.ceil(#self.materialsData/number)*number),number)
end
--品质筛选
function ShenShouStrength:onClickColorCal(context)
    local btn = context.sender 
    if self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.Panel.x = btn.x - self.Panel.width + btn.width + 8
    self.Panel.y = btn.y - self.Panel.height
    self.Panel.visible = true
    self.listPanel.numItems = #language.shenshou13
    -- self.listPanel:AddSelection(self.color-3,false)
end

function ShenShouStrength:materialsCell(index,obj)
    local data = self.materialsData[index+1]
    local item = obj:GetChild("n5")
    if data then
        item.visible = true
        local mid = data.mid
        local amount = data.amount
        local info = {mid = mid,amount = amount,bind = data.bind,colorAttris = data.colorAttris,isArrow = data.isArrow,isquan = true}
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
        -- obj.onClick:Clear()
        obj.touchable = false
        obj.selected = false
        item.visible = false
    end
end

function ShenShouStrength:onClickSelect(context)
    local cell = context.sender
    local data = cell.data
    -- print("选择>>>>>>>>>>>",cell.selected)
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
    -- print("选择装备",cell.selected,data.data.index,#self.selectData)

    self:getEquipExp(self.selectData)
    self:selelctCheck()
end

function ShenShouStrength:getEquipExp(data)
    local addExp = 0
    for k,v in pairs(data) do
        local confData = conf.ItemConf:getItem(v.mid)
        if confData.type == Pack.shenshouEquipType then--装备
            if self.doubelBtn.selected then--双倍
                if v.level <= 0 and v.exp <= 0 then
                    addExp = addExp + confData.partner_exp*2
                else
                    addExp = addExp + confData.partner_exp + v.exp
                end
            else
                addExp = addExp + confData.partner_exp + v.exp
            end
            if v.level > 0 then
                for i=1,v.level do
                    local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,i-1)
                    local confdata = conf.ShenShouConf:getLevelDataById(qhId)
                    addExp = addExp + confdata.need_exp
                end
            end
        else--经验丹
            local amount = 1
            if v.amount then
                amount = v.amount
            end
            if self.doubelBtn.selected then
                addExp = addExp + confData.ext01*2*amount
            else
                addExp = addExp + confData.ext01*amount
            end
        end
    end
    if self.equipData then
        local confData = conf.ItemConf:getItem(self.equipData.mid)
        local nextLvl = self.equipData.level + 1
        local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,nextLvl)
        local nextConf = conf.ShenShouConf:getLevelDataById(qhId)
        local titleTxt = self.progressbar:GetChild("title")
        if nextConf then
            local textData = {
                {text = self.progressbar.value,color = 5},
                {text = "+" .. addExp,color = 10},
                {text = "/" .. self.progressbar.max,color = 5},
            }
            titleTxt.text = mgr.TextMgr:getTextByTable(textData)
        else
            titleTxt.text = "MAX"
        end
    end
    return addExp
end

-- 变量名：ssId    说明：神兽id
-- 变量名：part    说明：部位
-- 变量名：doubleExp   说明：=1 双倍经验
-- 变量名：indexs  说明：消耗材料列表
function ShenShouStrength:onClickStrength()
    if not self.equipData then
        GComAlter(language.shenshou06)
        return
    end
    if #self.selectData <= 0 then
        GComAlter(language.shenshou07)
        return
    end
    local confData = conf.ItemConf:getItem(self.equipData.mid)
    local nextLvl = self.equipData.level + 1
    local qhId = string.format("1%02d%02d%03d",confData.color,confData.part,nextLvl)
    local nextConf = conf.ShenShouConf:getLevelDataById(qhId)
    if not nextConf then
        GComAlter(language.shenshou17)
        return
    end
    local equipConf = conf.ItemConf:getItem(self.equipData.mid)
    local param = {}
    param.ssId = self.data.ssId
    param.part = equipConf.part
    param.doubleExp = 0
    param.indexs = {}
    for k,v in pairs(self.selectData) do
        table.insert(param.indexs,v.index)
    end
    if self.doubelBtn.selected then
        param.doubleExp = 1
        param.costYb = self.ybNum.text
        mgr.ViewMgr:openView2(ViewName.ShenShouStrengthTips, param)
    else
        proxy.ShenShouProxy:sendMsg(1590105,param)
    end
end

--双倍熟练度复选按钮
function ShenShouStrength:selelctCheck()
    if self.doubelBtn.selected then
        self.ybIcon.visible = true
        self.ybNum.visible = true
        local ybCost = 0
        for k,v in pairs(self.selectData) do
            local confData = conf.ItemConf:getItem(v.mid)
            if confData.type == Pack.shenshouEquipType then--装备
                if v.level <= 0 and v.exp <= 0 then
                    local confData = conf.ItemConf:getItem(v.mid)
                    ybCost = ybCost + confData.buy_price
                end
            else
                ybCost = ybCost + confData.buy_price*v.amount
            end
        end
        self.ybNum.text = ybCost
        self:getEquipExp(self.selectData)
    else
        self:getEquipExp(self.selectData)
        self.ybIcon.visible = false
        self.ybNum.visible = false
    end
end

--全部选择
function ShenShouStrength:onClickGetAll()
    if self.getAllBtn.selected then
        self.selectData = self:getSwallowData()
        self.filtrateBtn:GetChild("n1").text = language.shenshou13[1]
    else
        self.selectData = {}
    end
    self:getEquipExp(self.selectData)
    self.materialsList:RefreshVirtualList()
end

-- 变量名：ssId    说明：神兽id
-- 变量名：part    说明：部位
-- 变量名：level   说明：装备等级
-- 变量名：exp 说明：装备经验
--强化后刷新
function ShenShouStrength:refreshData(data)
    if self.equipInfos then
        for k,v in pairs(self.equipInfos) do
            local confData = conf.ItemConf:getItem(v.mid)
            if confData.part == data.part then
                self.equipInfos[k].level = data.level
                self.equipInfos[k].exp = data.exp
                break
            end
        end
    end
    self.materialsList.numItems = 0
    self:setRightInfo()
end

--获取可吞噬道具
function ShenShouStrength:getSwallowData()
    local packData = cache.PackCache:getPackData()
    local data = {}
    for k,v in pairs(packData) do
        local itemType = conf.ItemConf:getType(v.mid)
        if itemType == Pack.shenshouEquipType  then
            local confData = clone(conf.ItemConf:getItem(v.mid))
            local flag = true
            flag =  confData.color < 7 and true or false
            if flag then
                confData.mid = v.mid
                confData.index = v.index
                confData.bind = v.bind
                confData.colorAttris = v.colorAttris
                confData.isArrow = true
                confData.colorBNum = GGetEquipMaxColorNum(v.colorAttris)
                confData.exp = v.exp or 0
                confData.level = v.level or 0
                confData.amount = v.amount
                table.insert(data,confData)
            end
        else
            --经验丹也算入
            local _t = conf.ShenShouConf:getValue("equip_exp_item")
            for _,var in pairs(_t) do
                if v.mid == var then
                    local confData = clone(conf.ItemConf:getItem(v.mid))
                    confData.index = v.index
                    confData.bind = v.bind
                    confData.mid = v.mid
                    confData.amount = v.amount
                    confData.partner_exp = confData.ext01
                    table.insert(data,confData)
                    break
                end
            end
        end
    end
    table.sort(data,function(a,b)
        if a.type ~= b.type then
            return a.type < b.type 
        elseif a.bind ~= b.bind then
            return a.bind > b.bind
        elseif a.color ~= b.color then
            return a.color > b.color
        elseif a.colorBNum ~= b.colorBNum then
            return a.colorBNum > b.colorBNum
        elseif a.part ~= b.part then
            return a.part < b.part
        end
    end)
    return data
end

--规则
function ShenShouStrength:onClickGuize()
    GOpenRuleView(1141)
end

return ShenShouStrength