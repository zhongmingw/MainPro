--
-- Author: 
-- Date: 2018-01-31 15:57:39
--
--答题界面
local LanternDtView = class("LanternDtView", base.BaseView)

function LanternDtView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function LanternDtView:initView()
    self.questionTitle = self.view:GetChild("n4")
    self.questionMsgText = self.view:GetChild("n5")
    self.answerTextA = self.view:GetChild("n6")
    self.answerTextB = self.view:GetChild("n7")
    self.timeText = self.view:GetChild("n8")
end

function LanternDtView:initData(data)
    self:setData(data)
    self:addTimer(1, -1, handler(self, self.onTimer))
end

function LanternDtView:setData(data)
    self.time = data.subjectLeftSec or conf.ActivityWarConf:getActGlobal("lantern_question_number")[2]
    local confData = conf.ActivityWarConf:getGuessQuestion(data.subjectId)
    if confData then
        self.questionTitle.text = "第"..mgr.TextMgr:getTextColorStr(data.curQuestionNum, 7).."题"
        self.questionMsgText.text = confData.question
        self.answerTextA.text = confData.opt[1]
        self.answerTextB.text = confData.opt[2]
    end
    self:setChosseIndex(data.answer)
end

function LanternDtView:onTimer()
    self.timeText.text = language.lantern13..mgr.TextMgr:getTextColorStr(self.time, 7)
    self.time = math.max(0, self.time - 1)
end

function LanternDtView:setChosseIndex(index)
    if index == 1 then
        self.answerTextA.text = self.answerTextA.text..language.lantern16
    elseif index == 2 then
        self.answerTextB.text = self.answerTextB.text..language.lantern16
    end
end

return LanternDtView