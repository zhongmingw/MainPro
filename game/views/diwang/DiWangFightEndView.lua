--
-- Author: Your Name
-- Date: 2018-07-26 15:20:00
--

local DiWangFightEndView = class("DiWangFightEndView", base.BaseView)

function DiWangFightEndView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function DiWangFightEndView:initView()
    self.closeBtn = self.view:GetChild("n5")
    self.closeBtn.onClick:Add(self.onCloseView,self)
    self.titleIcon = self.view:GetChild("n10")
    self.decTxt = self.view:GetChild("n7")
    self.c1 = self.view:GetController("c1")
end

-- 变量名：rank    说明：位置
-- 变量名：win 说明：1:胜利 2:失败
-- array<SimpleItemInfo>   变量名：items   说明：获得道具
-- 变量名：oldRank 说明：旧的排名
function DiWangFightEndView:initData(data)
    self.lastTime = 10
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.decTxt.text = string.format(language.fuben11,self.lastTime)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))

    local rank = data.rank
    if rank ~= 0 then
        local xianWeiData = conf.DiWangConf:getXianWeiDataByRank(rank)
        local titleId = xianWeiData.title[1]
        local titleData = conf.RoleConf:getTitleData(titleId)
        self.titleIcon.url = UIPackage.GetItemURL("head" , tostring(titleData.scr))
    else
        self.titleIcon.url = UIPackage.GetItemURL("diwang" , "dwjxiang_021")
    end
    if data.win == 1 then
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 1
    end
end

function DiWangFightEndView:onTimer()
    if self.lastTime > 0 then
        self.lastTime = self.lastTime - 1
        self.decTxt.text = string.format(language.fuben11,self.lastTime)
    else
        self:onCloseView()
    end
end

function DiWangFightEndView:onCloseView()
    local view = mgr.ViewMgr:get(ViewName.ArenaFightView) 
    if view then
        view:onCloseView()
    end
    self:closeView()
end

return DiWangFightEndView