--
-- Author: 
-- Date: 2018-11-22 11:59:47
--

local YueMoKuangHuan = class("YueMoKuangHuan", base.BaseView)

function YueMoKuangHuan:ctor()
    YueMoKuangHuan.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale

end

function YueMoKuangHuan:initView()
    local btn = self.view:GetChild("n0"):GetChild("n6")
    self:setCloseBtn(btn)
    self.labtimer = self.view:GetChild("n6")

    local btn1 = self.view:GetChild("n4")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.chargetimeTxt = self.view:GetChild("n7")

end

function YueMoKuangHuan:initData(data)
    if data then
        self:addMsgCallBack(data)
    end
    self.chargetimeTxt.text = conf.ActivityConf:getHolidayGlobal("recharge_double_max_times")
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"YueMoKuangHuan")

end

function YueMoKuangHuan:onTimer( ... )
    -- body
    if not self.data then return end
    if self.data.lastTime <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return
    end

    self.data.lastTime = self.data.lastTime - 1
    self.data.lastTime = math.max(self.data.lastTime,0)
    self.labtimer.text = language.jhs01 .. mgr.TextMgr:getTextColorStr( GGetTimeData2(self.data.lastTime), 7)
end

function YueMoKuangHuan:onBtnCallBack()
    GOpenView({id = 1042})
end

function YueMoKuangHuan:addMsgCallBack( data )
    self.data = data 
end


return YueMoKuangHuan