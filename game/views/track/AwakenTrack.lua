--
-- Author: 
-- Date: 2017-09-19 20:13:39
--

local AwakenTrack = class("AwakenTrack",import("game.base.Ref"))

function AwakenTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function AwakenTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function AwakenTrack:setAwakenTrack()
    self:setItemUrl()
    self:setAwakenData()
end

function AwakenTrack:setItemUrl()
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "AwakenHallItem")
    local fubenObj = self.listView:AddItemFromPool(url)
    self.timeText = fubenObj:GetChild("n0")
    self.eliteBossText = fubenObj:GetChild("n1")
    fubenObj:GetChild("n2").text = language.awaken20
    fubenObj:GetChild("n3").text = mgr.TextMgr:getTextByTable(language.awaken21)
    self.jianshenLin = fubenObj:GetChild("n4")
    self.jianshenLin.text = language.awaken22

    local linkText = fubenObj:GetChild("n5")
    linkText.text = mgr.TextMgr:getTextColorStr(language.awaken23, 4, "")
    linkText.onClickLink:Add(self.onClickTextLink,self)

    local buyTiredBtn = fubenObj:GetChild("n7")
    buyTiredBtn.onClick:Add(self.onClickBuyTired,self)

     self.leftPlayTime = cache.AwakenCache:getAwakenLeftTime()
    if not self.timer then
        self:onTimer()
        self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function AwakenTrack:refreshPlayTime()
    self.leftPlayTime = cache.AwakenCache:getAwakenLeftTime()
end

function AwakenTrack:setAwakenData()
    -- body
end

function AwakenTrack:onTimer()
    self.timeText.text = string.format(language.kuafu122, GTotimeString(self.leftPlayTime))
    if self.leftPlayTime <= 0 then
        self:releaseTimer()
        return
    end
    self.leftPlayTime = self.leftPlayTime - 1
    cache.AwakenCache:setAwakenLeftTime(self.leftPlayTime)
    self:checkAwakenBoss()
end

--剑神boss
function AwakenTrack:checkAwakenBoss()
    local bossList = cache.AwakenCache:getBossList()
    local disList = {}
    local deadNum = 0--死亡的数量
    for k,v in pairs(bossList) do
        if v.pox > 0 and v.poy > 0 then
            local pos = Vector3.New(v.pox,gRolePoz,v.poy)
            local distance = GMath.distance(gRole:getPosition(), pos)
            local data = {data = v,distance = distance}
            table.insert(disList, data)
        else
            deadNum = deadNum + 1
        end
    end
    local strTab = clone(language.awaken19)
    strTab[2].text = string.format(strTab[2].text, #bossList - deadNum)
    self.eliteBossText.text = mgr.TextMgr:getTextByTable(strTab)
    local bossData = nil
    if #disList > 0 then
        local distance = disList[1].distance
        for k,v in pairs(disList) do
            if v.distance <= distance then bossData = v.data end
        end
    end
    local isFind = false
    if bossData then--离我最近的boss
        local boss = mgr.ThingMgr:getObj(ThingType.monster, bossData.roleId)
        if boss then
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
            isFind = true
        end
    end
    if not isFind then
        local view = mgr.ViewMgr:get(ViewName.BossHpView)
        if view then view:close() end
    end
end

function AwakenTrack:onClickTextLink()
    -- body
end

function AwakenTrack:releaseTimer()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
end

function AwakenTrack:onClickBuyTired()
    local warData = cache.AwakenCache:getAwakenWarData()
    if not warData then return end
    local leftBuyTiredCount = warData.leftBuyTiredCount
    if leftBuyTiredCount > 0 then
        mgr.ViewMgr:openView2(ViewName.AwakenBuyFag)
    else
        GComAlter(language.awaken28)
    end
end

function AwakenTrack:endAwaken()
    -- body
end

return AwakenTrack