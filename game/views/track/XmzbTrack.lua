--
-- Author: 
-- Date: 2017-11-29 15:34:30
--
--仙盟争霸
local XmzbTrack = class("XmzbTrack",import("game.base.Ref"))

function XmzbTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function XmzbTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function XmzbTrack:setXmzbTrack()
    self.sId = cache.PlayerCache:getSId()
    self.sConf = conf.SceneConf:getSceneById(self.sId)
    self.nameText.text = self.sConf.name 
    self:setItemUrl()
    local data = cache.XmzbCache:getTrackData()
    self.lastTime = data.lastTime
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self:setXmzbData()
end

function XmzbTrack:setItemUrl()
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "XmzbTrack")
    local fubenObj = self.listView:AddItemFromPool(url)
    self.timeText = fubenObj:GetChild("n0")
    self.myResText = fubenObj:GetChild("n1")--我方资源
    self.myResPro = fubenObj:GetChild("n2")--我方资源进度条
    self.myResPro:GetChild("bar").url = UIItemRes.xmhd11[1]
    self.enemyResText = fubenObj:GetChild("n3")--敌方资源
    self.enemyResPro = fubenObj:GetChild("n4")--敌方资源进度条
    self.enemyResPro:GetChild("bar").url = UIItemRes.xmhd11[2]
    fubenObj:GetChild("n5").text = language.xmhd07
end
--[[
1   
int32
变量名：lastTime    说明：剩余时间
2   
int32
变量名：ourRes  说明：我方资源
3   
int32
变量名：otherRes    说明：敌方资源
4   
int32
变量名：otherNum    说明：敌方总人数
5   
int32
变量名：ourNum  说明：我方参与人数
]]
function XmzbTrack:setXmzbData()
    local data = cache.XmzbCache:getTrackData()
    local resMax = conf.XmhdConf:getValue("xianmeng_max_res")
    if data then
        self.myResText.text = string.format(language.xmhd13, data.ourNum)
        self.myResPro.value = data.ourRes
        self.myResPro.max = resMax

        self.enemyResText.text = string.format(language.xmhd14, data.otherNum)
        self.enemyResPro.value = data.otherRes
        self.enemyResPro.max = resMax
    end
end

function XmzbTrack:releaseTimer()
    if self.timer then
        self.timer = self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function XmzbTrack:onTimer()
    local time = self.lastTime - mgr.NetMgr:getServerTime()
    self.timeText.text = language.fuben146..mgr.TextMgr:getTextColorStr(GTotimeString3(time), 4)
    if time <= 0 then
        self:releaseTimer()
    end
end

function XmzbTrack:endXmzb()
    self:releaseTimer()
end

return XmzbTrack