--
-- Author: 
-- Date: 2017-02-24 19:22:41
--

local AlertView7 = class("AlertView7", base.BaseView)

function AlertView7:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function AlertView7:initData(data)
    -- body
    self:addTimer(1, -1, handler(self,self.onTimer))
end

function AlertView7:initView()
    local window4 = self.view:GetChild("n3")
    local btnClose = window4:GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    self.titleIcon = window4:GetChild("icon")
    self.lab1 = self.view:GetChild("n19")
    self.bar = self.view:GetChild("n8")
    self.lab2 = self.view:GetChild("n20")
    self.lab3 = self.view:GetChild("n21")
    self.lab4 = self.view:GetChild("n22")
    self.lab5 = self.view:GetChild("n23")
    self.lab6 = self.view:GetChild("n24")
    self.radiobtn = self.view:GetChild("n15")
    self.lab7 = self.view:GetChild("n25")
    self.btnSure = self.view:GetChild("n18")
    self.btnSure.onClick:Add(self.onbtnSure,self)
    self.btnCancel = self.view:GetChild("n17")
    self.btnCancel.onClick:Add(self.onBtnClose,self)

    
    self:initDec()
end
--
function AlertView7:initDec()
    -- body
    self.lab1.text = language.zuoqi52
    self.lab4.text = language.zuoqi57
    self.lab5.text = language.zuoqi58
    self.lab6.text = language.zuoqi59
    self.lab7.text = language.zuoqi51
end

function AlertView7:onTimer()
    -- body
    if self.data and self.data.data.blessTime and self.data.data.blessTime ~= 0 then
        --self.decc2.text = language.zuoqi31
        local var = 24*3600 -(mgr.NetMgr:getServerTime()-self.data.data.blessTime) 
        if var <= 0 then
            self.lab3.text = ""
        else
            self.lab3.text = GTotimeString(var)
        end
    else
        self.lab3.text = ""
    end
end

function AlertView7:setData(data_)
    self.data = data_
    self.lab2.text = data_.text
    
    self.bar.value = data_.data.levExp
    self.bar.max = data_.need_exp or self.bar.value

    self.radiobtn.selected = data_.radio or false
end

function AlertView7:onbtnSure()
    -- body
    
    if self.data.sure then 
        self.data.sure(self.radiobtn.selected)
    end
    self:closeView()
end

function AlertView7:onBtnClose(  )
    -- body
    if self.data.cancel then
        self.data.cancel(self.radiobtn.selected)
    end
    self:closeView()
end

return AlertView7