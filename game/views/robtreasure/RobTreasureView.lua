--夺宝奇兵活动
-- Author: Your Name
-- Date: 2018-06-25 21:18:23
--
local RobTreasureView = class("RobTreasureView", base.BaseView)

local resName = {
    [1] = "xianmengshenghuo_007",
    [2] = "xianmengshenghuo_008",
    [3] = "xianmengshenghuo_009",
    [4] = "xianmengshenghuo_010",
    [5] = "xianmengshenghuo_011",
    [6] = "xianmengshenghuo_012",
}


function RobTreasureView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.drawcall = false
end

function RobTreasureView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.closeView,self)

    local chargeBtn = self.view:GetChild("n14")
    chargeBtn.onClick:Add(self.onClickCharge,self)
    local guizeBtn = self.view:GetChild("n15")
    guizeBtn.onClick:Add(self.onClickGuize,self)

    self.gridList = {}--移动格子列表
    for i=1,51 do
        local awardItem = self.view:GetChild("n82"):GetChild("n"..i)
        table.insert(self.gridList,awardItem)
    end

    self.times = 1--投掷次数
    
    self.throwBtn = self.view:GetChild("n13")
    self.throwBtn.onClick:Add(self.onClickThrow,self)

    self.lastCount = self.view:GetChild("n17")--夺宝单次消耗

    
    self.checkBtn = self.view:GetChild("n19")--投掷10次复选按钮
    self.checkBtn.onChanged:Add(self.selelctCheck,self)

    self.isAnimationBtn = self.view:GetChild("n18")--是否播放动画复选按钮


    self.myIcon = self.view:GetChild("n84")
    self.moveIcon = self.myIcon:GetChild("icon")
    self.currStep = 0--当前位置

    self.effectP = self.view:GetChild("n77")
    self.diceIcon = self.view:GetChild("n12")
    self.diceIcon.visible = false

    self.recordLab = self.view:GetChild("n10"):GetChild("n0")
    self.recordLab.text = ""

    self.decTxt = self.view:GetChild("n11"):GetChild("n0")
    self.decTxt.text = ""

    self.lastTimeTxt = self.view:GetChild("n79")

    self.needYbTxt = self.view:GetChild("n22")

    --标题图
    self.titleIcon = self.view:GetChild("n0"):GetChild("icon")
end

function RobTreasureView:initData()
    self.clickFlag = true
    self.costYb = conf.ActivityConf:getHolidayGlobal("dbqb_times_cost")
end

function RobTreasureView:selelctCheck()
    if self.checkBtn.selected then
        self.times = 10
    else
        self.times = 1
    end
end

function RobTreasureView:initGrid(lastAwardIndex)
    -- print("最终大奖索引>>>>>>>>",lastAwardIndex)
    local confData = conf.ActivityConf:getMulActById(self.mulActId)
    if confData.title_icon then
        self.titleIcon.url = UIPackage.GetItemURL("robtreasure" , confData.title_icon)
    else
        self.titleIcon.url = UIPackage.GetItemURL("robtreasure" , "duobaoqibing_001")
    end
    self.confData = conf.ActivityConf:getGridData(confData.award_pre)
    for i=1,#self.confData do
        local awards = self.confData[i].awards_normal[1]
        local awards_g = self.confData[i].awards_g
        if #self.confData == i then
            awards = self.confData[i].awards_normal[lastAwardIndex]
        end
        if awards_g then
            local sex = cache.PlayerCache:getSex()
            if sex == 2 then
                if #self.confData == i then
                    awards = awards_g[lastAwardIndex]
                else
                    awards = awards_g[1]
                end
            end
        end
        if awards then
            local obj = self.gridList[i]
            local isquan = false
            if not self.confData[i].isquan then
                isquan = true
            end
            local itemInfo = {mid = awards[1],amount = awards[2],bind = awards[3],isquan = isquan,amountScale = {x=1.5,y=1.5}}
            GSetItemData(obj, itemInfo, true)
        end
    end
end

-- 变量名：times   说明：投掷次数
-- 变量名：lastTime    说明：剩余活动时间
-- 变量名：dbTimes 说明：夺宝次数
-- 变量名：point   说明：随机总点数
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- array<string>
-- 变量名：records 说明：记录
-- 变量名：reqType 说明：0:显示 1:夺宝
-- 变量名：lastAwardIndex  说明：最终大奖索引
-- 变量名：currStep    说明：当前位置
-- 变量名：mulActId    说明：多开活动id
function RobTreasureView:setData(data)
    self.data = data
    self.diceIcon.visible = false
    self.mulActId = data.mulActId
    -- local needYb = conf.ActivityConf:getHolidayGlobal("dbqb_yb_times")
    -- local textData = clone(language.rob04)
    -- textData[2].text = string.format(textData[2].text,(needYb - data.czYb%needYb))
    self.needYbTxt.text = ""--mgr.TextMgr:getTextByTable(textData)
    --设置格子奖励
    self:initGrid(data.lastAwardIndex+1)

    self.lastCount.text = self.costYb[1][2]
    --记录
    self.recordLab.text = ""
    for k,v in pairs(data.records) do
        local strTab = string.split(v,"|")
        local roleName = strTab[1] or ""
        local awardsStr = ""
        local mid = strTab[2] or 0
        local hert = ChatHerts.SYSTEMPRO..mid..ChatHerts.SYSTEMPRO
        local name = conf.ItemConf:getName(mid)
        local color = conf.ItemConf:getQuality(mid)
        awardsStr = mgr.TextMgr:getQualityStr1(name, color, hert)
        self.recordLab.text = self.recordLab.text .. string.format(language.rob01, mgr.TextMgr:getTextColorStr(roleName,7), awardsStr)
        self.recordLab.onClickLink:Add(self.onClickLinkText,self)
    end

    self.decTxt.text = language.rob03

    --活动剩余时间
    if self.timer then
        self:removeTimer(self.timer)
    end
    self.lastTime = data.lastTime
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
    self.lastTimeTxt.text = GGetTimeData3(self.lastTime)

    local sex = cache.PlayerCache:getSex()
    self.myIcon:GetChild("icon").url = UIItemRes.playerIcon[sex]
    if data.reqType == 0 then
        self.currStep = data.currStep
        if data.currStep > 0 then
            local curPos = self.gridList[data.currStep].position--当前位置对应的点
            self.moveIcon.x = curPos.x
            self.moveIcon.y = curPos.y
            -- printt("当前位置>>>>>>>>",self.myIcon.position)
        end
        if self.currStep == 0 then
            self.myIcon.visible = false
        else
            self.myIcon.visible = true
        end
    elseif data.reqType == 1 then
        self.myIcon.visible = true
        if self.effect then
            self:removeUIEffect(self.effect)
            self.effect = nil
        end
        if not self.isAnimationBtn.selected then
            self.effect = self:addEffect(4020156,self.effectP)
            if self.timer1 then
                self:removeTimer(self.timer1)
                self.timer1 = nil
            end
            self.timer1 = self:addTimer(3, 1, function()
                if self.times == 1 then
                    self.diceIcon.visible = true
                    self.diceIcon.url = UIPackage.GetItemURL("_others" , resName[data.point])
                end
                if self.timer2 then
                    self:removeTimer(self.timer2)
                    self.timer2 = nil
                end
                self.timer2 = self:addTimer(0.3,data.point,function()
                    self.currStep = self.currStep + 1
                    if self.currStep > #self.confData then
                        self.currStep = 1
                    end
                    -- print("下一步位置",self.currStep)
                    -- self.myIcon.position = self.gridList[self.currStep].position
                    self.moveIcon.x = self.gridList[self.currStep].x
                    self.moveIcon.y = self.gridList[self.currStep].y
                    if self.currStep == data.currStep then
                        self.clickFlag = true
                        self:setTankuang(data)
                    end
                end)
            end)
        else
            self.clickFlag = true
            self.currStep = data.currStep
            self.moveIcon.x = self.gridList[self.currStep].x
            self.moveIcon.y = self.gridList[self.currStep].y
            self:setTankuang(data)
        end
    end
end

function RobTreasureView:timerClick()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.lastTimeTxt.text = GGetTimeData3(self.lastTime)
    else
        GComAlter(language.vip11)
        self:closeView()
    end
end

function RobTreasureView:onClickLinkText(context)
    local str = string.sub(context.data, 1,1)
    if str == ChatHerts.SYSTEMPRO then
        mgr.ChatMgr:onLinkRecordPros(context.data)
    end
end

function RobTreasureView:onClickThrow(context)
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local costYb = self.times*self.costYb[1][2]
    if self.times > 1 then--十次
        costYb = self.costYb[2][2]
    end
    if myYb >= costYb then
        if self.clickFlag then
            self.clickFlag = false
            local param = {}
            param.type = 2 
            local textData = clone(language.rob06)
            textData[2].text = string.format(textData[2].text,costYb)
            textData[4].text = string.format(textData[4].text,self.times)
            param.richtext = mgr.TextMgr:getTextByTable(textData)
            param.sure = function()
                proxy.ActivityProxy:sendMsg(1030188,{reqType = 1,times = self.times})
            end
            param.cancel = function()
                self.clickFlag = true
            end
            GComAlter(param)
        end
    else
        GComAlter(language.gonggong18)
    end
end

function RobTreasureView:setTankuang(data)
    local param = {}
    param.items = data.items
    param.type = 5
    param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 

    local str = clone(language.rob05)
    if data.point > data.currStep or data.currStep == 51 then
        param.richtext = mgr.TextMgr:getTextByTable(str)
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
    else
        GOpenAlert3(data.items)
    end

end

function RobTreasureView:onClickCharge()
    GOpenView({id = 1042})
end

function RobTreasureView:onClickGuize()
    local confData = conf.ActivityConf:getMulActById(self.mulActId)
    if confData and confData.rule_id then
        GOpenRuleView(confData.rule_id)
    else
        GOpenRuleView(1092)
    end
end

function RobTreasureView:closeView()
    if self.timer1 then
        self:removeTimer(self.timer1)
        self.timer1 = nil
    end
    if self.timer2 then
        self:removeTimer(self.timer2)
        self.timer2 = nil
    end
    self.super.closeView(self)
end

return RobTreasureView