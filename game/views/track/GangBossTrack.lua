--
-- Author: 
-- Date: 2017-07-25 19:28:34
--

local GangBossTrack = class("GangBossTrack",import("game.base.Ref"))

function GangBossTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function GangBossTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function GangBossTrack:setItemUrl()
    self.listView.numItems = 0
    local url1 = UIPackage.GetItemURL("track" , "WenDingItem")
    local url2 = UIPackage.GetItemURL("track" , "GangBossItem")

    local fubenObj1 = self.listView:AddItemFromPool(url1)
    fubenObj1:GetChild("n0").text = language.gangwar21
    self.fubenObj2 = self.listView:AddItemFromPool(url2)
    self.fubenObj2:GetChild("n1").text = language.gangwar22
    self.timeText = self.fubenObj2:GetChild("n9")
    self.listView:ScrollToView(0)
end

function GangBossTrack:setGangBossTrack()
    self:setItemUrl()
    local sceneId = cache.PlayerCache:getSId()
    local assignWarZone = tonumber(string.sub(sceneId,4,6))
    self.nameText.text = language.gangwar01[assignWarZone]
    self.bossIcon = self.fubenObj2:GetChild("n3")
    self.progressbar = self.fubenObj2:GetChild("n4")--boss进度
    self.progressbar:GetChild("title").visible = false
    self.barText = self.fubenObj2:GetChild("title")
    local gotoLink = self.fubenObj2:GetChild("n6")
    gotoLink.text = mgr.TextMgr:getTextColorStr(language.gangwar17, 10, "")
    gotoLink.onClickLink:Add(self.onClickGoto,self)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self:setBossData()
end

function GangBossTrack:onTimer()
    local time = cache.PlayerCache:getRedPointById(attConst.A20133)
    if self.timeText then
        local sec = time - mgr.NetMgr:getServerTime()
        if sec > 0 then
            self.timeText.text = GTotimeString(sec)
        else
            self.timeText.text = GTotimeString(0)
        end
    end
    self:checkGangBoss()
end

--刷新最近的boss的数据
function GangBossTrack:setBossData()
    local bossInfos = cache.GangWarCache:getBossList()
    local rolePos = cache.GangWarCache:getPosition()
    local distance = 1
    for k,v in pairs(bossInfos) do
        if rolePos and v.x > 0 and v.y > 0 then
            local pos = Vector3.New(v.x,gRolePoz,v.y)
            local dis = GMath.distance(rolePos, pos)
            if distance >= dis or distance == 1 then
                distance = dis
                self.bossData = v
            end
        end
    end
    if self.bossData and self.bossData.roleId then
        local mConf = conf.MonsterConf:getInfoById(self.bossData.monsterId)
        local icon = mConf and mConf.icon or ""
        self.bossIcon.url =  ResPath.iconRes(icon)
        local attris = self.bossData.attris
        local value,max = self:getBossValues(attris)
        self.progressbar.value = value
        self.progressbar.max = max
        local num = (value / max) * 100
        self.barText.text = string.format("%2d", num).."%"
    else
        self:bossDead()
    end
end

function GangBossTrack:bossDead()
    self.progressbar.value = 0
    self.progressbar.max = 100
    self.barText.text = string.format("%2d", 0).."%"
end

function GangBossTrack:getBossValues(attris)
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

function GangBossTrack:endGangBoss()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function GangBossTrack:onClickGoto()
    if self.bossData then
        if self.bossData.x == 0 and self.bossData.y == 0 then
            GComAlter(language.gangwar19)
        else
            local pos = Vector3.New(self.bossData.x,gRolePoz,self.bossData.y)
            mgr.HookMgr:enterHook({point = pos})
        end
    end
end

--仙盟boss
function GangBossTrack:checkGangBoss()
    local bossList = cache.GangWarCache:getBossList()
    local isFind = false
    local dis
    for k,v in pairs(bossList) do
        local roleId = v and v.roleId
        if roleId then
            if v.x > 0 and v.y > 0 then
                local boss = mgr.ThingMgr:getObj(ThingType.monster, roleId)
                if boss then
                    local view = mgr.ViewMgr:get(ViewName.BossHpView)
                    if view then
                        view:setBossRoleId(v.roleId)
                        view:setData(boss.data)
                        view:setAttisData(v.attris)
                    else
                        mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                            view:setBossRoleId(v.roleId)
                            view:setAttisData(v.attris)
                        end,boss.data)
                    end
                    isFind = true
                    break
                end
            end
        end
    end
    if not isFind then
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if view then
            view:close()
        end
    end
end

return GangBossTrack