--
-- Author: 
-- Date: 2017-10-21 15:19:38
--

local PanelMany = class("PanelMany",import("game.base.Ref"))
local module_id = 1131
function PanelMany:ctor(param)
    self.parent = param
    self.view = param:getChoosePanelObj(module_id)
    self:initView()
end

function PanelMany:initView()
    self.fightCdTime = 0
    local btnChange = self.view:GetChild("n14")
    btnChange.onClick:Add(self.onFightCall,self)

    local btnTeam = self.view:GetChild("n18")
    btnTeam.onClick:Add(self.onTeamCall,self)

    local btnPlus = self.view:GetChild("n12")
    btnPlus.onClick:Add(self.onPlusCall,self)

    local btnGuize = self.view:GetChild("n5")
    btnGuize.onClick:Add(self.onRuleCall,self)

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.listBoss = self.view:GetChild("n17")
    self.listBoss:SetVirtual()
    self.listBoss.itemRenderer = function(index, obj)
        self:cellBossData(index, obj)
    end
    self.listBoss.onClickItem:Add(self.onCallBack,self)
    self.listBoss.numItems = 0

    self.curCount = self.view:GetChild("n11")
    self.curCount.text = "0"

    self.view:GetChild("n6").text = language.fuben129
    self.view:GetChild("n10").text = language.fuben130
    self.view:GetChild("n13").text = ""--language.fuben200
    self.doubleImg = self.view:GetChild("n19")
end

function PanelMany:setData()
    -- body
    self.modelId = module_id
    --boss 列表
    self.condata = conf.SceneConf:getJianshengHouhu()
    self.listBoss.numItems = #self.condata
    --默认选着第一个
    --默认选择等级靠近的
    self.selectedIndex = 1
    for i = 1 , self.listBoss.numItems do
        --print("i",i)
        if self.condata[i].lvl == cache.PlayerCache:getRoleLevel() then
            self.selectedIndex = i
            break
        elseif i == self.listBoss.numItems then
            if self.condata[i].lvl > cache.PlayerCache:getRoleLevel() then
                self.selectedIndex = i - 1 
            else
                self.selectedIndex = i
            end
        elseif self.condata[i].lvl > cache.PlayerCache:getRoleLevel() then
            self.selectedIndex = math.max(1,i-1)
            break 
        end
    end
    --print("self.selectedIndex",self.selectedIndex)
    self.listBoss:ScrollToView(self.selectedIndex-1)
    self.listBoss:AddSelection(self.selectedIndex-1,false)
    self:setReward()
    if cache.ActivityCache:get5030168(1131) then
        self.doubleImg.visible = true
    else
        self.doubleImg.visible = false
    end
end


function PanelMany:setReward()
    -- body
    local condata = self.condata[self.selectedIndex]
    self.reward = {}
    if condata and condata.normal_drop then
        self.reward = condata.normal_drop
    end
    self.listView.numItems = #self.reward
end

function PanelMany:cellData(index, obj)
    -- body
     local data = self.reward[index+1]
    local _t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,_t,true)
end

function PanelMany:cellBossData(index, obj)
    -- body
    local data = self.condata[index+1]
    obj.data = index + 1 

    local name = obj:GetChild("n2")
    name.text = data.name

    local btnRank = obj:GetChild("n1")
    btnRank.data = data
    btnRank.title = language.fuben128
    btnRank.onClick:Add(self.onRank,self)

    local model = obj:GetChild("n3")
    --模型
    local monsterId = data and data.model or 0
    --print("monsterId",monsterId)
    local modelObj = self.parent:addModel(monsterId,model)--添加模型
    modelObj:setPosition(model.actualWidth/2,-model.actualHeight-400,1000)
    modelObj:setRotation(180)
    modelObj:setScale(70)

    local lv = obj:GetChild("n8")
    lv.text = "Lv."..data.lvl

    local lvimg = obj:GetChild("n6")
    lvimg.visible = false
    -- lvimg.url = "ui://fuben/jianshengshouhu_"..string.format("%03d",12+index) 
    local lvText = obj:GetChild("n4")
    if cache.PlayerCache:getRoleLevel() < data.lvl then
        lvText.text = language.fuben163
    else
        lvText.text = ""
    end
end

function PanelMany:onRank(context)
    -- body
    context:StopPropagation()
    local data = context.sender.data
    --查看排行
    proxy.FubenProxy:send(1027402,{sceneId = data.id})
end


function PanelMany:onCallBack(context)
    -- body
    self.selectedIndex = context.data.data
    self:setReward()
end

function PanelMany:onPlusCall()
    -- body
    if not self.data then
        return
    end

    if self.data.todayLeftBuyCount == 0 then
        local isGoto = false
        local str = ""
        local isHj = cache.PlayerCache:VipIsActivate(2)
        local isZs = cache.PlayerCache:VipIsActivate(3)
        -- if not isHj and not isZs then
        --     isGoto = true
        --     str = language.fuben160
        -- elseif not isHj then
        --     isGoto = true
        --     str = language.fuben158
        if not isZs then
            isGoto = true
            str = language.fuben159
        else
            GComAlter(language.fuben151)
        end
        if isGoto then
            local param = {type = 14,richtext = mgr.TextMgr:getTextColorStr(str, 6),sure = function()
                GOpenView({id = 1050})
            end}
            GComAlter(param)
        end
        return
    end

    local param = {}
    param.type = 16
    param.module_id = self.modelId
    if self.modelId == 1131 then
        local condata = conf.FubenConf:getTaFangValue("jssh_buy_cost")
        param.price = condata[2] --次数购买价格
    end
    param.max = self.data.todayLeftBuyCount
    param.sure = function(count)
        if count > self.data.todayLeftBuyCount then
            GComAlter(string.format(language.fuben152,self.data.todayLeftBuyCount))
            return
        end
        if self.modelId == 1131 then
            if count + self.data.todayLeftCount > (conf.FubenConf:getTaFangValue("jssh_max_count") or 0) then
                GComAlter(language.fuben154)
                return
            end
            local data = {}
            data.count = count
            proxy.FubenProxy:send(1027403,data)
        end
    end
    GComAlter(param)
end

function PanelMany:onFightCall()
    -- body
    if not self.data then
        return
    end
    if not self.selectedIndex then
        --当前必须选择一个boss
        return
    end
    local condata = self.condata[self.selectedIndex]
    if cache.PlayerCache:getRoleLevel() < condata.lvl then
        --等级不足
        return GComAlter(language.fuben163)
    end
    if self.data.todayLeftCount <= 0 then
        --次数不足
        GComAlter(language.fuben155)
        return
    end

    if cache.TeamCache:getTeamId() == 0 then
        --没有队伍
        GComAlter(language.team23)
        return
    elseif not cache.TeamCache:getIsCaptain(cache.PlayerCache:getRoleId()) then
        --不是队长
        GComAlter(language.team50)
        return
    end
    local sceneConfig = conf.SceneConf:getSceneById(condata.id)
    local lvl = sceneConfig and sceneConfig.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv < lvl then
        GComAlter(string.format(language.gonggong07, lvl))
        return
    end
    local targetId = sceneConfig and sceneConfig.team_target or 0
    local confData = conf.TeamConf:getTeamConfig(targetId)
    local cdTime = confData and confData.cd_time or 0--冷却时间
    if Time.getTime() - self.fightCdTime < cdTime then
        GComAlter(language.team66)
        return
    end
    local callback = function( ... )
        -- body
        proxy.FubenProxy:send(1027305,{sceneId = condata.id,reqType = 1})
    end
    if cache.TeamCache:getTeamMemberNum() < 3 then
        local param = {}
        param.type = 2
        param.richtext = language.gonggong103
        param.sure = function()
            -- body
            callback()
            --mgr.FubenMgr:gotoFubenWar(condata.id) --print("确定按钮点击")
        end
        GComAlter(param)
    else
        callback()
        --mgr.FubenMgr:gotoFubenWar(condata.id) --print("确定按钮点击")
    end
    self.fightCdTime = Time.getTime()
end

function PanelMany:onTeamCall()
    -- body
    local condata = self.condata[self.selectedIndex]
    -- if cache.PlayerCache:getRoleLevel() < condata.lvl then
    --     return GComAlter(language.fuben163)
    -- end
    mgr.ViewMgr:openView2(ViewName.TeamView, {targetSceneId = condata.id})
end

function PanelMany:onRuleCall()
    -- body
    GOpenRuleView(1052)
end


function PanelMany:addMsgCallBack(data)
    if data.msgId == 5027401 then
        self.data = data
    elseif data.msgId == 5027403  then
        --data.count 次数
        self.data.todayLeftCount = data.todayLeftCount
        self.data.todayLeftBuyCount = data.todayLeftBuyCount
    end
    --剩余挑战次数
    self.curCount.text = self.data.todayLeftCount

    self:refreshRed()
end

function PanelMany:refreshRed()
    if self.data.todayLeftCount <= 0 then--红点
        if self.modelId == 1131 then
            mgr.GuiMgr:redpointByVar(attConst.A50116,0)
        end
    else
        if self.modelId == 1131 then
            mgr.GuiMgr:redpointByVar(attConst.A50116,1)
        end
    end
end

return PanelMany