--
-- Author: 
-- Date: 2018-12-18 19:17:38
--

local YuanDanZhuanPan = class("YuanDanZhuanPan", base.BaseView)

local TransitionDelay  = {
    [1] = 0.13,
    [2] = 0.25,
    [3] = 0.38,
    [4] = 0.5,
    [5] = 0.63,
    [6] = 0.75,
    [7] = 0.88,
    [8] = 1,
}
--特效下标
local AwardPos = {
    [1001] = 1,
    [1002] = 2,
    [1003] = 3,
    [1004] = 4,
    [1005] = 5,
    [1006] = 6,
    [1007] = 7,
    [1008] = 8,
}

function YuanDanZhuanPan:ctor()
    YuanDanZhuanPan.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function YuanDanZhuanPan:initView()
    local closeBtn = self.view:GetChild("n4")
    self:setCloseBtn(closeBtn)
    self.titleIcon = self.view:GetChild("n52")

    self.leftTime = self.view:GetChild("n11")

    local ruleText = self.view:GetChild("n12")
    ruleText.text = language.ydzp01

    self.logsList = self.view:GetChild("n22")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()
    --充值
    self.curCharge = self.view:GetChild("n15")
    --拥有抽奖次数
    self.chouTime = self.view:GetChild("n18")

    self.zhuanBtn = self.view:GetChild("n13")
    self.zhuanBtn.onClick:Add(self.onClickBtn,self)


    self.t0 = self.view:GetTransition("t0")
    self.tList1 = {}
    self.awardsList = {}
    for i=1,8 do
        local tTransition = self.view:GetTransition("t"..i)
        table.insert(self.tList1,tTransition)
        local award = self.view:GetChild("n"..(23+i))
        award.data = i
        table.insert(self.awardsList, award)
    end
    --光标
    self.tEffect1 = self.view:GetChild("n23")

end

function YuanDanZhuanPan:initData()
    --正在播放动效
    self.isPlaying = false

    
end
function YuanDanZhuanPan:addMsgCallBack(data)
    printt("转盘",data)
    self.data  = data

      --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    local titleIconStr = self.mulConfData.title_icon or "chongzhichoubangyuan_019"
    self.titleIcon.url = UIPackage.GetItemURL("yuandan" , titleIconStr)
    local confData = conf.YuanDanConf:getZhuanPanData( self.mulConfData.award_pre)
    for k,v in pairs(self.awardsList) do
        local data = confData[v.data]
        local itemData = {mid = PackMid.gold,amount = 0 ,bind = 1,icon = UIItemRes.ingotType[1],isquan = 0}
        GSetItemData(v:GetChild("n0"), itemData)
        v:GetChild("n1").text = data.base.."*"..(data.nums /100)
    end
    self.time = data.leftTime
    --充值数
    self.curCharge.text = data.rechargeSum
    --祈福转盘获得抽奖次数的充值数
    local num = conf.YuanDanConf:getValue("ny_recharge_yb")
    --次数上限
    local zhuanMax = conf.YuanDanConf:getValue("ny_recharge_max_count")
    --可转的极限次数
    local limitTime = math.min(zhuanMax,  math.floor(tonumber(data.rechargeSum) / tonumber(num)))
    --剩余转盘次数
    local leftZhuan = limitTime - tonumber(data.lotteryCount)

    if data.lotteryCount >= zhuanMax then
        leftZhuan = 0
    end
    self.chouTime.text = leftZhuan
    self.zhuanBtn.grayed = leftZhuan <= 0
    self.view:GetChild("red").visible = leftZhuan > 0


    self.logsList.numItems = #data.logs

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if data.reqType == 1 then
        self:playComEffect()
    end
end

function YuanDanZhuanPan:playComEffect()
    self.isPlaying = true
    -- self.tEffect1.visible = true
    self.t0:Play()
    self:addTimer(2.25, 1, function ()
        local pos = AwardPos[tonumber(string.sub(self.data.cid,5,8))]
        self.tList1[pos]:Play()
        self:addTimer(TransitionDelay[pos], 1, function ()
            self:addTimer(0.8,1 , function ()--0.8秒后打开奖励界面
                -- self.tEffect1.visible = false
                self.tEffect1.rotation = 0
                GOpenAlert3(self.data.items)
                self.isPlaying = false
            end)
        end)
    end)
end


function YuanDanZhuanPan:cellLogData(index, obj)
    local data = self.data.logs[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local ybNum = strTab[2] or 0
    -- local bei = string.sub(strTab[3],2)
    -- local str = (ybNum*tonumber(bei)).."绑元"
    local awardsStr = mgr.TextMgr:getTextColorStr(ybNum, 10)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.ydzp03, mgr.TextMgr:getTextColorStr(rolename,10),awardsStr)
end


function YuanDanZhuanPan:onTimer()
    if self.time > 86400 then 
        self.leftTime.text = GGetTimeData2(self.time)
    else
        self.leftTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function YuanDanZhuanPan:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function YuanDanZhuanPan:onClickBtn(context)
    local btn = context.sender
    local zhuanLimit = conf.YuanDanConf:getValue("ny_recharge_max_count")
    if self.data.lotteryCount >= zhuanLimit then
        GComAlter(language.ydzp04)
    else
        if btn.grayed then
            GComAlter(language.ydzp05)
        else
            if not self.isPlaying then
                proxy.YuanDanProxy:sendMsg(1030681,{reqType = 1})
            end
        end
    end
end

return YuanDanZhuanPan