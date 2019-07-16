--
-- Author: ohf
-- Date: 2017-05-12 10:17:44
--
--仙盟战
local GangPanel = class("GangPanel", import("game.base.Ref"))

function GangPanel:ctor(mParent)
    self.mParent = mParent
    self.imgPath = nil
    self:initPanel()
end

function GangPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n55")
    self.gangName = panelObj:GetChild("n24")
    self.leaderName = panelObj:GetChild("n25")
    self.warZone = panelObj:GetChild("n28")
    self.listView = panelObj:GetChild("n10")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    local rankBtn = panelObj:GetChild("n26")
    rankBtn.onClick:Add(self.onClickRank,self)
    local warBtn = panelObj:GetChild("n7")
    warBtn.onClick:Add(self.onClickWar,self)

    self.modelList = {}
    self.nameList = {}
    for i=1,4 do
        local model = panelObj:GetChild("n4"..i)
        table.insert(self.modelList, model)
        local name = panelObj:GetChild("n7"..i)
        table.insert(self.nameList, name)
        local icon = panelObj:GetChild("n5"..i)
        local data = conf.RoleConf:getTitleData(language.gangwar11[i])
        icon.url = UIPackage.GetItemURL("head" , tostring(data.scr))
    end
    local ruleBtn = panelObj:GetChild("n6")
    ruleBtn.onClick:Add(self.onClickRule,self)
    panelObj:GetChild("n61").text = language.gangwar23
    panelObj:GetChild("n62").text = language.gangwar24
    panelObj:GetChild("n63").text = language.gangwar25
    panelObj:GetChild("n64").text = language.gangwar26
    self.bg = panelObj:GetChild("n55")
    --self:updateBgImg()
end

function GangPanel:updateBgImg()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bg.url = nil
    -- end
    self.imgPath = UIItemRes.zhanchang.."xianmengzhan_004"
    --self.bg.url = self.imgPath
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end

function GangPanel:setData(data)
    self.showRoles = data and data.showRoles or {}
    self:updateBgImg()
    local assignWarZone = data and data.assignWarZone or 1
    if assignWarZone <= 0 then
        assignWarZone = 1
        self.warZone.text = language.gangwar12
        local gangId = tonumber(cache.PlayerCache:getGangId())
        self.startLeftTime = data.startLeftTime or 0
        if not self.timer and gangId > 0 and self.startLeftTime > 0 then
            self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
        end
    else
        self.warZone.text = language.gangwar01[assignWarZone]
    end
    self.sceneId = assignWarZone + GangWarScene
    local lastGangName = data and data.lastGangName
    if not lastGangName or lastGangName == "" then
        lastGangName = language.rank03
    end
    self.gangName.text = lastGangName
    local lastGangLeaderName = data and data.lastGangLeaderName
    if not lastGangLeaderName or lastGangLeaderName == "" then
        lastGangLeaderName = language.rank03
    end
    self.leaderName.text = lastGangLeaderName
    
    local sceneData = conf.SceneConf:getSceneById(self.sceneId)
    self.awards = sceneData and sceneData.normal_drop or {}
    self.listView.numItems = #self.awards
    
    self:setModelInfo()--设置模型信息
end

function GangPanel:setModelInfo()
    table.sort(self.showRoles,function(a,b)
        return a.mark < b.mark
    end)
    local isFind = false
    for k,v in pairs(self.showRoles) do--寻找盟主夫人
        if v.mark == 2 then
            isFind = true
            break
        end
    end

    local newRoles = {}
    local dummyData = {
        roleId = 0,
        roleName = language.rank03,
        mark = 0,
        skins = {GuDingmodel[1]}
    }
    newRoles[1] = self.showRoles[1] or dummyData
    if not isFind then
        newRoles[2] = dummyData
        newRoles[3] = self.showRoles[2] or dummyData
        newRoles[4] = self.showRoles[3] or dummyData
    else
        newRoles[2] = self.showRoles[2]
        newRoles[3] = self.showRoles[3] or dummyData
        newRoles[4] = self.showRoles[4] or dummyData
    end
    for k,v in pairs(self.modelList) do
        local roleData = newRoles[k]
        self.nameList[k].text = mgr.TextMgr:getTextColorStr(roleData.roleName, 10)
        local modelObj = self.mParent:addModel(roleData.skins[1],v)--添加模型
        modelObj:setPosition(v.actualWidth/2,-v.actualHeight-240,500)
        modelObj:setRotation(180)
        modelObj:setScale(language.gangwar28[k])
    end
end

function GangPanel:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function GangPanel:onTimer()
    if self.startLeftTime <= 0 then
        self:releaseTimer()
        proxy.GangWarProxy:send(1360101)
        return
    end
    self.startLeftTime = self.startLeftTime - 1
end
--战场奖励
function GangPanel:cellAwardsData(index,cell)
    local award = self.awards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3]}
    GSetItemData(cell, itemData, true)
end

function GangPanel:onClickRank()
    mgr.ViewMgr:openView2(ViewName.ScoreRankView, {})
end

function GangPanel:onClickWar()
    local gangId = tonumber(cache.PlayerCache:getGangId())
    if gangId <= 0 then
        GOpenView({id = 1013,index = 0})
    else
        if self.sceneId then
            mgr.FubenMgr:gotoFubenWar(self.sceneId)
        end
    end
end

function GangPanel:onClickRule()
    GOpenRuleView(1037)
end

function GangPanel:clear()
    self.bg.url = nil
    self:releaseTimer()
end

return GangPanel