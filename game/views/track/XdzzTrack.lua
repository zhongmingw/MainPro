--
-- Author: 
-- Date: 2017-12-26 15:17:47
--

local XdzzTrack = class("XdzzTrack",import("game.base.Ref"))

function XdzzTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function XdzzTrack:initPanel()
    
end

function XdzzTrack:setXdzzTrack()
    self.sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(self.sId)
    self.mParent.nameText.text = sceneData and sceneData.name or ""
    self:setItemUrl(self.sId)
end

function XdzzTrack:setItemUrl(sId)
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "XdzzTrack")
    self.fubenObj = self.listView:AddItemFromPool(url)
    self.fubenObj:GetChild("n0").text = mgr.TextMgr:getTextByTable(language.ydact07)
    self.fubenObj:GetChild("n1").text = mgr.TextMgr:getTextByTable(language.ydact08)
    self.fubenObj:GetChild("n2").text = mgr.TextMgr:getTextByTable(language.ydact09)
    self.fubenObj:GetChild("n3").text = mgr.TextMgr:getTextByTable(language.ydact10)
    self.fubenObj:GetChild("n8").text = mgr.TextMgr:getTextByTable(language.ydact11)
    self.fubenObj:GetChild("n9").text = mgr.TextMgr:getTextByTable(language.ydact12)
    local skillItems = conf.ActivityWarConf:getSnowGlobal("skill_items")
    local listView = self.fubenObj:GetChild("n10")
    listView.itemRenderer = function(index,obj)
        local mid = skillItems[index + 1]
        local itemData = {mid = mid,amount = 1,bind = 0,func = function()
            mgr.ViewMgr:openView2(ViewName.ItemSkillDecView, {mid = mid})
        end}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #skillItems
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end
end

function XdzzTrack:onTimer()
    local act_sec = conf.ActivityWarConf:getSnowGlobal("act_sec")
    local data = cache.ActivityWarCache:getXdzzData()
    if data then
        local time = data.openTime + act_sec - mgr.NetMgr:getServerTime()
        local t = GGetTimeData(time)
        self.mParent.acttimeTxt1.text = string.format("%02d", t.min)
        self.mParent.acttimeTxt2.text = string.format("%02d", t.sec)
        if time <= 0 then
            if self.timer then
                self.mParent:removeTimer(self.timer)
                self.timer = nil
            end
            return
        end
    end
    self:updateBossHp()
end

function XdzzTrack:updateBossHp()
    local bossList = cache.ActivityWarCache:getXdzzBoss()
    if not bossList then return end
    local disList = {}
    for k,v in pairs(bossList) do
        if v.pox > 0 and v.poy > 0 then
            local pos = Vector3.New(v.pox,gRolePoz,v.poy)
            local distance = GMath.distance(gRole:getPosition(), pos)
            local data = {data = v,distance = distance}
            table.insert(disList, data)
        end
    end
    local bossData = nil
    if #disList > 0 then
        local distance = disList[1].distance
        for k,v in pairs(disList) do
            if v.distance <= distance then 
                distance = v.distance
                bossData = v.data 
            end
        end
    end
    if bossData then--离我最近的boss
        local boss = mgr.ThingMgr:getObj(ThingType.monster, bossData.roleId)
        if boss then
            local distance = GMath.distance(gRole:getPosition(), boss:getPosition())
            if distance <= 1000 then
                local view = mgr.ViewMgr:get(ViewName.BossHpView)
                if view then
                    view:setBossRoleId(bossData.roleId)
                    view:setData(boss.data)
                    view:setAttisData(bossData.attris)
                    view:setHateRoleName(bossData.hateRoleName)
                else
                    mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                        view:setBossRoleId(bossData.roleId)
                        view:setAttisData(bossData.attris)
                        view:setHateRoleName(bossData.hateRoleName)
                    end,boss.data)
                end
            end
        end
    end
end

function XdzzTrack:endXdzz()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

return XdzzTrack