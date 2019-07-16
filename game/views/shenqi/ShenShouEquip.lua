--
-- Author: Your Name
-- Date: 2018-09-03 21:33:31
--神兽装备穿戴
local ShenShouEquip = class("ShenShouEquip", base.BaseView)

function ShenShouEquip:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function ShenShouEquip:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    
    local guizeBtn = self.view:GetChild("n9")
    guizeBtn.onClick:Add(self.onClickGuize,self)

    self.equipsList = {}
    for i=4,8 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.equipsList,item)
    end

    self.listView = self.view:GetChild("n11")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.shenshouIcon = self.view:GetChild("n2")

    --筛选按钮
    local starBtn = self.view:GetChild("n12")--星级筛选按钮
    self.starTxt = starBtn:GetChild("n1")
    starBtn.onClick:Add(self.onClickStarCal,self)
    local colorBtn = self.view:GetChild("n17")--品质筛选按钮
    self.colorTxt = colorBtn:GetChild("n1")
    colorBtn.onClick:Add(self.onClickColorCal,self)
    --筛选组件
    self.Panel = self.view:GetChild("n16")
    self.listPanel = self.view:GetChild("n15")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)
    --装备获取跳转
    local getEquipBtn = self.view:GetChild("n18")
    getEquipBtn.onClick:Add(self.onClickGetEquip,self)
    --助战特效
    self.effectPanel = self.view:GetChild("n19")
end

--等阶筛选
function ShenShouEquip:onClickStarCal(context)
    local btn = context.sender 
    if self.call and self.call == 1 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 1
    self:callset(btn)
end
--品质筛选
function ShenShouEquip:onClickColorCal(context)
    local btn = context.sender 
    if self.call and self.call == 2 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 2
    self:callset(btn)
end

function ShenShouEquip:callset(btn)
    self.Panel.x = btn.x - self.Panel.width + btn.width + 8
    self.Panel.y = btn.y - self.Panel.height
    self.Panel.visible = true

    self.listPanel.numItems = #language.shenshou14[self.call]
    if self.call == 1 then
        self.listPanel:AddSelection(self.star,false)
    else
        self.listPanel:AddSelection(self.color-2,false)
    end
end

function ShenShouEquip:cellPanelData(index,obj)
    obj.data = index + 1
    obj.title = language.shenshou14[self.call][index+1]
end

function ShenShouEquip:onlistPanel(context)
    local data = context.data.data
    if self.call == 1 then
        self.star = data - 1
    else
        self.color = data + 1
    end
    self.Panel.visible = false
    self.starTxt.text = language.shenshou14[1][self.star+1]
    self.colorTxt.text = language.shenshou14[2][self.color-1]

    self:getIsShowEquips()
    
end

--是否是当前星数
function ShenShouEquip:isNowStar(star)
    if self.star == 0 then
        return true
    else
        return star >= self.star
    end
end

--是否是当前品质
function ShenShouEquip:isNowColor(color)
    if self.color == 2 then
        return true
    else
        return color >= self.color
    end
end

--获取当前要显示的装备
function ShenShouEquip:getIsShowEquips()
    local allEquips = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    self.equipData = {}
    for k,v in pairs(allEquips) do
        local starNums = GGetEquipMaxColorNum(v.colorAttris)
        local color = conf.ItemConf:getQuality(v.mid)
        if self:isNowStar(starNums) and self:isNowColor(color) then
            table.insert(self.equipData,v)
        end
    end
    local number = 16
    self.listView.numItems = math.max((math.ceil(#self.equipData/number)*number),number)
end

--播放助战特效
function ShenShouEquip:playZhuZhanEff()
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effectPanel.visible = true
    self.effect = self:addEffect(4020170, self.effectPanel)
    self.effect.LocalPosition = Vector3.New(0.3,1.45,0)
    self.effect.LocalRotation = Vector3.New(0,180,0)
end

--移除助战特效
function ShenShouEquip:removeEffect()
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
        self.effectPanel.visible = false
    end
end

function ShenShouEquip:initData(data)
    self.Panel.visible = false
    self.data = data
    self.shenshouIcon.url = UIPackage.GetItemURL("shenqi" , data.m_icon)
    if data.equipInfos and #data.equipInfos == 5 then
        self.shenshouIcon.grayed = false
    else        
        self.shenshouIcon.grayed = true
    end
    if data.inWar == 1 then
        self:playZhuZhanEff()
    elseif data.inWar == 0 then
        self:removeEffect()
    end
    self.star = 0--默认所有星级
    self.color = 2--默认所有品质
    self.starTxt.text = language.shenshou14[1][self.star+1]
    self.colorTxt.text = language.shenshou14[2][self.color-1]

    self:getIsShowEquips()
    -- printt("装备>>>>>>>>>>>",self.equipData)
    self:initShenShouEquip()
end

function ShenShouEquip:initShenShouEquip()
    local shenshou = conf.ShenShouConf:getShenShouDataById(self.data.ssId)
    local ssEquips = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)--获取当前背包神兽装备
    for k,v in pairs(self.equipsList) do
        local addImg = v:GetChild("n1")
        local item = v:GetChild("n2")
        local text = v:GetChild("n3")
        local red = v:GetChild("n4")
        red.visible = false
        text.visible = true
        item.onClick:Clear()
        v.onClick:Clear()
        addImg.visible = false
        item.visible = false
        local color = shenshou.active_conf[k][2]
        local str = language.gonggong110[color] .. language.shenshou01[k]
        text.text = mgr.TextMgr:getQualityStr1(str,color)
        for _,eq in pairs(ssEquips) do
            local eqColor = conf.ItemConf:getQuality(eq.mid)
            local part = conf.ItemConf:getPart(eq.mid)
            if eqColor >= color and part == k then
                -- red.visible = true ------屏蔽掉神兽装备上的红点
                break
            end
        end

    end
    local equipData = self.data and self.data.equipInfos or nil
    -- printt("self.data>>>>>>>>>",self.data)
    if equipData then
        for k,v in pairs(equipData) do
            local confdata = conf.ItemConf:getItem(v.mid)
            local equipItem = self.equipsList[confdata.part]
            local addImg = equipItem:GetChild("n1")
            local item = equipItem:GetChild("n2")
            local text = equipItem:GetChild("n3")
            local red = equipItem:GetChild("n4")
            red.visible = false
            text.visible = false
            addImg.visible = false
            v.isquan = true
            GSetItemData(item, v, false)
            equipItem.data = v
            equipItem.onClick:Add(self.onClickOpenEquip,self)
        end
    end
end

function ShenShouEquip:onClickOpenEquip(context)
    local data = context.sender.data
    if data then
        local t = clone(data)
        t.notsenddata = true 
        local confdata = conf.ItemConf:getItem(data.mid)
        GSeeLocalItem(t,{self.data,confdata.part}) 
    end
end

function ShenShouEquip:cellData(index,obj)
    local data = self.equipData[index+1]
    local item = obj:GetChild("n5")
    if data then
        item.visible = true
        data.isquan = true
        GSetItemData(item,data,false)
        obj.data = data
        obj.onClick:Add(self.onClickSee,self)

        local condata = conf.ItemConf:getItem(data.mid)
        local info = cache.ShenShouCache:getEquipDataByPart(self.data,condata.part)
        cache.ShenShouCache:conTrastScore(item,info,data)
    else
        obj.onClick:Clear()
        obj.selected = false
        item.visible = false
    end
end

function ShenShouEquip:onClickSee(context)
    local data = context.sender.data
    if data then
        GSeeLocalItem(data,{self.data,data.part})
    end
end

--神兽穿戴装备刷新
function ShenShouEquip:refreshEquip(data)
    self.listView.numItems = 0
    self.data.equipInfos = data.equipInfos
    if #data.equipInfos < 5 then
        self:removeEffect()
    end
    if data.equipInfos and #data.equipInfos == 5 then
        self.shenshouIcon.grayed = false
    else        
        self.shenshouIcon.grayed = true
    end
    self:getIsShowEquips()
    -- printt("装备>>>>>>>>>>>",self.equipData)
    self:initShenShouEquip()
end

--规则
function ShenShouEquip:onClickGuize()
    GOpenRuleView(1140)
end

--装备获取跳转
function ShenShouEquip:onClickGetEquip()
    GOpenView({id = 1337})
end
return ShenShouEquip