--
-- Author: 
-- Date: 2017-09-19 20:04:29
--

local AwakenBossTipView = class("AwakenBossTipView", base.BaseView)

function AwakenBossTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function AwakenBossTipView:initData()
    proxy.AwakenProxy:send(1430102)
end

function AwakenBossTipView:initView()
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self:initBoss()
end

function AwakenBossTipView:initBoss()
    local panel = self.view:GetChild("n3")
    self.bossListView = panel:GetChild("n1")
    self.bossListView.itemRenderer = function(index,obj)
        self:cellBossData(index, obj)
    end
end

function AwakenBossTipView:setData(data)
    if data.msgId == 5430102 then
        self.bossList = data.bossList
        self.bossListView.numItems = #self.bossList
    end
end

function AwakenBossTipView:cellBossData(index, obj)
    local data = self.bossList[index + 1]
    local curHp,maxHp = self:getBossValues(data.attris)
    local hpBar = obj:GetChild("n1")
    hpBar.value = curHp
    hpBar.max = maxHp
    local bossId = data.attris[601] or 0
    local sceneData = conf.SceneConf:getSceneById(bossId)
    obj:GetChild("n2").text = sceneData and sceneData.name or ""
    local refText = obj:GetChild("n4")
    if data.leftRefTime > 0 then
        refText.text = string.format(language.awaken26, GTotimeString3(data.leftRefTime))
    else
        refText.text = language.gonggong39
    end
    local gotoBtn = obj:GetChild("n3")
    gotoBtn.data = data
    gotoBtn.onClick:Add(self.onClickGoto,self)
end 

--刷新boss
function AwakenBossTipView:refreshBoss()
    local bossInfos = cache.AwakenCache:getBossList()
    for k,data in pairs(bossInfos) do
        local obj = self.bossListView:GetChildAt(k - 1)
        local curHp,maxHp = self:getBossValues(data.attris)
        local hpBar = obj:GetChild("n1")
        hpBar.value = curHp
        hpBar.max = maxHp
        local refText = obj:GetChild("n4")
        if data.leftRefTime > 0 then
            refText.text = string.format(language.awaken26, GTotimeString3(data.leftRefTime))
        else
            refText.text = language.gonggong39
        end
        local gotoBtn = obj:GetChild("n3")
        gotoBtn.data = data
    end
end

function AwakenBossTipView:getBossValues(attris)
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

function AwakenBossTipView:onClickGoto(context)
    local data = context.sender.data
end

return AwakenBossTipView