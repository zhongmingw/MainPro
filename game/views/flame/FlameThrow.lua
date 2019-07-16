--
-- Author: Your Name
-- Date: 2017-10-19 21:27:56
--

local FlameThrow = class("FlameThrow", base.BaseView)

local resName = {
    [1] = "xianmengshenghuo_007",
    [2] = "xianmengshenghuo_008",
    [3] = "xianmengshenghuo_009",
    [4] = "xianmengshenghuo_010",
    [5] = "xianmengshenghuo_011",
    [6] = "xianmengshenghuo_012",
}

function FlameThrow:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function FlameThrow:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView,self)
    local startBtn = self.view:GetChild("n2")
    startBtn.onClick:Add(self.onClickStart,self)
    self.lastTime = 0
    self.timeTxt = self.view:GetChild("n5")
    self.effectP = self.view:GetChild("n10")
end

function FlameThrow:onClickStart()
    if not self.data or #self.data == 0 then
        proxy.BangPaiProxy:sendMsg(1250506)
    else
        GComAlter(language.bangpai170)
    end
end

function FlameThrow:initData(data)
    -- self.sign = data.sign
    self.timers = self:addTimer(1, -1, handler(self,self.timerClick))
    for i=1,3 do
        self.view:GetChild("n"..(6+i)).visible = true
    end
end
--
function FlameThrow:timerClick()
    local curTime = GGetSecondBySeverTime(mgr.NetMgr:getServerTime()) --当前服务器时间转化为当天秒数
    local questionTime = conf.BangPaiConf:getValue("gang_question_time")
    if curTime > questionTime[2]-60 and curTime < questionTime[2] then
        self.lastTime = 60 - (curTime%60)
        self.timeTxt.text = self.lastTime .. language.gonggong20[4]
        -- print("倒计时",self.lastTime)
        if self.lastTime <= 5 then
            if not self.data or #self.data == 0 then
                -- if self.sign then
                --     self:setData({point = {1,2,3}})
                -- else
                    proxy.BangPaiProxy:sendMsg(1250506)
                -- end
            end
            if self.lastTime <= 1 then
                -- print("关闭界面")
                self:closeView()
            end
        end
    end
end
function FlameThrow:setData(data)
    -- print("抛骰子",data.point)
    self.data = data.point
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effect = self:addEffect(4020145,self.effectP)
    for i=1,3 do
        self.view:GetChild("n"..(6+i)).visible = false
    end
    mgr.TimerMgr:addTimer(0.8, 1, function()
        for k,v in pairs(data.point) do
            -- print(k,v)
            self.view:GetChild("n"..(6+k)).visible = true
            self.view:GetChild("n"..(6+k)).url = UIPackage.GetItemURL("flame" , resName[v])
        end
    end)
    proxy.BangPaiProxy:sendMsg(1250501)
end

function FlameThrow:onCloseView()
    if not self.data or #self.data == 0 then
        local param = {}
        param.type = 2
        param.richtext = language.bangpai171
        param.sure = function()
            -- body
            self:closeView()
        end
        param.cancel = function()
            -- body
        end
        GComAlter(param)
    else
        self:closeView()
    end
end

return FlameThrow