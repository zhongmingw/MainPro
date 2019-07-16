--
-- Author: wx
-- Date: 2017-08-15 14:23:35
-- 跨服日常任务

local SjRCTask = class("SjRCTask", base.BaseView)

function SjRCTask:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
    self.isBlack = true
end

function SjRCTask:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    local dec = self.view:GetChild("n7")
    dec.text = language.kuafu123[1]
    --当前通关几次
    self.curPass = self.view:GetChild("n12")
    self.curPass.text = ""
    --当前任务怪
    self.dec1 =  self.view:GetChild("n8")
    self.dec1.text = ""
    self.dec2 =  self.view:GetChild("n13")
    self.dec2.text = ""
    --复活时间
    self.c1 = self.view:GetController("c1")
    self.labdec = self.view:GetChild("n11")
    --dec.text = language.kuafu126
    self.labdec.text = language.kuafu126
    self.labtimer = self.view:GetChild("n14")
    --奖励
    local dec = self.view:GetChild("n9")
    dec.text = language.kuafu127
    local dec = self.view:GetChild("n10")
    dec.text = language.kuafu128
    self.c2 = self.view:GetController("c2")

    self.listView = self.view:GetChild("n5")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata1(index, obj)
    end
    self.listView.numItems = 0

    self.listView2 = self.view:GetChild("n6")
    self.listView2:SetVirtual()
    self.listView2.itemRenderer = function(index,obj)
        self:celldata2(index, obj)
    end
    self.listView2.numItems = 0

    self.btnGo = self.view:GetChild("n3")
    self.btnGo.onClick:Add(self.onGoWar,self)
end

function SjRCTask:initData()
    -- body
    self.data = cache.KuaFuCache:getTaskCache(1)
    self:setData()
    if self.timers then
        self:removeTimer(self.timers)
        self.timers = nil 
    end
    self.timers = self:addTimer(1,-1,handler(self,self.onTimer))
end

function SjRCTask:onTimer()
    -- body
    if not self.data then
        return
    end
    if self.data.taskState ~= 1 then
        return
    end

    local isalldead = true
    for k , v in pairs(self.data.monsterStates) do
        if v ~= 2 then
            isalldead = false
        end
    end

    self.data.nextRefreshBossLeftTime = self.data.nextRefreshBossLeftTime - 1
    self.data.nextRefreshBossLeftTime = math.max(self.data.nextRefreshBossLeftTime,0)

    if isalldead then
        --今天boss已经不刷新了
        self.labdec.text = language.kuafu141
        self.labtimer.text = ""
        self.c1.selectedIndex = 1
    else
        if self.data.curRefreshBossStep == 0 then
            --一个都没刷
            self.c1.selectedIndex = 1
            self.labdec.text = language.kuafu126
            self.labtimer.text = GTotimeString3(self.data.nextRefreshBossLeftTime) 
        elseif self.data.curRefreshBossStep == 1 then
            --:刷了第一只
            if self.data.monsterStates[self.sConf.order_monsters[1][2]] == 2 then
                --第一个boss死亡了
                self.c1.selectedIndex = 1
                self.labdec.text = language.kuafu126
                self.labtimer.text = GTotimeString3(self.data.nextRefreshBossLeftTime) 
            else
                self.c1.selectedIndex = 0
            end
        elseif self.data.curRefreshBossStep == 2 then
            --:刷了第二只
            self.c1.selectedIndex = 0
        end
    end
end

function SjRCTask:setData(data_)
    self.zone = cache.KuaFuCache:getZone()
    --plog("自己所在的区",self.zone)
    self.sConf = conf.SceneConf:getSceneById(Fuben.kuafuwar) --order_monsters
    local _t = conf.KuaFuConf:getSjzbTask(1)
    self.maxPass = _t and _t.limit_count or 1
    --当前完成了几次
    self.curPass.text = "("..self.data.curCount.."/"..self.maxPass..")"
    --plog("self.data.mid",self.data.mid)
    self.condata = conf.KuaFuConf:getSjzbdaily(self.data.mid)
    --检测任务状态
    self.btnGo.visible = false
    self.btnGo.data = nil 
    if self.data.taskState == 1 then--已经接受
        self.dec1.text = language.kuafu129
        --击杀的怪物
        --plog("self.sConf.order_monsters[1][1]",self.sConf.order_monsters[1][2])
        local mConf = conf.MonsterConf:getInfoById(self.sConf.order_monsters[1][2])
        self.dec2.text = mConf.name
        self.btnGo.visible = true
        self.btnGo.data = 1
    elseif self.data.curCount>= self.maxPass then
        self.dec1.text = language.kuafu130
        self.dec2.text = ""
        self.c2.selectedIndex = 1
    else
        self.dec1.text = language.kuafu129
        local mConf = conf.NpcConf:getNpcById(GNPC.kfrc[self.zone])
        self.dec2.text = mConf.name

        self.listView.numItems = 0
        self.listView2.numItems = 0
        self.c1.selectedIndex = 0
        self.c2.selectedIndex = 0
        self.btnGo.data = 0
        self.btnGo.visible = true
    end

    if self.condata then
        self.reward = self.condata.finish_item
        self.extitem = _t.ext_item
        self.listView.numItems = self.reward and #self.reward or 0
        self.listView2.numItems = self.extitem and #self.extitem or 0
    else
        self.listView.numItems = 0
        self.listView2.numItems = 0
    end
end

function SjRCTask:celldata1(index,obj)
    -- body
    local data = self.reward[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end

function SjRCTask:celldata2(index,obj)
    -- body
    local data = self.extitem[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end

function SjRCTask:onGoWar(context)
    -- body
    if not self.data then
        return
    end
    local data = context.sender.data
    if not data then
        return
    end
    local x
    local y 
    if data == 1 then --任务中
        
        if not self.sConf then
            return
        end
        --默认顺序第一个boss
        x = self.sConf.order_monsters[1][4]
        y = self.sConf.order_monsters[1][5]
        --检测boss 是否活着
        if self.data.monsterStates[self.sConf.order_monsters[1][2]] == 1 then
        elseif self.data.monsterStates[self.sConf.order_monsters[2][2]] == 1 then
            x = self.sConf.order_monsters[2][4]
            y = self.sConf.order_monsters[2][5]
        end
    elseif data == 0 then --完成任务
        local mConf = conf.NpcConf:getNpcById(GNPC.kfrc[self.zone])
        x = mConf.pos[1]
        y = mConf.pos[2]
    end
    if x and y then
        local point = Vector3.New(x, gRolePoz, y)
        mgr.JumpMgr:findPath(point, 100, function()
            -- body
            if data == 1 then
                --杀怪
                --mgr.HookMgr:startHook()
                local target, info = mgr.ThingMgr:getNearTar()
                if info then
                    mgr.HookMgr:startHook()
                end
            elseif data == 0 then
                --npc
                proxy.KuaFuProxy:sendMsg(1410201,{type=1})
            end
        end)
    end
    self:onCloseView()
end

function SjRCTask:onCloseView( ... )
    -- body
    self:closeView()
end

return SjRCTask