--
-- Author: Your Name
-- Date: 2018-09-20 19:12:06
--

local DaTiView = class("DaTiView", base.BaseView)

function DaTiView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function DaTiView:initView()
    local quiteBtn = self.view:GetChild("n21")
    quiteBtn.onClick:Add(self.onClickQuite,self)

    self.questionTitle = self.view:GetChild("n22")
    self.questionMsgText = self.view:GetChild("n16")
    self.timeText = self.view:GetChild("n15")
    self.c1 = self.view:GetController("c1")

    local decTxt = self.view:GetChild("n24")
    decTxt.text = language.gq28
    --等待时间
    self.waitTimeTxt = self.view:GetChild("n2")
    self.waitTime = 0

    --活动倒计时
    self.lastTimeTxt1 = self.view:GetChild("n9")
    self.lastTimeTxt2 = self.view:GetChild("n10")

    --选择按钮
    self.sureBtn = self.view:GetChild("n13")
    self.sureBtn.onClick:Add(self.onClickSure,self)
    self.notBtn = self.view:GetChild("n14")
    self.notBtn.onClick:Add(self.onClickNot,self)
    local leftBtn = self.view:GetChild("n20")
    local rightBtn = self.view:GetChild("n19")
    leftBtn.onClick:Add(self.onClickSure,self)
    rightBtn.onClick:Add(self.onClickNot,self)

    self.questionSum = conf.ActivityWarConf:getActGlobal("lantern_question_number")[1]--答题总数
    if self:isKeJu() then
        self.questionSum = conf.ActivityConf:getKeJuGlobal("kj_question_number")[1]
    end
end

--是否是科举答题
function DaTiView:isKeJu()
    local sId = cache.PlayerCache:getSId()
    return mgr.FubenMgr:isKeju(sId)
end

function DaTiView:initData(data)
    local netTime = mgr.NetMgr:getServerTime()
    --活动结束时间
    self.endTime = cache.PlayerCache:getRedPointById(20166)
    --准备时间
    local waitTime = conf.ActivityConf:getHolidayGlobal("lantern_pre_time")
    if self:isKeJu() then
        self.endTime = cache.PlayerCache:getRedPointById(20210)
        waitTime = conf.ActivityConf:getKeJuGlobal("kj_pre_time")
    end
    local t = GGetTimeData(self.endTime - netTime)
    self.lastTimeTxt1.text = string.format("%02d",t.min)
    self.lastTimeTxt2.text = string.format("%02d",t.sec)
    if data.actOpenTime then
        self.waitTime = data.actOpenTime + waitTime - netTime
        if self.waitTime > 0 then
            self.c1.selectedIndex = 0
            self.waitTimeTxt.text = self.waitTime
        else
            self.c1.selectedIndex = 1
        end
    end
    self:setData(data)
    self:addTimer(1, -1, handler(self, self.onTimer))
end

function DaTiView:setData(data)
    local questionSec = conf.ActivityWarConf:getActGlobal("lantern_question_number")[2]
    local confData = conf.ActivityWarConf:getGuessQuestion(data.subjectId)
    if self:isKeJu() then
        questionSec = conf.ActivityConf:getKeJuGlobal("kj_question_number")[2]
        confData = conf.ActivityConf:getGuessQuestion(data.subjectId)
    end
    self.time = data.subjectLeftSec or questionSec
    if confData then
        self.questionTitle.text = "第"..mgr.TextMgr:getTextColorStr(data.curQuestionNum, 7).."题"
        self.questionMsgText.text = confData.question
    end
end

function DaTiView:onTimer()
    self.timeText.text = self.time
    self.time = math.max(0, self.time - 1)

    if self.waitTime > 0 then
        self.waitTime = self.waitTime - 1
        self.waitTimeTxt.text = self.waitTime
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
    local netTime = mgr.NetMgr:getServerTime()
    local t = GGetTimeData(self.endTime - netTime)
    self.lastTimeTxt1.text = string.format("%02d",t.min)
    self.lastTimeTxt2.text = string.format("%02d",t.sec)
    -- local data = cache.ActivityWarCache:getCdmhData()
    -- if self:isKeJu() then
    --     data = cache.ActivityCache:getCdmhData()
    -- end
    -- if data then
    --     if self.questionSum == data.curQuestionNum and self.time == 0 then
    --         self.timeText.text = ""
    --         self.questionTitle.text = ""
    --         local roleName = data.scoreRankings and data.scoreRankings[1].roleName or ""
    --         self.questionMsgText.text = string.format(language.gq29,roleName)
    --     end
    -- end
end

function DaTiView:onClickSure()
    local regions = conf.ActivityWarConf:getActGlobal("lantern_regions")
    if self:isKeJu() then
        regions = conf.ActivityConf:getKeJuGlobal("kj_regions")
    end
    local pos = Vector3.New(regions[1][1],gRolePoz,regions[1][2])
    gRole:moveToPoint(pos, 50, function()
        
    end)
end

function DaTiView:onClickNot()
    local regions = conf.ActivityWarConf:getActGlobal("lantern_regions")
    if self:isKeJu() then
        regions = conf.ActivityConf:getKeJuGlobal("kj_regions")
    end
    local pos = Vector3.New(regions[2][1],gRolePoz,regions[2][2])
    gRole:moveToPoint(pos, 50, function()
        
    end)
end

function DaTiView:onClickQuite()
    local param = {}
    param.type = 2
    param.richtext = language.gonggong96
    param.sure = function()
        mgr.FubenMgr:quitFuben()
    end
    param.cancel = function()
        
    end
    GComAlter(param)
end

return DaTiView