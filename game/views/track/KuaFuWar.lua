--w
-- Author: wx
-- Date: 2017-08-14 15:02:48
-- 跨服三界争霸任务
local autoRun = 3 --每3秒检测一直位置跟随
local KuaFuWar = class("KuaFuWar",import("game.base.Ref"))

function KuaFuWar:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function KuaFuWar:initPanel()
    -- body
    --副本名称
    self.nameText = self.mParent.nameText
    local sId = cache.PlayerCache:getSId()
    self.Sconf = conf.SceneConf:getSceneById(sId)
    self.nameText.text = self.Sconf.name 
end

function KuaFuWar:onTimer()
    -- body
    if not self.data then
        return
    end

    --活动结束时间
    self.data.leftTime = self.data.leftTime - 1
    self.data.leftTime = math.max(0,self.data.leftTime)
    if self.timeText then
        local var = string.format(language.kuafu122,"")
        self.timeText.text = var..mgr.TextMgr:getTextColorStr(GTotimeString(self.data.leftTime), 4)
    end

    self.delayTime = self.delayTime + 1
    if cache.KuaFuCache:getIsAuto() and self.delayTime%autoRun < 1 then
        local task = cache.KuaFuCache:getTaskCache(2) 
        if task.taskState == 1 then
            --请求车子坐标
            proxy.KuaFuProxy:sendMsg(1410204)
        end
    end
    -- local task = cache.KuaFuCache:getTaskCache(3) 
    -- if task and task.taskState == 1 then
    --     local box = cache.KuaFuCache:getBoxGrids()
    --     for k ,v in pairs(box) do
    --         if v.triggerAppear == 0 then
    --             local b = Vector3.New(v.pox,gRolePoz,v.poy)
    --             local distance = GMath.distance(gRole:getPosition(), b)
    --             if distance < 500 then
    --                 proxy.KuaFuProxy:sendMsg(1810502,{gridId = v.gridId})
    --             end
    --         end
    --     end
    -- end

    ---执行一下触发宝箱操作
    -- local task = cache.KuaFuCache:getTaskCache(3) 
    -- if task and task.taskState == 1 and task.triggerAppear == 0 then
    --     --范围检测
    --     local b = Vector3.New(task.pox,gRolePoz,task.poy)
    --     local distance = GMath.distance(gRole:getPosition(), b)
    --     if distance < 500 then
    --         proxy.KuaFuProxy:sendMsg(1810502)
    --     end
    -- end
end
--设置三界争霸名字
function KuaFuWar:setKuaFu3Name()
    local sConf = conf.SceneConf:getSceneById(Fuben.kuafuwar)
    self.nameText.text = sConf.name 
end

function KuaFuWar:addComponent()
    -- body
    local var = UIPackage.GetItemURL("track" , "Component2")
    local _compent1 = self.listView:AddItemFromPool(var)
    return _compent1
end

function KuaFuWar:initMsg(data)
    self.data = cache.KuaFuCache:getTaskCache()
    self:setKuaFu3Name()
    --清理列表
    self.listView.numItems = 0
    --12-13双倍
    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent1 = self.listView:AddItemFromPool(var)
    self.timeText = _compent1:GetChild("n2")
    self.timeText.text = "" -- 

    --添加镖车任务
    self:setCheMsg()
    --添加寻宝任务
    self:setBoxMsg()


    -- --添加3个按钮
    -- self.btnlist = {}
    -- for i = 1 , 2 do
    --     local var = UIPackage.GetItemURL("track" , "Component2")
    --     local _compent1 = self.listView:AddItemFromPool(var)
    --     if i == 1 then
    --         _compent1.data = 2
    --     elseif i == 2 then
    --         _compent1.data = 3
    --     end
        
    --     _compent1.onClick:Add(self.onTaskSee,self)
    --     table.insert(self.btnlist,_compent1)
    -- end
    -- --设置任务信息
    -- self:setInfo()

    if self.timer then
        self.mParent:removeTimer(self.timer)  
    end
    self.delayTime = 0
    self:onTimer()
    self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
end

function KuaFuWar:setInfo()
    -- body
    self:setMsg(2)
    --self:setMsg(1)
    self:setMsg(3)
    -- for i = 1 , 3 do
    --     self:setMsg(i)
    -- end
end

function KuaFuWar:setCheMsg()
    -- body
    local id = 2
    local _t = conf.KuaFuConf:getSjzbTask(id)
    local var = _t and _t.limit_count or 1
    local task = cache.KuaFuCache:getTaskCache(id)
    local zone = cache.KuaFuCache:getZone()

    local item = self:addComponent()
    item.data = 2
    item.onClick:Add(self.onTaskSee,self)
    item:GetChild("n0").text = language.kuafu123[id]

    local dec = item:GetChild("n2")
    local dec1 = item:GetChild("n1")
    if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then --等级不足
        local ss = string.format(language.gonggong07,_t.open_lev or 0)
        dec.text = mgr.TextMgr:getTextColorStr(ss,14)
    else
        dec.text = "("..task.curCount.."/"..var..")"
    end
    if task.curCount >= var then
        dec1.text = language.kuafu130
    else
        if task.taskState == 1 then 
            --护送什么鬼镖车
            local cardId = math.max(task.cardId,1)
            local condata = conf.KuaFuConf:getSjzbCar(cardId)
            dec1.text = string.format(language.kuafu153,condata.name)
        else
            --寻找接受任务的npc
            local mConf = conf.NpcConf:getNpcById(GNPC.kfhs[zone])
            dec1.text = string.format(language.kuafu151,mConf.name)
        end
    end
end

function KuaFuWar:setBoxMsg()
    -- body
    local id = 3
    local _t = conf.KuaFuConf:getSjzbTask(id)
    local var = _t and _t.limit_count or 1
    local task = cache.KuaFuCache:getTaskCache(id)
    local box = cache.KuaFuCache:getBoxGrids()
    local zone = cache.KuaFuCache:getZone()

    local item = self:addComponent()
    item.data = 3
    item.onClick:Add(self.onTaskSee,self)
    item:GetChild("n0").text = language.kuafu123[id]

    local dec = item:GetChild("n2")
    local dec1 = item:GetChild("n1")
    if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then --等级不足
        local ss = string.format(language.gonggong07,_t.open_lev or 0)
        dec.text = mgr.TextMgr:getTextColorStr(ss,14)
    else
        dec.text = "("..task.curCount.."/"..var..")"
    end

    if task.curCount >= var then
        dec1.text = language.kuafu130
    else
        if task.taskState == 1 then 
            --添加第一个xy
            dec1.text = language.kuafu169

            -- if box[1].open == 1 then
            --     dec1.text = ""
            -- else
            --     dec1.text = string.format(language.kuafu154,box[1].pox,box[1].poy)
            -- end 
        else
            --寻找接受任务的npc
            local mConf = conf.NpcConf:getNpcById(GNPC.kfxb[zone])
            dec1.text = string.format(language.kuafu151,mConf.name)
        end
    end

    -- if task.taskState == 1 then
    --     --print("1111111111")
    --     --额外添加一个
    --     local var = UIPackage.GetItemURL("track" , "Component4")
    --     local _compent1 = self.listView:AddItemFromPool(var)
    --     local text = _compent1:GetChild("n0")
    --     _compent1.data = 4
    --     _compent1.onClick:Add(self.onTaskSee,self)
    --     if box[2].open == 1 then
    --         text.text = ""
    --     else
    --         text.text = string.format(language.kuafu154,box[2].pox,box[2].poy)
    --     end 
    -- end
end

function KuaFuWar:setMsg(pid)
    -- body
    --设置日常
    local id = pid or 1
    local _t = conf.KuaFuConf:getSjzbTask(id)
    local var = _t and _t.limit_count or 1
    local task = cache.KuaFuCache:getTaskCache(id)
    local zone = cache.KuaFuCache:getZone()
    local item --= self.btnlist[id]
    for k ,v in pairs(self.btnlist) do
        if v.data == id then
            item = v 
            break
        end
    end

    item:GetChild("n0").text = language.kuafu123[id]
    local dec = item:GetChild("n2")
    local dec1 = item:GetChild("n1")
    if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then --等级不足
        local ss = string.format(language.gonggong07,_t.open_lev or 0)
        dec.text = mgr.TextMgr:getTextColorStr(ss,14)
    else
        dec.text = "("..task.curCount.."/"..var..")"
    end

    if task.curCount >= var then
        dec1.text = language.kuafu130
    else
        if task.taskState == 1 then 
            --任务中 找对应的信息
            if id == 1 then
                dec1.text = language.kuafu152
            elseif id == 2 then
                local cardId = math.max(task.cardId,1)
                local condata = conf.KuaFuConf:getSjzbCar(cardId)
                dec1.text = string.format(language.kuafu153,condata.name)
            elseif id == 3 then
                dec1.text = string.format(language.kuafu154,task.pox,task.poy)
            end
        else
            --寻找接受任务的npc
            local mConf 
            if id == 1 then
                mConf = conf.NpcConf:getNpcById(GNPC.kfrc[zone])
            elseif id == 2 then
                mConf = conf.NpcConf:getNpcById(GNPC.kfhs[zone])
            elseif id == 3 then
                mConf = conf.NpcConf:getNpcById(GNPC.kfxb[zone])
            end
            dec1.text = string.format(language.kuafu151,mConf.name)
        end
    end

end

function KuaFuWar:onTaskSee(context)
    -- body
    if not self.data then
        return
    end

    local data = context.sender.data
    if tonumber(data) == 1 then
        --plog("日常任务")
        local _t = conf.KuaFuConf:getSjzbTask(1)
        if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then
            GComAlter(string.format(language.kuafu133,_t.open_lev or 0))
            return
        end
        local var = _t and _t.limit_count or 1
        local task = cache.KuaFuCache:getTaskCache(1)
        if task.taskState == 1 then
            --跑杀怪点
            if not self.Sconf then
                return
            end
            --默认顺序第一个boss
            local x = self.Sconf.order_monsters[1][4]
            local y = self.Sconf.order_monsters[1][5]
            --检测boss 是否活着
            if task.monsterStates[self.Sconf.order_monsters[1][2]] == 1 then
            elseif task.monsterStates[self.Sconf.order_monsters[2][2]] == 1 then
                x = self.Sconf.order_monsters[2][4]
                y = self.Sconf.order_monsters[2][5]
            end

            local point = Vector3.New(x, gRolePoz, y)
            mgr.JumpMgr:findPath(point, 100, function()
                -- body
                local target, info = mgr.ThingMgr:getNearTar()
                if info then
                    mgr.HookMgr:startHook()
                end
            end)

            proxy.KuaFuProxy:sendMsg(1410201,{type=0})
        elseif task.curCount>= var then
            GComAlter(language.kuafu124)
        else

            local zone = cache.KuaFuCache:getZone()
            local mConf = conf.NpcConf:getNpcById(GNPC.kfrc[zone])
            if mConf.pos then
                local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
                mgr.JumpMgr:findPath(point, 100, function()
                    -- body
                    proxy.KuaFuProxy:sendMsg(1410201,{type=1})
                end)
            end
        end
    elseif tonumber(data) == 2 then
        local _t = conf.KuaFuConf:getSjzbTask(2)
        if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then
            GComAlter(string.format(language.kuafu133,_t.open_lev or 0))
            return
        end
        local var = _t and _t.limit_count or 1
        local task = cache.KuaFuCache:getTaskCache(2)
        if task.taskState == 1 then
            if not cache.KuaFuCache:getIsAuto() then
                proxy.KuaFuProxy:sendMsg(1410204)
            end
            proxy.KuaFuProxy:sendMsg(1410202,{type = 0})
        elseif task.curCount>= var then 
            GComAlter(language.kuafu124)
        else
            local zone = cache.KuaFuCache:getZone()
            local mConf = conf.NpcConf:getNpcById(GNPC.kfhs[zone])
            if mConf.pos then
                mgr.ModuleMgr:startFindPath(0)
                local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
                mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(), point, function()
                    -- body
                    mgr.ViewMgr:openView2(ViewName.KufuCheViewNew,mConf.npc_use)
                end)


                -- local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
                -- mgr.JumpMgr:findPath(point, 100, function()
                --     -- body
                --     mgr.ViewMgr:openView2(ViewName.KufuCheViewNew,mConf.npc_use)
                -- end)
            end
        end
    elseif tonumber(data) == 3 or tonumber(data) == 4 then
        --plog("寻宝任务")
        local _t = conf.KuaFuConf:getSjzbTask(3)
        if (_t.open_lev or 0) > cache.PlayerCache:getRoleLevel() then
            GComAlter(string.format(language.kuafu133,_t.open_lev or 0))
            return
        end
        local task = cache.KuaFuCache:getTaskCache(3) 
        local var = _t and _t.limit_count or 1
        if task.taskState == 1 then--已经接受
            mgr.ViewMgr:openView2(ViewName.SjXBTask)
            -- local param = clone(self.data)
            -- local box = cache.KuaFuCache:getBoxGrids()

            -- local _index = 1 
            -- if tonumber(data) == 3 then
            --     _index = 1
            -- else
            --     _index = 2
            -- end
            -- local point = Vector3.New(box[_index].pox, gRolePoz, box[_index].poy)
            -- mgr.JumpMgr:findPath(point, 100, function()
            --     -- body
            -- end)
            --proxy.KuaFuProxy:sendMsg(1410203,{type=0}) 
        elseif task.curCount>= var then 
            GComAlter(language.kuafu124)
        else
            local zone = cache.KuaFuCache:getZone()
            local mConf = conf.NpcConf:getNpcById(GNPC.kfxb[zone])
            if mConf.pos then
                local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
                mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(), point, function()
                    -- body
                    proxy.KuaFuProxy:sendMsg(1410203,{type=0})
                    --proxy.KuaFuProxy:sendMsg(1410203,{type=1}) 
                end)
                -- local point = Vector3.New(mConf.pos[1], gRolePoz, mConf.pos[2])
                -- mgr.JumpMgr:findPath(point, 100, function()
                --     -- body
                --     proxy.KuaFuProxy:sendMsg(1410203,{type=0})
                --     --proxy.KuaFuProxy:sendMsg(1410203,{type=1}) 
                -- end)
            end
        end
        
    end
end

function KuaFuWar:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end
function KuaFuWar:endFuben()
    local view = mgr.ViewMgr:get(ViewName.SjHSTask)
    if view then
        view:onCloseView()
    end
    self:releaseTimer()
end
function KuaFuWar:onClickQuit()
    self:endFuben()
    mgr.FubenMgr:quitFuben()
end


return KuaFuWar