--
-- Author: yr
-- Date: 2017-01-17 16:13:16
--

local UIModel = class("UIModel",import("game.base.Ref"))

function UIModel:ctor()
    self.tType = ThingType.ui
    self.model = UnityObjMgr:CreateThing(self.tType)
    self.goWrapper = nil
    self.bodyLoaded = false
    self.modelScale = Vector3.one
    self.position = Vector3.one
    self.rotation = Vector3.zero
    self.body = 0
    self.resAssets = {}
    self.mParent = nil
    self.mAngle = 0

    self.model:OnRegisterLuaFunc(function()
        self:bodyLoadSuccess()
    end)
    self.model:OnUpdateLuaFunc(function()
        if self.goWrapper and self.goWrapper.wrapTarget then
            self.goWrapper:CacheRenderers()
        end
    end)
end

function UIModel:isDispose()
    if self.model then
        return false
    end
    return true
end

function UIModel:startFight(sId, action)
    self.model:StartFight(sId, action)
end

function UIModel:setName(name)
    self.modelName = name
    self.model.Name = name
end
function UIModel:getName()
    return self.modelName
end

function UIModel:setScale(scale)
    self.model.Scale = self.modelScale*scale
end
function UIModel:setPosition(x,y,z)
    self.position.x = x
    self.position.y = y
    self.position.z = z or 0
    self.model.MapPosition = self.position
end
function UIModel:setRotation(angle)
    self.rotation.y = angle
    self.model.LocalRotation = self.rotation
end

function UIModel:setRotationZ( angle )
    -- body
    self.rotation.z = angle
    self.model.LocalRotation = self.rotation
end

function UIModel:setRotationXYZ( x,y,z )
    -- body
    self.rotation.x = x or 0
    self.rotation.y = y or 0
    self.rotation.z = z or 0
    self.model.LocalRotation = self.rotation
end

function UIModel:setSkins(body, weapon, wing)
    local hasBody, hasWeapon, hasWing
    local url
    if body then
        local modelData = conf.RoleConf:getFashionUiModel(body)
        if modelData then
            body = modelData.modelId
        end
        self.body = body
        self.bodyLoaded = false
        url = ResPath.ThingResById(body)
        self.model.BodyID, hasBody = url
        if string.find(url, '_') then
            self:updateAssetsCount(url)
        end
    end
    if weapon then
        if weapon == 0 then
            self.model.WeaponID = "0"
        else
            url = ResPath.weaponResUI(weapon)
            self.model.WeaponID, hasWeapon = url
            if string.find(url, '_') then
                self:updateAssetsCount(url)
            end
        end
    else
        self.model.WeaponID = "0"
    end
    if wing then
        if wing == 0 then
            self.model.WingID = "0"
        else
            if string.find(wing,"_yd") then
                url = ResPath.wingResUI(wing)
                self.model.WingID = url
            else
                local p, c = ResPath.wingResUI(wing)
                hasWing = c
                url = p.."_ui"
                self.model.WingID = url
            end
            self:updateAssetsCount(url)
        end
    else
        self.model.WingID = "0"
    end
    if hasBody or hasWeapon or hasWing then
        return true
    end
    return false
end

function UIModel:updateAssetsCount(url)
    local o = self.resAssets[url]
    if o then
        self.resAssets[url] = o + 1
    else
        self.resAssets[url] = 1
    end
end

function UIModel:playAnimation(s)
    self.animation = s
end

function UIModel:setParent(parent)
    if parent then
        self.goWrapper = GoWrapper.New(self.model.RootGameObj)
        self.goWrapper.rotationX = -20
        parent:SetNativeObject(self.goWrapper)
        self.mParent = parent
    end
end

function UIModel:modelTouchRotate(touchObj, sex)
    if not sex then sex = 1 end
    self.mAngle = RoleSexModel[sex].angle
    touchObj:RemoveEventListeners()
    local gesture = SwipeGesture(touchObj)
    gesture.onBegin:Add(self.onTouchBegin, self)
    gesture.onMove:Add(self.onRotation, self)
end

function UIModel:onRotation(context)
    local gesture = context.sender
    local x = math.ceil((gesture.position.x - self.evtX)/30) 
    self.mAngle = self.mAngle - x
    self:setRotation(self.mAngle)
end

function UIModel:onTouchBegin(context)
    local gesture = context.sender
    self.evtX = gesture.position.x
end

--模型加载完毕
function UIModel:bodyLoadSuccess()
   -- print("bodyLoadSuccess ")
    self.bodyLoaded = true
    if self.goWrapper and self.goWrapper.wrapTarget then
        self.goWrapper:CacheRenderers()
    end
    --武器效果
    self:addWeaponEct(self.weaponEctId)
    self:addQingbiEct(self.qlbEctId)
    self:addHeadEct(self.headEctId)
    self:addMianJuEct(self.mjEctId)
    if self.animation then
        self.model:PlayAnimationByName(self.animation)
    end
end

function UIModel:addWeaponEct(eId)
    if self.weaponEctId ~= eId and self.weaponEct then
        if self.weaponEct then
            mgr.EffectMgr:removeEffect(self.weaponEct)
            self.weaponEct = nil
        end
    end
    self.weaponEctId = eId
    --print("self.addWeaponEct bodyLoaded",self.bodyLoaded)
    if self.bodyLoaded and self.weaponEctId then
        local wParent = self.model:WeaponGuadian()
        if self.weaponEct then
            self.weaponEct.Parent = wParent.transform
            self.weaponEct.LocalRotation = Vector3.zero
            self.weaponEct.LocalPosition = Vector3.zero
            self.weaponEct.Scale = Vector3.one
            if self.goWrapper and self.goWrapper.wrapTarget then
                self.goWrapper:CacheRenderers()
            end
        else
            self.weaponEct = mgr.EffectMgr:playCommonEffect(eId, wParent, -1, function()
                if self.goWrapper and self.goWrapper.wrapTarget then
                    self.goWrapper:CacheRenderers()
                end
            end)
            self.weaponEct.LocalRotation = Vector3.zero
            self.weaponEct.LocalPosition = Vector3.zero
            self.weaponEct.Scale = Vector3.one
        end
        self.weaponEct.Layer = 5
    end
end
--模型里面加特效
function UIModel:addQingbiEct(eId)
    if self.qlbEctId ~= eId and self.qlbEct then
        if self.qlbEct then
            mgr.EffectMgr:removeEffect(self.qlbEct)
            self.qlbEct = nil
           -- print("移除")
        end
    end
    self.qlbEctId = eId
    -- print("self.addQingbiEct bodyLoaded",self.bodyLoaded,self.qlbEctId)
    if self.bodyLoaded and self.qlbEctId then
        -- print("添加",self.qlbEctId)
        local wParent = self.model.mBody:BoneNode("tuowei1")
        if self.qlbEct then
            self.qlbEct.Parent = wParent.transform
            self.qlbEct.LocalRotation = Vector3.zero
            self.qlbEct.LocalPosition = Vector3.zero
            self.qlbEct.Scale = Vector3.one
            if self.goWrapper and self.goWrapper.wrapTarget then
                self.goWrapper:CacheRenderers()
            end
        else
            self.qlbEct = mgr.EffectMgr:playCommonEffect(eId, wParent, -1, function()
                if self.goWrapper and self.goWrapper.wrapTarget then
                    self.goWrapper:CacheRenderers()
                end
            end)
            self.qlbEct.LocalRotation = Vector3.zero
            self.qlbEct.LocalPosition = Vector3.zero
            self.qlbEct.Scale = Vector3.one
        end
        self.qlbEct.Layer = 5
    end
end

--添加头饰特效
function UIModel:addHeadEct(eId)
    if self.headEctId ~= eId and self.headEct then
        if self.headEct then
            mgr.EffectMgr:removeEffect(self.headEct)
            self.headEct = nil
            -- print("移除")
        end
    end
    self.headEctId = eId
        -- print("添加头饰特效",eId)
    local  isHead = conf.RoleConf:CheckisHead(eId)
    if self.bodyLoaded and self.headEctId and isHead == 1 then
        local wParent = self.model.mBody:BoneNode("Bip001 Head")
        if self.headEct then
            self.headEct.Parent = wParent.transform
            self.headEct.LocalRotation = Vector3.zero
            self.headEct.LocalPosition = Vector3.zero
            self.headEct.Scale = Vector3.one
            if self.goWrapper and self.goWrapper.wrapTarget then
                self.goWrapper:CacheRenderers()
            end
        else
            self.headEct = mgr.EffectMgr:playCommonEffect(eId, wParent, -1, function()
                if self.goWrapper and self.goWrapper.wrapTarget then
                    self.goWrapper:CacheRenderers()
                end
            end)
            self.headEct.LocalRotation = Vector3.zero
            self.headEct.LocalPosition = Vector3.zero
            self.headEct.Scale = Vector3.one
        end
        self.headEct.Layer = 5
    end
end

--添加面具特效
function UIModel:addMianJuEct(eId)
    if self.mjEctId ~= eId and self.mjEct then
        if self.mjEct then
            mgr.EffectMgr:removeEffect(self.mjEct)
            self.mjEct = nil
           -- print("移除")
        end
    end
    self.mjEctId = eId
    local  isMianJu = conf.MianJuConf:CheckisMianJu(eId)
    if self.bodyLoaded and self.mjEctId and isMianJu == 1 then
        local wParent = self.model.mBody:BoneNode("Bip001 Head")
        if self.mjEct then
            self.mjEct.Parent = wParent.transform
            self.mjEct.LocalRotation = Vector3.zero
            self.mjEct.LocalPosition = Vector3.zero
            self.mjEct.Scale = Vector3.one
            if self.goWrapper and self.goWrapper.wrapTarget then
                self.goWrapper:CacheRenderers()
            end
        else
            self.mjEct = mgr.EffectMgr:playCommonEffect(eId, wParent, -1, function()
                if self.goWrapper and self.goWrapper.wrapTarget then
                    self.goWrapper:CacheRenderers()
                end
            end)
            self.mjEct.LocalRotation = Vector3.zero
            self.mjEct.LocalPosition = Vector3.zero
            self.mjEct.Scale = Vector3.one
        end
        self.mjEct.Layer = 5
    end
end

--模型里面加特效
function UIModel:addModelEct(eId)
    self:removeModelEct()
    local wParent = self.model.mRoot.mTransform
    self.modelEct = mgr.EffectMgr:playCommonEffect(eId, wParent, -1, function()
        if self.goWrapper and self.goWrapper.wrapTarget then
            self.goWrapper:CacheRenderers()
        end
    end)
    self.modelEct.LocalRotation = Vector3.zero
    self.modelEct.LocalPosition = Vector3.zero
    self.modelEct.Scale = Vector3.one
    self.modelEct.Layer = 5
    return self.modelEct
end
function UIModel:removeModelEct()
    if self.modelEct then
        mgr.EffectMgr:removeEffect(self.modelEct)
        self.modelEct = nil
    end
    if self.qlbEct then
        mgr.EffectMgr:removeEffect(self.qlbEct)
        self.qlbEct = nil
    end
    if self.headEct then
        mgr.EffectMgr:removeEffect(self.headEct)
        self.headEct = nil
    end
    if self.mjEct then
        mgr.EffectMgr:removeEffect(self.mjEct)
        self.mjEct = nil
    end
end

function UIModel:dispose()
    self:removeAllEvent()
    if self.qlbEct then
        mgr.EffectMgr:removeEffect(self.qlbEct)
        self.qlbEct = nil
    end
    if self.headEct then
        mgr.EffectMgr:removeEffect(self.headEct)
        self.headEct = nil
    end
    if self.mjEct then
        mgr.EffectMgr:removeEffect(self.mjEct)
        self.mjEct = nil
    end
    self.qlbEctId = nil 
    self.headEctId = nil 
    self.mjEctId = nil 
    if self.weaponEct then
        mgr.EffectMgr:removeEffect(self.weaponEct)
        self.weaponEct = nil
    end
    self:removeModelEct()
    self.goWrapper.wrapTarget = nil
    self.model:Dispose()
    self.model = nil

    if g_var.gameFrameworkVersion >= 2 then
        if self.resAssets then
            for k, v in pairs(self.resAssets) do
                for i=1,v do
                    UPoolMgr:ClearPoolByResId(k, false, false)
                end
            end
        end
    end
    self.resAssets = nil
end

return UIModel