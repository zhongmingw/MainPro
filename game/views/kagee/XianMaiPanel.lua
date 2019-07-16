--
-- Author: bxp
-- Date: 2019-01-08 11:09:59
--仙脉

local XianMaiPanel = class("XianMaiPanel", import("game.base.Ref"))
local effectId1 = 4020107
local effectId2 = 4020108
local attiList = {att_102 = 0, att_103 = 0, att_105 = 0, att_106 = 0, att_107 = 0, att_108 = 0}

function XianMaiPanel:ctor(mParent)
    self.parent = mParent
    self.view = self.parent.xianMaiObj
    self:initView()
end

function XianMaiPanel:initView()
    -- self.window2 = self.view:GetChild("window2")
    -- local closeBtn = self.window2:GetChild("btn_close")
    -- closeBtn.onClick:Add(self.onClickClose,self)

    self.mConfData = conf.KageeConf:getYwLimit()
    local listView = self.view:GetChild("n1")
    self.listView = listView
    listView.itemRenderer = function(index,obj)
        self:cellBtnData(index, obj)
    end
    listView.onClickItem:Add(self.onClickItem,self)--目标选择

    local kageeLsBtn = self.view:GetChild("n43")--影卫连锁
    self.kageeLsRed = kageeLsBtn:GetChild("red")
    kageeLsBtn.onClick:Add(self.onClickLs,self)
    -- local kageeJbBtn = self.view:GetChild("n44")--影卫羁绊
    -- kageeJbBtn.onClick:Add(self.onClickJb,self)

    self.nameText = self.view:GetChild("n22")
    self.zodiacPanel = self.view:GetChild("n42")--形象
    self.zodiacImg = self.zodiacPanel:GetChild("n0")

    local ruleBtn = self.view:GetChild("n56")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self:initPanel()
    self:initAtti()
end

function XianMaiPanel:flush()
    self.is10 = true
    self.reqType = 0
    -- GSetMoneyPanel(self.window2,self.parent:viewName())
    self.playLv = cache.PlayerCache:getRoleLevel()
    -- self.super.initData()
end

function XianMaiPanel:initPanel()
    self.starList = {}--星星
    self.starModel1s = {}--特效位置1
    self.starModel2s = {}--特效位置2
    self.moveList = {}--动效
    for i=1,10 do
        local star = self.zodiacPanel:GetChild("n"..i)
        local num1 = i + 10
        local starModel1 = self.zodiacPanel:GetChild("n"..num1)
        local num2 = i + 20
        local starModel2 = self.zodiacPanel:GetChild("n"..num2)
        local t = self.zodiacPanel:GetTransition("t"..i)
        star.grayed = true
        star.data = {i = i,jhValue = 0}
        star.onClick:Add(self.onClickStar,self)
        table.insert(self.starList, star)
        table.insert(self.starModel1s, starModel1)
        table.insert(self.starModel2s, starModel2)
        table.insert(self.moveList, t)
    end
    Stage.inst.onTouchBegin:Add(self.onTouchBegin,self)

    self.starPanel = self.view:GetChild("n21")--星星
    self.starFrame = self.view:GetChild("n6")--星星底板
    self.downFrame = self.view:GetChild("n52")--底板
    
    self.downLv = self.view:GetChild("n51")

    local leftBtn = self.view:GetChild("n53")
    self.leftBtn = leftBtn
    leftBtn.data = 1
    leftBtn.onClick:Add(self.onClickChoose,self)
    local rightBtn = self.view:GetChild("n54")
    self.rightBtn = rightBtn
    rightBtn.data = 2
    rightBtn.onClick:Add(self.onClickChoose,self)

    self.maxImg = self.view:GetChild("n55")
    self.lineList = {}--九条线
    self.lineW = 10
    self.lineH = 4
    for i=1,9 do
        local line = self.zodiacPanel:GetChild("n3"..i)
        if i == 1 then
            self.lineW,self.lineH = clone(line.width),clone(line.height)
        end
        table.insert(self.lineList, line)
    end
end

function XianMaiPanel:initAtti()
    self.attiList = {}--影卫总属性
    for i=23,28 do
        local text = self.view:GetChild("n"..i)
        table.insert(self.attiList, text)
    end

    self.descText = self.view:GetChild("n29")--神肖攻击说明
    self.skillNameText = self.view:GetChild("n30")
    self.skillIcon = self.view:GetChild("n64")
    self.titleIcon = self.view:GetChild("n19")
    
    self.curText = self.view:GetChild("n31")--本级属性说明
    self.curText.text = language.kagee02
    self.curAttiList = {}
    table.insert(self.curAttiList, self.view:GetChild("n33"))--本级属性1
    table.insert(self.curAttiList, self.view:GetChild("n61"))--本级属性2

    self.nextText = self.view:GetChild("n32")--下级属性说明
    self.nextText.text = language.kagee03
    self.nexAttiList = {}
    table.insert(self.nexAttiList, self.view:GetChild("n34"))--下级属性1
    table.insert(self.nexAttiList, self.view:GetChild("n62"))--下级属性2

    self.demandLvDesc = self.view:GetChild("n35")

    self.demandLv = self.view:GetChild("n36")--需求等级
    self.demandLv.text = string.format(language.gonggong16,0)
    self.lvDc = self.view:GetChild("n39")--是否达成
    self.moneyDesc = self.view:GetChild("n37")
    self.money = self.view:GetChild("n38")
    self.moneyDc = self.view:GetChild("n40")--是否达成
    
    self.uplvBtn = self.view:GetChild("n41")--升级按钮
    self.uplvBtn.onClick:Add(self.onClickUp,self)
end
--初始化属性值
function XianMaiPanel:initDec()
    self.isNotLv = false--判断升级是否够等级
    self.isNotMoney = false--判断升级是否够钱
    -- self.starPanel.visible = false
    self.starFrame.visible = false
    self.downFrame.visible = false
    local attiData = attiList
    for k,v in pairs(attiData) do
        if self.attiList[k] then
            self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..v[2]
        end
    end
    self.nameText.text = ""
    self.titleIcon.text = ""
    self.curAttiList[1].text = ""
    self.curAttiList[2].text = ""

    self.nexAttiList[1].text = ""
    self.nexAttiList[2].text = ""
    self.lvDc.text = ""
    self.moneyDc.text = ""
    self.money.text = ""
    self.downLv.text = ""
end
--请求类型（0.显示 1.升级）
function XianMaiPanel:setReqType(reqType)
    if reqType == 1 then
        mgr.SoundMgr:playSound(Audios[2])
    end
    self.reqType = reqType
end
--影卫羁绊等级
function XianMaiPanel:setYwJbLevel(ywJbLevel)
    self.ywJbLevel = ywJbLevel
end

function XianMaiPanel:setData(data)
    self.mData = data
    if not self.isRefKagee then
        self.listView.numItems = #self.mConfData
        self.listView:ScrollToView(0)
    else
        self.is10 = false
    end
    self:refreshRed()
    self.isRefKagee = true
    self:setFirstData()
end
--红点
function XianMaiPanel:refreshRed()
    self:refreshLsRed()
    local redNum = 0
    for i=1,self.listView.numItems do
        local cell = self.listView:GetChildAt(i-1)
        local data = cell.data
        if self:isRefreshRed(cell,data) then redNum = redNum + 1 end
    end
    if redNum == 0 and not self.kageeLsRed.visible then
        plog("客户端清除红点")
        mgr.GuiMgr:redpointByVar(attConst.A10217,0)
    end
end

function XianMaiPanel:cellBtnData(index,cell)
    local data = self.mConfData[index + 1]
    local title = cell:GetChild("title")
    title.text = data.name
    cell.data = data
    self:isRefreshRed(cell,data)
end
--刷新红点
function XianMaiPanel:isRefreshRed(cell,data)
    local redPanel = cell:GetChild("n4")
    local redText = cell:GetChild("n5")
    redText.visible = false
    local isRed = false
    if self.playLv >= data.open_lvl then
        local mId = data.id
        local starLv = self.mData and self.mData[mId] or 0--当前影卫总级别
        local nextAttData = conf.KageeConf:getUpattr(mId,starLv + 1)
        if nextAttData then
            local costMoney = nextAttData.cost_money or 0
            local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
            local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
            local lvl = nextAttData.lvl or 0
            if bmoney >= costMoney and self.playLv >= lvl then
                isRed = true
            else
                isRed = false
            end
        end
    else
        isRed = false
    end
    redPanel.visible = isRed
    return isRed
end

function XianMaiPanel:setFirstData()
    local index = self.mIndex or 0--默认选择当前或者第一个
    local cell = self.listView:GetChildAt(index)
    local myData = cell.data
    -- local ctrl = cell:GetController("button")
    cell.selected = true
    self:setKageeData(myData)
    self:setDownData()
    self:setAttiData()
end

function XianMaiPanel:onClickItem(context)
    local cell = context.data
    local myData = cell.data
    local len = #self.mConfData
    for i=1,len do
        local cell = self.listView:GetChildAt(i-1)
        local data = cell.data
        if myData.id ~= data.id then
            local ctrl = cell:GetController("button")
            ctrl.selectedIndex = 0
            if self.playLv < data.open_lvl then
                cell:GetChild("n4").visible = false
            end
        else
            self.mIndex = i - 1
        end
    end
    self.is10 = true
    self:setKageeData(myData)
    self:setDownData()
    self:setAttiData()
end

function XianMaiPanel:setKageeData(data)
    self.mId = data.id
    self.openlv = data.open_lvl--开放等级
    self.starLv = self.mData and self.mData[data.id] or 0--当前影卫总级别
    self:initDec()
end

function XianMaiPanel:setDownData()
    self.starlev1 = 0
    if self.playLv >= self.openlv then
        self.starPanel.visible = true
        self.starFrame.visible = true
        local ctrl = self.starPanel:GetController("c1")
        local starlev1 = GGetStarLev2(self.starLv)[1]--阶
        self.starlev1 = starlev1
        if self.is10 and starlev1~=0 then
            ctrl.selectedIndex = starlev1 + 10 
        else
            ctrl.selectedIndex = starlev1
        end
    else
        self.starPanel.visible = false
        self.downFrame.visible = true
        self.downLv.text = string.format(language.gonggong07, self.openlv)
    end

    local confData = conf.KageeConf:getYwLimitById(self.mId)
    self.nameText.text = confData.name
    self.titleIcon.text = confData.name--UIPackage.GetItemURL("kagee" , ""..confData.font)
    local curImgPath = UIItemRes.kageeImg..confData.icon
    if self.kageeImgPath then
        if self.kageeImgPath ~= curImgPath then
            if g_var.gameFrameworkVersion >= 2 then
                UnityResMgr:ForceDelAssetBundle(self.kageeImgPath)
            else
                UnityResMgr:UnloadAssetBundle(self.kageeImgPath, true)
            end
            self.kageeImgPath = curImgPath
            self.zodiacImg.url = self.kageeImgPath
        end
    else
        self.kageeImgPath = curImgPath
        self.zodiacImg.url = self.kageeImgPath
    end
    local pos = confData.pos
    for k,v in pairs(self.starList) do--设置星星位置
        local x = pos[k][1]
        local y = pos[k][2]
        self.starList[k].x = x
        self.starList[k].y = y
        self.starModel1s[k].x = x
        self.starModel1s[k].y = y
        self.starModel2s[k].x = x
        self.starModel2s[k].y = y
    end
    local starNum = GGetStarLev2(self.starLv)[2]
    self.starNum = starNum
    self.index = self.starlev1 + 1
    if self.starNum == 10 and self.index ~= 10 then
        self.index = self.index + 1
    end
    self.skillIcon.url = UIPackage.GetItemURL("kagee" , ""..confData.skill_icon)
    self.skillName = confData.skill_name
    self:setStarData()--设置星星高亮
end
--右方属性
function XianMaiPanel:setAttiData()
    self:setAllAttiData()
    self:setSelfData()
end
--影卫总属性
function XianMaiPanel:setAllAttiData()
    local confData = conf.KageeConf:getAllattr(self.mData)
    local lev = self:getKageeLv()
    local curJbData = conf.KageeConf:getFettersattrById(self.ywJbLevel)--当前仙盟攻击
    local function callback(data1,data2)
        if data2 then
            local data = clone(data2)
            for k,v in pairs(data) do
                if string.find(k,"att_") then
                    if not data1[k..""] then
                        data1[k..""] = 0
                    end
                    data1[k..""] = data1[k..""] + v
                end
            end
        end
    end
    local data = {}
    for i=1,2 do
        if i == 1 then
            callback(data,confData)
        elseif i == 2 then
            callback(data,curJbData)
        end
    end
    -- printt(data)
    local t = GConfDataSort(data)
    for k,v in pairs(t) do
        self.attiList[k].text = conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],v[2])
    end
    --仙脉攻击描述
    local rate = 0
    local lvl = 1
    if curJbData then--连锁概率
        rate = curJbData.rate
        lvl = curJbData.id
    end
    local desc = ""
    if curJbData then--羁绊描述
        desc = curJbData.desc
    else
        local jbData = conf.KageeConf:getFettersattrById(1)
        desc = jbData.desc
    end
    local str = mgr.TextMgr:getTextColorStr((rate / 100).."%", 7)..desc
    if rate <= 0 then
        str = language.kagee25
    end
    self.descText.text = str
    local level = self.ywJbLevel or 0
    self.skillNameText.text = self.skillName.."Lv"..level
end
--本肖属性
function XianMaiPanel:setSelfData()
    local isNotMax = true --是否满级
    --本级属性
    local curAttData = conf.KageeConf:getUpattr(self.mId,self.starLv)
    if curAttData then
        local t = GConfDataSort(curAttData)
        for k,v in pairs(t) do
            self.curAttiList[k].text = conf.RedPointConf:getProName(v[1])..GProPrecnt(v[1],v[2])
        end
    else
        self.curAttiList[1].text = language.kagee04
        self.curAttiList[2].text = language.kagee04
    end
    local red = 0
    --下级属性
    local nextAttData = conf.KageeConf:getUpattr(self.mId,self.starLv + 1)
    if nextAttData then
        local t = GConfDataSort(nextAttData)
        for k,v in pairs(t) do
            self.nexAttiList[k].text = conf.RedPointConf:getProName(v[1])..GProPrecnt(v[1],v[2])
        end
        --需求等级
        local lvl = nextAttData.lvl or 0
        local costMoney = nextAttData.cost_money or 0

        
        if self.playLv >= lvl then
            self.demandLv.text = mgr.TextMgr:getTextColorStr(string.format(language.gonggong16,lvl),7)
            self.lvDc.text = mgr.TextMgr:getTextColorStr(language.skill12, 7)
        else
            self.demandLv.text = mgr.TextMgr:getTextColorStr(string.format(language.gonggong16,lvl),14)
            self.lvDc.text = mgr.TextMgr:getTextColorStr(language.skill11, 14)
            self.isNotLv = true
        end

        local money = cache.PlayerCache:getTypeMoney(MoneyType.copper)
        local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper)
        if bmoney >= costMoney then
            self.moneyDesc.text = language.kagee19
            self.money.text = mgr.TextMgr:getTextColorStr(costMoney,7)
            self.moneyDc.text = mgr.TextMgr:getTextColorStr(language.skill12, 7)
        else
            self.moneyDesc.text = language.kagee18
            if money >= costMoney then
                self.money.text = mgr.TextMgr:getTextColorStr(costMoney,7)
                self.moneyDc.text = mgr.TextMgr:getTextColorStr(language.skill12, 7)
            else
                self.money.text = mgr.TextMgr:getTextColorStr(costMoney,14)
                self.moneyDc.text = mgr.TextMgr:getTextColorStr(language.skill11, 14)
                self.isNotMoney = true
            end
        end
    else
        local str = mgr.TextMgr:getTextColorStr(language.forging3, 7)
        self.nexAttiList[1].text = str
        self.nexAttiList[2].text = str
        self.demandLv.text = str
        self.money.text = str
        isNotMax = false
    end
    local redPoint = self.uplvBtn:GetChild("red")
    if not self.isNotLv and not self.isNotMoney then
        redPoint.visible = true
    else
        redPoint.visible = false
    end
    self:setMaxData(isNotMax)
end

function XianMaiPanel:refreshLsRed()
    local isRed = false
    if self.ywJbLevel <= 0 then
        local curData = conf.KageeConf:getFettersattr(self.mData)
        if curData then
            isRed = true
        end
    else
        local curData = conf.KageeConf:getFettersattrById(self.ywJbLevel)
        local nextData = conf.KageeConf:getFettersattrById(curData.id + 1)
        if nextData then
            local num = 0
            for k,v in pairs(self.mData) do
                if v >= nextData.lvl then num = num + 1 end
            end
            if num >= nextData.lvl_count then isRed = true end
        end
    end
    self.kageeLsRed.visible = isRed
end
--满级状态
function XianMaiPanel:setMaxData(isNotMax)
    self.maxImg.visible = (not isNotMax)
    self.curText.visible = isNotMax
    self.curAttiList[1].visible = isNotMax
    self.curAttiList[2].visible = isNotMax
    self.nextText.visible = isNotMax
    self.nexAttiList[1].visible = isNotMax
    self.nexAttiList[2].visible = isNotMax
    self.demandLvDesc.visible = isNotMax
    self.demandLv.visible = isNotMax
    self.lvDc.visible = isNotMax
    self.moneyDesc.visible = isNotMax
    self.money.visible = isNotMax
    self.moneyDc.visible = isNotMax
    self.uplvBtn.visible = isNotMax
end
--仙脉攻击
function XianMaiPanel:onClickLs()
    mgr.ViewMgr:openView(ViewName.KageeTipsView1,function(view)
        view:setData(self.mData,self.mId,self.ywJbLevel)
    end)
end

--当前影卫总等级
function XianMaiPanel:getKageeLv()
    local lv = 0
    for k,v in pairs(self.mData) do
        lv = lv + v
    end
    return lv
end

--升级
function XianMaiPanel:onClickUp()
    if self.isNotLv then
        GComAlter(language.gonggong06)
        return
    end
    if self.isNotMoney then
        local param = {}
        param.mId = MoneyPro2[MoneyType.bindCopper]
        GGoBuyItem(param)
        return
    end
    proxy.KageeProxy:send(1150101,{reqType = 1,ywId = self.mId})
end

function XianMaiPanel:getAngleByPos(p1,p2)  
    local x = p2.x - p1.x  
    local y = p2.y - p1.y
         
    local angle = math.atan2(y,x)*180/math.pi  
    local distance = math.sqrt(math.pow(y,2)+math.pow(x,2))
    self.lineList[p1.data.i].width = distance
    self.lineList[p1.data.i].position = p1.position
    self.lineList[p1.data.i].rotation = angle
    self.lineList[p1.data.i].visible = true
end  
--设置形象的星星数据
function XianMaiPanel:setStarData()
    for k,line in pairs(self.lineList) do
        line.visible = false
        line.width = self.lineW
        line.height = self.lineH
    end
    local len = #self.starList
    self.leftBtn.enabled = true
    self.rightBtn.enabled = true
    if self.index <= 1 then
        self.leftBtn.enabled = false
        self.index = 1
    elseif self.index >= len then
        self.rightBtn.enabled = false
        self.index = len
    end
    for k,v in pairs(self.starList) do--点亮星星
        self.starList[k].grayed = true
        self.starList[k].data.jhValue = 0
        local isL = false
        if self.index == self.starlev1 + 1 then--当前阶
            self.starList[k].grayed = false
            self.starList[k].data.jhValue = 1
            if k <= self.starNum then
                isL = true
            else
                self.starList[k].grayed = true
                self.starList[k].data.jhValue = 0
            end
        elseif self.index <= self.starlev1 then
            self.starList[k].grayed = false
            self.starList[k].data.jhValue = 1
            if self.index <= self.starlev1 then--前面所有阶
                isL = true
            end
        end
        if isL then
            if self.starList[k - 1] then
                self.starList[k - 1].grayed = false
                self.starList[k - 1].data.jhValue = 1
                self:getAngleByPos(self.starList[k - 1], self.starList[k])
            end
        end
    end
    self:playEffect()
end

function XianMaiPanel:releaseEffect()
    if self.effect1 then
        self.parent:removeUIEffect(self.effect1)
        self.effect1 = nil
    end
    if self.effect2 then
        self.parent:removeUIEffect(self.effect2)
        self.effect2 = nil
    end
end
--播放特效
function XianMaiPanel:playEffect()
    self:releaseEffect()
    local index = 0
    for k,v in pairs(self.starList) do
        self.moveList[k]:Stop()
        v.scaleX = 1
        v.scaleY = 1
        if v.grayed == false then
            index = k
        end
    end
    if index > 0 then
        local effectPanel1 = self.starModel1s[index]
        if self.reqType == 1 then--升星成功播放一个特效
            self.effect1 = self.parent:addEffect(effectId1, effectPanel1)
        end
        -- local effectPanel2 = self.starModel2s[index]
        -- self.effect2 = self:addEffect(effectId2, effectPanel2)
    end
    if index >= 0 and self.playLv >= self.openlv then
        local t = self.moveList[index + 1]
        if t then
            t:Play()
            local star = self.starList[index + 1]
            star.grayed = false
            if index > 0 then
                self:getAngleByPos(self.starList[index], star)
            end
        end
    end
    self.reqType = 0
end
--点击图形的星星
function XianMaiPanel:onClickStar(context)
    local cell = context.sender
    local cellData = cell.data
    local index = cellData.i
    local data = {pos = cell:LocalToGlobal(cell.xy),data = {mId = self.mId,jhValue = cellData.jhValue,starlv = (self.index - 1) * 10 + index,index = index}}
    mgr.ViewMgr:openView(ViewName.KageeTipsView2,function(view)
        view:setData(data)
    end)
end

function XianMaiPanel:onTouchBegin(context)
    local evt = context.data
    self.evtX = evt.x
    self.evtY = evt.y
end

function XianMaiPanel:getPos()
    return {x = self.evtX,y = self.evtY}
end
--当前生肖当前阶的星级选择
function XianMaiPanel:onClickChoose(context)
    local index = context.sender.data
    if index == 1 then--左
        self.index = self.index - 1
        self:setStarData()
    else--右
        self.index = self.index + 1
        self:setStarData()
    end
end

function XianMaiPanel:closeView()
    for k,line in pairs(self.lineList) do
        line.visible = false
        line.width = self.lineW
        line.height = self.lineH
    end
    self:releaseEffect()
    self.mIndex = nil
    self.listView.numItems = 0
    self.isRefKagee = nil
    Stage.inst.onTouchBegin:Remove(self.onTouchBegin,self)
    self.super.closeView(self)
end

function XianMaiPanel:onClickClose()
    self:closeView()
end

--规则
function XianMaiPanel:onClickRule()
    GOpenRuleView(1034)
end

function XianMaiPanel:dispose(clear)
    if self.kageeImgPath then
        UnityResMgr:UnloadAssetBundle(self.kageeImgPath, true)
        self.kageeImgPath = nil
    end
    if self.zodiacImg then
        self.zodiacImg.url = nil
    end
    self.super.dispose(self, clear)
end
return XianMaiPanel