--
-- Author: Your Name
-- Date: 2018-09-03 14:20:51
--

local ShenShouPanel = class("ShenShouPanel", import("game.base.Ref"))

function ShenShouPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n16")
    self:initView()
end

function ShenShouPanel:initView()
    local guizeBtn = self.view:GetChild("n9")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.shenshouList = self.view:GetChild("n10")
    self.shenshouList.itemRenderer = function (index,obj)
        self:shenShouCell(index, obj)
    end
    self.shenshouList.numItems = 0
    -- self.shenshouList:SetVirtual()
    self.equipList = {}
    for i=25,29 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.equipList,item)
        item.onClick:Add(self.onClickOpenEquip,self)
    end
    self.selectData = nil
    self.selectedIndex = 0--当前选择神兽  默认先选第一个
    --神兽装备按钮
    local equipBtn = self.view:GetChild("n22")
    equipBtn.onClick:Add(self.onClickOpenEquip,self)
    --助战按钮
    self.zhuzhanBtn = self.view:GetChild("n23")
    self.zhuzhanBtn.data = 1
    self.zhuzhanBtn.onClick:Add(self.onClickZhuZhan,self)
    --召回按钮
    self.zhaohuiBtn = self.view:GetChild("n24")
    self.zhaohuiBtn.data = 0
    self.zhaohuiBtn.onClick:Add(self.onClickZhuZhan,self)
    --属性列表
    self.attrsList = self.view:GetChild("n11")
    self.attrsList.itemRenderer = function (index,obj)
        self:attrCellData(index, obj)
    end
    self.attrsList.numItems = 0
    self.attrsList:SetVirtual()
    --技能列表
    self.skillList = self.view:GetChild("n12")
    self.skillList.itemRenderer = function (index,obj)
        self:skillCellData(index, obj)
    end
    self.skillList.numItems = 0
    self.skillList:SetVirtual()
    --强化
    self.strengthBtn = self.view:GetChild("n21")
    self.strengthBtn.onClick:Add(self.onClickStrength,self)
    --神兽Icon
    self.shenshouIcon = self.view:GetChild("n2")
    --助战数量
    self.zhuzhanNum = self.view:GetChild("n18")
    --助战数量提升按钮
    self.addZhuzhanBtn = self.view:GetChild("n17")
    self.addZhuzhanBtn.onClick:Add(self.onClickAddCount,self)
    --一键卸下按钮
    self.allDischarge = self.view:GetChild("n20")
    self.allDischarge.onClick:Add(self.onClickAllDischarge,self)
    --助战特效
    self.effectPanel = self.view:GetChild("n30")
end

-- 1   int32   变量名: ssId   说明: 神兽id
-- 2   array<ItemInfo> 变量名: equipInfos  说明: 装备信息
-- 3   int32   变量名: power  说明: 战力
-- 4   int8    变量名: inWar  说明: =1助战
function ShenShouPanel:setData(data)
    -- printt("神兽信息>>>>>>>>>>",data)
    self.holeCount = data.holeCount --当前上阵位总数
    self.shenShouInfos = data.shenShouInfos
    self.shenShouData = conf.ShenShouConf:getShenShouData()
    for k,v in pairs(self.shenShouData) do
        local flag,info = self:isHasEquips(v.id)
        if flag then
            self.shenShouData[k].ssId = info.ssId
            self.shenShouData[k].equipInfos = info.equipInfos
            self.shenShouData[k].power = info.power
            self.shenShouData[k].inWar = info.inWar
        else
            self.shenShouData[k].ssId = v.id
            self.shenShouData[k].equipInfos = nil
            self.shenShouData[k].power = nil
            self.shenShouData[k].inWar = 0
        end
    end
    self.shenshouList.numItems = #self.shenShouData

    self.zhuzhanNum.text = self:getIsBattleNum() .. "/" .. self.holeCount

    self.selectData = self.shenShouData[self.selectedIndex+1]
    if self.selectData then
        local cell = self.shenshouList:GetChildAt(self.selectedIndex)
        cell.onClick:Call()
    end
end

--判断当前神兽是否有装备信息
function ShenShouPanel:isHasEquips(ssId)
    local flag = false
    local info = nil
    for k,v in pairs(self.shenShouInfos) do
        if v.ssId == ssId then
            flag = true
            info = v
            break
        end
    end
    return flag,info
end

--当前已上阵数量
function ShenShouPanel:getIsBattleNum()
    local num = 0
    for k,v in pairs(self.shenShouData) do
        if v.inWar == 1 then
            num = num + 1
        end
    end
    return num
end

--左侧神兽列表
function ShenShouPanel:shenShouCell(index,obj)
    local data = self.shenShouData[index+1]
    if data then
        local nameTxt = obj:GetChild("n2")
        local scoreTxt = obj:GetChild("n3")
        local icon = obj:GetChild("n0"):GetChild("icon")
        local zhuzhanImg = obj:GetChild("n5")
        local red = obj:GetChild("n6")
        red.visible = false
        icon.url = UIPackage.GetItemURL("shenqi" , data.s_icon)
        if data.equipInfos and #data.equipInfos >= 5 then
            nameTxt.text = mgr.TextMgr:getTextColorStr(data.name,6)
            scoreTxt.text = mgr.TextMgr:getTextColorStr(language.powerRanking01_1 .. (data.power or data.scores),7)
            icon.grayed = false
        else
            nameTxt.text = mgr.TextMgr:getTextColorStr(data.name,8)
            scoreTxt.text = mgr.TextMgr:getTextColorStr(language.powerRanking01_1 .. (data.power or data.scores),8)
            icon.grayed = true
        end

        if self:isHasEquipRed(data) or cache.ShenShouCache:presentPromote(data) then--有可穿戴装备或战力更高的装备
            if self:getIsBattleNum() < self.holeCount then
                red.visible = true
            else
                if data.inWar == 1 then
                    red.visible = true
                else
                    red.visible = false
                end
            end
        end
        if (data.inWar ~= 1 and data.equipInfos and #data.equipInfos == 5) and self:getIsBattleNum() < self.holeCount then--当前可助战
            red.visible = true
        end
        if data.inWar == 1 then
            zhuzhanImg.visible = true
        else
            zhuzhanImg.visible = false
        end
        data.selectedIndex = index
        obj.data = data
        obj.onClick:Add(self.onClickSelect,self)
    end
end

--当前选择的神兽
function ShenShouPanel:onClickSelect(context)
    local data = context.sender.data
    self.selectData = data
    self.selectedIndex = data.selectedIndex
    self:initShenShouEquip()
    self.shenshouIcon.url = UIPackage.GetItemURL("shenqi" , data.m_icon)
    --助战召回按钮显示
    if data.inWar == 1 then
        self.zhaohuiBtn.visible = true
        self.zhuzhanBtn.visible = false
        self:playZhuZhanEff()
    elseif data.inWar == 0 then
        self.zhaohuiBtn.visible = false
        self.zhuzhanBtn.visible = true
        self:removeEffect()
        --助战按钮红点
        if data.equipInfos and #data.equipInfos == 5 and self:getIsBattleNum() < self.holeCount then
            self.zhuzhanBtn:GetChild("red").visible = true
        else
            self.zhuzhanBtn:GetChild("red").visible = false
        end
    end
    if data.equipInfos and #data.equipInfos == 5 then
        self.shenshouIcon.grayed = false
    else
        self.shenshouIcon.grayed = true
    end
    if not data.equipInfos or #data.equipInfos == 0 then
        self.allDischarge.visible = false
    else
        self.allDischarge.visible = true
    end
    self:setShenShouAttr()
    self:setShenShouSkils()
end

--所选神兽装备
function ShenShouPanel:initShenShouEquip()
    if self.selectData then
        local shenshou = conf.ShenShouConf:getShenShouDataById(self.selectData.ssId)
        local ssEquips = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)--获取当前背包神兽装备
        for k,v in pairs(self.equipList) do
            local addImg = v:GetChild("n1")
            local item = v:GetChild("n2")
            local red = v:GetChild("n4")
            addImg.visible = true
            item.visible = false
            red.visible = false
            local color = shenshou.active_conf[k][2]
            for _,eq in pairs(ssEquips) do
                local eqColor = conf.ItemConf:getQuality(eq.mid)
                local part = conf.ItemConf:getPart(eq.mid)
                if eqColor >= color and part == k then
                    -- red.visible = true ----屏蔽掉神兽装备上的红点
                    break
                end
            end
            if self:getIsBattleNum() >= self.holeCount then--助战位满了后不显示红点
                red.visible = false
            end
        end
        local equipData = self.selectData and self.selectData.equipInfos or nil
        -- printt("self.selectData>>>>>>>>>",self.selectData)
        if equipData then
            for k,v in pairs(equipData) do
                local confdata = conf.ItemConf:getItem(v.mid)
                local equipItem = self.equipList[confdata.part]
                local addImg = equipItem:GetChild("n1")
                local item = equipItem:GetChild("n2")
                local red = equipItem:GetChild("n4")
                red.visible = false
                addImg.visible = false
                v.isquan = true
                GSetItemData(item, v, false)
            end
        end
    end
end

--是否有可穿戴装备
function ShenShouPanel:isHasEquipRed(shenshouData)
    if shenshouData then
        local equipData = shenshouData.equipInfos
        local shenshou = conf.ShenShouConf:getShenShouDataById(shenshouData.ssId)
        local ssEquips = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)--获取当前背包神兽装备
        local flag = false
        for _,v in pairs(shenshou.active_conf) do
            local part = v[1]
            local color = v[2]
            if not equipData or not self:isWearByPart(equipData,part) then--当前部位没有穿戴装备
                for _,eq in pairs(ssEquips) do
                    local eqColor = conf.ItemConf:getQuality(eq.mid)
                    local eqPart = conf.ItemConf:getPart(eq.mid)
                    if eqColor >= color and eqPart == part then
                        flag = true
                        break
                    end
                end
            end
        end
        return flag
    end
end
--当前部位是否穿戴装备
function ShenShouPanel:isWearByPart(equipData,part)
    local flag = false
    for k,v in pairs(equipData) do
        local p = conf.ItemConf:getPart(v.mid)
        if p == part then
            flag = true
            break
        end
    end
    return flag
end

--神兽属性
function ShenShouPanel:setShenShouAttr()
    if self.selectData then
        --神兽属性
        local confData = conf.ShenShouConf:getShenShouDataById(self.selectData.ssId)
        local protable = GConfDataSort(confData)
        for k , v in pairs(protable) do
            protable[k][2] = v[2]
        end

        --累计装备属性
        if self.selectData.equipInfos then
            for k ,v in pairs(self.selectData.equipInfos) do
                local _equipBase = cache.ShenShouCache:getEquipPro(v)
                G_composeData(protable,_equipBase)
            end
        end
        self.attris = mgr.PetMgr:changePercntToBase(protable)
        -- printt("属性>>>>>>>>>>>>>",t)
        self.attrsList.numItems = #self.attris
    end
end

--属性列表
function ShenShouPanel:attrCellData(index,obj)
    local data = self.attris[index+1]
    if data then
        local decTxt = obj:GetChild("n0")
        decTxt.text = conf.RedPointConf:getProName(data[1]) .. "+" .. GProPrecnt(data[1],data[2])
    end
end

--神兽技能
function ShenShouPanel:setShenShouSkils()
    if self.selectData then
        self.skillData = self.selectData.skills
        if self.skillData then
            self.skillList.numItems = #self.skillData
        end
    end
end
--神兽技能列表
function ShenShouPanel:skillCellData(index,obj)
    local skillId = self.skillData[index+1]
    if skillId then
        local icon = obj:GetChild("n1")
        local level = obj:GetChild("n2")
        local skillConf = conf.ShenShouConf:getSkillById(skillId)
        if skillConf then
            icon.url = UIPackage.GetItemURL("_icons" , skillConf.icon)
            level.text = string.format(language.gonggong51,skillConf.lv)
            obj.data = skillConf
            obj.onClick:Add(self.onClickSkill,self)
        end
    end
end
function ShenShouPanel:onClickSkill(context)
    local data = context.sender.data
    if data then
        mgr.ViewMgr:openView2(ViewName.ShenShouSkillTips, data)
    end
end

--打开神兽装备界面
function ShenShouPanel:onClickOpenEquip()
    if self.selectData then
        mgr.ViewMgr:openView2(ViewName.ShenShouEquip, self.selectData)
    end
end

-- 1助战 0召回
function ShenShouPanel:onClickZhuZhan(context)
    local data = context.sender.data
    local reqType = data
    if self.selectData then
        if reqType == 1 then
            --判断是否激活
            local equipInfos = self.selectData.equipInfos
            if not equipInfos or #equipInfos < 5 then
                GComAlter(language.shenshou04)
                return
            end 
            --判断当前上阵位数量是否已满
            local isInWar = self:getIsBattleNum()
            if isInWar >= self.holeCount then
                GComAlter(language.shenshou05)
                return
            end
        end
        proxy.ShenShouProxy:sendMsg(1590103,{reqType = reqType,ssId = self.selectData.ssId})
    end
end

--播放助战特效
function ShenShouPanel:playZhuZhanEff()
    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effectPanel.visible = true
    self.effect = self.parent:addEffect(4020170, self.effectPanel)
    self.effect.LocalPosition = Vector3.New(-2.86,-4.54,0)
    self.effect.LocalRotation = Vector3.New(0,180,0)
end

--移除助战特效
function ShenShouPanel:removeEffect()
    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil
        self.effectPanel.visible = false
    end
end

--强化打开界面
function ShenShouPanel:onClickStrength()
    if self.selectData then
        local equipInfos = self.selectData.equipInfos
        if not equipInfos or #equipInfos <= 0 then
            GComAlter(language.shenshou18)
            return
        end
        mgr.ViewMgr:openView2(ViewName.ShenShouStrength, self.selectData)
    end
end

--扩展助战数量
function ShenShouPanel:onClickAddCount()
    local confData = conf.ShenShouConf:getOpenLimitByNum(self.holeCount+1)
    if confData then
        --已上阵数量
        local isBattleNum = self:getIsBattleNum()
        mgr.ViewMgr:openView2(ViewName.ShenShouTips, {confData = confData,holeCount = self.holeCount,isBattleNum = isBattleNum})
    else
        GComAlter(language.shenshou10)
    end
end

-- 变量名：ssId    说明：神兽id
-- 变量名：opType  说明：=0穿,=1脱
-- 变量名：indexs  说明：=1时装备位置
-- 变量名：parts   说明：部位
--一键卸下
function ShenShouPanel:onClickAllDischarge()
    if self.selectData then
        local equipInfos = self.selectData.equipInfos
        if not equipInfos or #equipInfos <= 0 then
            GComAlter(language.shenshou15)
            return
        end
        local param = {}
        param.ssId = self.selectData.ssId
        param.opType = 1
        param.parts = {}
        for k,v in pairs(equipInfos) do
            local confdata = conf.ItemConf:getItem(v.mid)
            table.insert(param.parts,confdata.part)
        end
        if self.selectData.inWar == 1 then
            --助战神兽二次弹窗
            local data = {}
            data.type = 2
            data.sure = function()
                proxy.ShenShouProxy:sendMsg(1590102,param)
            end
            data.richtext = language.shenshou16
            GComAlter(data)
        else
            proxy.ShenShouProxy:sendMsg(1590102,param)
        end
    end
end

--规则
function ShenShouPanel:onClickGuize()
    GOpenRuleView(1139)
end

return ShenShouPanel