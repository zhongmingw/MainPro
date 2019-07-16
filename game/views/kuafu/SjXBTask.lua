--
-- Author: wx
-- Date: 2017-08-15 17:33:22
-- 跨服寻宝

local SjXBTask = class("SjXBTask", base.BaseView)

function SjXBTask:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
    self.isBlack = true
end

function SjXBTask:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.kuafu123[3]
    self.title = dec1
    
    --地图
    self.bg = self.view:GetChild("n15"):GetChild("n0")
    --宝箱
    self.btn = self.view:GetChild("n15"):GetChild("n1")
    self.labxy = self.btn:GetChild("n2")
    self.btn.onClick:Add(self.onGoBox,self) 

    self.btnBox2 = self.view:GetChild("n15"):GetChild("n2")
    self.labxy2 = self.btnBox2:GetChild("n2")
    self.btnBox2.onClick:Add(self.onGoBox2,self) 
    --
    local dec6 = self.view:GetChild("n6")
    dec6.text = language.kuafu146

    self.listView = self.view:GetChild("n4")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata1(index, obj)
    end
    self.listView.numItems = 0

    self.btnGo = self.view:GetChild("n13")
    self.btnGo.onClick:Add(self.onGoBox3,self)
end

function SjXBTask:initData()
    -- body
    self.data = cache.KuaFuCache:getTaskCache(3)
    self:setData()
end

function SjXBTask:setBgInfo()
    -- body
    local sId = cache.PlayerCache:getSId()  
    local sConf = conf.SceneConf:getSceneById(sId)
    self.scaleX = sConf["size"][1] / 285
    self.scaleY = sConf["size"][2] / 206
    --plog("...",sConf["map_id"])
    self.bg.url = "res/maps/s"..sConf["map_id"].."/s"..sConf["map_id"].."_s"
end
function SjXBTask:celldata1( index, obj )
    -- body
    local data = self.reward[index+1]
    local t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,t,true)
end

function SjXBTask:setData()
    self:setBgInfo()
    self.title.text = language.kuafu123[3]
    self.zone = cache.KuaFuCache:getZone()
    self.data = cache.KuaFuCache:getBoxGrids()

    --self.btn.x = self.data[1].pox / self.scaleX
    --self.btn.y = self.data[1].poy / self.scaleY 
    self.labxy.text =""-- self.data[1].pox ..",".. self.data[1].poy
    self.btn.visible=true

    --self.btnBox2.x = self.data[2].pox / self.scaleX
    --self.btnBox2.y = self.data[2].poy / self.scaleY 
    self.labxy2.text =""-- self.data[2].pox ..",".. self.data[2].poy
    self.btnBox2.visible=true
    -- self.zone = cache.KuaFuCache:getZone()
    -- local _t = conf.KuaFuConf:getSjzbTask(3)
    -- self.maxPass = _t and _t.limit_count or 1

    -- --当前完成了几次
    -- self.curPass.text = "("..self.data.curCount.."/"..self.maxPass..")"
    -- self:setBgInfo()

    -- self.dec1.text = ""
    -- self.dec2.text = ""
    -- self.dec3.text = ""
    -- local _npc = conf.NpcConf:getNpcById(GNPC.kfxb[self.zone])

    self.condata = conf.KuaFuConf:getSjzbBox(self.data[1].mId)

    -- self.btn.visible = false
    -- ----检测任务状态
    -- if self.data.taskState == 1 then--已经接受
    --     self.title.text = language.kuafu123[3]
    --     --计算宝箱的位置
    --     self.btn.x = self.data.pox / self.scaleX 
    --     self.btn.y = self.data.poy / self.scaleY 
    --     --plog(self.btn.x,self.btn.y)
    --     self.labxy.text = self.data.pox ..",".. self.data.poy

    --     self.btn.visible=true
    -- elseif self.data.curCount>= self.maxPass then
    --     self.title.text = language.kuafu123[3]
    -- else
    --     self.title.text = _npc.name
    -- end

    if self.condata  then
        self.reward = self.condata.finish_item
        self.listView.numItems = self.reward and #self.reward or 0
    else
        self.listView.numItems = 0
    end
end

function SjXBTask:onGoWar()
    -- body
    if not self.data then
        return
    end
    local x 
    local y 
    if self.data.taskState == 1 then--已经接受
        x =  self.data.pox
        y = self.data.poy
    else
        --找npc
        local _npc = conf.NpcConf:getNpcById(GNPC.kfxb[self.zone])
        x = _npc.pos[1]
        y = _npc.pos[2]
    end

    local _t = conf.KuaFuConf:getSjzbTask(3)
    local var = _t and _t.limit_count or 1
    if self.data.curCount>= var then 
        GComAlter(language.kuafu124)
    else
        local param = clone(self.data)
        local point = Vector3.New(x, gRolePoz, y)
        mgr.ModuleMgr:startFindPath(0)
        mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(),point,function()
            -- body
            if param.taskState == 1 then
            else
                if param.curCount>= var then 
                    GComAlter(language.kuafu124)
                else
                    proxy.KuaFuProxy:sendMsg(1410203,{type=1}) 
                end
            end
        end)

        -- local param = clone(self.data)
        -- local point = Vector3.New(x, gRolePoz, y)
        -- mgr.JumpMgr:findPath(point, 100, function()
        --     -- body

        --     if param.taskState == 1 then
        --     else
        --         if param.curCount>= var then 
        --             GComAlter(language.kuafu124)
        --         else
        --             proxy.KuaFuProxy:sendMsg(1410203,{type=1}) 
        --         end
        --     end
        -- end)
    end
    
    

    self:onCloseView()
end

function SjXBTask:goAndGet( index )
    -- body
    local point = Vector3.New(self.data[index].pox, gRolePoz,self.data[index].poy )
    mgr.ModuleMgr:startFindPath(0)
    mgr.TaskMgr:goTaskBy(cache.PlayerCache:getSId(),point,function()
        -- body
        print("11")
        local box = cache.KuaFuCache:getBoxGrids()
        local t = {}
        for k ,v in pairs(box) do
            t[v.gridId] = v 
        end
        local monster = mgr.ThingMgr:objsByType(ThingType.monster)
        if monster then
            for k ,v in pairs(monster) do
                if v.data.kind ==  MonsterKind.sjchest then
                    if v.data.attris and v.data.attris[611] then
                        if t[v.data.attris[611]] 
                            and t[v.data.attris[611]].roleId 
                            and t[v.data.attris[611]].roleId ==  cache.PlayerCache:getRoleId() then
                            mgr.InputMgr:choosSjbx(v.data)
                            return
                        end
                    end
                end
            end
        end
    end)


    -- local point = Vector3.New(self.data[index].pox, gRolePoz,self.data[index].poy )
    -- mgr.JumpMgr:findPath(point, 40, function()
    --     -- body
    --     local box = cache.KuaFuCache:getBoxGrids()
    --     local t = {}
    --     for k ,v in pairs(box) do
    --         t[v.gridId] = v 
    --     end
    --     local monster = mgr.ThingMgr:objsByType(ThingType.monster)
    --     if monster then
    --         for k ,v in pairs(monster) do
    --             if v.data.kind ==  MonsterKind.sjchest then
    --                 if v.data.attris and v.data.attris[611] then
    --                     if t[v.data.attris[611]] 
    --                         and t[v.data.attris[611]].roleId 
    --                         and t[v.data.attris[611]].roleId ==  cache.PlayerCache:getRoleId() then
    --                         mgr.InputMgr:choosSjbx(v.data)
    --                         return
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end)
end


function SjXBTask:onGoBox3()
    -- body
    if not self.data then
        return
    end
    local box = cache.KuaFuCache:getBoxGrids()
    if box[1].open == 1 then
        self:goAndGet(2)
    else
        self:goAndGet(1)
    end
    self:closeView()
end
function SjXBTask:onGoBox(  )
    -- body
    if not self.data then
        return
    end

    self:goAndGet(1)
    self:closeView()
end

function SjXBTask:onGoBox2()
    -- body
    if not self.data then
        return
    end
    self:goAndGet(2)
    
    self:closeView()
end

function SjXBTask:onCloseView()
    -- body
    self:closeView()
end

return SjXBTask