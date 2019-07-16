--
-- Author: 
-- Date: 2017-07-25 17:25:58
--
--仙盟战排行
local GangRankPanel = class("GangRankPanel",import("game.base.Ref"))

function GangRankPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function GangRankPanel:sendMsg()
    self.listView1.numItems = 0
    self.listView2.numItems = 0
    self.myScoreText.text = 0
    self.gangScoreText.text = 0
    proxy.GangWarProxy:send(1360103)
end

function GangRankPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n4")
    self.listView1 = panelObj:GetChild("n7")
    self.listView1:SetVirtual()
    self.listView1.itemRenderer = function(index,obj)
        self:cellRankData1(index, obj)
    end
    self.listView2 = panelObj:GetChild("n10")
    self.listView2:SetVirtual()
    self.listView2.itemRenderer = function(index,obj)
        self:cellRankData2(index, obj)
    end
    self.gangScoreText = panelObj:GetChild("n16")
    self.myScoreText = panelObj:GetChild("n17")
    self.notRank1 = panelObj:GetChild("n19")
    self.notRank2 = panelObj:GetChild("n20")
end

function GangRankPanel:setData(data)
    self.mData = data
    local len1 = #self.mData.gangRanking
    if len1 <= 0 then
        self.notRank1.visible = true
    else
        self.notRank1.visible = false
    end
    local len2 = #self.mData.userRanking
    if len2 <= 0 then
        self.notRank2.visible = true
    else
        self.notRank2.visible = false
    end
    self.listView1.numItems = len1
    self.listView2.numItems = len2
    self.myScoreText.text = self.mData.score--我的积分
    self.gangScoreText.text = self.mData.gangScore--仙盟积分
end
--仙盟排行
function GangRankPanel:cellRankData1(index,cell)
    local data = self.mData.gangRanking[index + 1]
    cell:GetChild("n1").text = data.rank
    cell:GetChild("n2").text = data.gangName
    cell:GetChild("n3").text = data.score
end
--玩家排行
function GangRankPanel:cellRankData2(index,cell)
    local data = self.mData.userRanking[index + 1]
    cell:GetChild("n1").text = data.rank
    cell:GetChild("n2").text = data.roleName
    cell:GetChild("n3").text = data.score
end

return GangRankPanel