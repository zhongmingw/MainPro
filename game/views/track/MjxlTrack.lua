--
-- Author: 
-- Date: 2017-10-23 17:37:07
--
--秘境修炼
local MjxlTrack = class("MjxlTrack",import("game.base.Ref"))

function MjxlTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function MjxlTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function MjxlTrack:setMjxlTrack()
    self.sId = cache.PlayerCache:getSId()
    self.sConf = conf.SceneConf:getSceneById(self.sId)
    self.nameText.text = self.sConf.name 
    self:setItemUrl(self.sId)
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self:setMjxlData()
end
--[[
1   
int32
变量名：curBo   说明：当前波
2   
int32
变量名：exp 说明：经验获得
3   
int32
变量名：atkAdd  说明：利刃伤害加成
4   
int32
变量名：expDrup 说明：经验药水加成
]]
function MjxlTrack:setItemUrl(sId)
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "MjxlTrack")
    self.fubenObj = self.listView:AddItemFromPool(url)
    self.timeText = self.fubenObj:GetChild("n0")
    self.curBoText = self.fubenObj:GetChild("n1")
    self.expText = self.fubenObj:GetChild("n2")
    self.killText = self.fubenObj:GetChild("n3")--杀怪数量
    self.atkAddText = self.fubenObj:GetChild("n4")
    self.expDrupText = self.fubenObj:GetChild("n5")--经验符加成
    self.zuanshiTxt = self.fubenObj:GetChild("n6")--钻石仙尊经验加成
    self.zuduiDrupText = self.fubenObj:GetChild("n7")--组队经验加成
end

function MjxlTrack:setMjxlData()
    local data = cache.FubenCache:getMjxlData()
    if self.zuduiDrupText then
        self.zuduiDrupText.visible = false
    end
    if cache.PlayerCache:VipIsActivate(3) then
        local zsAdd = conf.FubenConf:getValue("fam_tq_exp_plus")
        if mgr.FubenMgr:isHjzyScene(self.sId) then
            zsAdd = conf.FubenConf:getValue("hjzy_tq_exp_plus")
        end
        self.zuanshiTxt.text = mgr.TextMgr:getTextColorStr(language.fuben190,1)..mgr.TextMgr:getTextColorStr(zsAdd .. "%", 4)
    else
        self.zuanshiTxt.text = mgr.TextMgr:getTextColorStr(language.fuben190,1)..mgr.TextMgr:getTextColorStr("0%", 4)
    end
    local maxBo = conf.FubenConf:getValue("fam_refresh_time")
    if mgr.FubenMgr:isHjzyScene(self.sId) then
        maxBo = conf.FubenConf:getValue("hjzy_refresh_time")
        data = cache.FubenCache:getHjzyData()
        local teamDrup = conf.SysConf:getValue("team_exp_coef")
        local teamMemberNum = cache.TeamCache:getTeamMemberNum()
        if self.zuduiDrupText then
            self.zuduiDrupText.visible = true
            self.zuduiDrupText.text = mgr.TextMgr:getTextColorStr(language.fuben178, 1)..mgr.TextMgr:getTextColorStr(teamDrup[teamMemberNum].."%", 4)
        end
    end
    if not data then return end
    -- printt(data)
    self.curBoText.text = mgr.TextMgr:getTextColorStr(language.fuben147, 1)..mgr.TextMgr:getTextColorStr(data.curBo.."/"..#maxBo, 4)
    self.expText.text = mgr.TextMgr:getTextColorStr(language.fuben148, 1)..mgr.TextMgr:getTextColorStr(GTransFormNumX(data.exp), 4)
    local atkAdd = data.atkAdd / 100
    self.atkAddText.text = mgr.TextMgr:getTextColorStr(language.fuben149, 1)..mgr.TextMgr:getTextColorStr(atkAdd.."%", 4)
    local expDrup = data.expDrup / 100
    self.expDrupText.text = mgr.TextMgr:getTextColorStr(language.fuben150, 1)..mgr.TextMgr:getTextColorStr(expDrup.."%", 4)
    self.killText.text = language.fuben187..mgr.TextMgr:getTextColorStr(cache.FubenCache:getMjDieNum(), 4)
end

function MjxlTrack:onTimer()
    local data = cache.FubenCache:getMjxlData()
    if mgr.FubenMgr:isHjzyScene(self.sId) then
        data = cache.FubenCache:getHjzyData()
    end
    local overTime = self.sConf and self.sConf.over_time or 0
    local endTime = overTime / 1000
    local time = endTime + data.firstInTime - mgr.NetMgr:getServerTime()
    -- cache.FubenCache:setMjxlTime(endTime - time)
    self.timeText.text = language.fuben146..mgr.TextMgr:getTextColorStr(GTotimeString3(time), 4)
end

function MjxlTrack:endMjxl()
    cache.FubenCache:setMjDieNum(0)
    if self.timer then
        self.mParent:removeTimer(self.timer)
    end
    if self.timeText then
        self.timeText.text = language.fuben164
    end
    self.timer = nil
end

return MjxlTrack