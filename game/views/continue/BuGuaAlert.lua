--
-- Author: 
-- Date: 2018-08-21 14:05:25
--

local BuGuaAlert = class("BuGuaAlert", base.BaseView)

function BuGuaAlert:ctor()
    BuGuaAlert.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BuGuaAlert:initView()
    local closeBtn = self.view:GetChild("n1")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.richText = self.view:GetChild("n2")
    self.sureBtn = self.view:GetChild("n5")
    self.sureBtn.onClick:Add(self.onSureBtnCallBack,self)

    self.cancleBtn = self.view:GetChild("n6")
    self.cancleBtn.onClick:Add(self.onCancleBtnCallBack,self)

    self.hintBtn = self.view:GetChild("n3")
    self.hintBtn.onClick:Add(self.onChooseSelect,self)
    self.hintGroup = self.view:GetChild("n7")

end
--isHint “不在提示” 
function BuGuaAlert:initData(data)
    self.data = data
    self.richText.text = data.richText 
    self.hintGroup.visible = data.isHint and data.isHint or false

end

--本次登录提醒按钮
function BuGuaAlert:onChooseSelect()
    if self.hintGroup.visible then
        cache.ActivityCache:setTMBGAlertFlag(self.hintBtn.selected)
    end
end


function BuGuaAlert:onCancleBtnCallBack()
    if self.data.cancel then 
        self.data.cancel()
    end
    self:closeView()
end

function BuGuaAlert:onSureBtnCallBack()
    if self.data.sure then 
        self.data.sure()
        
    end
    self:closeView()
end

function BuGuaAlert:onCloseView()
    if self.data.closefun then 
        self.data.closefun()
    end
    self:closeView()
end

return BuGuaAlert