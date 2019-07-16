--
-- Author: EVE
-- Date: 2017-07-28 21:44:50
--

local RemindCopy = class("RemindCopy", base.BaseView)

function RemindCopy:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function RemindCopy:initView()
    self.logo = self.view:GetChild("n0")
end

function RemindCopy:initData()
    self:setClose() --设置关闭
    self:setPos()  --设置位置
end 

function RemindCopy:setClose()
    local temp = self:addTimer(5, 1, function()
        self:closeView()     
    end)
end

function RemindCopy:setPos()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        local pairs = pairs
        local topos
        for k ,v in pairs(view.TopActive.btnlist) do
            for i , j in pairs(v) do
                if j.data and j.data.id == 1060 then
                    topos = j.xy + j.parent.xy
                    break
                end
            end
        end
        if topos then
            self.logo.xy = topos
            self.logo.x = self.logo.x - 115
            self.logo.y = self.logo.y + 50
            -- plog("坐标：",self.logo.x,self.logo.y)
        end
    end
end

return RemindCopy