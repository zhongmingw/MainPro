--
-- Author: 
-- Date: 2017-05-26 15:05:19
--

local DropItem = class("DropItem", import(".Thing"))

function DropItem:ctor()
    self.headHeight = StaticVector3.monsterHeadH
    self.headRes = "HeadView2"
    self.tType = ThingType.monster
    self.character = UnityObjMgr:CreateThing(self.tType)
    self:createHeadBar()
    self.bloodBar.visible = false
    self.headBar:GetChild("n6").visible = false
    --额外添加组件
    self.componeents = {}
end
--设置源坐标
function DropItem:setSPos(sx, sy)
    self.sx,self.sy = sx, sy
end

function DropItem:setData(data)
    self.data = data
    self.sx = self.data.sx or self.sx
    self.sy = self.data.sy or self.sy
    local mId = conf.ItemConf:getModel(data.mid)
    local isV = conf.ItemConf:getItemDropisV(data.mid)
    if isV == 1 then
        self.isVisibleName = true
    else
        self.isVisibleName = false
    end
    local mConf = conf.MonsterConf:getInfoById(mId)
    if not mConf then
        print("@策划：掉落物配置异常！")
        return
    end
    if mConf["height"] then
        self.headHeight = Vector3.New(0,-mConf["height"],0)
        self.headBar.position = self.headHeight
    end
    local body = mConf["src"]
    self:setSkins(body)
    self:thingAction()
    self:createHead()
end
--出现时间
function DropItem:getAppearTime()
    return 0.5
end
--死亡时间
function DropItem:getDeadTime()
    return 0.3
end

function DropItem:thingAction()
    if g_var.gameFrameworkVersion < 15 then
        local cpos = self:getCPos()
        self:setPosition(cpos.x, cpos.y)
    else
        self:setPosition(self.sx, self.sy)
    end
    self.character.mModel.LocalRotation = Vector3.zero
end
--掉落坐标
function DropItem:getCPos()
    return {x = self.data.cx,y = self.data.cy}
end
--出现坐标
function DropItem:getSPos()
    return {x = self.sx,y = self.sy}
end
--掉落位置
function DropItem:getSPoint()
    local pos = self:getSPos()
    return Vector3.New(pos.x,gRolePoz,pos.y)
end
--出现位置
function DropItem:getCPoint()
    local pos = self:getCPos()
    return Vector3.New(pos.x,gRolePoz,pos.y)
end

--设置外部
function DropItem:setSkins(body,kind)
    if body then
        local resPath = ResPath.monsterRes(body)
        self.character.BodyID = resPath
        cache.ResCache:addMonsterCache(resPath)
    end
end

--添加组件
function DropItem:createHead()
    self:clearComponents()
    local pack = "head"
    local component = nil
    if self.isVisibleName then--名字
        if not self.componeents["name"] then
            component = UIPackage.CreateObject(pack , "Component2")
            component:GetChild("n1").text = mgr.TextMgr:getColorNameByMid(self.data.mid,self.data.amount)
            self.componeents["name"] = component
        end   
    end
    if component then
        component.x = (self.headBar.width -  component.width)/2
        component.y = self.headBar.height - component.height
        self.headBar:AddChild(component)
    end
end

function DropItem:setTarRolId(roleId)
    self.tarRoleId = roleId
end
--目标玩家roleId
function DropItem:getTarPlayer()
    local roleId = self.tarRoleId or 0
    if roleId == cache.PlayerCache:getRoleId() then--自己
        return gRole
    else
        local player = mgr.ThingMgr:getObj(ThingType.player, roleId)
        if player then
            return player
        else
            return gRole
        end
    end
end

function DropItem:clearComponents()
    --移除多余添加控件
    for k ,v in pairs(self.componeents) do
        self.headBar:RemoveChild(v)
        v:Dispose()
        self.componeents[k] = nil 
    end
end

function DropItem:dispose()
    self.sx,self.sy = nil,nil
    self:clearComponents()
    self.isVisibleName = false
    self.super.dispose(self)
end

return DropItem