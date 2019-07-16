--
-- Author: 
-- Date: 2018-08-02 21:07:11
--

local RachargeCrazy = class("RachargeCrazy", base.BaseView)

function RachargeCrazy:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function RachargeCrazy:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n7")
    self:setCloseBtn(btnClose)

    local btnCz = self.view:GetChild("n4")
    btnCz.onClick:Add(self.onBtnChongzhi,self)

    self.view:GetChild("n6").text = language.fkfl01

    self.labtime = self.view:GetChild("n3")
end

function RachargeCrazy:initData(data)
    -- body
    if data then
        self:addMsgCallBack(data)
    end
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"RachargeCrazy")
end

function RachargeCrazy:onTimer( ... )
    -- body
    if not self.data then
        return
    end
    self.data.actLeftTime = math.max(self.data.actLeftTime - 1,0)
    if self.data.actLeftTime <= 0 then
        GComAlter(language.kuafu106)
        self:closeView()
        return 
    end
    self.labtime.text = language.lcth01 .. mgr.TextMgr:getTextColorStr( GGetTimeData2(self.data.actLeftTime), 7)
end

function RachargeCrazy:setData(data_)

end

function RachargeCrazy:onBtnChongzhi()
    -- body
    GOpenView({id = 1042})
end

function RachargeCrazy:addMsgCallBack( data )
    -- body
    self.data = data 
end

return RachargeCrazy