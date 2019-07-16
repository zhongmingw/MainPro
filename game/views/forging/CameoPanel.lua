--
-- Author: ohf
-- Date: 2017-02-06 16:11:28
--
--宝石区域
local CameoPanel = class("CameoPanel",import("game.base.Ref"))

local EquipNum = 12--装备数量
local CameoNum = 6--宝石位置数量

function CameoPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function CameoPanel:initPanel()
    self.osTime = 0
    local panelObj = self.mParent.view:GetChild("n7")
    self.panelObj = panelObj
    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.controller.onChanged:Add(self.selelctPart,self)--给控制器获取点击事件
    -- self.controller2 = panelObj:GetController("c2")--特效控制器

    self.equipList = {}
    for i=1,EquipNum do
        local num = i + 70
        local equipObj = equipPanel:GetChild("n"..num)
        for j=1,CameoNum do
            local cameoStar = equipObj:GetChild("n"..j)
            cameoStar.visible = true
            cameoStar.enabled = false
        end
        table.insert(self.equipList, equipObj)
    end
    self.equipObj = panelObj:GetChild("n19")--要镶嵌的装备部位

    self.cameoList = {}--宝石孔图片
    self.arrowList = {}--箭头
    self.frameList = {}--开启文字底板
    self.textlvList = {}--开启文字
    self.movieClices = {}--动画
    self.tActions = {}
    for i=1,CameoNum do
        local cameoObj = panelObj:GetChild("n2"..i)--宝石icon
        self.unlockUrl = cameoObj.url
        local posId = 2
        if i == 1 or i == 5 or i == 6 then
            posId = 1
        end
        cameoObj.data = {index = 4,posId = posId,hole = i,itemId = 0}
        cameoObj.onClick:Add(self.onClickCameObj,self)--
        table.insert(self.cameoList, cameoObj)
        local arrow = panelObj:GetChild("n7"..i)--对应的箭头
        arrow.visible = false
        table.insert(self.arrowList, arrow)
        local frame = panelObj:GetChild("n4"..i)
        table.insert(self.frameList, frame)
        local textLv = panelObj:GetChild("n5"..i)--开启等级描述
        textLv.text = string.format(language.gonggong07, 0)
        table.insert(self.textlvList, textLv)
        local cameoStar = self.equipObj:GetChild("n"..i)
        cameoStar.visible = true
        local movie = self.panelObj:GetChild("n9"..i)
        movie.visible = false
        table.insert(self.movieClices, movie)
        local index = i - 1
        local t = self.panelObj:GetTransition("t"..index)
        table.insert(self.tActions, t)
    end
    self.equipIcon = self.equipObj:GetChild("icon")
    self.textPower = panelObj:GetChild("n20")--战斗力
    local descText = panelObj:GetChild("n49")--
    descText.text = language.forging6
    local suitBtn = panelObj:GetChild("n65")--宝石套装按钮
    suitBtn.onClick:Add(self.onClickSuit,self)
    local attriBtn = panelObj:GetChild("n66")--宝石总属性按钮
    attriBtn.onClick:Add(self.onClickAttr,self)

    local ruleBtn = panelObj:GetChild("n67")
    ruleBtn.onClick:Add(self.onClickRule,self)

    local oneKeyBtn = panelObj:GetChild("n89")--一键镶嵌
    self.oneRedPoint = panelObj:GetChild("red")
    oneKeyBtn.onClick:Add(self.onClickOneKey,self)

    local onKeyUpBtn = panelObj:GetChild("n100")--一键升级
    onKeyUpBtn.onClick:Add(self.onClickUpKey,self)

    if g_is_banshu then
        oneKeyBtn:SetScale(0,0)
        self.oneRedPoint:SetSize(0,0)
        panelObj:GetChild("n69").visible = false

    end
end

function CameoPanel:setData()
    self:selelctPart()
    self:setEquipCameo()
end

function CameoPanel:setChildIndex(index)
    if index then
        local selectedIndex = index - 1
        if self.controller.selectedIndex ~= selectedIndex then
            self.controller.selectedIndex = selectedIndex
        end
    end
end
--当前部位镶嵌的宝石
function CameoPanel:selelctPart()
    self.gemItems = clone(cache.PackCache:getPackProsData())
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local data = cache.PackCache:getForgData(part)--返回该部位的数据
    if not data then return end
    self.equipIcon.url = UIItemRes.part[part]
    local power = cache.PackCache:getCameoPower(part)
    for i=1,6 do--先重置宝石孔的所有属性
        local cameoStar = self.equipObj:GetChild("n"..i)
        cameoStar.enabled = false
        self.cameoList[i].touchable = false
        local camo = conf.ForgingConf:getCamobyPart(part,i)
        local openLv = camo and camo.open_lev or 0
        self.frameList[i].visible = true
        self.textlvList[i].visible = true
        self.textlvList[i].text = string.format(language.forging58, openLv)
        self.cameoList[i].url = self.unlockUrl--宝石孔图片
    end
    local redPoint1 = false--是否可以一键镶嵌
    for k,v in pairs(data.gemMap) do--根据开启设置宝石孔属性
        self.frameList[k].visible = false
        self.textlvList[k].visible = false
        local cameoStar = self.equipObj:GetChild("n"..k)
        self.cameoList[k].touchable = true
        if v > 0 then
            cameoStar.enabled = true
            local src = conf.ItemConf:getSrc(v)
            self.cameoList[k].url =  ResPath.iconRes(src)  --UIPackage.GetItemURL("_icons" , ""..src)
            self.cameoList[k].data.index = 5
            self.cameoList[k].data.itemId = v
        else
            self.cameoList[k].data.index = 4
            local isJude = self:isJudeGem(k,0)--判断有没有镶嵌的
            local url = ""
            if isJude then
                url = UIItemRes.plus01
                redPoint1 = true
            end
            self.cameoList[k].url = url
            self.cameoList[k].data.itemId = 0
        end
    end
    local redPoint2 = false--是否可以一键替换
    for k,v in pairs(self.arrowList) do
        if data.gemMap[k] then
            local itemId = self.cameoList[k].data.itemId
            local isUp = self:isJudeUp(k,itemId)
            local isReplace = self:isJudeReplace(k,itemId)
            if isReplace then
                redPoint2 = true
            end
            v.visible = isUp or isReplace
        else
            v.visible = false
        end
    end
    self:setEquipData(self.equipObj,part)
    self.textPower.text = power
    self.oneRedPoint.visible = false
    if redPoint1 or redPoint2 then
        self.oneRedPoint.visible = true
    else
        self.oneRedPoint.visible = false
    end
end

function CameoPanel:setGemHole(hole)
    self:playEffect({hole})
end
--十个部位的宝石数据
function CameoPanel:setEquipCameo()
    local data = cache.PackCache:getForgData()
    if not data then
        return
    end
    local redNum = 0
    for _,v in pairs(data) do
        local equipObj = self.equipList[v.part]
        if equipObj then
            if self:judeCameoRed(v,equipObj) then
                redNum = redNum + 1
            end
            self:setEquipData(equipObj,v.part)
        end
    end
    cache.PlayerCache:setRedpoint(attConst.A10231, redNum)
    if redNum <= 0 then
        mgr.GuiMgr:refreshRedBottom()
        mgr.GuiMgr:updateRedPointPanels(attConst.A10231)
    end
end

function CameoPanel:judeCameoRed(data,equipObj)
    local cameoList = {0,0,0,0,0,0}
    local redPoint1 = false
    for k,v in pairs(data.gemMap) do
        local cameoStar = equipObj:GetChild("n"..k)
        if v <= 0 then
            if not redPoint1 then
                redPoint1 = self:isJudeGem(k,0,data.part)--判断有没有镶嵌的
            end
            cameoStar.enabled = false
        else
            cameoStar.enabled = true
        end
        cameoList[k] = v
    end
    local redPoint2 = false
    for i=1,6 do
        if data.gemMap[i] then
            local isUp = self:isJudeUp(i,cameoList[i])
            local isReplace = self:isJudeReplace(i,cameoList[i])
            if isUp or isReplace then
                redPoint2 = true
            end
        end
    end
    local arrow = equipObj:GetChild("n9")
    if redPoint1 or redPoint2 then
        arrow.visible = true
    else
        arrow.visible = false
    end
    return arrow.visible
end
--装备信息
function CameoPanel:setEquipData(equipObj,part)
    local icon = equipObj:GetChild("icon")
    local equip = equipObj:GetChild("n11")
    local equipData = cache.PackCache:getEquipByIndex(Pack.equip + part)--同部位的装备
    if equipData then
        local tt = clone(equipData)
        tt.isquan = true
        icon.visible = false
        GSetItemData(equip,tt)
    else
        equip.visible = false
        icon.visible = true
    end
end
--判断宝石是否可镶嵌
function CameoPanel:isJudeGem(hole,itemId,part)
    local part = part or self.controller.selectedIndex + 1
    local camoList,gemIds = self:getCamoList(part,hole)
    if gemIds[#gemIds] == itemId then
        return false
    end
    if #camoList > 0 then
        if not itemId or itemId and itemId <= 0 then
            return true
        end
    end
end
--判断宝石是否可替换
function CameoPanel:isJudeReplace(hole,itemId)
    local part = self.controller.selectedIndex + 1
    local camoList,gemIds = self:getCamoList(part,hole)
    if gemIds[#gemIds] == itemId then
        return false
    end

    if #camoList > 0 then
        if itemId and itemId > 0 then
            local count = 0
            for k,v in pairs(camoList) do
                if v.mid > itemId then
                    return true
                end
            end
        end
    end
end
--判断宝石是否可升级
function CameoPanel:isJudeUp(hole,itemId)
    local part = self.controller.selectedIndex + 1
    local camoList,gemIds = self:getCamoList(part,hole)
    if gemIds[#gemIds] == itemId then
        return false
    end
    
    if #camoList > 0 then
        if itemId and itemId > 0 then
            local count = 0
            local fuseCount = conf.ItemConf:getFuseCount(itemId)
            for k,v in pairs(camoList) do
                local mid = v.mid
                if mid <= itemId then
                    count = count + conf.ItemConf:getFuseCount(mid) * v.amount
                    if count >= fuseCount then
                        return true
                    end
                end
            end
        end
    end
end
--返回对应的宝石列表
function CameoPanel:getCamoList(part,hole)
    local confData = conf.ForgingConf:getCamobyPart(part,hole)
    local gemIds = confData.gem_id
    local camoList = {}
    for k,v in pairs(self.gemItems) do--找出该部位和等级对应的宝石
       for k,id in pairs(gemIds) do
            if v.mid == id then
                table.insert(camoList, v)
            end
       end
    end
    return camoList,gemIds
end

function CameoPanel:onClickCameObj(context)
    self:clear()
    local data = context.sender.data
    local index = data.index
    local posId = data.posId
    local part = self.controller.selectedIndex + 1
    local pos = {x = self.cameoList[posId].x + 120,y = self.cameoList[posId].y + 80}
    local camoList,gemIds = self:getCamoList(part,data.hole)
    if index == 5 then
        local itemId = data.itemId
        local num = 1
        local isFind1 = false
        local isFind2 = false
        if gemIds[#gemIds] > itemId then
            if #camoList > 0 then
                local count = 0
                local fuseCount = conf.ItemConf:getFuseCount(itemId)
                for k,v in pairs(camoList) do
                    if v.mid <= itemId and not isFind1 then
                        count = count + conf.ItemConf:getFuseCount(v.mid) * v.amount
                        if count >= fuseCount then
                            num = num + 1
                            isFind1 = true
                        end
                    end
                    if v.mid > itemId and not isFind2 then
                        num = num + 1
                        isFind2 = true
                    end
                end
                
            end
        end
        local iType = 1
        if num == 1 then--只可卸下
            iType = 1
        elseif num == 2 then
            if isFind1 then--升级+卸下
                iType = 2
            elseif isFind2 then --替换+卸下
                iType = 3
            end
        elseif num == 3 then--替换+升级+卸下 
            iType = 4
        end
        local cameoData = cache.PackCache:getPackDataById(data.itemId, true)
        cameoData["cameo"] = true--已经镶嵌的宝石
        cameoData["part"] = part
        cameoData["pos"] = pos
        cameoData["hole"] = data.hole
        cameoData["holeUpType"] = iType
        cameoData["camoList"] = camoList
        cameoData["itemId"] = itemId
        cameoData.amount = 1
        mgr.ViewMgr:openView(ViewName.PropMsgView,function(view)
            view:setData(cameoData)
        end)
        -- local cameoData = {pos = {x = context.sender.x + 120,y = context.sender.y + 80},pos2 = pos, part = part,camoList = camoList,hole = data.hole,type = iType,itemId = itemId}--pos位置,pos2打开宝石列表的位置,装备部位,宝石列表,宝石孔,镶嵌类型
        -- mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        --     view:setData(index,cameoData)
        -- end)
        return
    end
    if #camoList > 0 then
        local cameoData = {pos = pos, part = part,camoList = camoList,hole = data.hole}
        mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
            view:setData(index,cameoData)
        end)
    else
        local data = cache.PackCache:getPackDataById(gemIds[1])
        if data then
            GGoBuyItem(data)
        end
    end
end
--宝石套装
function CameoPanel:onClickSuit(context)
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        --刷新锻造装备套装数据
        proxy.ForgingProxy:send(1100108,{roleId = 0,srvId = 0})
        view:setData(7)
    end)
end
--宝石总属性
function CameoPanel:onClickAttr(context)
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setData(6)
    end)
end

--规则
function CameoPanel:onClickRule()
    GOpenRuleView(1005)
end

function CameoPanel:onClickOneKey()
    if os.time() - self.osTime >= 0.8 then
        self.osTime = os.time()
        local part = self.controller.selectedIndex + 1
        proxy.ForgingProxy:send(1100110,{part = part})
    else
        GComAlter(language.gonggong65)
    end
end
--一键升级
function CameoPanel:onClickUpKey()
    local buyPrice = 0
    local maxNum = 0
    for k,v in pairs(self.cameoList) do
        local data = v.data
        local itemId = data.itemId
        if itemId and itemId > 0 then
            local itemLv = conf.ItemConf:getLvl(itemId)
            if itemLv >= GemMaxLv then
                maxNum = maxNum + 1
            else
                buyPrice = buyPrice + conf.ItemConf:getBuyPrice(itemId)
            end
        end
    end

    if maxNum >= #self.cameoList then
        GComAlter(language.forging47)
        return
    end
    local sendMsg = function()
        local part = self.controller.selectedIndex + 1
        proxy.ForgingProxy:send(1100104,{reqType = 4,part = part,hole = 0,itemId = 0})
    end
    if buyPrice > 0 then
        local strTab = clone(language.forging46)
        strTab[2].text = string.format(strTab[2].text, buyPrice)
        local param = {type = 2,richtext = mgr.TextMgr:getTextByTable(strTab),sure = function()
            sendMsg()
        end}
        GComAlter(param)
    else
        sendMsg()
    end
end

function CameoPanel:setOneKeySucc(holes)
    self:playEffect(holes)
end

function CameoPanel:clear()
    self.osTime = 0
    self:playEffect()
end

function CameoPanel:playEffect(holes)
    if holes then
        for k,hole in pairs(holes) do
            self.movieClices[hole].visible = true
            self.tActions[hole]:Play()
        end
        self.mParent:addTimer(0.75, 1, function( ... )
            self:clear()
        end)
        mgr.SoundMgr:playSound(Audios[2])
    else
        for k,v in pairs(self.movieClices) do
            v.visible = false
        end
    end
end

return CameoPanel