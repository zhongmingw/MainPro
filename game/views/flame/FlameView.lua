--
-- Author: EVE
-- Date: 2017-10-17 14:44:34
-- DESC:仙盟驻地界面

local FlameView = class("FlameView", base.BaseView)

function FlameView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.drawcall = false
end

function FlameView:initView()
    local closeBtn = self.view:GetChild("n10")
    closeBtn.onClick:Add(self.onClickExit,self)
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.lastTimeTxt = self.view:GetChild("n15")  
    self.lastTime = 0--活动剩余时间
    self.joinCountTxt = self.view:GetChild("n16") 
    self.joinCount = 0--参与人数
    self.expRateTxt = self.view:GetChild("n17")    
    self.expRate = 0--经验获得倍率
    self.questionTxt = self.view:GetChild("n18")--答题进度
    self.questionSec = self.view:GetChild("n19")
    self.queSec = 0--答题倒计时
    self.pointTxt = self.view:GetChild("n20")   --骰子点数
    self.addFireTimes = 0 --已添柴次数
    self.addBtn = self.view:GetChild("n7")
    self.addBtn.onClick:Add(self.onClickAdd,self)--添柴按钮
    self.answerBtn = self.view:GetChild("n8")
    self.answerBtn.onClick:Add(self.onClickAnswer,self)--答题按钮

    --答题界面
    self.answerPanel = self.view:GetChild("n12")
    --抛骰子界面
    self.dicePanel = self.view:GetChild("n14")
    --经验获得部分
    self.bg = self.view:GetChild("n23")
    self.bg.visible = false
    self.txtMg = self.view:GetChild("n24")
    self.txtMg.visible = false
    self.ExpTxt = self.view:GetChild("n25")
    self.ExpTxt.visible = false

    --仙盟BOSS按钮（圣火活动期间才显示）
    self.btnBoss = self.view:GetChild("n30")   -- language.bangpai181
    self.btnBoss.onClick:Add(self.onBtnBoss,self)
    self.btnBoss.title = ""
end

function FlameView:initData()
    self.c1.selectedIndex = 0
    self.lastTimeTxt.text = ""
    self.joinCountTxt.text = ""
    self.expRateTxt.text = ""
    self.questionTxt.text = ""
    self.questionSec.text = ""
    self.pointTxt.text = ""
    self.addexpTime = -1--圣火活动增加经验倒计时(活动未开启时为-1)
    self.answerTime = -1--活动答题倒计时(活动未开启时为-1)
    --圣火活动期间显示经验获得
    self.timeCount = 0
    self.minCount = 0
    self.roleExp = cache.PlayerCache:getRoleExp() --玩家挂机时的经验
    self.roleAddExp = 0--记录玩家挂机15秒后增加的经验
end

function FlameView:onTiemr()
    --BOSS倒计时
    if (self.lastTime - 900) >= 0 then 
        self.btnBoss.title = GTotimeString3(self.lastTime-900)
        -- print(self.lastTime)

    elseif self.bossData and self.bossData.curHpPercent > 0 then --BOSS已刷新
        self.btnBoss.title = language.bangpai181  

    else  --BOSS已击杀

        self.btnBoss.title = language.bangpai182
    end  
    if self.bossData then
        -- print("BOSS信息",self.bossData.curHpPercent)
    end
    --
    if self.lastTime > 0 then
        self.lastTimeTxt.text = GTotimeString3(self.lastTime)
        self.lastTime = self.lastTime - 1
    else
        self.lastTimeTxt.text = ""
        self.c1.selectedIndex = 0
    end
    if self.addexpTime > 0 then--修炼经验获取
        self.addexpTime = self.addexpTime - 1
    elseif self.addexpTime ~= -1 then
        self.addexpTime = 5
        proxy.BangPaiProxy:sendMsg(1250507,{reqType = 2})
    end
    local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime()) --当前服务器时间转化为当天秒数
    local questionTime = conf.BangPaiConf:getValue("gang_question_time")
    if curTime >= questionTime[1] and curTime <= questionTime[2]-60 then
        self.answerTime = 60-(curTime%60)
        self.questionSec.text = "(" .. self.answerTime .. ")"
        if self.answerTime < 1 or self.answerTime >= 59 then
            if curTime <= questionTime[2]-120 then
                proxy.BangPaiProxy:sendMsg(1250505,{reqType = 1})
            end
            proxy.BangPaiProxy:sendMsg(1250501)
        end
    else
        self.questionSec.text = ""
        self.answerTime = -1
    end
    if curTime > questionTime[2]-60 and curTime < questionTime[2] then
        if self.data.rightNum >= 2 and self.data.point == 0 then
            local view = mgr.ViewMgr:get(ViewName.FlameThrow)
            if not view then
                mgr.ViewMgr:openView2(ViewName.FlameThrow,{})
            end
        end
    end
end

function FlameView:onController1()
    if self.c1.selectedIndex == 1 then
        self.addexpTime = 5
        proxy.BangPaiProxy:sendMsg(1250501)
        proxy.BangPaiProxy:sendMsg(1250507,{reqType = 1})
    else
        self.bg.visible = false
        self.txtMg.visible = false
        self.ExpTxt.visible = false
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if view then
            view:close()
        end
    end
end

--驻地界面index: 0 圣火活动未开启 1圣火活动开启
function FlameView:setSkip(index)
    local canJoinFire = cache.BangPaiCache:getCanJoinFire()
    if canJoinFire then
        if self.c1.selectedIndex ~= index then
            self.c1.selectedIndex = index
        end
    else
        self.c1.selectedIndex = 0
    end
    if self.c1.selectedIndex == 0 then
        if self.timers then
            self:removeTimer(self.timers)
            self.timers = nil 
        end
    end
end

--添柴按钮
function FlameView:onClickAdd()
    local maxAdd = conf.BangPaiConf:getValue("add_fire_max_times")
    local addData = conf.BangPaiConf:getValue("add_fire_rate")
    local maxRate = conf.BangPaiConf:getValue("gang_exp_rate_max")--最大百分比上限

    local cost = addData[1]
    local contribution = addData[2]
    local rate = addData[3]
    if maxAdd > self.addFireTimes then
        if self.data.rate < maxRate then
            local roleLv = cache.PlayerCache:getRoleLevel()
            local addExp = conf.BangPaiConf:getGangActExpByLv(roleLv)
            local param = {}
            param.type = 2
            param.sure = function()
                proxy.BangPaiProxy:sendMsg(1250503)
            end
            local textData = {
                                {text = language.bangpai162[1],color = 9},
                                {text = string.format(language.bangpai162[2],cost),color = 7},
                                {text = language.bangpai162[3],color = 9},
                                {text = string.format(language.bangpai162[4],contribution,addExp),color = 7},
                                {text = language.bangpai162[5],color = 9},
                                {text = string.format(language.bangpai162[6],(rate/100)),color = 7},
                            }
            param.richtext = mgr.TextMgr:getTextByTable(textData)
            GComAlter(param)
        else
            GComAlter(language.bangpai179)
        end
    else
        GComAlter(language.bangpai166)
    end
end

--答题按钮
function FlameView:onClickAnswer()
    -- body
    local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime())
    local questionTime = conf.BangPaiConf:getValue("gang_question_time")
    if curTime >= questionTime[1] and curTime <= questionTime[2] then
        proxy.BangPaiProxy:sendMsg(1250505,{reqType = 1})
    elseif curTime < questionTime[1] then
        GComAlter(language.bangpai173)
    elseif curTime > questionTime[2]-60 then
        GComAlter(language.bangpai167)
    end
end

--广播刷新面板
function FlameView:refreshView(data)
    self.joinCountTxt.text = data.joinCount
    self.expRateTxt.text = ((data.rate/100)+100).. "%"   --EVE 加成从100%开始算
    self.questionTxt.text = data.questionNum .."/4"

    local roleLv = cache.PlayerCache:getRoleLevel()
    local addExp = conf.BangPaiConf:getGangActAddExpByLv(roleLv)
    self.ExpTxt.text = (addExp + math.floor(addExp*(data.rate/10000)))*(60/5)
end

--退出驻地
function FlameView:onClickExit()
    local sId = cache.PlayerCache:getSId()
    proxy.FubenProxy:send(1020103,{sceneId = sId})
    self:onCloseView()
end

function FlameView:setData(data)
    self.data = data
    self.lastTime = data.lastTime
    self.lastTimeTxt.text = GTotimeString3(data.lastTime)
    self.joinCountTxt.text = data.joinCount
    self.expRateTxt.text = ((data.rate/100)+100).. "%" --EVE 经验加成从100%开始算
    self.questionTxt.text = data.questionNum .."/4"
    self.addFireTimes = data.addFireTimes
    if data.point > 0 then
        self.pointTxt.text = mgr.TextMgr:getTextByTable({{text = data.point,color = 7}})--
    else
        if data.rightNum < 2 then
            self.pointTxt.text = mgr.TextMgr:getTextByTable({{text = language.bangpai172,color = 14}})
        else
            self.pointTxt.text = mgr.TextMgr:getTextByTable({{text = language.bangpai172,color = 7}})
        end
    end
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end
    self.timers = self:addTimer(1, -1, handler(self,self.onTiemr))
    --经验获得
    local roleLv = cache.PlayerCache:getRoleLevel()
    local addExp = conf.BangPaiConf:getGangActAddExpByLv(roleLv)
    self.ExpTxt.text = (addExp + math.floor(addExp*(data.rate/10000)))*(60/5)
    self.bg.visible = true
    self.txtMg.visible = true
    self.ExpTxt.visible = true
end

--仙盟BOSS按钮事件
function FlameView:onBtnBoss()
    if (self.lastTime-900) >= 0 then  --飘字倒计时
        local tempStr = string.format(language.bangpai183,GTotimeString3(self.lastTime-900))
        GComAlter(tempStr)

    elseif self.bossData and self.bossData.curHpPercent > 0 then --BOSS已刷新，点击寻路   
        
        local mosterId = self.bossData.roleId
        local mConf = conf.MonsterConf:getInfoById(mosterId)
        local p = mConf and mConf.pos or {1,1}
        local pos = {x = p[1],y = p[2]}
        cache.FubenCache:setChooseBossId(mosterId)
        mgr.HookMgr:enterHook({point = pos})

        -- print("圣火boss寻路~~~~~")
    else --BOSS已击杀，点击飘字
        GComAlter(language.bangpai184)
    end
end

function FlameView:setFlameBossData(data)
    self.bossData = data
end

function FlameView:onCloseView()
    self:closeView()
end

return FlameView