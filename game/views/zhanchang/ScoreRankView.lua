--
-- Author: ohf
-- Date: 2017-05-12 10:30:22
--
--仙盟上一次积分排行
local ScoreRankView = class("ScoreRankView", base.BaseView)

function ScoreRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function ScoreRankView:initData(data)
    self.listView.numItems = 0
    proxy.GangWarProxy:send(1360102)
end

function ScoreRankView:initView()
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self:setCloseBtn(self.view:GetChild("n8"))
    self:setCloseBtn(self.view:GetChild("n9"))
    self.notRank = self.view:GetChild("n10")
end

function ScoreRankView:setData(data)
    self.rankList = data.rankList
    local len = #self.rankList
    if len <= 0 then
        self.notRank.visible = true
    else
        self.notRank.visible = false
    end
    self.listView.numItems = len
end

function ScoreRankView:cellRankData(index,cell)
    local data = self.rankList[index + 1]
    cell:GetChild("n1").text = data.rank
    cell:GetChild("n2").text = data.gangName
    cell:GetChild("n3").text = data.warZone
    cell:GetChild("n4").text = data.score
    local img = cell:GetChild("n5")
    if data.rank == 1 then
        img.visible = true
    else
        img.visible = false
    end
end

return ScoreRankView