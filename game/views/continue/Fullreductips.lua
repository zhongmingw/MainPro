--
-- Author: 
-- Date: 2018-10-31 17:04:39
--

local Fullreductips = class("Fullreductips", base.BaseView)

function Fullreductips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function Fullreductips:initView()
    local btn = self.view:GetChild("n8")
    self:setCloseBtn(btn)
    local btn = self.view:GetChild("n6")
    self.cancelbtn = btn
    self.cancelurl = btn.icon
    btn.onClick:Add(self.onBtnCallBack,self)

    local sureBtn = self.view:GetChild("n7")
    self.sureBtn = sureBtn
    self.surelurl = sureBtn.icon
    sureBtn.onClick:Add(self.onBtnCallBack,self)

    self.richText = self.view:GetChild("n9")
end

function Fullreductips:initData(data)

    self.data = data 
    self.richText.text = data.richtext or ""

    self.cancelbtn.icon = data.cancelicon or self.cancelurl
    self.sureBtn.icon = data.sureicon or self.surelurl
end

function Fullreductips:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if "n7" == btn.name then
        if self.data.sure then
            self.data.sure()
        end
    elseif "n6" ==  btn.name  then
        if self.data.cancel then
            self.data.cancel()
        end
    end

    self:closeView()
end

return Fullreductips