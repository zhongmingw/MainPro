--
-- Author: ohf
-- Date: 2017-02-22 16:23:03
--
--剑神区域
local AwakenPanel = class("AwakenPanel",import("game.base.Ref"))

function AwakenPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function AwakenPanel:initPanel()
    self.heroPanel = self.mParent.view:GetChild("n2")--形象区域
    self.attiPanel = self.mParent.view:GetChild("n3")--属性区域
    self:initHero()
    self:initAtti()
end
--形象区域
function AwakenPanel:initHero()
    local roleIcon = cache.PlayerCache:getRoleIcon()
    self.sex = GGetMsgByRoleIcon(roleIcon).sex

    self.confData = conf.AwakenConf:getJsImage()
    self.heroName = self.heroPanel:GetChild("n48")--剑神名字
    self.heroName.text = ""
    self.heroLvHero = self.heroPanel:GetChild("n12")

    self.heroCom = self.heroPanel:GetChild("n37")--模型容器
    self.heroModel = self.heroCom:GetChild("n0")

    self.heroPanel:GetChild("n22").text = language.awaken02

    self.skillListView = self.heroPanel:GetChild("n30")--剑神技能列表
    self.skillListView.itemRenderer = function(index,obj)
        self:cellSkillData(index, obj)
    end
    self.skillListView.onClickItem:Add(self.onClickItem,self)

    self.heroPanel:GetChild("n23").text = language.awaken46
    self.skinListView = self.heroPanel:GetChild("n31")--剑神幻化列表
    self.skinListView.itemRenderer = function(index,obj)
        self:cellSkinData(index, obj)
    end
    self.skinListView.onClickItem:Add(self.onClickItemSkin,self)

    self.powerImg = self.heroPanel:GetChild("n2")--战斗力
    self.powerImg.visible = false
    self.powerText = self.heroPanel:GetChild("n28")
    self.powerText.text = ""

    self.downPanel = self.heroPanel:GetChild("n53")--激活条件描述
    self.downPanel.visible = false
    self.jhText = self.heroPanel:GetChild("n44")
    self.jhText.text = ""

    self.leftBtn = self.heroPanel:GetChild("n20")
    self.leftBtn.data = 1
    self.leftBtn.onClick:Add(self.onClickSelect,self)
    self.rightBtn = self.heroPanel:GetChild("n19")
    self.rightBtn.data = 2
    self.rightBtn.onClick:Add(self.onClickSelect,self)
    self.signBtn = self.heroPanel:GetChild("n54")
    self.signBtn.data = self.signBtn.xy
    self.signBtn.onClick:Add(self.onClickBuy,self)
     --特惠提示按钮
    self.tehuiBtn = self.heroPanel:GetChild("n56")
    self.tehuiBtn.data = self.tehuiBtn.xy
    self.tehuiBtn.onClick:Add(self.onClickTeHui,self)
    --百倍豪礼提示按钮
    self.baibeiBtn = self.heroPanel:GetChild("n57")
    self.baibeiBtn.data = self.baibeiBtn.xy
    self.baibeiBtn.onClick:Add(self.onClickBaibei,self)

    local huoquBtn = self.heroPanel:GetChild("n58")
    self.huoquBtn = huoquBtn
    huoquBtn.onClick:Add(self.onBtnGo,self)

    self.bianshenBtn = self.heroPanel:GetChild("n59")
    self.bianshenBtn.onClick:Add(self.onClickBianshen,self)
    self.returnBtn = self.heroPanel:GetChild("n60")--返回按钮
    self.returnBtn.onClick:Add(self.onClickReturn,self)

    self.starBtn = self.heroPanel:GetChild("n61")
    self.starBtn.onClick:Add(self.onClickStar,self)
    if g_ios_test then    --EVE iso屏蔽
        self.signBtn.scaleX = 0
        self.signBtn.scaleY = 0
    end 
end
--特惠礼包提示按钮
function AwakenPanel:onClickTeHui()
    -- body
    local data = cache.ActivityCache:get5030111()
    if not data then
        GComAlter(language.acthall03)
        return
    end
    if data.acts[1026] and data.acts[1026] == 1 then
        GOpenView({id = 1028,childIndex = 1026})
    elseif data.acts[1032] and data.acts[1032] == 1 then
        GOpenView({id = 1028,childIndex = 1032})
    else
        GComAlter(language.acthall03)
    end
end

--百倍豪礼提示按钮
function AwakenPanel:onClickBaibei()
    -- body
    GOpenView({id = 1114,index = 9998})
end
--属性区域
function AwakenPanel:initAtti()
    self.c1 = self.attiPanel:GetController("c1")
    self.attiList = {}
    for i=14,25 do
        local atti = self.attiPanel:GetChild("n"..i)
        table.insert(self.attiList,atti)
    end
    -- self.skinsAttiList = {}
    -- for i=44,50 do
    --     local atti = self.attiPanel:GetChild("n"..i)
    --     table.insert(self.skinsAttiList,atti)
    -- end
    --升星属性
    self.starSuitImg = self.attiPanel:GetChild("n61")
    self.starSuitImg.visible = false
    self.proMporeList = self.attiPanel:GetChild("n54")
    self.proMporeList.numItems = 0
    self.starAttrList = {}
    for i=58,60 do
        local lab = self.attiPanel:GetChild("n"..i)
        lab.text = ""
        table.insert(self.starAttrList, lab)
    end

    self.progressBar = self.attiPanel:GetChild("n5")--进度条
    self.starPanel = self.attiPanel:GetChild("n27")--星星
    self.proObj = self.attiPanel:GetChild("n35")--所需消耗的道具
    self.btnBuy = self.attiPanel:GetChild("n11")
    self.btnBuy.onClick:Add(self.onClickBuy,self)
    self.proName = self.attiPanel:GetChild("n21")--道具名称
    self.proConsume = self.attiPanel:GetChild("n22")--道具消耗指示
    self.advancedBtn = self.attiPanel:GetChild("n6")--进阶按钮
    self.advancedBtn.onClick:Add(self.onClickAdvanced,self)
    self.jhBtn = self.attiPanel:GetChild("n36")--激活按钮
    self.jhBtn.onClick:Add(self.onClickJh,self)
    self.maxImg = self.attiPanel:GetChild("n37")
    self.maxImg.visible = false
    local ruleBtn = self.attiPanel:GetChild("n38")
    ruleBtn.onClick:Add(self.onClickRule,self)
end

function AwakenPanel:refreshRed()
    if not self.isUp then
        mgr.GuiMgr:redpointByVar(attConst.A10218,0,2)
    end
    self.jhBtn:GetChild("red").visible = self.isUp
    self.advancedBtn:GetChild("red").visible = self.isUp
end
--左边
function AwakenPanel:cellSkillData(index,cell)
    local skillNum = index + 1
    local data = self.mData.skillInfos[skillNum]
    local awakenId = conf.AwakenConf:getIdByStarLv(self.attrData.starlv)
    local skillLv = conf.AwakenConf:getSkillLv(awakenId)
    local skillData = skillLv[skillNum]
    if not skillData then 
        cell.visible = false
        return
    end
    local level = skillData[2]
    local skillId = data.skillId
    local affectData = conf.SkillConf:getSkillByIdAndLevel(skillId,level)
    if not affectData then
        return
    end
    if level <= 0 then
        cell.grayed = true
    else
        cell.grayed = false
    end
    
    local icon = cell:GetChild("n2")
    local iconId = conf.SkillConf:getSkillIcon(skillId)
    icon.url =  ResPath.iconRes(iconId) --UIPackage.GetItemURL("_icons" , ""..iconId)

    local lablevel = cell:GetChild("n3")
    lablevel.text = "Lv."..level
    local skillData = {skillId = skillId,level = level, starlv = self.attrData.starlv,index = skillNum}
    cell.data = skillData
end

function AwakenPanel:setData(data,isBs)
    if data then
        self.mData = data
    end
    if self.mData.jsLevel <= 0 then
        self.advancedBtn.visible = false
        self.jhBtn.visible = true
    else
        self.advancedBtn.visible = true
        self.jhBtn.visible = false
    end
    self.attrData = conf.AwakenConf:getJsAttr(self.mData.jsLevel)
    self.modelId = 0--初始化第几个模型
    self.curModelId = self.mData.currId--当前穿戴皮肤id
    local starLv = self.attrData and self.attrData.starlv or 1--初始的模型
    self.initModelId = conf.AwakenConf:getIdByStarLv(starLv)
    self.getIds = self.mData.getIds or {}--获得的皮肤id
    if data.reqType == 1 or isBs then--如果是查看信息或者变身
        self.isClick = false
        if isBs then
            self:selectModel(self.curModelId)
        else
            self:selectModel(self.initModelId)
        end
    end
    self.heroLvHero.url = UIItemRes.jieshu[starLv]
    self:setAttiData()
    self:setLeftTopVis()
    self.jianImgs = {}
    local jsSkins = conf.AwakenConf:getJsImage(2)
    for k ,v in pairs(jsSkins) do
        if v.buysee then--如果拥有才可见
            for k,getId in pairs(self.getIds) do
                if v.id == getId then
                    table.insert(self.jianImgs,v)
                end
            end
        else
            table.insert(self.jianImgs,v)
        end
    end
    self.skinListView.numItems = #self.jianImgs
    self:refreshRed()
    if data.reqType == 2 then--如果按了自动升阶
        if self.mData.jsLevel < conf.AwakenConf:getUpMaxlv() then
            if self.isClick  then
                if not self.isUp and self.proData then
                    self:onClickBuy()
                    self.isClick = false
                    return
                end
                proxy.AwakenProxy:send(1190101,{reqType = 2,auto = 0})
            end
        else
            GComAlter(language.awaken08)
        end
    end
end
--改变剑神id
function AwakenPanel:updateSkins(data)
    if data.reqType == 1 then
        self.mData.currId = 0
    else
        self.mData.currId = data.id
    end
    self:setData(self.mData,true)
end

function AwakenPanel:cellSkinData(index,cell)
    local data = self.jianImgs[index + 1]
    cell:GetChild("n2").url = ResPath.iconRes(data.icon)
    cell:GetChild("n3").visible = false
    cell.data = data
end
--点击剑神技能
function AwakenPanel:onClickItem(context)
    local cell = context.data
    local data = cell.data
    if data.level > 0 then
        mgr.ViewMgr:openView(ViewName.AwakenTipView, function(view)
            view:setData(data)
        end)
    end
end
--点击剑神外形
function AwakenPanel:onClickItemSkin(context)
    local cell = context.data
    local data = cell.data
    self.c1.selectedIndex = 1
    self:selectModel(data.id)
end

function AwakenPanel:setLeftTopVis()
    -- body
    --进阶活动
    self:setSignBtnVisible()
    --特惠礼包
    --特惠礼包
   self:setTehuiBtnVisible()
    --百倍豪礼
    self:setBaibeiVisible()
    --可见往左边移动
    local t = {self.signBtn,self.tehuiBtn,self.baibeiBtn}
    local index = 1
    for k ,v in pairs(t) do
        if v.visible then
            v.xy = t[index].data
            index = index + 1
            if k == 3 then
                v.y = v.y - 2
            end
        end
    end
end

function AwakenPanel:setArrPanel()
    self.c1.selectedIndex = 1--升星跳转bxp打开特殊属性面板
end

function AwakenPanel:selectModel(modelId)
    if self.modelId ~= modelId then
        self.modelId = modelId
        local buffId = conf.AwakenConf:getBuffId(self.modelId)
        local buffData = conf.BuffConf:getBuffConf(buffId)
        local model = buffData.bs_args
        self:setModel(model)
        self:setDownData()
        self.skillListView.numItems = #self.mData.skillInfos
        self:skinsAttiData()
    end
    self.heroName.text = conf.AwakenConf:getName(self.modelId)
    self.bianshenBtn.visible = false
    self.returnBtn.visible = false
    -- plog(self.c1.selectedIndex,self.curModelId,self.modelId)
    if self.curModelId == 0 then
        if self.c1.selectedIndex == 1 then
            self.bianshenBtn.visible = true
            self.returnBtn.visible = true
        end
    else
        if self.initModelId ~= self.modelId then
            self.returnBtn.visible = true
        end
        if self.curModelId ~= self.modelId then
            self.bianshenBtn.visible = true
        end
    end
    local confData = conf.AwakenConf:getJsImageData(self.modelId)--升星
    local starPre = confData and confData.star_pre or 0
    if starPre > 0 then
        self.starBtn.visible = true
    else
        self.starBtn.visible = false
    end
    self.confStarData = confData
end

--添加模型
function AwakenPanel:setModel(model)
    local angle = RoleSexModel[self.sex].angle
    local cansee
    local modelObj
    if not self.modelObj or self.modelObj:isDispose() then
        modelObj = self.mParent:addModel(model[1],self.heroModel)
        cansee = modelObj:setSkins(nil,model[2],model[3])
        self.modelObj = modelObj
    else
        modelObj = self.modelObj
        cansee = modelObj:setSkins(model[1],model[2],model[3])
    end
    modelObj:setPosition(self.heroModel.actualWidth/2,-self.heroModel.actualHeight-200,500)
    modelObj:setRotation(angle)
    modelObj:setScale(150)
    local effect = self.mParent:addEffect(4020102,self.heroCom:GetChild("n1"))
    effect.LocalPosition = Vector3(self.heroModel.actualWidth/2,-self.heroModel.actualHeight,500)
    modelObj:modelTouchRotate(self.heroCom,self.sex)
    self.heroPanel:GetChild("n55").visible = cansee
end
--判断是否激活了
function AwakenPanel:isHaveJs()
    local isJh = false
    for k,v in pairs(self.getIds) do
        if self.modelId == v then
            isJh = true
            break
        end
    end
    return isJh
end

function AwakenPanel:setDownData()
    local isJh = self:isHaveJs()
    local isVisible = false
    if self.c1.selectedIndex == 0 and self.mData.jsLevel > 0 then
        isVisible = true
    elseif self.c1.selectedIndex == 1 and isJh then
        isVisible = true
    end
    if isVisible then
        self.downPanel.visible = false
        self.jhText.text = ""
    else
        self.downPanel.visible = true
        self.huoquBtn.visible = false
        if self.mData.jsLevel > 0 then
            local confData = conf.AwakenConf:getJsImageData(self.modelId)
            local moduleData = confData.tab_type
            if moduleData then
                local id = moduleData and moduleData[1]
                local childIndex = moduleData and moduleData[2]
                local goBtnVisible = moduleData and moduleData[3]
                local data = conf.SysConf:getModuleById(id)
                self.jhText.text = data.desc or ""
                self.moduleData = {id = id,childIndex = childIndex}
                self.huoquBtn.visible = true
                if goBtnVisible and goBtnVisible == 1 then
                    self.huoquBtn.visible = false
                end
            end
        else
            self.jhText.text = string.format(language.awaken07)
        end
    end
end

function AwakenPanel:onBtnGo()
    if not self.moduleData then return end
    local data = self.moduleData
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end
--右边属性
function AwakenPanel:setAttiData()
    local jsLevel = self.mData.jsLevel
    local max = #self.getIds
    local attiData = {}
    for i=1,max + 1 do
        local data = {}
        if i <= max then
            data = conf.AwakenConf:getJsImageData(self.getIds[i])
        else
            data = self.attrData
        end
        for k,value in pairs(data) do
            if not attiData[k] then
                attiData[k] = 0
            end
            if string.find(k,"att_") then
                attiData[k] = attiData[k] + data[k]
            end
        end
    end
    local t = GConfDataSort(attiData)
    if jsLevel <= 0 then
        local data = conf.AwakenConf:getJsAttr(jsLevel + 1)
        t = GConfDataSort(data)
    end

    for k,v in pairs(t) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])
    end
    
    local star = self.attrData.star--星星数
    local ctrl = self.starPanel:GetController("c1")
    if star ~= 0 then
        ctrl.selectedIndex = star + 10
    else
        ctrl.selectedIndex = star
    end

    self.progressBar.value = self.mData.process
    local nextData = conf.AwakenConf:getJsAttr(jsLevel + 1)

    local data = self.attrData
    if nextData then
        data = nextData
    end
    self.progressBar.max = data.advance_value or 0
    local progressText = self.progressBar:GetChild("title")
    progressText.text = self.mData.process
    
    if data.cost then
        local proId = data.cost[1][1]
        local proNum = data.cost[1][2]--所要消耗的数量
        self.proName.text = conf.ItemConf:getName(proId)
        local proData = cache.PackCache:getPackDataById(proId)
        self.proData = proData
        if self.proData then--剑神购买进阶道具用的id
            self.proData.index = 5
        end
        local packNum = proData.amount--背包数量
        local color = 14
        self.isUp = false
        local str = mgr.TextMgr:getTextColorStr(packNum, color)..mgr.TextMgr:getTextColorStr("/"..proNum, 7)
        if packNum >= proNum then
            color = 7
            self.isUp = true
            str = mgr.TextMgr:getTextColorStr(packNum.."/"..proNum, color)
        end
        self.proConsume.text = str
        local data = clone(proData)
        data.amount = 1
        data.isquan = true
        GSetItemData(self.proObj, data, true)
    else
        self.proObj.visible = false
    end
    self:setVisibleBtn()
end

function AwakenPanel:composeData(data,param)
    for k ,v in pairs(param) do
        local falg = false
        for i , j in pairs(data) do
            if j[1] == v[1] then
                data[i][2] = j[2] + v[2]
                falg = true 
            end
        end
        if not falg then
            table.insert(data,v)
        end
    end
end
--特殊皮肤属性
function AwakenPanel:skinsAttiData()
    if self.c1.selectedIndex == 1 then
        -- for k,v in pairs(self.skinsAttiList) do
        --     v.text = ""
        -- end
        -- local confData = conf.AwakenConf:getJsImageData(self.modelId)
        -- local t = GConfDataSort(confData)
        -- local starPre = confData and confData.star_pre or 0
        -- local starId = starPre * 1000 + cache.PlayerCache:getSkinStarLv(starPre)
        -- local fsData = conf.RoleConf:getFashionStarAttr(starId) or {}
        -- local t2 = GConfDataSort(fsData)
        -- self:composeData(t,t2)--属性累加
        -- for k,v in pairs(t) do
        --     self.skinsAttiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])
        -- end
        for k , v in pairs(self.starAttrList) do
            v.text = ""
        end
        self.proMporeList.numItems = 0
        local confData = conf.AwakenConf:getJsImageData(self.modelId)

        local suitStarPre = confData and confData.star_pre or 0
        local suitStars = cache.PlayerCache:getSkinStarLv(suitStarPre)
        print("剑神系统属性>>>>>>>>>>>",confData.star_pre)
        if confData.star_pre then
            self.starSuitImg.visible = false
            --升星属性
            local suitStarConf = conf.RoleConf:getSkinsStarAttrData(self.modelId,1012)
            for k,v in pairs(suitStarConf) do
                local str = string.format(language.fashion14,v.need_star) .. string.format(language.fashion15_1,language.gonggong94[1012],(v.attr_show/100))
                if suitStars >= v.need_star then
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,7)
                else
                    self.starAttrList[k].text = mgr.TextMgr:getTextColorStr(str,8)
                end
            end
        else
            self.starSuitImg.visible = true
        end

        local starId = suitStarPre*1000+suitStars
        local t = GConfDataSort(confData)
        printt("升星id>>>>>>>>>>>>>",t)
        self.proMporeList.itemRenderer = function (index,obj)
            local data = t[index+1]
            if data then
                local txt1 = obj:GetChild("n0")
                local txt2 = obj:GetChild("n1")
                txt1.text = conf.RedPointConf:getProName(data[1]).." "..GProPrecnt(data[1],math.floor(data[2]))
                if suitStars > 0 then
                    local curData = GConfDataSort(conf.RoleConf:getFashionStarAttr(starId))
                    if curData[index+1] then
                        txt2.text = "+".. curData[index+1][2]
                    end
                else
                    txt2.text = ""
                end
            end
        end
        self.proMporeList.numItems = #t
    end
    self:setVisibleBtn()
end

--判断是否满级
function AwakenPanel:setVisibleBtn()
    if self.c1.selectedIndex == 0 then
        local maxLv = conf.AwakenConf:getMaxlv()
        local confData = conf.AwakenConf:getJsImageData(self.initModelId)
        local jie = confData.icon % 1000
        if jie >= conf.AwakenConf:getEndMaxJie() then--满级显示已满级
            self.starPanel.visible = false
            self.progressBar.visible = false
            self.proObj.visible = false
            self.btnBuy.visible = false
            self.proName.visible = false
            self.proConsume.visible = false
            self.advancedBtn.visible = false
            self.jhBtn.visible = false
            self.maxImg.visible = true
        elseif self.mData.jsLevel == 0 then
            self.starPanel.visible = false
            self.progressBar.visible = false
            self.proObj.visible = false
            self.btnBuy.visible = false
            self.proName.visible = false
            self.proConsume.visible = false
            self.advancedBtn.visible = false
            self.jhBtn.visible = true
        else
            self.starPanel.visible = true
            self.progressBar.visible = true
            self.proObj.visible = true
            self.btnBuy.visible = true
            self.proName.visible = true
            self.proConsume.visible = true
            self.advancedBtn.visible = true
            self.jhBtn.visible = false
            self.maxImg.visible = false
        end
    end
end

function AwakenPanel:setVisible(isVisible)
    self.heroPanel.visible = isVisible
    self.attiPanel.visible = isVisible
end

function AwakenPanel:getVisible()
    return self.heroPanel.visible
end

function AwakenPanel:onClickSelect(context)
    -- local tag = context.sender.data
    -- if tag == 1 then--左选
    --     self:selectModel(-1)
    -- else--右选
    --     self:selectModel(1)
    -- end
end
--进阶
function AwakenPanel:onClickAdvanced()
    if not self.isUp and self.proData then
        self:onClickBuy()
        return
    end
    if not self.isClick then
        proxy.AwakenProxy:send(1190101,{reqType = 2,auto = 0})
        self.isClick = true
    else
        self.isClick = false
    end
end

--激活
function AwakenPanel:onClickJh()
    proxy.AwakenProxy:send(1190101,{reqType = 2})
end

function AwakenPanel:onClickBuy()
    if cache.GuideCache:getIsJsguide() then
        cache.GuideCache:setIsJsguide(false)
    else
        if self.proData then
            GGoBuyItem(self.proData)
        end
    end
end

--规则
function AwakenPanel:onClickRule()
    GOpenRuleView(1035)
end

function AwakenPanel:clear()
    self.c1.selectedIndex = 0
end

--活动提示按钮显隐设置
function AwakenPanel:setSignBtnVisible()
    self.signBtn.visible = false
end
function AwakenPanel:setTehuiBtnVisible()
    -- body
    if true then
        --屏蔽特惠抢购 20180301
        self.tehuiBtn.visible = false
        return false
    end
    if g_ios_test then
        self.tehuiBtn.visible = false
        return
    end 
    self.tehuiBtn.visible = false
    local data = cache.ActivityCache:get5030111()
    if not data then
        return
    end
    local condata = conf.SysConf:getHwbSBItem("jiansheng0")
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
    --没有购买要求
    if not condata.buy_id then
        self.tehuiBtn.visible = false
        return
    end
    local _in = clone(condata.buy_id)
    if not condata.open_day then
        _in = {condata.buy_id[curday] or condata.buy_id[9]}
    end
    --检测是否购买了要求物品
    local key = g_var.accountId.."1026buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        self.tehuiBtn.visible = falg
    else
        self.tehuiBtn.visible = true
    end
end

function AwakenPanel:onClickBianshen()
    if self.modelId == self.initModelId then--还原
        proxy.AwakenProxy:send(1190102,{id = self.curModelId,reqType = 1})
    elseif self.modelId ~= self.initModelId and self:isHaveJs() then
        proxy.AwakenProxy:send(1190102,{id = self.modelId,reqType = 2})
    else
        GComAlter(language.awaken47)
    end
end
--返回初始模型
function AwakenPanel:onClickReturn()
    self.c1.selectedIndex = 0
    self:selectModel(self.initModelId)
end

function AwakenPanel:setBaibeiVisible()
    -- body
    if true then
       self.baibeiBtn.visible = false
        return false
    end
    if g_ios_test then
        self.baibeiBtn.visible = false
        return
    end
    self.baibeiBtn.visible = false
    if cache.PlayerCache:getRedPointById(attConst.A30111)<=0 then
        return
    end
    local data = cache.ActivityCache:get5030111()
    if not data then
        return
    end

    local condata = conf.SysConf:getHwbSBItem("jiansheng0")
    if not condata then
        return
    end
    local curday = data.openDay % 9
    if condata.open_day and curday  ~= condata.open_day then--有天数 要求
        return
    end
    
    --没有购买要求
    if not condata.buy_danci then
        self.baibeiBtn.visible = true
        return
    end
    local _in = clone(condata.buy_danci)
    if not condata.open_day then
        _in = {condata.buy_danci[curday] or condata.buy_danci[9]}
    end
    --printt(_in)
    --检测是否购买了要求物品
    local key = g_var.accountId.."3010buy"
    local _localbuy = UPlayerPrefs.GetString(key)
    if _localbuy~="" then
        local _t = json.decode(_localbuy)
        local pairs = pairs

        local falg = false 
        for k,v in pairs(_in) do
            local innnerbuy = false--当前物品是否买过
            for i , j in pairs(_t) do
                if tonumber(j) == tonumber(v) then
                    innnerbuy = true 
                    break
                end
            end
            if not innnerbuy then --有个需求物品没有买
                falg = true
                break
            end
        end
        self.baibeiBtn.visible = falg
    else
        self.baibeiBtn.visible = true
    end
    
end

function AwakenPanel:onClickStar()
    if not self.confStarData then return end
    if not self:isHaveJs() then
        GComAlter(language.fashion13)
        return
    end
    mgr.ViewMgr:openView2(ViewName.FashionStarView, self.confStarData)
end

return AwakenPanel