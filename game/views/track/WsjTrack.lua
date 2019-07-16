--
-- Author: 
-- Date: 2018-10-23 16:19:06
--

local WsjTrack = class("WsjTrack",import("game.base.Ref"))

function WsjTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
end

function WsjTrack:setWsjTrack()
    self.sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(self.sId)
    self.mParent.nameText.text = sceneData and sceneData.name or ""
    self:setItemUrl(self.sId)
end

function WsjTrack:setItemUrl(sId)
    self.floor = sId%100
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "TrackWSJCom")
    self.wsjObj = self.listView:AddItemFromPool(url)
    local dec1 = self.wsjObj:GetChild("n3")
    local proNum = self.wsjObj:GetChild("n5")
    local putin = self.wsjObj:GetChild("n6")
    putin.onClickLink:Add(self.onClickPutIn,self)


    local dec2 = self.wsjObj:GetChild("n7")
    local awardList = self.wsjObj:GetChild("n8")
    local dec3 = self.wsjObj:GetChild("n11")
    dec3.text = language.wsj13
    local confData = conf.WSJConf:getWSJFloorAward()
    local maxFloor = #confData
    dec1.text = self.floor == maxFloor and "" or language.wsj09
    local mid = conf.WSJConf:getValue("wsj_ng_mid")
    local awardConf = conf.WSJConf:getWSJAwardByFloor(self.floor)
    local nextConf = conf.WSJConf:getWSJAwardByFloor(self.floor+1)
    local c1 = self.wsjObj:GetController("c1")
    --下层奖励
    if nextConf then
        GSetAwards(awardList, nextConf.fly_awards)
        dec2.text = language.wsj11
        c1.selectedIndex = 0


    else
        --顶层
        -- GSetAwards(awardList, awardConf.fly_awards)
        c1.selectedIndex = 1
        dec2.text = language.wsj12
    end
    local packData = cache.PackCache:getPackDataById(mid)
    local color
    local textData
    if awardConf.need_next_num then
        color = tonumber(packData.amount) >= tonumber(awardConf.need_next_num) and 20 or 0
        textData = {
            {text = packData.amount,color = color},
            {text = "/"..awardConf.need_next_num,color = 0},
        }
        putin.text = mgr.TextMgr:getTextColorStr(language.wsj10,20,"")
    else
        color = 20
        textData = {
            {text = packData.amount,color = color},
        }
        putin.text = mgr.TextMgr:getTextColorStr("",20,"")
    end
    --南瓜数量
    proNum.text = mgr.TextMgr:getTextByTable(textData)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end
end



function WsjTrack:onTimer()
    local endTime =cache.PlayerCache:getRedPointById(20208)
    local severTime = mgr.NetMgr:getServerTime()
    local time = endTime  - severTime
    local t = GGetTimeData(time)
    self.mParent.acttimeTxt1.text = string.format("%02d", t.min)
    self.mParent.acttimeTxt2.text = string.format("%02d", t.sec)
    self:updateBossHp()
    -- print("endTime",endTime,t.min,t.sec)
    if endTime <=0 or ( t.min <= 0 and t.sec <= 0)then
        if self.timer then
            self.mParent:removeTimer(self.timer)
            self.timer = nil
            mgr.FubenMgr:quitFuben()
        end
        return
    end
end

function WsjTrack:setBossData()
    self.bossData = cache.FubenCache:getXycmBossData()
end

function WsjTrack:updateBossHp()
    if not self.bossData then return end
    local bossList = self.bossData.bossList
    local disList = {}
    for k,v in pairs(bossList) do
        if v.pox and v.poy and v.pox > 0 and v.poy > 0 then
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
                    -- view:setHateRoleName(bossData.hateRoleName)
                    view:setAttisData(bossData.attris)
                else
                    mgr.ViewMgr:openView(ViewName.BossHpView, function(view)
                        view:setBossRoleId(bossData.roleId)
                        -- view:setHateRoleName(bossData.hateRoleName)
                        view:setAttisData(bossData.attris)
                    end,boss.data)
                end
                isFind = true
            end
        end
    end
end

function WsjTrack:onClickPutIn()
    local mConf = conf.NpcConf:getNpcById(GNPC.xycm[self.floor])
    if mConf.pos then
        local view = mgr.ViewMgr:get(ViewName.PickAwardsView)
        if view then
            CClearPickView()
            GCancelPick()
        end  
        local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
        print("NPC位置",mConf.pos[1], gRolePoz, mConf.pos[2])
        mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(), point, function()
            mgr.ViewMgr:openView2(ViewName.WSJTaskView,{floor = self.floor})
        end)
    end
    
end



return WsjTrack