--
-- Author: 
-- Date: 2017-06-26 14:48:40
--

local BossRankAwards = class("BossRankAwards", base.BaseView)

function BossRankAwards:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BossRankAwards:initView()
    self:setCloseBtn(self.view:GetChild("n2"))
    self.view:GetChild("n6").text = language.fuben79
    self.view:GetChild("n7").text = language.fuben80
    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
end

function BossRankAwards:initData(sceneId)
    local sConf = conf.SceneConf:getSceneById(sceneId)
    if sConf and sConf.kind == SceneKind.kuafueliteBoss then
        self.bossAwards = conf.KuaFuConf:getEliteRankAward(sceneId)
    else
        self.bossAwards = conf.FubenConf:getEliteRankAward(sceneId)
    end
    self.listView.numItems = #self.bossAwards
end

function BossRankAwards:cellData(index,cell)
    local data = self.bossAwards[index + 1]
    local ranks = data.ranks
    local items = data.items
    local str = ranks[1].."-"..ranks[2]
    if ranks[1] == ranks[2] then
        str = ranks[1]
    end
    cell:GetChild("n1").text = str
    local listView = cell:GetChild("n2")
    listView.itemRenderer = function(index, obj)
        local award = items[index + 1]
        local itemData = {mid = award[1],amount = award[2]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #items
end

return BossRankAwards