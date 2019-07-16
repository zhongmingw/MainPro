--
-- Author: 
-- Date: 2017-01-09 20:28:23
--

local DialogView = class("DialogView", base.BaseView)

function DialogView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function DialogView:initView()
    --说话的人的名字
    self.labname = self.view:GetChild("title")
    self.labname.text = ""

    self.leftRoleIcon = self.view:GetChild("icon")
    self.rightRoleIcon = self.view:GetChild("icon2")

    self.speak = self.view:GetChild("n6")
    self.speak.text = ""
    --左边iocn 透明控制
    self.controllerC1 = self.view:GetController("c1")
    --右边
    self.controllerC2 = self.view:GetController("c2")

    self.view.onClick:Add(self.onPanelCallBack,self)
end
--对话完成
function DialogView:completeDialog()
    -- body
    mgr.TaskMgr:openTaskView()
    self:closeView()
end

function DialogView:filterIcon(obj)
    -- body
    --用不了啊
    --local filter = obj.filter
    --filter.AdjustBrightness(0); --亮度
    --filter.AdjustContrast(0); --对比度
    --filter.AdjustSaturation(-0.8);--饱和度
    --filter.AdjustHue(0);--色相
end

function DialogView:startSpeak()
    -- body
    self.labname.text = self.confData.name or ""
    self.speak.text = self.confData.value or "" 

 
    if self.confData.side == 2 then
        self.controllerC1.selectedIndex = 1
        self.controllerC2.selectedIndex = 0
    else
        self.controllerC1.selectedIndex = 0
        self.controllerC2.selectedIndex = 1
    end
end

function DialogView:setData(id)
    self.confData = conf.DialogConf:getDataById(id)

    self:startSpeak()
end

function DialogView:onPanelCallBack()
    -- body
    if self.confData.nextid then
        self.confData = conf.DialogConf:getDataById(self.confData.nextid)
        self:startSpeak()
    else
        self:completeDialog()
    end
    
end

return DialogView