--
-- Author: 
-- Date: 2017-06-05 10:22:48
--
--外观获得提示小窗
local SkinTipsView = class("SkinTipsView", base.BaseView)

function SkinTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function SkinTipsView:initView()
    local wearBtn = self.view:GetChild("n3")
    wearBtn.onClick:Add(self.onClickWear,self)
    self.titleText = self.view:GetChild("n5")
    self.titleText.text = language.tip13
    self.nameText = self.view:GetChild("n6")
    self.icon = self.view:GetChild("n8")
    self.model = self.view:GetChild("n9")
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onClickClose,self)
end

function SkinTipsView:initData(data)
    -- print(debug.traceback())
    if data then
        self:releaseTimer()
        self:refSkinsData()
    end
end
--接收从副本缓存的外观
function SkinTipsView:setFubenSkins(skins)
    cache.PlayerCache:setSkinsList(skins)
    self:releaseTimer()
    self:refSkinsData()
end

function SkinTipsView:refSkinsData()
    self:setSkinsData()
    if not self.skinsTimer then
        self.time = SkinTipTime
        self:onTimer()
        self.skinsTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end
--设置其中一个外观数据
function SkinTipsView:setSkinsData()
    local data = cache.PlayerCache:getSkinsList()[1]
    if not data then return end
    local key = data[1]
    local skinId = data[2]
    self.titleText.text = language.tips01[key]
    self.icon.visible = false
    self.model.visible = true
    if key == Skins.clothes then--时装
        self:setClotes(skinId)
    elseif key == Skins.wuqi then
        self:setQuqi(skinId)
    elseif key == Skins.huobanteshu then--伙伴
        self:setHuoban(skinId)
    elseif key == Skins.title then--称号
        confData = conf.RoleConf:getTitleData(skinId)
        if confData then
            self.icon.url = UIPackage.GetItemURL("head" , ""..confData.scr)
            self.icon.visible = true
            self.model.visible = false
        end
    elseif key == Skins.zuoqi then--特殊坐骑
        self:setZuoqi(skinId)
    elseif key == Skins.shenbing then--特殊神兵
        self:setShenbing(skinId)
    elseif key == Skins.fabao then--特殊法宝
        self:setFabao(skinId)
    elseif key == Skins.xianyu then--特殊仙羽
        self:setWing(skinId)
    elseif key == Skins.xianqi then--特殊仙器
        self:setXianqi(skinId)
    elseif key == Skins.huobanxianyu then--特殊伙伴仙羽
        self:setHuobanxianyu(skinId)
    elseif key == Skins.huobanshenbing then--特殊伙伴神兵
        self:setHuobanshenbing(skinId)
    elseif key == Skins.huobanfabao then--特殊伙伴法宝
        self:setHuobanfabao(skinId)
    elseif key == Skins.huobanxianqi then--特殊伙伴仙器
        self:setHuobanxianqi(skinId)
    elseif key == Skins.newpet then --宠物系统皮肤
        self:setPetSkins(skinId)
    elseif key == Skins.halo then--光环
        self:setHalo(skinId)
    elseif key == Skins.headwear then--头饰
        self:setHead(skinId)
    elseif key == Skins.mianju then--面具
        self:setMianJu(skinId)    
    end
    self.nameText.text = confData and confData.name or ""
end
--衣服
function SkinTipsView:setClotes(skinId)
    local confData = conf.RoleConf:getFashData(skinId)
    self.model.visible = true
    local obj = self:addModel(confData.model,self.model)
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
    obj:setRotation(180)
    obj:setScale(120)
end
--武器
function SkinTipsView:setQuqi(skinId)
    local confData = conf.RoleConf:getFashData(skinId)
    local skins1 = cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = confData.model
    local skins3 = cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local obj = self:addModel(skins1,self.model)
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
    obj:setRotation(180)
    obj:setScale(120)
    obj:setSkins(nil,skins2,skins3)
end
--伙伴
function SkinTipsView:setHuoban(skinId)
    local confData = conf.HuobanConf:getSkinsData(skinId)
    local obj = self:addModel(confData.modle_id,self.model)
    obj:setScale(150)--SkinsScale[Skins.huoban]
    obj:setRotationXYZ(0,180,0)--180
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
end
--坐骑
function SkinTipsView:setZuoqi(skinId)
    --print("skinId",skinId)
    local cccc = 70 
    if tonumber(skinId) == 1025 then
        cccc = 50
    end

    local confData = conf.ZuoQiConf:getSkinsByIndex(skinId,0)
    local obj = self:addModel(confData.modle_id,self.model)
    if confData.scaletips then
        obj:setScale(confData.scaletips)
    else
        obj:setScale(cccc)
    end
    obj:setRotationXYZ(0,130,0)--180
    if confData.offect_xy1 then
         obj:setPosition(confData.offect_xy1[1],confData.offect_xy1[2],confData.offect_xy1[3] or 500)
    else
         obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
    end
   
end
--神兵
function SkinTipsView:setShenbing(skinId)
    local confData = conf.ZuoQiConf:getSkinsByIndex(skinId,1)
    local id = cache.PlayerCache:getSkins(Skins.wuqi)
    if id == 0 then
        id = GuDingmodel[3]
    end
    local obj = self:addModel(id,self.model)
    obj:setScale(180)
    obj:setRotationXYZ(30,90,90)
    obj:setPosition(self.model.actualWidth/2+60,-self.model.actualHeight/2-100,500)
    obj:addModelEct(confData.modle_id.."_ui")
end
--法宝
function SkinTipsView:setFabao(skinId)
    local confData = conf.ZuoQiConf:getSkinsByIndex(skinId,2)
    local effect = self:addEffect(confData.modle_id,self.model)
    effect.Scale = Vector3.New(300,300,300)
    effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight-200,500)
end
--仙羽
function SkinTipsView:setWing(skinId)
    local confData = conf.ZuoQiConf:getSkinsByIndex(skinId,3)
    local obj = self:addModel(confData.modle_id,self.model)
    obj:setSkins(GuDingmodel[1],nil,confData.modle_id)
    obj:setScale(120)
    obj:setRotationXYZ(0,330,0)--180
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
end
--仙器
function SkinTipsView:setXianqi(skinId)
    local confData = conf.ZuoQiConf:getSkinsByIndex(skinId,4)
    local effect = self:addEffect(confData.modle_id,self.model)
    effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight-300,500)

    if confData.scaletips then
        effect.Scale = Vector3.New(confData.scaletips,confData.scaletips,confData.scaletips)
    end
    if confData.postips then
        effect.LocalPosition = Vector3(confData.postips[1],confData.postips[2],500)
    end
    if confData.xuanzhuan then
        effect.LocalRotation = Vector3(confData.xuanzhuan[1],confData.xuanzhuan[2],0)
    end

end
--伙伴仙羽
function SkinTipsView:setHuobanxianyu(skinId)
    local confData = conf.HuobanConf:getSkinsByIndex(skinId,1)
    local obj = self:addModel(GuDingmodel[2],self.model)
    obj:setSkins(GuDingmodel[2],nil,confData.modle_id)
    obj:setRotationXYZ(0,0,0)
    obj:setScale(180)
    obj:setPosition(self.model.actualWidth,-self.model.actualHeight-280,500)
end
--伙伴神兵
function SkinTipsView:setHuobanshenbing(skinId)
    local confData = conf.HuobanConf:getSkinsByIndex(skinId,2)
    local id = GuDingmodel[2] 
    local obj = self:addModel(id,self.model)
    obj:setRotationXYZ(0,180,0)--180
    obj:setPosition(self.model.actualWidth/2,-self.model.actualHeight-249,500)
    obj:addWeaponEct(confData.modle_id.."_ui")
end
--伙伴法宝
function SkinTipsView:setHuobanfabao(skinId)
    local confData = conf.HuobanConf:getSkinsByIndex(skinId,3)
    local effect = self:addEffect(confData.modle_id,self.model)
    effect.Scale = Vector3.New(300,300,300)
    effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight-150,500)
end
--伙伴仙器
function SkinTipsView:setHuobanxianqi(skinId)
    local confData = conf.HuobanConf:getSkinsByIndex(skinId,4)
    local effect = self:addEffect(confData.modle_id,self.model)
    effect.LocalPosition = Vector3(self.model.actualWidth/2,-self.model.actualHeight-200,500)
end
--宠物模型
function SkinTipsView:setPetSkins(skinId)
    -- body
    local confData = conf.PetConf:getPetItem(skinId)
    local obj = self:addModel(GuDingmodel[2],self.model)
    obj:setSkins(confData.model)
    obj:setRotationXYZ(0,0,0)
    obj:setScale(180)
    obj:setPosition(self.model.actualWidth,-self.model.actualHeight-280,500)

end
--光环
function SkinTipsView:setHalo(skinId)
    local confData = conf.RoleConf:getHaloData(skinId)
    local obj = self:addModel(GuDingmodel[1],self.model)
    local modelEct = obj:addModelEct(confData.effect_id .. "_ui")
    modelEct.Scale =  Vector3.New(0.4,0.4,0.4)
    obj:setRotationXYZ(0,0,0)
    obj:setScale(120)
    obj:setPosition(50,-330,500)
end
--头饰
function SkinTipsView:setHead(skinId)
    local confData = conf.RoleConf:getHeadData(skinId)
    local obj = self:addModel(GuDingmodel[1],self.model)
    obj:setRotationXYZ(0,180,0)
    obj:setScale(120)
    obj:setPosition(50,-330,500)
    obj:addHeadEct(confData.effect_id)
end
--面具
function SkinTipsView:setMianJu(skinId)
    local confData = conf.MianJuConf:getMianJuData(skinId)
    local obj = self:addModel(GuDingmodel[1],self.model)
    obj:setRotationXYZ(0,180,0)
    obj:setScale(120)
    obj:setPosition(50,-330,500)
    obj:addMianJuEct(confData.effect_id)
end
--释放定时器
function SkinTipsView:releaseTimer()
    if self.skinsTimer then
        self:removeTimer(self.skinsTimer)
        self.skinsTimer = nil
    end
end

function SkinTipsView:onTimer()
    if self.time <= 0 then
        self:releaseTimer()
        local mAllWearData = {}
        local skinsList = cache.PlayerCache:getSkinsList()
        for k,v in pairs(skinsList) do
            local key = v[1]
            local skinId = v[2]
            mAllWearData[key] = skinId
        end
        for key,skinId in pairs(mAllWearData) do--时间到了一次性穿上几种外观
            self:sendWear(key,skinId)
        end
        self:closeView()
        return
    end
    self.time = self.time - 1
end
--穿戴外观
function SkinTipsView:onClickWear()
    local skinData = cache.PlayerCache:getSkinsList()[1]
    if skinData then
        self:sendWear(skinData[1],skinData[2])
    end
    cache.PlayerCache:cleanSkinsList()
    if #cache.PlayerCache:getSkinsList() <= 0 then 
        self:closeView() 
        return
    end
    self.time = SkinTipTime
    self:setSkinsData()
end

function SkinTipsView:sendWear(key,skinId)
    local skin = cache.PlayerCache:getSkins(key)
    if skin == skinId then
        return
    end
    if key == Skins.clothes or key == Skins.wuqi then--衣服时装时装
        proxy.PlayerProxy:send(1270105,{fashionId = skinId,reqType = 1})
    elseif key == Skins.huobanteshu then--伙伴
        proxy.HuobanProxy:send(1200105,{skinId = skinId,reqType = 0})
    elseif key == Skins.title then--称号
        proxy.PlayerProxy:send(1270102,{titleId = skinId,reqType = 1})
    elseif key == Skins.zuoqi then--特殊坐骑
        proxy.ZuoQiProxy:send(1120105,{skinId = skinId,reqType = 1})
    elseif key == Skins.shenbing then--特殊神兵
        proxy.ZuoQiProxy:send(1160105,{skinId = skinId})
    elseif key == Skins.fabao then--特殊法宝
        proxy.ZuoQiProxy:send(1170105,{skinId = skinId})
    elseif key == Skins.xianyu then--特殊仙羽
        proxy.ZuoQiProxy:send(1140105,{skinId = skinId})
    elseif key == Skins.xianqi then--特殊仙器
        proxy.ZuoQiProxy:send(1180105,{skinId = skinId})
    elseif key == Skins.huobanxianyu then--特殊伙伴仙羽
        proxy.HuobanProxy:send(1210105,{skinId = skinId})
    elseif key == Skins.huobanshenbing then--特殊伙伴神兵
        proxy.HuobanProxy:send(1220106,{skinId = skinId})
    elseif key == Skins.huobanfabao then--特殊伙伴法宝
        proxy.HuobanProxy:send(1230105,{skinId = skinId})
    elseif key == Skins.huobanxianqi then--特殊伙伴仙器
        proxy.HuobanProxy:send(1240105,{skinId = skinId})
    elseif key == Skins.halo then--光环
        proxy.PlayerProxy:send(1570102,{reqType = 1,haloId = skinId})
    elseif key == Skins.headwear then--头饰
        proxy.PlayerProxy:send(1570203,{reqType = 1,hwId = skinId})
    end
end

function SkinTipsView:onClickClose()
    cache.PlayerCache:cleanSkinsList()
    if #cache.PlayerCache:getSkinsList() <= 0 then 
        self:closeView() 
        return
    end
    self.time = SkinTipTime
    self:setSkinsData()
end

return SkinTipsView