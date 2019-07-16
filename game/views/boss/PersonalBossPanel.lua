--
-- Author: ohf 
-- Date: 2017-04-10 14:24:59
--
--个人boss
local PersonalBossPanel = class("PersonalBossPanel",import("game.base.Ref"))

function PersonalBossPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function PersonalBossPanel:initPanel()
    self.confData = conf.FubenConf:getPersonalData()
    local panelObj = self.mParent.view:GetChild("n4")
    self.listView = panelObj:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.countText = panelObj:GetChild("n3")
end

function PersonalBossPanel:setData(data)
    self.mData = data
    self.leftMap = self.mData and self.mData.leftMap
    self.fubenCount = self.mData and self.mData.dayLeftCount or 0--每日剩余挑战次数
    self.listView.numItems = #self.confData
    self.countText.text = language.fuben03..mgr.TextMgr:getTextColorStr(self.fubenCount, 7)
    self:refreshRed()
end

function PersonalBossPanel:refreshRed()
    local fubenNum = 0
    local index = 1
    for k,v in pairs(self.confData) do
        local sceneId = tonumber(string.sub(v.id,1,6))
        local fubenCount = self.leftMap and self.leftMap[sceneId] or 0
        if fubenCount > 0 then
            fubenNum = fubenNum + 1
        end
        local monsterId = v.ref_monsters and v.ref_monsters[1][1] or 0
        local monster = conf.MonsterConf:getInfoById(monsterId)
        local level = monster and monster.level or 0
        if level <= cache.PlayerCache:getRoleLevel() then
            index = k
        end
    end
    local scroll = index - 4
    if scroll <= 0 then
        scroll = 0
    end
    self.listView:ScrollToView(scroll)
    local redNum = 0
    if fubenNum >= self.fubenCount then
        redNum = self.fubenCount
    else
        redNum = fubenNum
    end
    if redNum <= 0 then
        local num = cache.PlayerCache:getRedPointById(attConst.A20136) or 0
        mgr.GuiMgr:redpointByID(attConst.A20136,num)
    end
end

function PersonalBossPanel:cellData(index, cell)
    local data = self.confData[index + 1]
    local icon = cell:GetChild("n0")
    icon.url = UIPackage.GetItemURL("boss" , tostring(data.view_icon))
    local awards = data.normal_drop or {}
    local listView = cell:GetChild("n2")
    listView.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards

    local warBtn = cell:GetChild("n3")
    warBtn.data = {data = data,index = index}
    warBtn.onClick:Add(self.onClickWar,self)

    local sceneId = tonumber(string.sub(data.id,1,6))
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    local lvl = sceneData and sceneData.lvl or 1
    local lvDesc = cell:GetChild("n4")
    lvDesc.text = string.format(language.gonggong07, lvl)
    if cache.PlayerCache:getRoleLevel() >= lvl then
        lvDesc.visible = false
        warBtn.visible = true
    else
        lvDesc.visible = true
        warBtn.visible = false
    end
    local fubenData = conf.FubenConf:getPassDatabyId(sceneId.."001")
    local mosterId = fubenData and fubenData.ref_monsters[1][1]
    local confMonster = conf.MonsterConf:getInfoById(mosterId)
    local level = confMonster and confMonster.level or 1
    cell:GetChild("n5").text = "Lv."..level..confMonster.name
    
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    local maxCount = sceneData and sceneData.max_over_count
    local fubenCount = self.leftMap and self.leftMap[sceneId] or 0
    if fubenCount > 0 then
        warBtn.enabled = true
        icon.grayed = false
    else
        warBtn.enabled = false
        icon.grayed = true
    end
    local model = cell:GetChild("n7")
    local modelObj = self.mParent:addModel(data.model,model)--添加模型
    modelObj:setPosition(model.actualWidth/2,-model.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(70)
end
--进入副本
function PersonalBossPanel:onClickWar(context)
    if self.fubenCount <= 0 then
        GComAlter(language.fuben85)
        return
    end
    local cell = context.sender
    local data = cell.data.data
    local index = cell.data.index
    local sceneId = tonumber(string.sub(data.id,1,6))
    mgr.FubenMgr:gotoFubenWar(sceneId)
end

return PersonalBossPanel