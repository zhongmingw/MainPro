--
-- Author: Your Name
-- Date: 2017-10-26 15:03:40
--

local PasswordView = class("PasswordView", base.BaseView)

function PasswordView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function PasswordView:initView()
    local closeBtn = self.view:GetChild("n2")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.passWordTxt = self.view:GetChild("n5")
    self.dec1 = self.view:GetChild("n36")
    self.dec2 = self.view:GetChild("n37")
end

function PasswordView:initData(data)
    self.type = data.Type
    self.param = data.param
    self.callback = data.callback
    self.passWordStr = "" --交易密码
    self.passWordTxt.text = self.passWordStr
    for i=20,31 do
        local btn = self.view:GetChild("n"..i)
        btn.data = i-20
        btn.onClick:Add(self.onClick,self)
    end
    if self.type == 1 then
        self.dec1.text = language.sell29
        self.dec2.text = language.sell30
    else
        self.dec1.text = language.sell31
        self.dec2.text = language.sell32
    end
end

function PasswordView:onClick(context)
    local data = context.sender.data
    if data >= 0 and data < 10 then
        if string.len(self.passWordStr) >= 6 then
            -- GComAlter(language.sell25)
        else
            self.passWordStr = self.passWordStr .. data
            self.passWordTxt.text = self.passWordStr
        end
    elseif data == 11 then
        -- print("重置")
        self.passWordStr = ""
        self.passWordTxt.text = self.passWordStr
    elseif data == 10 then
        if string.len(self.passWordStr) < 6 then
            GComAlter(language.sell26)
        else
            if self.type == 1 then
                local view = mgr.ViewMgr:get(ViewName.PutAwayPanel)
                if view then
                    view:setPassword(self.passWordStr)
                    GComAlter(language.sell27)
                end
            else
                local view = mgr.ViewMgr:get(ViewName.MarketMainView)
                if view then
                    -- view.MarketPanel:setPassword(data)
                    local param = self.param
                    param.passWord = self.passWordStr
                    proxy.MarketProxy:sendMarketMsg(1260106,param)
                    -- GComAlter(language.sell28)
                end
            end
            self:onCloseView()
            -- print("密码设置完毕",self.passWordStr)
        end
    end
end

function PasswordView:onCloseView()
    self:closeView()
end

return PasswordView