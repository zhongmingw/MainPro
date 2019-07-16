--
-- Author: 
-- Date: 2018-12-20 13:26:40
--
local LightImg = {
    "jiyihuandeng_015",
    "jiyihuandeng_016",
    "jiyihuandeng_017",
}

local ColumnGap = {
    [3] = 117,
    [4] = 87,
    [5] = 62,

}

local ColumnGap2 = {
    [2] = 117,
    [3] = 87,
}
local PosX = {
    [2] = 325 ,
    [3] = 338 ,
}


local JiYiHuaDengView = class("JiYiHuaDengView", base.BaseView)

function JiYiHuaDengView:ctor()
    JiYiHuaDengView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
    self.oldCdTime = 0
    self.selectTypeList = {[1]=0,[2]=0,[3]=0,[4]=0,[5]= 0}
end



function JiYiHuaDengView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n6"))

    local ruleBtn = self.view:GetChild("n18")  
    ruleBtn.onClick:Add(self.onBtnCallback,self)
    self.rulePanel = self.view:GetChild("n25")
    local ruleTxt = self.rulePanel:GetChild("n1"):GetChild("n1")
    ruleTxt.text = language.dz28
    self.rulePanel.visible = false

    local btn2 = self.view:GetChild("n10")  
    btn2.onClick:Add(self.onBtnCallback,self)

    self.timeBar = self.view:GetChild("n6")
    --回合
    self.huiHeTxt = self.view:GetChild("n20")
    self.roleList = {}
    for i=1,3 do
        local role = self.view:GetChild("n"..(6+i))
        role.data = i
        table.insert(self.roleList,role)
    end
    --记忆列表
    self.jiYiList = self.view:GetChild("n11")
    self.jiYiList.itemRenderer = function(index,obj)
        self:cellJiYiData(index, obj)
    end
    self.jiYiList.onClickItem:Add(self.onClickJiYiList,self)

    --恢复列表
    self.huiFuList = self.view:GetChild("n12")
    self.huiFuList.itemRenderer = function(index,obj)
        self:cellHuiFuData(index, obj)
    end
    self.huiFuList.onClickItem:Add(self.onClickHuiFuList,self)

    --选择列表
    self.choseList = self.view:GetChild("n13")
    self.choseList.itemRenderer = function(index,obj)
        self:cellChoseData(index, obj)
    end
    self.choseList.onClickItem:Add(self.onClickChoseList,self)

    --输入框
    self.inPutTxt = self.view:GetChild("n15")
    self.inPutTxt.promptText = language.dz27

    self.sendBtn = self.view:GetChild("n17")
    self.sendBtn.onClick:Add(self.onSend,self)
    self.sendMask = self.sendBtn:GetChild("n5").asImage
    self.sendMask.fillAmount = 0


    --表情
    local phizBtn = self.view:GetChild("n16")
    phizBtn.onClick:Add(self.onBtnCallback,self)
    self.phizPanel = self.view:GetChild("n24")
    self.phizPanel.visible = false

    self.phizList = self.phizPanel:GetChild("n51")
    self.phizList.itemRenderer = function(index,obj)
        self:cellPhizData(index, obj)
    end
    self.phizList.numItems = ChatType.phizNum
    self.phizList.onClickItem:Add(self.onPhizClickCall,self)


    local sureBtn =  self.view:GetChild("n22")
    sureBtn.onClick:Add(self.onBtnCallback,self)
    self.sureBtn = sureBtn
    self.sureBtnC1 = sureBtn:GetController("c1")



    --弹幕开关按钮
    self.openDanMuBtn = self.view:GetChild("n19")
    self.openDanMuBtn.onClick:Add(self.onClickDanMuBtn,self)

    --记忆时间
    self.memoryTime = conf.DongZhiConf:getGlobal("ws_memory_time")
    --答题时间
    self.answerTime = conf.DongZhiConf:getGlobal("ws_answer_time")
    --展示时间
    self.showTime = conf.DongZhiConf:getGlobal("ws_show_time")

    local cont = conf.DongZhiConf:getGlobal("ws_round_time")
    --回合次数
    self.roundNum = cont[1]
    --回合时间
    self.roundTime = cont[2]

    --准备时间
    self.preTime = conf.DongZhiConf:getGlobal("ws_pre_time")

    --是否提交过答案
    self.isPutIn = false

    --默认打开弹幕
    self.isOpenDanMu = true

    self.myRank = self.view:GetChild("n21")

    cache.ActivityCache:setDanMuIsOpen(true)

    self.sendCDTime = conf.DongZhiConf:getGlobal("ws_danmu_cd")

    self.c1 = self.view:GetController("c1")


end

function JiYiHuaDengView:initData(data)
    if data then
        self:addMsgCallBack(data)
        -- self:releaseTimer()
        -- if not self.actTimer then
        --     self:onTimer()
        --     self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
        -- end
    end
end


function JiYiHuaDengView:addMsgCallBack(data)
    self.data = data
    -- printt("记忆花灯消息返回",data)
    if data.reqType == 2 then
        GComAlter(language.dz30)
        self.isPutIn = true
    end
    
    --设置提交按钮状态
    if self.isPutIn then
        self.sureBtnC1.selectedIndex = 1
    else
        self.sureBtnC1.selectedIndex = 0
    end
    local round = 1
    if data.curRound == 0 then
        self.huiHeTxt.text = ""
        round = 1
    else
        round = data.curRound
        self.huiHeTxt.text = string.format(language.dz10,data.curRound,tonumber(self.roundNum))
    end
 

    --当前回合的剩余秒数
    self.curSec = data.curSec or 60

    local stage = self:whichStage()
    if stage == 3 then
        self.leftTime = self.curSec
    elseif stage == 2 then
        self.leftTime = self.curSec - self:getLeftTimeByStage(3)
    elseif stage == 1 then
        self.leftTime = self.curSec - self:getLeftTimeByStage(3) - self:getLeftTimeByStage(2)
    elseif stage == 0 then
        self.leftTime = self:getLeftTimeByStage(0)
    end
    self.c1.selectedIndex = stage
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    --设置人物头像
    if data.curRound == 0 then
        self:setRoleIcon()
        self.myRank.text = language.rank04
        --我的排名
        if data.ranking == 0 then
            self.myRank.text = language.rank04
        else
            self.myRank.text = string.format(language.dz26,data.ranking,data.myScore)
        end
    elseif stage == 1 or stage == 3 or (stage == 2 and data.reqType ~= 2) then --1,3阶段， 2阶段且没有提交，可设置
        self:setRoleIcon(data.scoreRankings)
           --我的排名
        if data.ranking == 0 then
            self.myRank.text = language.rank04
        else
            self.myRank.text = string.format(language.dz26,data.ranking,data.myScore)
        end
    end
       --回合数据

    self.huiHeData = conf.DongZhiConf:getDongZhiJiaoYan(round)

    self.jiYiList.numItems = self.huiHeData.memory
    self.jiYiList.columnGap  = ColumnGap[self.huiHeData.memory]

    
    self.huiFuList.numItems = self.huiHeData.restore
    self.huiFuList.columnGap  = ColumnGap[self.huiHeData.restore]



    self.choseList.numItems = self.huiHeData.select
    self.choseList.columnGap  = ColumnGap2[self.huiHeData.select]
    self.choseList.x = PosX[self.huiHeData.select]

end
--哪个阶段
--0:准备阶段，1：记忆阶段。2：答题阶段。3展示阶段
function JiYiHuaDengView:whichStage()
    local _type  = 0
    if self.data and self.data.curRound == 0 then
        _type = 0
    else
        --当前回合剩余时间
        if tonumber(self.roundTime) - self.curSec <= tonumber(self.memoryTime) then
            _type = 1
        elseif tonumber(self.roundTime) - self.curSec <= tonumber(self.answerTime) + tonumber(self.memoryTime) then
            _type = 2
        else
            _type = 3
        end
    end
    return _type
end
--根据阶段类型获得本阶段倒计时
function JiYiHuaDengView:getLeftTimeByStage(stage)
    --阶段类型
    local time = 0
    if stage == 0 then--准备
        local severTime = mgr.NetMgr:getServerTime()
        time = self.data.actStartTime + self.preTime - severTime
    elseif stage == 1 then--记忆
        time = self.memoryTime
    elseif stage == 2 then--答题
        time = self.answerTime
    elseif stage == 3 then--展示
        time = self.showTime  
    end
    return time
end

function JiYiHuaDengView:getTimeBarMax(stage)
    --阶段类型
    local time = 0
    if stage == 0 then--准备
        time = self.preTime
    elseif stage == 1 then--记忆
        time = self.memoryTime
    elseif stage == 2 then--答题
        time = self.answerTime
    elseif stage == 3 then--展示
        time = self.showTime  
    end
    return time
end

function JiYiHuaDengView:onTimer()
    if self.data.curRound ~= 0 then
        self.curSec = self.curSec  - 1
    end
    self.stage = self:whichStage()

    self.timeBar.max = self:getTimeBarMax(self.stage)

    self.timeBar.value = self.leftTime
    self.leftTime = self.leftTime - 1

    if self.leftTime <= 0  then
        if self.stage == 0 then --这是从准备阶段过渡来的
            -- GComAlter(language.dz17)

        elseif self.stage == 1 then
            GComAlter(language.dz18)
        elseif self.stage == 3 and self.curSec > 0 then
            GComAlter(language.dz19)
        end
    end
    --print("当前回合的剩余秒数",self.curSec,"当前倒计时",self.leftTime,"当前阶段",self.stage)
    if (self.curSec <= 0 and  self.curSec >= -1) or self.leftTime <= 0 then--大于-1是防止一直发送请求
        local nullTable = {}
        proxy.DongZhiProxy:sendMsg(1030676,{reqType = 0,answer = {}})
        -- print("发送消息~~~~~~~~~~~~~~~~~~~~~~")
    end
    -- local var = cache.PlayerCache:getRedPointById(20214) or 0
    -- if var <= 0 then
    --     self.timeBar.value = 0
    --     self:releaseTimer()
    -- end

end

function JiYiHuaDengView:refeshCurSec(time)
    GComAlter(language.dz17)
    -- self.curSec = time

    self.isPutIn = false--每回合刷新，提价答案置false
    self.selectTypeList = {[1]=0,[2]=0,[3]=0,[4]=0,[5]= 0}

end

function JiYiHuaDengView:setRoleIcon(rankdata)
    local frameUrl = UIPackage.GetItemURL("huadeng" , "jiyihuandeng_009")
    for k,v in pairs(self.roleList) do
        local c1 = v:GetController("c1")
        local name = v:GetChild("title")
        local rank = v:GetChild("n5")
        local data = rankdata and  rankdata[k]
        if data then
            c1.selectedIndex = 0
            local t = {level = data.level , roleIcon = data.roleIcon,roleId = data.roleId,frameUrl =frameUrl }
            -- GBtnGongGongSuCai_050(v,t)
            self:setInfoRole(v,t)
            name.text = data.roleName
            rank.text = string.format(language.dz12,data.ranking,data.score)
        else
            name.text = "虚位以待"
            rank.text = ""
            c1.selectedIndex = 1
        end
    end
end

function JiYiHuaDengView:setInfoRole(obj,data)
    local roleicon = obj:GetChild("icon"):GetChild("n3")
    local frameIcon = obj:GetChild("n1")
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(t)
        if roleicon then
            roleicon.url = t.headUrl
        end
    end)
    roleicon.url = t.headUrl
    frameIcon.url = data.frameUrl
end


function JiYiHuaDengView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end

end


function JiYiHuaDengView:cellJiYiData(index, obj)
    -- print("渲染记忆列表",self.stage)
    local c1 = obj:GetController("c1")
    local c2 = obj:GetController("c2")
    local icon = obj:GetChild("icon")
    c1.selectedIndex = 0
    if self.stage == 0 or self.stage == 2 then--背面,
        c2.selectedIndex = 0
    else
        c2.selectedIndex = 1
    end
    local data = self.data.curAnswer[index+1]
    if data and data ~= 0 then
        icon.url = UIPackage.GetItemURL("huadeng" , LightImg[data])
    end
end

function JiYiHuaDengView:onClickJiYiList(context)
    local cell = context.data


end

function JiYiHuaDengView:cellHuiFuData(index, obj)
    -- print("渲染恢复列表",self.stage)

    local c1 = obj:GetController("c1")
    local c2 = obj:GetController("c2")
    local icon = obj:GetChild("icon")
    if self.stage == 0 or self.stage == 1 then--背面,
        c1.selectedIndex = 0
        c2.selectedIndex = 0
        icon.url = ""
    elseif self.stage == 1 then--记忆阶段
        c1.selectedIndex = 0
        c2.selectedIndex = 1
        icon.url = ""

    elseif self.stage == 2 then--答题
        c2.selectedIndex = 1
        local myAnswer = self.selectTypeList[index+1]
        if myAnswer and myAnswer ~= 0  then

            icon.url = UIPackage.GetItemURL("huadeng" , LightImg[myAnswer])
        else
            icon.url = ""
        end
    elseif self.stage  == 3 then--展示阶段
        c2.selectedIndex = 1
        local myAnswer = self.selectTypeList[index+1]
        if myAnswer and myAnswer ~= 0  then
            icon.url = UIPackage.GetItemURL("huadeng" , LightImg[myAnswer])
        else
            icon.url = ""--没有答题
            c1.selectedIndex = 2--都是错的
        end
        local rightAnswer = self.data.curAnswer[index+1]
        if rightAnswer and myAnswer then
            if rightAnswer ==  myAnswer then
                c1.selectedIndex = 1--答对了
            else
                c1.selectedIndex = 2--答错了
            end
        end
    end
    obj.data = {index = index+1}
end
--点击恢复区
function JiYiHuaDengView:onClickHuiFuList(context)
    local cell = context.data
    local data = cell.data
    if self.stage == 0 then
        GComAlter(language.dz16)
        return 
    elseif self.stage == 1 then
        GComAlter(language.dz15)
        return
    elseif self.stage == 3 then
        GComAlter(language.dz20_01)
        return
    end
    if  self.stage == 2 then
        --设置恢复区数据
        if not self.isPutIn then
            self.selectTypeList[data.index] = self.choseType or 0
            -- for k,v in pairs(self.selectTypeList) do
            --     print("点击内容",k,v,self.choseType)
            -- end
            self.huiFuList.numItems = self.huiHeData.restore
        else
            GComAlter(language.dz29)
        end
    else
        self.selectTypeList = {[1]=0,[2]=0,[3]=0,[4]=0,[5]= 0}
    end
end

function JiYiHuaDengView:cellChoseData(index, obj)
    -- print("渲染选择列表",self.stage)
    local c1 = obj:GetController("c1")
    local c2 = obj:GetController("c2")
    local icon = obj:GetChild("icon")
    c1.selectedIndex = 0
    if self.stage == 0 then--背面,
        c2.selectedIndex = 0
    else
        c2.selectedIndex = 1
    end
    local data = self.data.curAnswerType[index+1]
    if data and data ~= 0  then
        icon.url = UIPackage.GetItemURL("huadeng" , LightImg[data])
    end
    if self.stage == 2 then
        obj.data = data
    end
end
--点击选择列表
function JiYiHuaDengView:onClickChoseList(context)
    local cell = context.data
    if self.stage == 0 then
        GComAlter(language.dz16)
        return 
    end
    self.choseType = cell.data or 1
end

function JiYiHuaDengView:onSend()
    local contentTxt = self.inPutTxt.text
    if string.trim(contentTxt) == "" then
        GComAlter(language.dz13 )
    else
        if self.sendMask.fillAmount > 0 then
            GComAlter(language.dz21)
        else
            local params = {
                type = ChatType.jiyiDanMu,
                content = contentTxt,
                isVoice = 0,
                voiceStr = "",
                tarName = ""
            }
            proxy.ChatProxy:send(1060101,params)
        end
    end
end
--弹幕开关按钮
function JiYiHuaDengView:onClickDanMuBtn()
    self.isOpenDanMu = not self.isOpenDanMu
    -- print("弹幕开关",self.isOpenDanMu)

    cache.ActivityCache:setDanMuIsOpen(self.isOpenDanMu)
    if not self.isOpenDanMu then--不开弹幕
        -- mgr.TipsMgr:disposeDanMu()
        local view = mgr.ViewMgr:get(ViewName.DanMuTipsView)
        if view then
            view:closeView()
        end
    else
        local view = mgr.ViewMgr:get(ViewName.DanMuTipsView)
        if not view then
            mgr.ViewMgr:openView2(ViewName.DanMuTipsView)--弹幕显示层
        end
    end
end




function JiYiHuaDengView:onBtnCallback(context)
    local btn = context.sender
    if btn.name == "n18" then--规则
        self.rulePanel.visible = not self.rulePanel.visible
    elseif btn.name == "n10" then--排名
      mgr.ViewMgr:openView2(ViewName.JiYiRankView)
    elseif btn.name == "n16" then--表情
        self.phizPanel.visible = not self.phizPanel.visible

    elseif btn.name == "n22" then--提交
        -- print("是否提交过答案",self.isPutIn)
        if self.stage == 0 then
            GComAlter(language.dz16)
            return 
        elseif self.stage == 1 then--记忆阶段
            GComAlter(language.dz15)
        elseif self.stage == 2 then--作答阶段
            if not self.isPutIn then
                -- printt("提交内容",self.selectTypeList)
                -- for k,v in pairs(self.selectTypeList) do
                --     print("##",k,v)
                -- end
                proxy.DongZhiProxy:sendMsg(1030676,{reqType = 2,answer = self.selectTypeList})

            else
                GComAlter(language.dz24)--"客官您已经回答过，答案即将揭晓"
            end
        elseif self.stage == 3 then--展示阶段
            GComAlter(language.dz20_01)
        end
    end
end


--表情列表

function JiYiHuaDengView:cellPhizData(index,cell)
    local phizId = index + 1
    if phizId < 10 then
        cell.data = "0"..phizId
    else
        cell.data = phizId
    end
    local imgObj = cell:GetChild("n0")
    imgObj.url = ResPath.phizRes(cell.data)
end

function JiYiHuaDengView:onPhizClickCall(context)
    local cell = context.data
    local index = cell.data
    local len = string.utf8len(self.inPutTxt.text)
    if len >= language.chatNum then--输入限制
        GComAlter(string.format(language.chatSend6, language.chatNum))
        return
    end
    if index then
        self.inPutTxt.text = self.inPutTxt.text.."#"..index
    else
        self.inPutTxt.text = mgr.TextMgr:getPhiz(index)
    end
    self.phizPanel.visible = false
end




--刷新发送CD
function JiYiHuaDengView:refreshSendCD()
    self.inPutTxt.text = ""
    self.oldCdTime = mgr.NetMgr:getServerTime()
    self:coolChatCD()
end
--发送倒计时
function JiYiHuaDengView:coolChatCD()
    if not self.cdTimer then--整理cd
        self.cdActionTime = self.sendCDTime - (mgr.NetMgr:getServerTime() - self.oldCdTime)
        self:sendCDTimer()
        self.cdTimer = self:addTimer(0.2, -1, handler(self,self.sendCDTimer))
    end
end
function JiYiHuaDengView:sendCDTimer()
    local leftTime = mgr.NetMgr:getServerTime() - self.oldCdTime
    if leftTime >= self.sendCDTime then
        self:releaseSendTimer()
        self.sendMask.fillAmount = 0
        return
    end
    if self.cdActionTime then
        local time = math.ceil(self.cdActionTime)
        self.inPutTxt.promptText = string.format(language.chatSend18, time)
        self.cdActionTime = self.cdActionTime - 0.2
        self.sendMask.fillAmount = self.cdActionTime / self.sendCDTime
    end
end

function JiYiHuaDengView:releaseSendTimer()
    if self.cdTimer then
        self:removeTimer(self.cdTimer)
        self.cdTimer = nil
        self.inPutTxt.promptText = language.dz27
    end
end

return JiYiHuaDengView