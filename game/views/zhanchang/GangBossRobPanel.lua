--
-- Author: 
-- Date: 2017-07-25 17:24:53
--
--仙盟boss抢夺
local GangBossRobPanel = class("GangBossRobPanel",import("game.base.Ref"))

function GangBossRobPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function GangBossRobPanel:sendMsg()
    self.bigBoss = nil
    proxy.GangWarProxy:send(1360105)
end

function GangBossRobPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n3")
    panelObj:GetChild("n5").text = language.gangwar13
    panelObj:GetChild("n6").text = language.gangwar14
    panelObj:GetChild("n7").text = language.gangwar15
    self.listView = panelObj:GetChild("n3")
    -- self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end

    self.bossIcon = panelObj:GetChild("n9")
    self.bossProBar = panelObj:GetChild("n10")
    self.bossProBar:GetChild("title").visible = false
    self.bossProBarText = panelObj:GetChild("title")
    local gotoLink = panelObj:GetChild("n14")
    gotoLink.text = mgr.TextMgr:getTextColorStr(language.gangwar17, 7, "")
    gotoLink.onClickLink:Add(self.onClickGoto,self)
end

function GangBossRobPanel:setData(data)
    local bossInfos = data and data.bossInfos or {}
    self.smallBossList = {}
    local rolePos = cache.GangWarCache:getPosition()
    local distance = 1
    local key = 0
    for k,v in pairs(bossInfos) do
        if k <= 3 then
            if rolePos and v.x > 0 and v.y > 0 then
                local pos = Vector3.New(v.x,gRolePoz,v.y)
                local dis = GMath.distance(rolePos, pos)
                if distance >= dis or distance == 1 then
                    distance = dis
                    key = k
                end
            end
            table.insert(self.smallBossList, v)
        end
    end
    self.bigBoss = bossInfos[4]
    local len = #self.smallBossList
    if len > 0 and key > 0 then
        self.smallBossList[key].sign = true
    end
    self.listView.numItems = len
    self:setBigBossData()
end
--小boss数据
function GangBossRobPanel:cellData(index, cell)
    local data = self.smallBossList[index + 1]
    -- printt(data.monsterId)
    local mConf = conf.MonsterConf:getInfoById(data.monsterId)
    local icon = mConf and mConf.icon or ""
    cell:GetChild("n7").url = ResPath.iconRes(icon)  --UIPackage.GetItemURL("_icons" , ""..icon)
    local progressbar = cell:GetChild("n3")--boss进度
    progressbar:GetChild("title").visible = false
    local barText = cell:GetChild("title")
    local attris = data.attris
    local value,max = self:getBossValues(attris)
    progressbar.value = value
    progressbar.max = max
    local num = (value / max) * 100
    barText.text = string.format("%2d", num).."%"
    local link = cell:GetChild("n6")
    link.text = mgr.TextMgr:getTextColorStr(language.gangwar17, 7, "")
    local clickPanel = cell:GetChild("n12")
    clickPanel.data = data
    clickPanel.onClick:Add(self.onClickText,self)
    local sign = cell:GetChild("n10")--最近标志
    sign.visible = data.sign
end
--大boss数据
function GangBossRobPanel:setBigBossData()
    local sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(sId)
    local monster = sceneData and sceneData.order_monsters or {}
    local monsterId = monster and monster[4][2] or ""
    local value = 100
    local max = 100
    if self.bigBoss then
        monsterId = self.bigBoss.monsterId
        local attris = self.bigBoss.attris
        value,max = self:getBossValues(attris)
    end
    local mConf = conf.MonsterConf:getInfoById(monsterId)
    local icon = mConf and mConf.icon or ""
    self.bossIcon.url =  ResPath.iconRes(icon) --UIPackage.GetItemURL("_icons" , ""..icon)
    self.bossProBar.value = value
    self.bossProBar.max = max
    local num = (value / max) * 100
    self.bossProBarText.text = string.format("%2d", num).."%"
end

function GangBossRobPanel:onClickGoto()
    if self.bigBoss then
        if self.bigBoss.x == 0 and self.bigBoss.y == 0 then
            GComAlter(language.gangwar19)
        else
            local pos = Vector3.New(self.bigBoss.x,gRolePoz,self.bigBoss.y)
            mgr.HookMgr:enterHook({point = pos})
            -- gRole:moveToPoint(pos, 100, function()
            --     if mgr.ThingMgr:getNearTar() then 
            --         if not mgr.HookMgr.isHook then
            --             mgr.HookMgr:startHook()
            --         end
            --     end
            -- end)
        end
    else
        GComAlter(language.gangwar18)
    end
end

function GangBossRobPanel:onClickText(context)
    local data = context.sender.data
    -- printt(data)
    if data.x == 0 and data.y == 0 then
        GComAlter(language.gangwar19)
    else
        local pos = Vector3.New(data.x,gRolePoz,data.y)
        mgr.HookMgr:enterHook({point = pos})
        -- gRole:moveToPoint(pos, 100, function()
        --     if mgr.ThingMgr:getNearTar() then 
        --         if not mgr.HookMgr.isHook then
        --             mgr.HookMgr:startHook()
        --         end
        --     end
        -- end)
    end
end

function GangBossRobPanel:refreshBoss()
    local bossInfos = cache.GangWarCache:getBossList()
    self.smallBossList = {}
    local rolePos = cache.GangWarCache:getPosition()
    local distance = 1
    local key = 1
    for k,v in pairs(bossInfos) do
        if k <= 3 then
            local cell = self.listView:GetChildAt(k - 1)
            local mConf = conf.MonsterConf:getInfoById(v.monsterId)
            local icon = mConf and mConf.icon or ""
            cell:GetChild("n7").url =  ResPath.iconRes(icon)-- UIPackage.GetItemURL("_icons" , ""..icon)
            local progressbar = cell:GetChild("n3")--boss进度
            local barText = cell:GetChild("title")
            local attris = v.attris
            local value,max = self:getBossValues(attris)
            progressbar.value = value
            progressbar.max = max
            local num = (value / max) * 100
            barText.text = string.format("%2d", num).."%"
            local clickPanel = cell:GetChild("n12")
            clickPanel.data = v
        end
    end
    if bossInfos[4] then
        self.bigBoss = clone(bossInfos[4])
        self:setBigBossData()
    end
end

function GangBossRobPanel:getBossValues(attris)
    local value = 100
    local max = 100
    local curHp = attris[104] or 0
    local maxHp = attris[105] or 0
    local cur = attris[121] or 0
    local sum = attris[120] or 0
    if cur == 0 then
        value = curHp
    else
        value = curHp + (cur - 1) * maxHp
    end
    max = maxHp * sum
    return value,max
end

return GangBossRobPanel