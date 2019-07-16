--
-- Author: 
-- Date: 2018-07-23 14:11:08
--

local XianLvPKMainView = class("XianLvPKMainView", base.BaseView)

local AwardShowPanel = import(".AwardShowPanel")--奖励展示
local PkPanel = import(".PkPanel")--PK

function XianLvPKMainView:ctor()
    XianLvPKMainView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XianLvPKMainView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local ruleBtn = self.view:GetChild("n26")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    
    self.c1 = self.view:GetController("c1")

    -- self.c1.onChanged:Add(self.onController1,self)

    self.titleIcon = self.view:GetChild("n0"):GetChild("n6")


    self.awardShowPanel = AwardShowPanel.new(self)
    self.pkPanel = PkPanel.new(self)

end

function XianLvPKMainView:initData(data)
    self.c1.selectedIndex = data and data.index and data.index - 1 or 0

    local hxsTime = conf.XianLvConf:getValue("hxs_race_time")--海选赛时间
    local zbsTime1 = conf.XianLvConf:getValue("zbs_race_time01")--争霸赛第一场时间
    local zbsTime2 = conf.XianLvConf:getValue("zbs_race_time02")--争霸赛第二场时间
    --海选赛开始
    self.hxsTimeBegin = {}
    self.hxsTimeBegin.hour = math.floor(hxsTime[1]/3600)  
    self.hxsTimeBegin.min = math.floor((hxsTime[1]%3600)/60)
    self.hxsTimeBegin.sec = (hxsTime[1]%3600)%60
    --海选赛结束
    self.hxsTimeEnd = {}
    self.hxsTimeEnd.hour = math.floor(hxsTime[2]/3600)  
    self.hxsTimeEnd.min = math.floor((hxsTime[2]%3600)/60)
    self.hxsTimeEnd.sec = (hxsTime[2]%3600)%60

    --争霸赛一场结束
    self.zbsTimeEnd = {}
    self.zbsTimeEnd.hour = math.floor(zbsTime1[2]/3600)  
    self.zbsTimeEnd.min = math.floor((zbsTime1[2]%3600)/60)
    self.zbsTimeEnd.sec = (zbsTime1[2]%3600)%60

    --争霸赛二场结束
    self.zbsTimeEnd2 = {}
    self.zbsTimeEnd2.hour = math.floor(zbsTime2[2]/3600)  
    self.zbsTimeEnd2.min = math.floor((zbsTime2[2]%3600)/60)
    self.zbsTimeEnd2.sec = (zbsTime2[2]%3600)%60


    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
   
    self.refTime = 0
end

function XianLvPKMainView:setData(data)
    self.msgId = data.msgId
    local actData = cache.ActivityCache:get5030111()
    if self.pkPanel and data.msgId == 5540101 then
        self.pkPanel:addMsgCallBack(data)
        self.serverTime = data.serverTime
        if actData.acts[1135] and actData.acts[1135] == 1 then 
            self.view:GetChild("n2").visible = false
        else
            self.view:GetChild("n2").visible = true
        end
    elseif self.pkPanel and data.msgId == 5540201 then
        self.pkPanel:addMsgCallBack(data)
        self.serverTime = data.serverTime
        if actData.acts[5009] and actData.acts[5009] == 1 then 
            self.view:GetChild("n2").visible = false
        else
            self.view:GetChild("n2").visible = true
        end
    end
    if self.awardShowPanel then
        self.awardShowPanel:addMsgCallBack(data)
    end
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(data.mulActiveId)
    print("多开id",data.mulActiveId)
    local titleIconStr = self.mulConfData and self.mulConfData.title_icon or "xianlvpk_008"
    self.titleIcon.url = UIPackage.GetItemURL("xianlvpk" , titleIconStr)

    if not self.timer then
        self:onTimer()
        self.timer = self:addTimer(1, -1, handler(self,self.onTimer))
    end
end

function XianLvPKMainView:refreshHaiXuanPlan()
    if self.pkPanel then
        self.pkPanel:setHaiXunaPlan()
    end
end

function XianLvPKMainView:onTimer()
    -- local serverTime =  mgr.NetMgr:getServerTime()
    if self.serverTime then
        self.serverTime = self.serverTime + 1 
    end
    local timeTab = os.date("*t",self.serverTime)

    -- print("跨服时间>>>>>>>>>",timeTab.hour,timeTab.min,timeTab.sec)
  
    local nowTime = {}
    nowTime.hour = tonumber(timeTab.hour)
    nowTime.min = tonumber(timeTab.min)
    nowTime.sec = tonumber(timeTab.sec)
    self:compareTime(nowTime,self.hxsTimeBegin)

    self:compareTime(nowTime,self.hxsTimeEnd)

    self:compareTime(nowTime,self.zbsTimeEnd)

    self:compareTime(nowTime,self.zbsTimeEnd2)


end

function XianLvPKMainView:compareTime(nowTime,tarTime)
    local nowHour = nowTime.hour
    local nowMin = nowTime.min
    local nowSec = nowTime.sec

    local tarHour = tarTime.hour
    local tarMin = tarTime.min
    local tarSec = tarTime.sec
    -- print("目标时间",tarHour,tarMin,tarSec)
    if nowHour == tarHour and tarMin == nowMin and nowSec == tarSec + 2 then --math.abs(nowSec - tarSec) <= 3 then
        if self.msgId == 5540101 then
            proxy.XianLvProxy:sendMsg(1540101,{reqType = 0})
        elseif self.msgId == 5540201 then
            proxy.XianLvProxy:sendMsg(1540201,{reqType = 0})
        end
    end
end

function XianLvPKMainView:onClickRule()
    GOpenRuleView(1112)
end

function XianLvPKMainView:onBtnClose()
    self:closeView()
end

return XianLvPKMainView