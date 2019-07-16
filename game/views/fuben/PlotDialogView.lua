--
-- Author: ohf
-- Date: 2017-03-16 20:33:54
--
--剧情对话
local PlotDialogView = class("PlotDialogView", base.BaseView)

local plotTime = 10

function PlotDialogView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PlotDialogView:initView()
    
end

function PlotDialogView:setData(passId,bossId)
    local dialogText = self.view:GetChild("n2")
    local confData = conf.FubenConf:getPassDatabyId(passId)
    local dialog = confData and confData.dialog
    if bossId and confData then
        if confData.boss_monsters then
            for k,v in pairs(confData.boss_monsters) do
                if v[1] == bossId then
                    dialog = conf.FubenConf:getBossDialog(v[2])
                end
            end
        end
    end
    dialogText.text = dialog
    self.time = plotTime
    self:onTimer()
    if not self.dilogTimer then
        self.dilogTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function PlotDialogView:releaseTimer()
    if self.dilogTimer then
        self:removeTimer(self.dilogTimer)
        self.dilogTimer = nil
    end
end

function PlotDialogView:onTimer()
    if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
        if self.time <= 0 then
            self:releaseTimer()
            self:closeView()
            return
        end
        self.time = self.time - 1
    else
        self:releaseTimer()
        self:closeView()
    end
end

return PlotDialogView