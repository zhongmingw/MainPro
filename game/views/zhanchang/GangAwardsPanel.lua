--
-- Author: 
-- Date: 2017-07-25 17:27:33
--
--仙盟战奖励
local GangAwardsPanel = class("GangAwardsPanel",import("game.base.Ref"))

function GangAwardsPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function GangAwardsPanel:sendMsg()
    self.listView1.numItems = 0
    self.listView2.numItems = 0
    self.mScoreText.text = 0
    self.scoreDesc.text = 0
    proxy.GangWarProxy:send(1360104)
end

function GangAwardsPanel:initPanel()
    self.panelObj = self.mParent.view:GetChild("n5")
    self:initDec()
    self.listView1 = self.panelObj:GetChild("n14")
    self.listView1:SetVirtual()
    self.listView1.itemRenderer = function(index,obj)
        self:cellAwardsData1(index, obj)
    end
    self.listView2 = self.panelObj:GetChild("n3")
    self.listView2:SetVirtual()
    self.listView2.itemRenderer = function(index,obj)
        self:cellAwardsData2(index, obj)
    end
    self.mScoreText = self.panelObj:GetChild("n5")
    self.scoreDesc = self.panelObj:GetChild("n6")
end
--各种描述
function GangAwardsPanel:initDec()
    local color1 = 6
    local color2 = 7
    self.panelObj:GetChild("n7").text = mgr.TextMgr:getTextColorStr(language.gangwar02[1], color1)..mgr.TextMgr:getTextColorStr(language.gangwar02[2], color2)--胜利仙盟奖励（仅第一战区）

    self.panelObj:GetChild("n8").text = mgr.TextMgr:getTextColorStr(language.gangwar03, color1)

    local name = conf.RoleConf:getTitleData(language.gangwar11[1]).name
    self.panelObj:GetChild("n9").text = mgr.TextMgr:getTextColorStr(language.gangwar04, color1)..mgr.TextMgr:getTextColorStr(name, color2)--盟主成员专属称号：

    self.panelObj:GetChild("n10").text = mgr.TextMgr:getTextColorStr(language.gangwar05, color1)

    local name = conf.RoleConf:getTitleData(language.gangwar11[2]).name
    self.panelObj:GetChild("n11").text = mgr.TextMgr:getTextColorStr(language.gangwar06, color1)..mgr.TextMgr:getTextColorStr(name, color2)--盟主专属称号：
    self.panelObj:GetChild("n12").text = mgr.TextMgr:getTextColorStr(language.gangwar05, color1)

    self.panelObj:GetChild("n16").text = mgr.TextMgr:getTextColorStr(language.gangwar07, color2)
    self.panelObj:GetChild("n17").text = mgr.TextMgr:getTextColorStr(language.gangwar08, color2)
    self.panelObj:GetChild("n18").text = mgr.TextMgr:getTextColorStr(language.gangwar09, color2)
    self.panelObj:GetChild("n19").text = mgr.TextMgr:getTextColorStr(language.gangwar10, color2)
end

function GangAwardsPanel:setData(data)
    local score = data and data.score or 0
    self.mScoreText.text = score
    local sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(sId)--仙盟奖励
    self.gangAwards = sceneData and sceneData.normal_drop or {}
    self.listView1.numItems = #self.gangAwards
    --积分奖励
    local scoreData = conf.GangWarConf:getScoreAwards(score)
    if scoreData then
        local str1 = mgr.TextMgr:getTextColorStr(language.wending04[1].text, language.wending04[1].color)

        local color = 14
        if score >= scoreData.value_con then
            color = 7
        end
        local str2 = mgr.TextMgr:getTextColorStr(string.format(language.wending04[2].text, scoreData.value_con), color)
        local str3 = mgr.TextMgr:getTextColorStr(language.wending04[3].text, language.wending04[3].color)
        self.scoreDesc.text = str1..str2..str3
        self.scoreAwards = scoreData.items or {}
        self.listView2.numItems = #self.scoreAwards
    else
        self.listView2.numItems = 0
        self.scoreDesc.text = ""
    end
end
--仙盟奖励
function GangAwardsPanel:cellAwardsData1(index,cell)
    local award = self.gangAwards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(cell, itemData, true)
end
--积分奖励
function GangAwardsPanel:cellAwardsData2(index,cell)
    local award = self.scoreAwards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(cell, itemData, true)
end


return GangAwardsPanel