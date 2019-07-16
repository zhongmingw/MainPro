--
-- Author: 
-- Date: 2017-02-16 21:12:32
--

local ZuoQiUpView = class("ZuoQiUpView", base.BaseView)

local effectId = 4020104--特效id

function ZuoQiUpView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true --黑色的底
end

function ZuoQiUpView:initData()
    -- body
    self:playEffect()

    for k ,v in pairs(self.rewardlist) do
        v.visible = false
    end
end

function ZuoQiUpView:initView()
    self.model = self.view:GetChild("n2")
    self.name = self.view:GetChild("n16")
    self.t0 = self.view:GetTransition("t0")

    self.rewardlist = {}
    table.insert(self.rewardlist,self.view:GetChild("n8")) 
    table.insert(self.rewardlist,self.view:GetChild("n9")) 
    

    local btnSure = self.view:GetChild("n11")
    self.btnSure = btnSure
    btnSure.onClick:Add(self.onSureCallBack,self)
end

function ZuoQiUpView:initModel(model,scale,angle)

    local panel = self.model:GetChild("n0")
    local id = model
    if type(model) == "table" then
        id = model[1]
    end

    if self.index == 0 or self.index == 3 then
        self.t0:Stop()
        local obj = self:addModel(id,panel)
        if self.index == 3 then
            obj:setSkins(GuDingmodel[1],nil,id) 
            obj:setScale(SkinsScale[Skins.xianyu])
            obj:setRotationXYZ(0,130,0)
            obj:setPosition(panel.actualWidth/2,-panel.actualHeight,10)
        else
            obj:setScale(SkinsScale[Skins.zuoqi])
            obj:setRotationXYZ(0,90,0)
            obj:setPosition(panel.actualWidth/2,-panel.actualHeight,10)
        end
    elseif self.index == 2 or self.index == 4  then
        local obj = self:addEffect(id,panel)
        if self.index == 2 then
            self.t0:Play()
            obj.Scale = Vector3.New(300,300,300)
            obj.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50,10)
        elseif self.index == 4 then
            self.t0:Stop()
            obj.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-100,10)
        elseif self.index == 5 then
            self.t0:Play()
            obj.Scale = Vector3.New(300,300,300)
            obj.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-50+200,10)
        end
    elseif self.index == 5 then
        self.t0:Stop()
        local info = GuDingmodel[1]

        local obj = self:addModel(info,panel)
        obj:setPosition(209,-586,500)
        obj:setRotationXYZ(0,239.3,0)
        obj:setScale(SkinsScale[Skins.wuqi])
        obj:addQingbiEct(id.."_ui")
    elseif self.index == 1 then
        self.t0:Play()
        local info = cache.PlayerCache:getSkins(Skins.wuqi)
        if not info or info == 0 then
            info = GuDingmodel[3]
        end

        local obj = self:addModel(info,panel)
        obj:setPosition(panel.actualWidth/2+100,-panel.actualHeight/2+65,10)
        obj:setRotationXYZ(30,90,90)
        obj:setScale(SkinsScale[Skins.wuqi])
        obj:addModelEct(id.."_ui")
    else
        local modelObj = self:addModel(id,panel)
        if type(model) == "table" then
           modelObj:setSkins(nil,model[2],model[3])
        end
        modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight,-150)
        modelObj:setRotation(angle)
        modelObj:setScale(scale) 
    end 

    local node = self.view:GetChild("n24") --self.effect = self:addEffect(effectId, )
    local effect = self:addEffect(4020109,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,100)
end
--坐骑进阶
function ZuoQiUpView:setData(data_,bdata,items,pjie,index)
    self.index = index
    self.data = data_
    self.items = items
    
    local jie = (bdata and bdata.jie and bdata.jie > 0) and bdata.jie or 1
    self.jie = jie+1
    local modelData = conf.ZuoQiConf:getSkinsByJie(jie+1,index)

    self:initModel(modelData.modle_id,100,90)
    self.name.text = modelData.name

    local nextData = conf.ZuoQiConf:getDataByLv(self.data.lev,index)
    local curData = conf.ZuoQiConf:getDataByLv(self.data.lev-1,index)

    if items then
        for k ,v in pairs(items) do
            if k > 2 then
                break
            end
            local itemObj = self.rewardlist[k]
            itemObj.visible = true
            local param = {mid = v.mid,amount = v.amount ,bind = v.bind,isquan = true}
            GSetItemData(itemObj,param,true)
        end
    else
        if bdata.jie_items then
            for k ,v in pairs(bdata.jie_items) do
                if k > 2 then
                    break
                end
                local itemObj = self.rewardlist[k]
                itemObj.visible = true
                local param = {mid = v[1],amount = v[2] ,bind = v[3],isquan = true}
                GSetItemData(itemObj,param,true)
            end
        end
    end
    -- self:playEffect()
end

--剑神进阶
function ZuoQiUpView:setData2(data,model,items,curModelId)
    for k,v in pairs(items) do
        local itemData = {mid = v.mid,index = 0, amount = v.amount,isquan = true}
        GSetItemData(self.rewardlist[k], itemData, true)
    end
    local roleIcon = cache.PlayerCache:getRoleIcon()
    local sex = GGetMsgByRoleIcon(roleIcon).sex
    self:initModel(model,200,RoleSexModel[sex].angle)
    local confData = conf.AwakenConf:getJsAttr(data.jsLevel)
    self.name.text = conf.AwakenConf:getName(confData.starlv)
    local power1 = conf.AwakenConf:getPower(curModelId - 1)
    local power2 = conf.AwakenConf:getPower(curModelId)
    self.items = items
end

--出现特效
function ZuoQiUpView:playEffect()
    self.oldTime = os.time()
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effect = self:addEffect(effectId, self.view:GetChild("n23"))
    mgr.SoundMgr:playSound(Audios[1])
end

function ZuoQiUpView:onSureCallBack()
    -- body
    local cdTime = os.time() - self.oldTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0

    local needtolv = {99,99}
    if self.index == 0 then 
        --坐骑
        needtolv = {3,4}
    elseif self.index == 1 then
        --神兵
        needtolv = {3,4}
    elseif self.index == 2 then
        --法宝
        needtolv = {3,4}
    elseif self.index == 3 then 
        --仙羽
        needtolv = {3,4}
    elseif self.index == 4 then
        --仙器
        needtolv = {3,4}
    end
    local confData = conf.VipChargeConf:getDataById(self.index)
    if needtolv[1] == self.jie or needtolv[2] == self.jie then
        --达到了档位要求 198元档的跳转
        local grade = 1
        if needtolv[2] == self.jie then
            grade = 2
        end
        local data = cache.ActivityCache:get5030111() or {}
        local openDay = data.openDay
        if openDay <= 7 then 
            print("坐骑",openDay,SkipType[openDay%7],self.index,GGetDayChargeState(confData.charge_grade),confData.charge_grade)
            if SkipType[openDay%7] == self.index and GGetDayChargeState(4) then
                local param = {}
                param.mId = 221051004
                param.grade = grade
                param.isShow = true
                param.isDayFirst = true
                param.index = self.index
                if param.mId then
                    GGoBuyItem(param)
                end
            end
        end
    end
    self:closeView()
end

return ZuoQiUpView