--
-- Author: wx 
-- Date: 2017-06-29 11:51:29
--跨服精英boss信息

local BossPanel = class("BossPanel",import("game.base.Ref"))

function BossPanel:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n8")
    self:initView() 
end

function BossPanel:initView()
    -- body
    --剩余疲劳值
    self.title = self.view:GetChild("n3")
    --
    self.listView = self.view:GetChild("n2")
    --self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    local btnGuize = self.view:GetChild("n4")
    btnGuize.onClick:Add(self.onGuize,self)
end

function BossPanel:onTimer()
    if not self.data or self.listView.numItems==0 then
        return
    end
    --local size = math.min(3,self.listView.numItems)
    for k = 1, self.listView.numItems do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local timeText = cell:GetChild("n4")
            local warBtn = cell:GetChild("n3")
            local color = 7
            local str = ""
            local data = cell.data

            if data.bossStatu == 99 then
                --这个是虚拟列表
                return
            end

            if data.bossStatu == 1 then--boss已经死了
                warBtn.enabled = false
                color = 14
                local curTime = mgr.NetMgr:getServerTime()
                local time = data.nextRefreshTime - curTime
                str = language.gonggong38..GTotimeString(time)
                if time <= 0 then
                    proxy.FubenProxy:send(1330301)
                end
            else
                warBtn.enabled = true
                color = 7
                str = language.gonggong39
            end
            timeText.text = mgr.TextMgr:getTextColorStr(str, color)
        end
    end
end

function BossPanel:cellData(index, cell)
    -- body
    local data = self.data.bossInfos[index+1]
    cell.data = data
    
    local icon = cell:GetChild("n0") --底图
    local sceneId = data.sceneId
    local sceneData = conf.SceneConf:getSceneById(sceneId)

    local warBtn = cell:GetChild("n3")
    local labname = cell:GetChild("n5")
    if not sceneData then
        warBtn.visible = false
        labname.text = data.sceneId
        return
    end


    --底图
    local viewIcon = sceneData and sceneData.view_icon or ""
    icon.url = UIPackage.GetItemURL("kuafu" , tostring(viewIcon))
    --奖励
    local awards = sceneData.normal_drop or {}
    local listView = cell:GetChild("n2")
    listView.itemRenderer = function(index,obj)
        local awardData = awards[index + 1]
        local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3]}
        GSetItemData(obj, itemData, true)
    end
    listView.numItems = #awards--预览boss奖励
    --挑战
    warBtn.visible = true
    warBtn.data = {data = data,index = index}
    warBtn.onClick:Add(self.onClickWar,self)
    --怪物名字
    local mosterId = sceneData.order_monsters[1][2]
    local confMonster = conf.MonsterConf:getInfoById(mosterId)
    
    labname.text = "Lv"..confMonster.level..confMonster.name --confMonster.name
    --模型
    local model = cell:GetChild("n7")
    local monsterId = sceneData.model or 0
    local modelObj = self.parent:addModel(monsterId,model)--添加模型
    modelObj:setPosition(model.actualWidth/2,-model.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(70)

    local rankBtn = cell:GetChild("n8")
    rankBtn.onClick:Add(function()
        mgr.ViewMgr:openView2(ViewName.BossRankAwards, sceneId)
    end)

    --刷新提示
    local dec =  cell:GetChild("n9")
    dec.text = language.kuafu25

    local btnRadio = cell:GetChild("n10")
    btnRadio.data = sceneId
    btnRadio.onClick:Add(self.onbtnRadio,self)
    local var = self.data.tipConfMap[sceneId]
    if var and var > 0 then
        btnRadio.selected = true
    else
        btnRadio.selected = false
    end
end

function BossPanel:onbtnRadio(context)
    -- body
    if self.willopen then
        GComAlter(self.str)
        return
    end
    local btn = context.sender 
    local param = {}
    param.sceneId = btn.data
    if btn.selected then
        param.optionVal = 1
    else
        param.optionVal = 0
    end
    proxy.KuaFuProxy:sendMsg(1330303,param)
end

function BossPanel:onClickWar(context)
    -- body
    if self.willopen then
        GComAlter(self.str)
        return
    end

    local cell = context.sender
    local data = cell.data.data
    if self.data.leftTired <= 0 then
        GComAlter(language.kuafu13)
        return
    end
    local Sconf = conf.SceneConf:getSceneById(data.sceneId)
    local var = Sconf and (Sconf.lvl or 1) or 1
    if cache.PlayerCache:getRoleLevel() >= var then
        mgr.FubenMgr:gotoFubenWar(data.sceneId)
        -- --切换pk模式
        -- if cache.PlayerCache:getPKState() ~= PKState.server then
        --     proxy.PlayerProxy:send(1020106,{pkState = PKState.server})
        -- end
    else
        GComAlter(string.format(language.kuafu98,var))
        --language.gonggong06
    end
end

function BossPanel:setWillOpen()
    -- body
    self.willopen = true

    local temp = os.date("*t",cache.KuaFuCache:isWillOpenByid(1)) 
    local str = ""
    --str = str .. temp.year .. language.gonggong78
    str = str .. temp.month .. language.gonggong79
    str = str .. temp.day  .. language.gonggong80 ..language.kuafu109
    self.str = str
    self.title.text = mgr.TextMgr:getTextColorStr(str, 7)

    self.data = {}
    self.data.bossInfos = {}
    self.data.tipConfMap = {}
    --虚拟列表
    for i = BossScene.kuafuelite , BossScene.kuafuelite + PassLimit do
        local confdata = conf.SceneConf:getSceneById(i)
        if not confdata then
            break
        end

        local t = {}
        t.bossStatu = 99
        t.lastRefreshTime = 0
        t.nextRefreshTime = 0
        t.sceneId = i 
        t.lastKillName = ""


        table.insert(self.data.bossInfos,t)
        self.data.tipConfMap[i] = 0
    end
    self.listView.numItems = #self.data.bossInfos

end

function BossPanel:add5330301(data,sceneId)
    -- body
    self.willopen = false
    self.data = data
    table.sort(data.bossInfos,function(a,b)
        -- body
        return a.sceneId < b.sceneId
    end)

    self.listView.numItems = #data.bossInfos
    local scroll = 0
    if not sceneId then
        --BUG #6455 跨服精英boss：BOSS界面初始位置优化（与自身等级贴近）
        local index = 1
        for k,v in pairs(data.bossInfos) do
            local mConf = conf.SceneConf:getSceneById(v.sceneId)
            local monsters = mConf and mConf["order_monsters"]
            local monsterId = monsters[1][2]
            local monster = conf.MonsterConf:getInfoById(monsterId)
            local level = monster and monster.level or 0
            if level <= cache.PlayerCache:getRoleLevel() then
                index = k
            end
        end
        scroll = index - 2
        if scroll <= 0 then
            scroll = 0
        end
    else
        --如果是提示打boss进来界面
        for k,v in pairs(data.bossInfos) do
            if sceneId == v.sceneId then
                scroll = k - 1
                break
            end
        end
    end
    
    if self.listView.numItems > 0 and not self.reset then
        self.listView:ScrollToView(scroll)
        --已经设置过了
        self.reset = true
    end



    --剩余疲劳度
    local str = language.kuafu12..mgr.TextMgr:getTextColorStr(self.data.leftTired, 10)
    self.title.text = str
end

function BossPanel:onGuize( ... )
    -- body
    GOpenRuleView(1039)
end

return BossPanel