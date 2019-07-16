--
-- Author: Your Name
-- Date: 2017-10-19 21:27:40
--

local FlameAnswer = class("FlameAnswer", base.BaseView)

function FlameAnswer:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function FlameAnswer:initView()
    local closeBtn = self.view:GetChild("n15")
    closeBtn.onClick:Add(self.closeQuestion,self)
    self.listView = self.view:GetChild("n17")
    self.questionSec = self.view:GetChild("n4")
    self.questionNum = self.view:GetChild("n3")
    self.rightNumTxt = self.view:GetChild("n5")
    self.answerTime = 0--答题时间
end

function FlameAnswer:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function FlameAnswer:celldata( index,obj )
    local data = self.data.optInfo[index+1]
    if data then
        local answer = obj:GetChild("title")
        answer.text = data
        obj.data = index + 1
        obj.onClick:Add(self.onClickSelect,self)
        local rightImg = obj:GetChild("n4")
        if index == self.data.rightAnswers and self.data.result ~= 0 then
            rightImg.visible = true
        else
            rightImg.visible = false
        end
        if index+1 == self.data.myAnswer and self.data.result ~= 0 then
            -- print("第几题",index)
            obj.selected = true
        else
            obj.selected = false
        end
    end
end

function FlameAnswer:onClickSelect(context)
    local index = context.sender.data
    self.answer = index
    -- print("自己选择的答案",self.answer)
end

function FlameAnswer:initData()
    self:initListView()
    self.answer = nil --当前选择的答案
    self.timers = self:addTimer(1, -1, handler(self,self.timeTick))
end

function FlameAnswer:timeTick()
    local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime()) --当前服务器时间转化为当天秒数
    local questionTime = conf.BangPaiConf:getValue("gang_question_time")
    if curTime >= questionTime[1] and curTime <= questionTime[2]-60 then
        self.answerTime = 60-(curTime%60)
        self.questionSec.text = "(" .. self.answerTime .. ")"
        if self.answerTime <= 1 or self.answerTime >= 59 then
            proxy.BangPaiProxy:sendMsg(1250505,{reqType = 1})
        end
    else
        self.questionSec.text = ""
        self.answerTime = -1
        self:closeView()
    end
end

--答题面板设置
function FlameAnswer:setQuestion(data)
    self.data = data
    local questionData = conf.BangPaiConf:getQuestionData(data.titleId)
    local questionTitleTxt = self.view:GetChild("n2")
    questionTitleTxt.text = questionData.question
    if data.optInfo then
        self.listView.numItems = #data.optInfo
    end
    self.questionNum.text = string.format(language.bangpai164,data.questionNum)
    self.rightNumTxt.text = language.bangpai165 .. data.rightNum .. "/4"
    -- print("正确答案,我的答案",self.data.rightAnswers,self.data.myAnswer)
    local answerBtn = self.view:GetChild("n6")
    answerBtn.onClick:Add(self.onClickAnswer,self)
end

--答题
function FlameAnswer:onClickAnswer()
    if self.data.result == 0 then--当前可答题
        if self.answer then
            proxy.BangPaiProxy:sendMsg(1250505,{reqType = 2,answer = self.answer})
        else
            GComAlter(language.bangpai168)
        end
    else
        GComAlter(language.bangpai169)
    end
end

--广播刷新面板
function FlameAnswer:refreshView(data)
    self.questionNum.text = string.format(language.bangpai164,data.questionNum)
end

function FlameAnswer:closeQuestion()
    self:closeView()
end

return FlameAnswer