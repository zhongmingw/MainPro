--
-- Author: ohf
-- Date: 2017-02-06 21:13:11
--
--升星区域
local StarPanel = class("StarPanel",import("game.base.Ref"))

local equipNum = 12
local StarNum = 10
local StarProId = 221031001
local effectId = 4020106

function StarPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function StarPanel:initPanel()
    self.starTime = 0
    self.starSuc = 0--是否升星成功
    self.costStarNum = 0--所需要消耗的数量
    local panelObj = self.mParent.view:GetChild("n9")

    local equipPanel = panelObj:GetChild("n0")
    self.controller = equipPanel:GetController("c1")--主控制器
    self.controller.onChanged:Add(self.selelctPart,self)--给控制器获取点击事件
    self:initEquip(equipPanel)
    -- self.starList = {}
    -- for i=1,StarNum do
    --     local num = 150 + i
    --     local starObj = panelObj:GetChild("n"..num)
    --     table.insert(self.starList, starObj)
    -- end
    local starPanel = panelObj:GetChild("n899")
    self.starC1 = starPanel:GetController("c1")
    self.starLvText = panelObj:GetChild("n111")
    --当前
    self.defCur = panelObj:GetChild("n114")--防御
    self.ackCur = panelObj:GetChild("n115")--攻击
    self.breathCur = panelObj:GetChild("n116")--生命
    self.powerCur = panelObj:GetChild("n117")--战斗力
    --下一级
    self.defNext = panelObj:GetChild("n118")--防御
    self.ackNext = panelObj:GetChild("n119")--攻击
    self.breathNext = panelObj:GetChild("n120")--生命
    self.powerNext = panelObj:GetChild("n121")--战斗力

    local descText = panelObj:GetChild("n122")
    descText.text = language.forging59
    local equipCur = panelObj:GetChild("n42")--当前部位
    self.equipCur = equipCur
    self.curIcon = equipCur:GetChild("icon")
    local equipNext = panelObj:GetChild("n43")--下一级部位
    self.equipNext = equipNext
    self.nextIcon = equipNext:GetChild("icon")
    self.arrowList = {}
    for i=38,41 do
        local arrow = panelObj:GetChild("n"..i)
        self.posCenterX = arrow.x--属性升满后的中间位置
        table.insert(self.arrowList, arrow)
    end

    self.rateDesc = panelObj:GetChild("n112")
    self.rateText = panelObj:GetChild("n113")

    self.proStar = panelObj:GetChild("n92")

    self.starProObj = panelObj:GetChild("n31")--升星石
    self.starProName = panelObj:GetChild("n33")--升星石名字
    self.starNumText = panelObj:GetChild("n34")--升星石數量
    self.autoBuyBtn = panelObj:GetChild("n98")--自动购买
    panelObj:GetChild("n99").text = language.forging38
    self.starTen = panelObj:GetChild("n124")--升星十次
    panelObj:GetChild("n123").text = language.forging39
    local starBtn = panelObj:GetChild("n56")
    self.starBtn = starBtn
    starBtn.onClick:Add(self.onClickStar,self)
    --升星总属性
    local starAttBtn = panelObj:GetChild("n96")
    starAttBtn.onClick:Add(self.onClickStarAtt,self)    
    --升星套装
    local starSuitBtn = panelObj:GetChild("n100")
    starSuitBtn.onClick:Add(self.onClickStarSuit,self)    

    self.arrowLast = panelObj:GetChild("n41")
    local buyProBtn = panelObj:GetChild("n32")
    buyProBtn.onClick:Add(self.onClickBuyPro,self)
    local helpBtn = panelObj:GetChild("n29")--帮助
    helpBtn.onClick:Add(self.onClickHelp, self)
end

function StarPanel:initEquip(equipPanel)
    self.equipList = {}
    for i=1,equipNum do
        local num = i + 70
        local equipObj = equipPanel:GetChild("n"..num)
        equipObj.onClick:Add(self.onClickTip,self)
        table.insert(self.equipList,equipObj)
    end
end

function StarPanel:setStarSuc(starSuc)
    self.starSuc = starSuc
end

function StarPanel:setData()
    self:selelctPart()
    self:refreshEquip()
    self.starSuc = 0
end

function StarPanel:getMaxLvAndNextLv(starLev,part)
    local maxLvl = conf.ForgingConf:getValue("star_maxlvl")--升星最高等级
    local nextLvl = starLev + 1--下一级升星等级
    if starLev >= maxLvl then nextLvl = starLev end
    local starMaxlvl = conf.ForgingConf:getValue("star_noteq_maxlvl")--无装备升星最高等级
    local equip = cache.PackCache:getEquipDataByPart(part)
    if equip then
        local stageLvl = conf.ItemConf:getStagelvl(equip.mid) or 0
        local confDzData = conf.ForgingConf:getStageDuanzao(stageLvl)
        starMaxlvl = confDzData and confDzData.star_max_lvl or starMaxlvl
    else
        if starLev >= starMaxlvl then
            starMaxlvl = starLev
        end
    end
    self.starMaxlvl = starMaxlvl
    return starMaxlvl,nextLvl
end

function StarPanel:refreshEquip()
    local forgData = cache.PackCache:getForgData()
    local dataStar = cache.PackCache:getPackDataById(StarProId)
    local redNum = 0
    for k,v in pairs(self.equipList) do
        local data = forgData[k]
        if data then
            self:setEquipData(v,k)
            local lvText = v:GetChild("n8")
            local arrow = v:GetChild("n9")
            local confData = conf.ForgingConf:getStarData(k,data.starLev)
            local starMaxlvl = self:getMaxLvAndNextLv(data.starLev,k)
            if confData and confData.cost_star and dataStar.amount >= confData.cost_star and starMaxlvl > data.starLev then
                arrow.visible = true
                redNum = redNum + 1
            else
                arrow.visible = false
            end
            if data.starLev > 0 then
                lvText.visible = true
                lvText.text = "+"..data.starLev
            else
                lvText.visible = false
            end
        end
    end
    cache.PlayerCache:setRedpoint(attConst.A10230, redNum)
    if redNum <= 0 then
        mgr.GuiMgr:refreshRedBottom()
        mgr.GuiMgr:updateRedPointPanels(attConst.A10230)
        GCloseAdvTip(1030)
    end
end
--装备信息
function StarPanel:setEquipData(obj,part)
    local icon = obj:GetChild("icon")
    local equipObj = obj:GetChild("n11")
    local equipData = cache.PackCache:getEquipByIndex(Pack.equip + part)--同部位的装备
    if equipData then
        icon.visible = false
        local _t = clone(equipData)
        _t.isquan = true
        GSetItemData(equipObj,_t)
    else
        equipObj.visible = false
        icon.visible = true
    end
end

function StarPanel:setChildIndex(index)
    if index then
        local selectedIndex = index - 1
        if self.controller.selectedIndex ~= selectedIndex then
            self.controller.selectedIndex = selectedIndex
        end
    end
end

function StarPanel:selelctPart()
    local selectedIndex = self.controller.selectedIndex
    local part = selectedIndex + 1
    local data = cache.PackCache:getForgData(part)--返回该部位的数据
    if data then
        self.curIcon.url = UIItemRes.part[part]
        self.nextIcon.url = UIItemRes.part[part]
        self.orderLv = GGetStarLev(data.starLev)[1]
        self.starNum = GGetStarLev(data.starLev)[2]
        self.starLev = data.starLev
        self.maxlv = conf.ForgingConf:getStarMaxLv(part)
        if self.starSuc == 0 and self.starNum ~= 0 then
            self.starC1.selectedIndex = self.starNum + 10 
        else
            self.starC1.selectedIndex = self.starNum
        end
        self.isRef = nil
        self.starLvText.text = self.starLev
        self.part = part
        self:setAttData()
        self:setAttNextData()
    end
end
--当前属性
function StarPanel:setAttData()
    local dataStar = cache.PackCache:getPackDataById(StarProId)
    self.dataStar = dataStar
    if self.dataStar then --装备购买升星道具用的id
        self.dataStar.index = 6
    end
    --当前
    local confData1 = conf.ForgingConf:getStarData(self.part,self.starLev)
    self.isAmount = false
    if confData1 then
        local t = GConfDataSort(confData1)
        if #t <= 0 then--没有属性的情况
            local confData2 = conf.ForgingConf:getStarData(self.part,self.starLev + 1)
            local t2 = GConfDataSort(confData2)
            for k,v in pairs(t2) do
                if k == 1 then
                    self.defCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 2 then
                    self.ackCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                elseif k == 3 then
                    self.breathCur.text = conf.RedPointConf:getProName(v[1]).." 0"
                end
            end
        else
            for k,v in pairs(t) do
                if k == 1 then
                    self.defCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 2 then
                    self.ackCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                elseif k == 3 then
                    self.breathCur.text = conf.RedPointConf:getProName(v[1]).." "..v[2]
                end
            end
        end
        local rate = confData1.rate
        if rate then
            self.rateText.visible = true
            self.rateDesc.visible = true
            self.rateText.text = rate.."%"
        else
            self.rateText.visible = false
            self.rateDesc.visible = false
        end
        local power = confData1.power or 0
        self.powerCur.text = conf.RedPointConf:getProName(501).." "..power

        self.starProName.text = conf.ItemConf:getName(StarProId)
        local cost_star = confData1.cost_star
        local curText = self.equipCur:GetChild("n8")--当前部位
        if self.starLev > 0 then
            curText.visible = true
            if self.starLev >= self.maxlv then--最大值
                curText.text = language.forging3 
            else
                curText.text = "+"..self.starLev
            end
        else
            curText.visible = false
        end
        self.costStarNum = cost_star or 0
        if cost_star then
            local color = 14
            local redVisile = false
            local starMaxlvl = self:getMaxLvAndNextLv(self.starLev,self.part)
            if dataStar.amount >= cost_star and starMaxlvl > self.starLev then
                color = 7
                redVisile = true
            end
            self.starBtn:GetChild("red").visible = redVisile
            self.starNumText.text = mgr.TextMgr:getTextColorStr(dataStar.amount.."/"..cost_star, color)
            local curArrow = self.equipCur:GetChild("n9")--当前箭头
            if dataStar.amount >= cost_star then
                -- curArrow.visible = true
                self.isAmount = true
            else
                -- curArrow.visible = false
            end
        end
    end
    self:setEquipData(self.equipCur,self.part)
    -- GSetItemData(self.proStar,dataStar,true)--设置右上角道具信息
    local data = clone(dataStar)
    data.amount = 1
    data.isquan = true
    GSetItemData(self.starProObj, data, true)--设置升星石
end
--下一级属性
function StarPanel:setAttNextData()
    local dataStar = cache.PackCache:getPackDataById(StarProId)
    local nextText = self.equipNext:GetChild("n8")--当前部位
    local confData = conf.ForgingConf:getStarData(self.part,self.starLev + 1)
    if confData then
        local t = GConfDataSort(confData)
        for k,v in pairs(t) do
            if k == 1 then
                self.defNext.text = v[2]
            elseif k == 2 then
                self.ackNext.text = v[2]
            elseif k == 3 then
                self.breathNext.text = v[2]
            end
        end
        self.powerNext.text = confData.power or 0
        self.arrowLast.visible = true
        self.isMaxLv = false
    else--没有下一级就是满级了
        self.isMaxLv = true
        self.rateText.visible = false
        self.defNext.text = language.forging3
        self.ackNext.text = language.forging3
        self.breathNext.text = language.forging3
        self.powerNext.text = language.forging3 
        self.arrowLast.visible = false
        local confData3 = conf.ForgingConf:getStarData(self.part,self.starLev - 1)--显示最后一级的升星石数量
        local color = 7
        local cost_star = confData3.cost_star
        if dataStar.amount < cost_star then
            color = 14
        end
        self.starNumText.text = mgr.TextMgr:getTextColorStr(dataStar.amount.."/"..cost_star, color)
        self.starBtn:GetChild("red").visible = false
    end
    nextText.visible = true
    if self.starLev >= self.maxlv or self.starLev >= self.starMaxlvl then--最大值
        nextText.text = language.forging3 
    else
        local starlv = self.starLev + 1
        nextText.text = "+"..starlv
    end
    self:setEquipData(self.equipNext,self.part)
    self:playEffect()
end
--升星成功加特效
function StarPanel:playEffect()
    local cdTime = os.time() - self.starTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    if cdTime >= confTime * 0.5 then
        if cache.PackCache:getIsStar() then
            local effectPanel = self.equipNext:GetChild("n10")
            self.mParent:addEffect(effectId, effectPanel)
            mgr.SoundMgr:playSound(Audios[2])
            self.starTime = os.time()
        end
    end
    cache.PackCache:setIsStar(nil)
end

function StarPanel:onClickStar()
    if self.isMaxLv then
        GComAlter(language.forging19)
        return
    end
    local auto = 0
    if self.starTen.selected then--升星10次
        auto = 1
    end
    local reqType = 1
    if self.autoBuyBtn.selected then--自动购买升星
        reqType = 2
    else
        if not self.isAmount then
            GGoBuyItem(self.dataStar)
        end
    end
    local func = function()
        proxy.ForgingProxy:send(1100103,{reqType = reqType,part = self.part, auto = auto})
    end
    if reqType == 2 then--自动购买
        local price = conf.ItemConf:getBuyPrice(self.dataStar.mid)
        local constMoney = self.costStarNum * price
        if auto == 1 then
            constMoney = constMoney * 10
        end
        local money = cache.PlayerCache:getTypeMoney(MoneyType.bindGold) or 0
        if money < constMoney then--要扣元宝了
            if self.notTips then
                func()
                return
            end
            local param = {}
            param.type = 8
            param.richtext = language.gonggong74
            param.richtext1 = language.zuoqi51
            param.sure = function(flag)
                func()
                self.notTips = flag
            end
            param.sureIcon = UIItemRes.imagefons01
            GComAlter(param)
        else
            func()
        end
    else
        func()
        end
end

function StarPanel:onClickStarAtt()
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        view:setData(2)
    end)
end

function StarPanel:onClickStarSuit()
    mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
        --刷新锻造装备套装数据
        proxy.ForgingProxy:send(1100108,{roleId = 0,srvId = 0})
        view:setData(3)
    end)
end

function StarPanel:onClickTip()
    local selectedIndex = self.controller.selectedIndex
    -- local part = selectedIndex + 1
    -- local data = cache.PackCache:getForgData(part)
    -- if data then
    --     mgr.ViewMgr:openView(ViewName.ForgingTipsView, function(view)
    --         view:setData(8,data)
    --     end)
    -- end
end

function StarPanel:onClickBuyPro()
    if self.dataStar then
        GGoBuyItem(self.dataStar)
    end
end

--帮助
function StarPanel:onClickHelp()
    GOpenRuleView(1004)
end

return StarPanel