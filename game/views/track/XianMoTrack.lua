--
-- Author: 
-- Date: 2017-08-30 20:14:56
--

local XianMoTrack = class("XianMoTrack",import("game.base.Ref"))

function XianMoTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function XianMoTrack:initPanel()
    self.nameText = self.mParent.nameText
end

function XianMoTrack:setXianMoTrack()
    local sceneData = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())
    self.nameText.text = sceneData and sceneData.name or ""
    self:setItemUrl()
    self:setXianMoData()
end

function XianMoTrack:setItemUrl()
    self.listView.numItems = 0
    self.confScore = 0
    local url1 = UIPackage.GetItemURL("track" , "XianMoItem")

    local fubenObj1 = self.listView:AddItemFromPool(url1)
    fubenObj1:GetChild("n0").text = language.xianmoWar08
    fubenObj1:GetChild("n1").text = language.xianmoWar09
    self.timeText = fubenObj1:GetChild("n6")
    self.scoreText = fubenObj1:GetChild("n2")
    self.myKillText = fubenObj1:GetChild("n3")
    self.myScoreText = fubenObj1:GetChild("n4")
    self.awardList = fubenObj1:GetChild("n5")
    self.awardList = fubenObj1:GetChild("n5")
    self.awardList:SetVirtual()
    self.awardList.itemRenderer = function(index,obj)
        self:cellScoreAwards(index, obj)
    end
    self.listView:ScrollToView(0)
    self.scoreText.text = ""
    self.myKillText.text = 0
    self.myScoreText.text = 0
    self.awardList.numItems = 0
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.isInit = true
end

function XianMoTrack:setXianMoData()
    if not self.isInit then return end--没有初始化不刷新数据
    -- plog("刷新数据")
    local data = cache.XianMoCache:getWarData()
    local score = data.score or 0--我的积分
    self.myKillText.text = data.killCount or 0--击杀数
    self.myScoreText.text = score
    local confData = conf.XianMoConf:getScoreAward(score)
    local strTab = clone(language.xianmoWar10)
    self.isGet = false
    if score < confData.score then
        strTab[2].color = 14
    else
        self.isGet = true
        strTab[2].color = 10
    end
    strTab[2].text = string.format(strTab[2].text, confData.score)
    self.scoreText.text = mgr.TextMgr:getTextByTable(strTab)--达到多少积分可获得奖励
    -- if self.confScore ~= confData.score then
    --     self.awards = confData.items
    --     self.awardList.numItems = #confData.items
    --     self.confScore = confData.score
    -- end
    local expCoefs = conf.XianMoConf:getValue("exp_coef")
    local expXA,expXB = expCoefs[1],expCoefs[2]--经验系数A,B
    local exp = expXA * cache.PlayerCache:getRoleLevel() + expXB--公式
    local coef = confData.coef or 0
    local amount = math.floor(exp * (coef / 10000))
    local expData = {PackMid.exp,amount,1}
    local awards = {}
    awards[1] = expData
    for k,v in pairs(confData.items) do
        table.insert(awards, v)
    end
    self.awards = awards
    self.awardList.numItems = #self.awards
end

function XianMoTrack:cellScoreAwards(index,cell)
    local award = self.awards[index + 1]
    local itemData = {mid = award[1],amount = award[2],bind = award[3],grayed = self.isGet,isGet = self.isGet}
    GSetItemData(cell, itemData, true)
end

function XianMoTrack:onTimer()
    local useTime = cache.XianMoCache:getFubenETime() - mgr.NetMgr:getServerTime()
    if useTime < 0 then
        self:releaseTimer()
        return
    end
    self.timeText.text = language.fuben20.." "..mgr.TextMgr:getTextColorStr(GTotimeString3(useTime), 10)
end

function XianMoTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function XianMoTrack:endXianMo()
    self:releaseTimer()
    self.confScore = 0
    self.isInit = false
    if gRole then
        local skins = gRole.data.skins
        gRole.skins = skins
        gRole:setSkins(skins[1], skins[2], skins[3])
        gRole:setChenghao()
    end
end

return XianMoTrack