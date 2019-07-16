--
-- Author: ohf
-- Date: 2017-04-10 14:25:29
--
--精英boss
local EliteBossPanel = class("EliteBossPanel",import("game.base.Ref"))

function EliteBossPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function EliteBossPanel:initPanel()
    self.isInit = true--打开当前页面
    local panelObj = self.mParent.view:GetChild("n5")
    self.listView = panelObj:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.countText = panelObj:GetChild("n3")
end

function EliteBossPanel:setData(data)
    self.bossInfos = data and data.bossInfos or {}
    self.leftTired = data and data.leftTired or 0--疲劳值
    self.tipConfMap = data and data.tipConfMap or {}
    if #self.bossInfos > 0 then
        table.sort(self.bossInfos,function(a,b)
            return a.sceneId < b.sceneId
        end)
    end
    for k,v in pairs(self.bossInfos) do
        if v.sceneId == data.sceneId then
            v.leftPlayCount = v.leftPlayCount + data.count
            v.leftBuyCount = data.leftBuyCount
        end
    end
    self.listView.numItems = #self.bossInfos
    if self.gotoSceneId then--有外部跳转
        local index = 1
        for k,v in pairs(self.bossInfos) do
            if self.gotoSceneId == v.sceneId then
                index = k
                break
            end
        end
        self.listView:ScrollToView(index - 1)
    else
        if self.isInit then--如果是刚刚打开当前页面
            local index = 1
            for k,v in pairs(self.bossInfos) do
                local mConf = conf.SceneConf:getSceneById(v.sceneId)
                local monsters = mConf and mConf["order_monsters"]
                local monsterId = monsters[1][2]
                local monster = conf.MonsterConf:getInfoById(monsterId)
                local level = monster and monster.level or 0
                if level <= cache.PlayerCache:getRoleLevel() then
                    index = k
                end
            end
            local scroll = index - 3
            if scroll <= 0 then
                scroll = 0
            end
            self.listView:ScrollToView(scroll)
        end
    end
    self.gotoSceneId = false
    self.isInit = false
    
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.countText.text = language.fuben68..mgr.TextMgr:getTextColorStr(self.leftTired, 7)
end
--返回购买次数
function EliteBossPanel:setBuyCout(data)
    for k,v in pairs(self.bossInfos) do
        if v.sceneId == data.sceneId then
            v.leftPlayCount = v.leftPlayCount + data.count
            v.leftBuyCount = data.leftBuyCount
        end
    end
    self.listView.numItems = #self.bossInfos
end

function EliteBossPanel:cellData(index, cell)
    local key = index + 1
    local data = self.bossInfos[key]
    local icon = cell:GetChild("n0")
    local sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(sceneId)

    local isKuafu = cell:GetChild("n11")  --EVE 设置世界boss标志
    if mgr.FubenMgr:isKuaFuBoss(data.sceneId) then 
        isKuafu.visible = true
    else  
        isKuafu.visible = false
    end

    local viewIcon = sceneData and sceneData.view_icon or ""
    icon.url = UIPackage.GetItemURL("boss" , tostring(viewIcon))
    local sceneData = conf.SceneConf:getSceneById(sceneId)
    local awards = sceneData and sceneData.normal_drop or {}
    local listView = cell:GetChild("n2")
    listView.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards--预览boss奖励
    -- local leftPlayCount = data.leftPlayCount
    local warBtn = cell:GetChild("n3")
    warBtn.data = {data = data,index = index}
    warBtn.onClick:Add(self.onClickWar,self)
    local mosterId = sceneData and sceneData.order_monsters[1][2]
    local confMonster = conf.MonsterConf:getInfoById(mosterId)


    cell.data = data
    cell:GetChild("n5").text = "Lv"..confMonster.level..confMonster.name
    
    local model = cell:GetChild("n7")
    local monsterId = sceneData and sceneData.model or 0
    local modelObj = self.mParent:addModel(monsterId,model)--添加模型
    modelObj:setPosition(model.actualWidth/2,-model.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(70)
    self:updateBossTime(cell)
    local rankBtn = cell:GetChild("n8")
    rankBtn.onClick:Add(function()
        mgr.ViewMgr:openView2(ViewName.BossRankAwards, sceneId)
    end)
    cell:GetChild("n9").text = language.fuben91
    local checkBtn = cell:GetChild("n10")
    local optionVal = self.tipConfMap[sceneId] or 0
    if optionVal == 0 then
        checkBtn.selected = false
    else
        checkBtn.selected = true
    end
    checkBtn.data = data
    checkBtn.onChanged:Add(self.onClickCheck,self)
end

function EliteBossPanel:setGotoSceneId(sceneId)
    self.gotoSceneId = sceneId
end

function EliteBossPanel:setTipScene(data)
    self.tipConfMap[data.sceneId] = data.optionVal
    self.listView.numItems = #self.bossInfos
end

function EliteBossPanel:onTimer()
    for k = 1,3 do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            self:updateBossTime(cell)
        end
    end
end

function EliteBossPanel:updateBossTime(cell)
    local timeText = cell:GetChild("n4")
    local warBtn = cell:GetChild("n3")
    local color = 7
    local str = ""
    local data = cell.data
    if data.bossStatu == 1 then--boss已经死了
        warBtn.enabled = false
        color = 14
        local curTime = mgr.NetMgr:getServerTime()
        local time = data.nextRefreshTime - curTime
        str = language.gonggong38..GTotimeString(time)
        if time <= 0 then
            proxy.FubenProxy:send(1330101)
        end
    else
        warBtn.enabled = true
        color = 7
        str = language.gonggong39
    end
    timeText.text = mgr.TextMgr:getTextColorStr(str, color)
end

function EliteBossPanel:clear()
    self.isInit = true
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function EliteBossPanel:onClickWar(context)
    if self.leftTired <= 0 then
        GComAlter(language.fuben84)
        return
    end
    local cell = context.sender
    local data = cell.data.data
    local sceneId = data.sceneId
    mgr.FubenMgr:gotoFubenWar2(sceneId)
end

function EliteBossPanel:onClickCheck(context)
    local checkBtn = context.sender
    local data = checkBtn.data
    local param = {}
    param.optionVal = 0
    if checkBtn.selected then
        param.optionVal = 1
    end
    param.sceneId = data.sceneId
    
    if mgr.FubenMgr:isKuaFuBoss(data.sceneId) then
        proxy.KuaFuProxy:sendMsg(1330303,param)
    else
        proxy.FubenProxy:send(1330104,param)
    end
end

return EliteBossPanel