--
-- Author: 
-- Date: 2017-07-15 11:01:45
--

--问鼎追踪
local WenDingTrack = class("WenDingTrack",import("game.base.Ref"))

local EXPID = PackMid.exp
local MaxFloor = 9

function WenDingTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function WenDingTrack:initPanel()
    self.confData = conf.SceneConf:getWenDings()
    self.wendingNum = self.mParent.nameText
end

function WenDingTrack:setWenDingTrack()
    self:setItemUrl()
    self:setWendingData()
    
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function WenDingTrack:setItemUrl()
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "WenDingItem")
    self.fubenObj = self.listView:AddItemFromPool(url)
    local url2 = UIPackage.GetItemURL("track" , "WenDingItem2")
    self.fubenObj2 = self.listView:AddItemFromPool(url2)
    local listView = self.fubenObj2:GetChild("n9")
    self.awardListView = listView
    listView.itemRenderer = function(index,obj)
        self:cellScoreAwards(index, obj)
    end
    self.fubenObj2:GetChild("n10").text = language.wending09
    self.fubenObj2:GetChild("n2").text = language.wending08
    self.myScoreText = self.fubenObj2:GetChild("n11")--我的积分
    self.scoreDesc = self.fubenObj2:GetChild("n12")--达到多少积分描述
    self.timeText = self.fubenObj2:GetChild("n7")
end
--问鼎数据
function WenDingTrack:setWendingData()
    local sId = cache.PlayerCache:getSId()
    local conds = cache.WenDingCache:getConds()
    local sceneNum = tonumber(string.sub(sId,6,6))
    self.wendingNum.text = string.format(language.wending20, sceneNum) 
    local nextNum = sceneNum + 1
    local desc = self.fubenObj:GetChild("n0")--描述
    local floorData1 = conf.WenDingConf:getFloorData(sceneNum)
    desc.text = floorData1 and floorData1.desc or ""
    self.fubenObj2:GetChild("n3").text = language.wending05[2]--后一层

    local condNum = conds and conds[sceneNum] or 0--击杀人数
    local floorData = conf.WenDingConf:getFloorData(sceneNum + 1)
    local killNum = floorData and floorData.kill_num or 0
    local condText = self.fubenObj2:GetChild("n6")
    if killNum > 0 then
        condText.text = condNum.."/"..killNum
    else
        condText.text = condNum
    end
    self:setScoreData()
end
--
--积分奖励
function WenDingTrack:setScoreData()
    local score = cache.WenDingCache:getScore()
    self.myScoreText.text = score
    local scoreData = conf.WenDingConf:getScoreAward(score)
    if scoreData then
        local str1 = mgr.TextMgr:getTextColorStr(language.wending04[1].text, language.wending04[1].color)

        local color = 14
        self.isGet = false
        if score >= scoreData.score then
            self.isGet = true
            color = 7
        end
        local str2 = mgr.TextMgr:getTextColorStr(string.format(language.wending04[2].text, scoreData.score), color)
        local str3 = mgr.TextMgr:getTextColorStr(language.wending04[3].text, language.wending04[3].color)
        self.scoreDesc.text = str1..str2..str3
        local expCoefs = conf.WenDingConf:getValue("wending_exp_coef")
        local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
        local exp = expXA * cache.PlayerCache:getRoleLevel() + expXB--公式
        local coef = scoreData.coef or 0
        local amount = math.floor(exp * (coef / 10000))
        local expData = {EXPID,amount,1}
        local awards = scoreData.awards or {}
        local scoreAwards = {}
        scoreAwards[1] = expData
        for k,v in pairs(awards) do
            table.insert(scoreAwards, v)
        end
        self.scoreAwards = scoreAwards
        self.awardListView.numItems = #self.scoreAwards
    else
        self.awardListView.numItems = 0
        self.scoreDesc.text = ""
    end
end

function WenDingTrack:cellScoreAwards(index,cell)
    local award = self.scoreAwards[index + 1]
    local itemData = {mid = award[1],amount = award[2], bind = award[3],isGet = self.isGet}
    GSetItemData(cell, itemData, true)
end
--设置战旗持有者
function WenDingTrack:setFlagHold(flagHoldRoleId)
    self.isFlag = false
    self.flagHoldRoleId = flagHoldRoleId--持有者的roleId
    if flagHoldRoleId == "0" then
        if gRole then
            gRole:updateRoleName(gRole.data.roleName)
            gRole:hitChenghao(false)
        end
        local player = mgr.ThingMgr:objsByType(ThingType.player)
        for k, v in pairs(player) do
            v:hitChenghao(false)
            -- v:updateRoleName(language.wending06[1])
        end
    end
end

function WenDingTrack:onTimer()
    local time = cache.PlayerCache:getRedPointById(attConst.A20131)
    if self.timeText then
        local sec = time - mgr.NetMgr:getServerTime()
        if sec > 0 then
            self.timeText.text = GTotimeString(sec)
        else
            self.timeText.text = GTotimeString(0)
        end
    end
    local flagHoldRoleId = self.flagHoldRoleId or "0"
    if not self.isFlag and flagHoldRoleId ~= "0" then--如果还没设置战旗持有者
        if flagHoldRoleId ~= cache.PlayerCache:getRoleId() then
            local player = mgr.ThingMgr:getObj(ThingType.player, flagHoldRoleId)
            if player then
                player:updateRoleTitle(ResPath.titleRes(UIItemRes.wending02))
                -- player:updateRoleName(language.wending06[2])
                self.isFlag = true
            end
            if gRole then
                gRole:updateRoleName(gRole.data.roleName)
                gRole:hitChenghao(false)
            end
        else
            if gRole then
                gRole:updateRoleName(gRole.data.roleName)
                gRole:updateRoleTitle(ResPath.titleRes(UIItemRes.wending02))
                self.isFlag = true
            end
            local player = mgr.ThingMgr:objsByType(ThingType.player)
            for k, v in pairs(player) do
                v:hitChenghao(false)
                -- v:updateRoleName(language.wending06[1])
            end
        end
    end
end
--结束问鼎之战
function WenDingTrack:endWenDing()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.flagHoldRoleId = "0"
    self.listView.numItems = 0
    cache.WenDingCache:cleanSid()
    local view = mgr.ViewMgr:get(ViewName.FlagHoldView)
    if view then
        view:closeView()
    end 
    if gRole then
        gRole:setChenghao()
    end
end

return WenDingTrack