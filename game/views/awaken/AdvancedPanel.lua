--
-- Author: ohf
-- Date: 2017-02-22 16:23:21
--
--进阶区域
local AdvancedPanel = class("AdvancedPanel",import("game.base.Ref"))

function AdvancedPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AdvancedPanel:initPanel()
    self.modelObj = {}--模型
    self.oldLv = 0--旧阶数
    self.oldjsLevel = 0
    local roleIcon = cache.PlayerCache:getRoleIcon()
    self.sex = GGetMsgByRoleIcon(roleIcon).sex
    self.confData = conf.AwakenConf:getJsImage()

    local panelObj = self.mParent.view:GetChild("n4")
    self.panelObj = panelObj
    self.curHeroName = panelObj:GetChild("n47")
    self.curHeroName.text = ""--名字
    self.curHeroLvImg = panelObj:GetChild("n35")--模型阶数
    self.curHeroPanel = panelObj:GetChild("n48")--模型容器
    self.curHeroModel = self.curHeroPanel:GetChild("n0")

    self.nextHeroName = panelObj:GetChild("n50")
    self.nextHeroName.text = ""--名字
    self.nextHeroLvImg = panelObj:GetChild("n37")--模型阶数
    self.nextHeroPanel = panelObj:GetChild("n49")--模型容器
    self.nextHeroModel = self.nextHeroPanel:GetChild("n0")

    self.powerText = panelObj:GetChild("n38")

    self.attListView = panelObj:GetChild("n46")--属性列表
    self.attListView.itemRenderer = function(index,obj)
        self:cellAttiData(index, obj)
    end
    self.skillList = {}
    for i=57,60 do
        local skill = panelObj:GetChild("n"..i)
        skill.visible = false
        table.insert(self.skillList, skill)
    end

    self.starPanel = panelObj:GetChild("n51")
    self.progressBar = panelObj:GetChild("n29")
    self.proObj = panelObj:GetChild("n53")--所需消耗的道具
    self.proName = panelObj:GetChild("n54")--道具名称
    self.proConsume = panelObj:GetChild("n55")--道具消耗指示
    local advancedBtn1 = panelObj:GetChild("n24")--升阶按钮
    self.advancedBtn1 = advancedBtn1
    advancedBtn1.data = 1
    advancedBtn1.onClick:Add(self.onClickUp,self)
    local advancedBtn2 = panelObj:GetChild("n56")--自动升阶按钮
    advancedBtn2.data = 2
    self.advancedBtn2 = advancedBtn2
    advancedBtn2.onClick:Add(self.onClickUp,self)
    local returnBtn = panelObj:GetChild("n64")
    returnBtn.onClick:Add(self.onClickReturn,self)
    local buyBtn = panelObj:GetChild("n26")
    self.buyBtn = buyBtn
    buyBtn.onClick:Add(self.onClickBuy,self)
    self.maxImg = panelObj:GetChild("n65")--已满级字样
    self.maxImg.visible = false
    self.awards = {}--升阶奖励
    for i=66,67 do
        local award = panelObj:GetChild("n"..i)
        award.visible = false
        table.insert(self.awards, award)
    end
    self.autoBuy = panelObj:GetChild("n98")
    self.autoBuy.onChanged:Add(self.onCheck,self)
    self.autoBuy.visible = false
    self.autoBuy.selected = false
    panelObj:GetChild("n99").text = language.forging38
end

function AdvancedPanel:setData(data)
    if data then
        self.mData = data
        self.attrData = conf.AwakenConf:getJsAttr(self.mData.jsLevel)
    end
    local isUp = false
    self.powerText.text = self.mData.power--战斗力
    local curModel = {}
    local curModelId = self.attrData.starlv--当前
    if curModelId > self.oldLv then
        if self.oldLv > 0 then
            isUp = true--进阶成功
        end
        self.oldLv = curModelId
        self.curHeroName.text = conf.AwakenConf:getName(curModelId)--名字
        local buffId = conf.AwakenConf:getBuffId(curModelId)--获取buff
        local buffData = conf.BuffConf:getBuffConf(buffId)
        curModel = buffData.bs_args
        local len = #self.confData
        self:addModel(self.curHeroPanel,self.curHeroModel,curModel,1,self.curHeroPanel:GetChild("n1"))--添加模型
        self.curHeroLvImg.url = UIItemRes.jieshu[curModelId]--阶数

        local nextModelId = curModelId + 1--下一阶
        if curModelId >= len then
            nextModelId = curModelId
        end
        self.nextModelId = nextModelId
        self.nextHeroName.text = conf.AwakenConf:getName(nextModelId)--名字
        local buffId = conf.AwakenConf:getBuffId(nextModelId)--获取buff
        local buffData = conf.BuffConf:getBuffConf(buffId)
        local nextModel = buffData.bs_args
        self:addModel(self.nextHeroPanel,self.nextHeroModel,nextModel,2,self.nextHeroPanel:GetChild("n1"))--添加模型
        self.nextHeroLvImg.url = UIItemRes.jieshu[nextModelId]--阶数
    end
    local power1 = conf.AwakenConf:getPower(curModelId)
    local power2 = conf.AwakenConf:getPower(self.nextModelId)
    local power = power2 - power1
    self.powerText.text = power--战斗力
    local jsLevel = self.mData and self.mData.jsLevel or 0
    self.reqType = data and data.reqType or 1
    if self.isClick then--升级成功播特效
        self:playEff()
    end
    self.isClick = nil
    self.oldjsLevel = self.mData.jsLevel
    local items = self.mData.items
    if items and isUp then--进阶成功弹窗
        local func = nil
        -- if curModelId == nextModelId then
        --     func = function()
        --         self:onClickReturn()
        --     end
        -- end
        local data = {model = curModel,index = 11,func = func}
        mgr.ViewMgr:openView2(ViewName.GuideZuoqi, data)
        self.mTag = 0
        self.isUpAuto = nil
    end
    if curModelId == self.nextModelId then
        self:onClickReturn()
    end

    self:setAttiData()
    self:setSkillData()  
    self:setAutoUp()
end

function AdvancedPanel:setAutoUp()
    if self.mTag and self.mTag == 2 then--如果按了自动升阶
        if self.mData.jsLevel < self.upMaxLv then
            self.advancedBtn2.title = language.awaken05
            self:sendMsg()
        else
            self.isUpAuto = nil
            self.mTag = 0
            self.advancedBtn2.title = language.awaken06
            GComAlter(language.awaken08)
        end
    else
        self.advancedBtn2.title = language.awaken06
    end
end

function AdvancedPanel:setAttiData()
    local jsLevel = self.mData.jsLevel

    local star = self.attrData.star--星星数
    local ctrl = self.starPanel:GetController("c1")
    if self.reqType == 1 and star ~= 0 then
        ctrl.selectedIndex = star + 10 
    else
        if self.oldStar ~= star then
            ctrl.selectedIndex = star
        end
    end
    self.oldStar = clone(star)

    local nextData = conf.AwakenConf:getJsAttr(self.mData.jsLevel + 1)
    self.attiData = GConfDataSort(self.attrData)
    if nextData then
        self.nextData = GConfDataSort(nextData)
    else
        self.nextData = self.attiData
    end
    self.attListView.numItems = #self.attiData

    self.progressBar.value = self.mData.process
    local data = self.attrData
    if nextData then
        data = nextData
    end
    self.progressBar.max = data.advance_value or 0
    local progressText = self.progressBar:GetChild("title")
    progressText.text = self.mData.process
    self.isUp = false
    if data.cost then
        self.buyBtn.visible = true
        local proId = data.cost[1][1]
        local proNum = data.cost[1][2]--所要消耗的数量
        self.proNum = proNum
        self.proName.text = conf.ItemConf:getName(proId)
        local proData = cache.PackCache:getPackDataById(proId)
        self.proData = proData
        if self.proData then--剑神购买进阶道具用的id
            self.proData.index = 5
        end
        self.upMaxLv = conf.AwakenConf:getUpMaxlv()--自动升阶最大等级
        local packNum = proData.amount--背包数量
        local color = 14
        local str = mgr.TextMgr:getTextColorStr(packNum, color)..mgr.TextMgr:getTextColorStr("/"..proNum, 7)
        if packNum >= proNum then
            self.isUp = true
            color = 7
            str = mgr.TextMgr:getTextColorStr(packNum.."/"..proNum, color)
        else
            local redNum = cache.PlayerCache:getRedPointById(attConst.A10218) or 0
            mgr.GuiMgr:redpointByID(attConst.A10218,redNum)
        end
        self.proConsume.text = str
        local data = clone(proData)
        data.amount = 1
        data.isquan = true
        GSetItemData(self.proObj, data, true)
    else
        self.proName.text = ""
        self.proConsume.text = ""
        self.proObj.visible = false
        self.buyBtn.visible = false
    end
    if not self.isUp then
        GCloseAdvTip(1062)
    end
    self:setVisibleBtn()--判断是否满级
    self:setAwardsData()
end
--升阶奖励
function AdvancedPanel:setAwardsData()
    -- local awards = conf.AwakenConf:getAwards(self.nextModelId)
    -- if not awards then return end
    -- for k,v in pairs(awards) do
    --     local itemData = {mid = v[1],index = 0, amount = v[2]}
    --     GSetItemData(self.awards[k], itemData, true)
    -- end
end
--判断是否满级
function AdvancedPanel:setVisibleBtn()
    local maxLv = conf.AwakenConf:getMaxlv()
    if self.mData.jsLevel >= maxLv then--满级显示已满级
        self.starPanel.visible = false
        self.progressBar.visible = false
        self.proObj.visible = false
        self.proName.visible = false
        self.proConsume.visible = false
        self.advancedBtn1.visible = false
        self.advancedBtn2.visible = false
        self.buyBtn.visible = false
        self.maxImg.visible = true
    end
end
--设置技能数据
function AdvancedPanel:setSkillData()
    local skillInfo = self.mData.skillInfos
    for k,v in pairs(skillInfo) do
        local skillObj = self.skillList[k]
        if skillObj then
            skillObj.visible = true
            local skillLv = conf.AwakenConf:getSkillLv(self.attrData.starlv)
            local skillData = skillLv[k]
            if not skillData then 
                skillObj.visible = false 
                return 
            end
            local level = skillData[2]
            local skillId = v.skillId
            local affectData = conf.SkillConf:getSkillByIdAndLevel(skillId,level)
            if not affectData then
                return
            end
            if level <= 0 then
                skillObj.grayed = true
            else
                skillObj.grayed = false
            end

            local icon = skillObj:GetChild("n2")
            local iconId = conf.SkillConf:getSkillIcon(skillId)
            icon.url =ResPath.iconRes(iconId)   --UIPackage.GetItemURL("_icons" , ""..iconId)
            
            local lablevel = skillObj:GetChild("n3")
            lablevel.text = "Lv."..level
            local skillData = {skillId = skillId,level = level, starlv = self.attrData.starlv,index = k}
            skillObj.data = skillData
            skillObj.onClick:Add(self.onClickSkill,self)
        end
    end
end

function AdvancedPanel:onClickSkill(context)
    local cell = context.sender
    local data = cell.data
    if data.level > 0 then
        mgr.ViewMgr:openView(ViewName.AwakenTipView, function(view)
            view:setData(data)
        end)
    end
end
--属性
function AdvancedPanel:cellAttiData(index,cell)
    local text = cell:GetChild("n0")
    local data = self.attiData[index + 1]
    local str1 = conf.RedPointConf:getProName(data[1]).."    "..data[2]
    local str2 = ""
    local arrow = cell:GetChild("n3")
    if self.nextData then
        local nextData = self.nextData[index + 1]
        local atti = nextData[2] - data[2]
        if atti >= 0 then
            arrow.visible = true
            str2 = " +"..atti
        else
            arrow.visible = false
        end
    else
        arrow.visible = false
    end
    text.text = mgr.TextMgr:getTextColorStr(str1, 8)..mgr.TextMgr:getTextColorStr(str2, 7)
end
--容器，图形，模型id
function AdvancedPanel:addModel(panel,modelPanel,model,index,effectPanel)
    local modelObj = self.mParent:addModel(model[1],modelPanel)
    local cansee = modelObj:setSkins(nil,model[2],model[3])
    self.modelObj[index] = modelObj
    modelObj:setPosition(modelPanel.actualWidth/2,-modelPanel.actualHeight-200,500)
    modelObj:setRotation(RoleSexModel[self.sex].angle)
    modelObj:setScale(150)
    local effect = self.mParent:addEffect(4020102,effectPanel)
    effect.LocalPosition = Vector3(modelPanel.actualWidth/2,-modelPanel.actualHeight,500)

    modelObj:modelTouchRotate(panel,self.sex)
    if index == 1 then
        self.panelObj:GetChild("n73").visible = cansee
    else
        self.panelObj:GetChild("n74").visible = cansee
    end
end

function AdvancedPanel:setVisible(isVisible)
    self.panelObj.visible = isVisible
end

function AdvancedPanel:getVisible()
    return self.panelObj.visible
end
--升阶
function AdvancedPanel:onClickUp(context)
    if self.proData and not self.isUp and not self.autoBuy.selected then
        self:onClickBuy()
        return
    end
    local tag = context.sender.data
    self.mTag = tag
    local text = language.awaken03
    if tag == 1 then
        text = language.awaken03
        self.isUpAuto = nil
    else--自动升阶
        if self.isUpAuto then
            self.mTag = 0
            self.isUpAuto = nil
            return
        else
            text = language.awaken04
            self.isUpAuto = true
        end
    end
    self:sendMsg()
end

function AdvancedPanel:sendMsg()
    if self.proData and not self.isUp and not self.autoBuy.selected then
        self.isUpAuto = nil
        self.mTag = 0
        self.advancedBtn2.title = language.awaken06
        self:onClickBuy()
        return
    end
    self.isClick = true
    local auto = 0
    if self.autoBuy.selected then
        auto = 1
    end
    proxy.AwakenProxy:send(1190101,{reqType = 2,auto = auto})
end
--返回
function AdvancedPanel:onClickReturn()
    self.mTag = 0
    self.isUpAuto = nil
    self:setVisible(false)
    local awakenPanel = self.mParent:getAwakenPanel()
    awakenPanel:setVisible(true)
    awakenPanel:refreshRed()
end

function AdvancedPanel:onClickBuy()
    if self.proData then
        GGoBuyItem(self.proData)
    end
end

function AdvancedPanel:clear()
    self.reqType = 1
    self.oldjsLevel = 0
    self.oldLv = 0
    self.isUpAuto = nil
    self.isClick = nil
    self.mTag = 0
end

function AdvancedPanel:onCheck()
    if self.autoBuy.selected then
        if self.notTips then return end
        local param = {}
        param.type = 8
        param.richtext = mgr.TextMgr:getTextByTable(language.jianshen01)
        param.richtext1 = language.zuoqi51
        param.sure = function(flag)
            self.notTips = flag
        end
        param.sureIcon = UIItemRes.imagefons01
        GComAlter(param)
    end
end

function AdvancedPanel:playEff()
    -- body
    if self.playing then
        return
    end
    local node = self.panelObj:GetChild("n69")
    local effect,durition = self.mParent:addEffect(4020103,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,0)--坐标
    effect.Scale = Vector3.New(65,68,70) 
    self.playing = true
    if self.isUpAuto then--进阶声音
        if not self.isAudio then
            mgr.SoundMgr:playSound(Audios[2])
            self.isAudio = true
        end
    else
        mgr.SoundMgr:playSound(Audios[2])
        self.isAudio = nil
    end
    self.mParent:addTimer(1,durition,function()
        -- body
        self.playing = false
    end)
end

return AdvancedPanel