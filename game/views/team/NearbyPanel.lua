--
-- Author: ohf
-- Date: 2017-03-28 15:22:36
--
--附近队伍
local NearbyPanel = class("NearbyPanel",import("game.base.Ref"))

local maxNum = Team.maxNum

function NearbyPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function NearbyPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n38")
    self.listView = panelObj:GetChild("n1")--队伍列表
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.choosePanel = panelObj:GetChild("n12")--目标选择区域
    self.targetListView = panelObj:GetChild("n11")
    self.targetListView:SetVirtual()
    self.targetListView.itemRenderer = function(index,obj)
        self:cellTargetData(index, obj)
    end
    local targetBtn = panelObj:GetChild("n2")
    targetBtn.onClick:Add(self.onBtnTarget,self)
    local touch = panelObj:GetChild("n13")
    touch.onTouchBegin:Add(self.onTouchBegin,self)

    panelObj:GetChild("n4").text = language.team19
    panelObj:GetChild("n5").text = language.team20
    panelObj:GetChild("n6").text = language.team21
    panelObj:GetChild("n7").text = language.team22
end

function NearbyPanel:setData(data)
    self.teamInfos = data.teamInfos
    self.listView.numItems = #self.teamInfos
end
--队伍列表
function NearbyPanel:cellData(index, cell)
    local data = self.teamInfos[index + 1]
    local nameText = cell:GetChild("n1")--队长名字
    nameText.text = data.captainName
    local lvText = cell:GetChild("n2")--队长等级
    lvText.text = data.minLvl.."-"..data.maxLvl
    local targetText = cell:GetChild("n3")--队长帮派名字
    local confData = conf.TeamConf:getTeamConfig(data.targetId)
    targetText.text = confData and confData.name or "无"
    local numText = cell:GetChild("n4")--队伍人数
    numText.text = data.teamMemNum.."/"..maxNum
    local btnApply = cell:GetChild("n5")
    btnApply.data = data
    btnApply.onClick:Add(self.onClickApply,self)

    cell:GetChild("n6").text = GTransFormNum(data.captainPower)
end
--目标列表
function NearbyPanel:cellTargetData(index, cell)
    local targetData = self.teamConfigs[index + 1]
    cell.title = targetData.name or "无"
    cell.data = targetData
    cell.onClick:Add(self.onClickTarget,self)
end
--选择队伍目标
function NearbyPanel:onClickTarget(context)
    local cell = context.sender
    local targetData = cell.data
    proxy.TeamProxy:send(1300101,{targetId = targetData.id})
    self.choosePanel.visible = false
end

function NearbyPanel:onClickApply(context)
    if GGetisOperationTeam() == Team.fubenType1 then
        GComAlter(language.team64)
        return
    end
    local cell = context.sender
    local data = cell.data
    local level = cache.PlayerCache:getRoleLevel()
    local minLv,maxLv = data.minLvl,data.maxLvl
    if level < minLv or level > maxLv then
        GComAlter(string.format(language.team54, minLv.."-"..maxLv))
    else
        proxy.TeamProxy:send(1300111,{teamId = data.teamId})
    end
end
--打开目标区域
function NearbyPanel:onBtnTarget()
    self.teamConfigs = conf.TeamConf:getTeamConfigs()----组队目标
    self.choosePanel.visible = true
    self.targetListView.numItems = #self.teamConfigs
end

function NearbyPanel:onTouchBegin()
    self.choosePanel.visible = false
end

return NearbyPanel