--
-- Author: 
-- Date: 2017-08-14 20:10:34
--

local TaskViewKuaFu = class("TaskView", base.BaseView)

function TaskViewKuaFu:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function TaskViewKuaFu:initView()
    self.view:GetChild("n23"):GetChild("n1").visible = false

    --立即前往
    local completeBtn = self.view:GetChild("n2")
    completeBtn.onClick:Add(self.oncloseView,self)
    --非引导
    self.c1 = self.view:GetController("c1")
    self.c1.selectedIndex = 2
    --模型储存
    self.model = self.view:GetChild("n32")
    --奖励
    self.list = {}
    for  i = 10 , 13 do 
        local frame = self.view:GetChild("n"..i)
        frame.visible = false
        table.insert(self.list,frame)
    end
    --名字
    self.name = self.view:GetChild("n7")
    self.name.text = ""
    --完成描述
    self.dec = self.view:GetChild("n8")
    self.dec.text = ""

    --不需要经验
    self.view:GetChild("n15").visible = false 
end

function TaskViewKuaFu:initModel(npcId)
    -- body
    local _npc = conf.NpcConf:getNpcById(npcId)
    if not _npc then
        return
    end 
    local obj = self:addModel(_npc.body_id,self.model)
    obj:setScale(190)
    obj:setRotationXYZ(0,180,0)
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-400,800)
end

function TaskViewKuaFu:initData(data)
    -- body
    local t = {ViewName.SjRCTask,ViewName.SjXBTask}
    for k , v in pairs(t) do
        local view = mgr.ViewMgr:get(v)
        if view then
            view:closeView()
        end
    end


    self.data = data
    self:setData()
end

function TaskViewKuaFu:setData(data_)
    self.sConf = conf.SceneConf:getSceneById(Fuben.kuafuwar)
    self.zone = cache.KuaFuCache:getZone()
    local npcId --= --self.data
    if self.data == 1 then
        npcId = GNPC.kfrc[self.zone]
    else
        npcId = GNPC.kfxb[self.zone]
    end

    --形象
    self:initModel(npcId)
    --名字
    local _npc = conf.NpcConf:getNpcById(npcId)
    self.name.text = _npc.name

    self.task = cache.KuaFuCache:getTaskCache(self.data)
    if self.data == 1 then
        self.condata = conf.KuaFuConf:getSjzbdaily(self.task.mid)
        self.dec.text = self.condata.finishdec
    elseif self.data == 3 then
        self.condata = conf.KuaFuConf:getSjzbBox(self.task.mid)
        --plog(self.task.posx,self.task.poy,self.condata.name)
        self.dec.text = string.format(language.kuafu150,self.task.pox,self.task.poy,self.condata.name)

        --self.dec.text = self.condata.finishdec
    end
    --plog(".self.task.taskId",self.task.taskId)
    --描述
    
    --奖励
    if self.condata.finish_item then
        local index = 1
        for k ,v in pairs(self.condata.finish_item) do
            if self.list[index] then
                self.list[index].visible = true
                local itemData = {}
                itemData.mid = v[1]
                itemData.amount = v[2]
                itemData.bind = v[3]
                GSetItemData(self.list[index],itemData,false)

                index = index + 1
            end
        end
    end
end

function TaskViewKuaFu:oncloseView()
    -- body
    if not self.data then
        return
    end
    --前往某个点杀怪
    local x 
    local y 
    if self.data == 1 then
        if not self.sConf then
            return
        end
        --默认顺序第一个boss
        x = self.sConf.order_monsters[1][4]
        y = self.sConf.order_monsters[1][5]
        --检测boss 是否活着
        if self.task.monsterStates[self.sConf.order_monsters[1][1]] == 1 then
        elseif self.task.monsterStates[self.sConf.order_monsters[2][1]] == 1 then
            x = self.sConf.order_monsters[2][4]
            y = self.sConf.order_monsters[2][5]
        end
    elseif self.data == 3 then
        if self.task.taskState == 1 then
            x = self.task.pox
            y = self.task.poy
        end
    end
    if x and y then
        local point = Vector3.New(x, gRolePoz,y)
        mgr.JumpMgr:findPath(point, 40, function()
            -- body
            
        end)
    end
    self:closeView()
end

return TaskViewKuaFu