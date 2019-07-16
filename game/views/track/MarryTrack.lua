--
-- Author: 
-- Date: 2017-07-22 11:01:12
--
--情缘副本追踪
local MarryTrack = class("MarryTrack",import("game.base.Ref"))

function MarryTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function MarryTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function MarryTrack:setItemUrl()
    self.listView.numItems = 0
    local url1 = UIPackage.GetItemURL("track" , "TrackItem1")
    local url2 = UIPackage.GetItemURL("track" , "MarryItem")
    -- local url3 = UIPackage.GetItemURL("track" , "TrackItem4")

    local fubenObj1 = self.listView:AddItemFromPool(url1)
    self.passText = fubenObj1:GetChild("n1")
    self.timeText = fubenObj1:GetChild("n2")
    self.fubenObj2 = self.listView:AddItemFromPool(url2)
    self.fubenObj2:GetChild("n4").text = language.kuafu97
    self.fubenObj2:GetChild("n2").text = language.kuafu66
    self.fubenObj2:GetChild("n3").text = language.fuben96
    self.useTimeText = self.fubenObj2:GetChild("n6")
    -- self.fubenObj3 = self.listView:AddItemFromPool(url3)
    self.listView:ScrollToView(0)
end
--[[请求-消息体
返回-消息体
1   
int32
变量名：curBo   说明：当前波
2   
int32
变量名：boLeftSec   说明：波倒计时
3   
int32
变量名：killBo  说明：已击杀波]]
function MarryTrack:setMarryTrack()
    self.passBo = 0
    self.oldkillBo = 0
    self.sId = cache.PlayerCache:getSId()
    self.curId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
    local sceneData = conf.SceneConf:getSceneById(self.sId)
    self.nameText.text = sceneData and sceneData.name or "情缘副本"
    self:setItemUrl()
    self:setMarryData()  
    -- self:setNormalData()
end

function MarryTrack:setMarryData()
    local fubenData = cache.MarryCache:getFubenData()
    self.time = fubenData.boLeftSec
    local passId = self.curId or 0
    local confData = conf.FubenConf:getPassDatabyId(passId)
    local normalDrops = confData and confData.normal_drop or {}
    local conds = confData and confData.order_monsters or {}
    local killBo = fubenData.killBo or 1
    local strTab = clone(language.kuafu69)
    local passBo = killBo + 1
    self.passBo = passBo
    if passBo > #normalDrops then
        passBo = #normalDrops
    end
    strTab[2].text = string.format(strTab[2].text, passBo)
    self.passText.text = mgr.TextMgr:getTextByTable(strTab)

    self.fubenObj2:GetChild("n1").text = "("..killBo.."/"..#conds..")"
    self.fubenObj2:GetChild("n5").text = mgr.TextMgr:getTextColorStr(killBo, 10)..language.tips06
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end 
    -- self:setNormalData()
end

function MarryTrack:setNormalData()
    local confData = conf.FubenConf:getPassDatabyId(self.curId)
    local normalDrops = confData and confData.normal_drop or {}
    local awards = {normalDrops[self.passBo]}
    self.fubenObj3:GetChild("n3").text = language.fuben36
    if self.passBo ~= self.oldkillBo then
        local listView = self.fubenObj3:GetChild("n7")
        listView:SetVirtual()
        listView.itemRenderer = function(index,item)
            local award = awards[index + 1]
            local itemData = {mid = award[1],amount = award[2],bind = award[3]}
            GSetItemData(item, itemData, true)
        end
        listView.numItems = #awards
    end
    self.oldkillBo = self.killBo
end
--副本结束
function MarryTrack:endMarryFuben()
    self.listView.numItems = 0
    self:releaseTimer()
end

function MarryTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function MarryTrack:onTimer()
    if self.time <= 0 then
        self.time = 0
    end
    self.timeText.text = language.fuben12.." "..mgr.TextMgr:getTextColorStr(GTotimeString(self.time), 10)
    local useTime = mgr.NetMgr:getServerTime() - cache.MarryCache:getFubenCTime()
    self.useTimeText.text = language.kuafu100.." "..mgr.TextMgr:getTextColorStr(GTotimeString(useTime), 10)
    if self.time <= 0 then
        self:releaseTimer()
        return
    end
    self.time = self.time - 1
end

return MarryTrack