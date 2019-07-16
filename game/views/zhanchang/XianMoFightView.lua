--
-- Author: 
-- Date: 2017-08-30 19:26:23
--
--仙魔战战斗界面
local XianMoFightView = class("XianMoFightView", base.BaseView)

local btnPos = {
    370,
    892,
}

function XianMoFightView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function XianMoFightView:initView()
    self.progressbar = self.view:GetChild("n2")

    local followBtn = self.view:GetChild("n11")--追随
    self.followBtn = followBtn
    followBtn.onClick:Add(self.onClickFollow,self)
    local killBtn = self.view:GetChild("n12")--追杀
    self.killBtn = killBtn
    killBtn.onClick:Add(self.onClickKill,self)

    -- self.view:GetChild("n13").text = language.xianmoWar05[1]
    -- self.view:GetChild("n14").text = language.xianmoWar05[2]

    self.xianShaikh = self.view:GetChild("n4")--仙族族长
    self.moShaikh = self.view:GetChild("n5")--魔族族长

    self.xianScoreText = self.view:GetChild("n6")--仙族积分
    self.moScoreText = self.view:GetChild("n7")--魔族积分
    self.mySign = self.view:GetChild("n15")
end

function XianMoFightView:initData()
    self:setData()
end
--站在自己的角度，别人就是魔
function XianMoFightView:setData()
    local data = cache.XianMoCache:getWarData()
    local xianCampInfo = data.xianCampInfo--仙
    local moCampInfo = data.moCampInfo--魔
    local xianScore = 0
    local moScore = 0
    
    self.xianShaikh.text = language.xianmoWar05[1]..":"..xianCampInfo.topOneName
    self.moShaikh.text = moCampInfo.topOneName..":"..language.xianmoWar05[2]
    self.xianScoreText.text = language.xianmoWar06[1]..xianCampInfo.score
    self.moScoreText.text = language.xianmoWar06[2]..moCampInfo.score
    xianScore = xianCampInfo.score
    moScore = moCampInfo.score
    self.progressbar.value = xianScore
    self.progressbar.max = xianScore + moScore
    if xianScore == moScore then
        self.progressbar.value = 1
        self.progressbar.max = 2
    end
    if xianCampInfo.campId == data.campId then--自己是仙的话
        self.followBtn.x = btnPos[1]
        self.killBtn.x = btnPos[2]
        self.mySign.x = 515
    else
        self.followBtn.x = btnPos[2]
        self.killBtn.x = btnPos[1]
        self.mySign.x = 768
    end
end
--追随
function XianMoFightView:onClickFollow()
    proxy.XianMoProxy:send(1420104,{reqType = 2})
end
--追杀
function XianMoFightView:onClickKill()
    proxy.XianMoProxy:send(1420104,{reqType = 3})
end

return XianMoFightView