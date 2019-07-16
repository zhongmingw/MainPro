--
-- Author: 
-- Date: 2018-07-07 11:22:54
--

local ShenLuView = class("ShenLuView", base.BaseView)
--延迟时间
local TransitionDelay  = {0.17,0.33,0.5,0.67,0.83,1,1.17,1.33}
local TransitionDelay2  = {[9] = 2.75,[10] = 3}
--特效下标
local AwardPos = {
    [1001] = 0,
    [1002] = 1,
    [1003] = 2,
    [1004] = 3,
    [1005] = 4,
    [1006] = 5,
    [2001] = 6,
    [2002] = 7,
    [2003] = 8,
    [3001] = 9,
    [3002] = 10,
}


function ShenLuView:ctor()
    ShenLuView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ShenLuView:initView()
    self.closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self.closeBtn.onClick:Add(self.onBtnClose,self)

    local dec1 = self.view:GetChild("n34")
    dec1.text = language.shenlu01
    local dec2 = self.view:GetChild("n35")
    dec2.text = language.shenlu02
    local dec3 = self.view:GetChild("n36")
    dec2.text = language.shenlu05
    self.lastTime = self.view:GetChild("n37")

    -- self.listView = self.view:GetChild("n12")
    -- self.listView:SetVirtual()
    -- self.listView.itemRenderer = function (index,obj)
    --     self:cellData(index,obj)
    -- end

    self.modlePanle = self.view:GetChild("n11")

    local ruleBtn = self.view:GetChild("n31")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.cost1 = conf.ActivityConf:getValue("sllb_per_cost")
    self.cost10 = conf.ActivityConf:getValue("sllb_ten_cost")

    self.oneBtn = self.view:GetChild("n28")
    self.oneBtn.data = 1
    self.oneBtn.title = self.cost1[2]
    self.oneBtn.onClick:Add(self.onClickChou,self)

    self.tenBtn = self.view:GetChild("n27")
    self.tenBtn.title = self.cost10[2]
    self.tenBtn.data = 2
    self.tenBtn.onClick:Add(self.onClickChou,self)

    self.shenLuBtn = self.view:GetChild("n26")
    self.shenLuBtn.data = 3 
    self.shenLuBtn.onClick:Add(self.onClickChou,self)

    self.bar = self.view:GetChild("n29")
    self.barTitle = self.view:GetChild("n30")
    --特效光标
    self.tEffect1 = self.view:GetChild("n14"):GetChild("n26")
    self.tEffect2 = self.view:GetChild("n14"):GetChild("n27")
    
    self.comItem = {}
    for i = 15,25 do
        local award = self.view:GetChild("n14"):GetChild("n"..i)
        table.insert(self.comItem,award)
    end
    -- --特殊道具
    -- self.speItem = {}
    -- for i=24,25 do
    --     local award = self.view:GetChild("n14"):GetChild("n"..i)
    --     table.insert(self.speItem,award)
    -- end
    self.t0 = self.view:GetChild("n14"):GetTransition("t0")
    self.tList1 = {}
    for i=1,10 do
        local tTransition = self.view:GetChild("n14"):GetTransition("t"..i)
        table.insert(self.tList1,tTransition)
    end
    self.tList2 = {}
    for i=9,10 do
        local tTransition = self.view:GetChild("n14"):GetTransition("t"..i)
        table.insert(self.tList2,tTransition)
    end
    self.t11 = self.view:GetChild("n14"):GetTransition("t11")
    self.t12 = self.view:GetChild("n14"):GetTransition("t12")

end

function ShenLuView:initData()
    self.isSpePlaying = false-- 特殊动画是正在播放
    self:setBtnTouch(true)
    self:initModel()
    self.tEffect1.visible = false
    self.tEffect2.visible = false

end
function ShenLuView:initModel()
    local sex = cache.PlayerCache:getSex()
    local suitId
    if sex == 1 then
        suitId = conf.ActivityConf:getValue("sllb_suit_boy")
    else
        suitId = conf.ActivityConf:getValue("sllb_suit_girl")
    end
    local modelObj1 = self:addModel(suitId[1],self.modlePanle)
    modelObj1:setSkins(suitId[1], suitId[2])
    modelObj1:setScale(210)
    modelObj1:setRotationXYZ(0,166,0)
    modelObj1:setPosition(0,-190,100)

end

-- function ShenLuView:cellData(index,obj)
--     local data = self.data.records[index+1]
--     local strTab = string.split(data,"|")
--     local rolename = strTab[1]
--     local mid = strTab[2] or 0
--     local proName = conf.ItemConf:getName(mid)
--     local color = conf.ItemConf:getQuality(mid)
--     local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
--     local recordItem = obj:GetChild("n0")
--     recordItem.text = string.format(language.chouqian07, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
-- end

function ShenLuView:setData(data)
    printt("神炉炼宝",data)
    print("抽到奖励>>>>>>>>>>>",data.lastCfgId)
    self.data = data
    if not self.oldSlz then
        self.oldSlz = data.slz
    end
    self.time = data.actLeftTime

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    --普通奖励
    self.commonAward = conf.ActivityConf:getSllbAwardByType(1)
    --神炉值奖励
    self.slzAward = conf.ActivityConf:getSllbAwardByType(2)
    --特殊奖励
    self.specialAward = conf.ActivityConf:getSllbAwardByType(3)
    for k,v in pairs(self.commonAward) do
        local awardData = v.item[1]
        if awardData then
            local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = 0}
            GSetItemData(self.comItem[v.sort], itemData, true)
        end
    end
    local t = {["n1"] = 1,["icon"] = 1}--神炉值要显示的
    for k,v in pairs(self.slzAward) do
        local src = v.item[1][1]
        local color = v.item[1][2]
        for i = 0 , self.comItem[v.sort].numChildren-1 do
            local varCom = self.comItem[v.sort]:GetChildAt(i)
            if not t[varCom.name] then
                varCom.visible = false
            end
        end
        local iconObj = self.comItem[v.sort]:GetChild("icon")
        local itemFrame = self.comItem[v.sort]:GetChild("n1")
        local iconUrl = ResPath.iconRes(tostring(src))
        iconObj.url = iconUrl
        itemFrame.url = ResPath.iconRes("beibaokuang_00"..color)--设置品质框
    end
    for k,v in pairs(self.specialAward) do
        local awardData = v.item[1]
        if awardData then
            local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = 0}
            GSetItemData(self.comItem[v.sort], itemData, true)
        end
    end

    self.shenLuMax = conf.ActivityConf:getValue("sllb_sl_cost")
    self.bar.max = self.shenLuMax
    self.bar:GetChild("title").text = ""

    if data.reqType == 0 then--显示
       self:setShenLuState()
    elseif data.reqType == 1 then--抽一次
        self:playComEffect()
    elseif data.reqType == 2 then--抽十次
        if self.oldSlz then
            local var = data.slz -self.oldSlz
            GComAlter(string.format(language.shenlu04,var))
            self.oldSlz = data.slz
        end
        GOpenAlert3(data.items)
        self:setBtnTouch(true)
        self:setShenLuState()
    elseif data.reqType == 3 then--神炉开奖
        self.oldSlz = data.slz
        self:playSpeEffect()
        self:setShenLuState()

    end
end
--设置神炉状态
function ShenLuView:setShenLuState()
    self.bar.value = self.data.slz
    self.barTitle.text = self.data.slz.."/"..self.shenLuMax
    if self.data.slz >= self.shenLuMax then
        self.shenLuBtn.grayed = false
        if self.isSpePlaying then
            self.shenLuBtn.touchable = false
        else
            self.shenLuBtn.touchable = true
        end
    else
        self.shenLuBtn.grayed = true
        self.shenLuBtn.touchable = false
    end
end
--get动效下标
function ShenLuView:getTransitonPos(id)
    local confData = conf.ActivityConf:getSllbDataById(id)
    local sort = confData.sort
    local transitonPos = sort-1
    return transitonPos
end

--播放普通道具动效
function ShenLuView:playComEffect()
    local lastCfgId = self.data.lastCfgId
    self.tEffect1.visible = true
    self.t0:Play()
    if lastCfgId == 1001 then
        self:addTimer(3.8+1, 1, function ()--防止点击过快+1秒
            self.tEffect1.visible = false
            GOpenAlert3(self.data.items)
            self:setBtnTouch(true)
            self:setShenLuState()
        end)
        return
    else
        self:addTimer(3, 1, function()
            local pos = self:getTransitonPos(lastCfgId)
            self.tList1[pos]:Play()
            self:addTimer(TransitionDelay[pos], 1, function()
                self:addTimer(0.8, 1, function ()--0.8秒后打开奖励界面
                    self.tEffect1.visible = false
                    if math.floor(tonumber(lastCfgId/1000)) == 2 then--抽到神炉值
                        local conf = conf.ActivityConf:getSllbDataById(lastCfgId)
                        local slz = conf.got_slz or 0
                        local str = string.format(language.shenlu03,tonumber(slz))
                        GComAlter(str)
                        -- self:setShenLuState()
                    else
                        GOpenAlert3(self.data.items)
                    end
                    self:setBtnTouch(true)
                    self:setShenLuState()
                    cache.ActivityCache:setSllbChouJiang(false)
                end)
            end)
        end)
    end
end
--特殊道具特效
function ShenLuView:playSpeEffect()
    self.isSpePlaying = true--特殊动画是否正在播放
    self.tEffect2.visible = true
    local lastCfgId = self.data.lastCfgId
    local pos = self:getTransitonPos(lastCfgId)
    self.tList1[pos]:Play()
    self:addTimer(TransitionDelay2[pos], 1, function()
        self:addTimer(0.8, 1, function ()
            self.tEffect2.visible = false
            GOpenAlert3(self.data.items)
            self.isSpePlaying = false
            self:setBtnTouch(true)
            self:setShenLuState()
        end)
    end)
end

function ShenLuView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ShenLuView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end

function ShenLuView:onClickChou(context)
    self:setBtnTouch(false)
    cache.ActivityCache:setSllbChouJiang(true)
    local data = context.sender.data
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    local haveYb = ybData.amount
    if data == 1 then
        if haveYb < self.cost1[2] then
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:onBtnClose()
            return
        end
    elseif data == 2 then
        if haveYb < self.cost10[2] then
            GComAlter(language.gonggong18)
            GGoVipTequan(0)
            self:setBtnTouch(true)
            return
        end
    end
    proxy.ActivityProxy:sendMsg(1030503,{reqType = data})
end

function ShenLuView:setBtnTouch(flag)
    self.oneBtn.touchable = flag
    self.tenBtn.touchable = flag
    -- self.closeBtn.touchable = flag
    self.shenLuBtn.touchable = flag
end

function ShenLuView:onClickRule()
    GOpenRuleView(1098)
end

function ShenLuView:onBtnClose()
    self:releaseTimer()
    self:closeView()
end


return ShenLuView