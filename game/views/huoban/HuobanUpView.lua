--
-- Author: 
-- Date: 2017-02-27 21:41:30
--

local HuobanUpView = class("HuobanUpView", base.BaseView)
local effectId = 4020104--特效id
function HuobanUpView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function HuobanUpView:initData()
    -- body
    self:playEffect()
end

function HuobanUpView:initView()
    self.model = self.view:GetChild("n2")
    self.name = self.view:GetChild("n16")
    self.t0 = self.view:GetTransition("t0")

    self.rewardlist = {}
    table.insert(self.rewardlist,self.view:GetChild("n8")) 
    table.insert(self.rewardlist,self.view:GetChild("n9")) 

    local btnSure = self.view:GetChild("n11")
    btnSure.onClick:Add(self.onSureCallBack,self)
end

function HuobanUpView:initModel(id)
    -- body
    --local condata  = conf.HuobanConf:getSkinsByJie(index,self.index)
    local panel = self.model:GetChild("n0")
    local touc = self.model:GetChild("n1")
    local node = self.model:GetChild("n2")
    if self.index == 0 or self.index == 1 or self.index == 2 then --伙伴
        --移除特效
        self.t0:Stop() 
        --添加模型
        local modelObj
        if self.index == 0 then
            modelObj = self:addModel(self.confData.modle_id,panel)
            modelObj:setScale(SkinsScale[Skins.huoban])
            modelObj:setSkins(self.confData.modle_id)
            modelObj:setRotationXYZ(0,0,0)
            modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight/2,10)
        elseif self.index == 1 then
            modelObj = self:addModel(self.confData.modle_id,panel)
            modelObj:setSkins(GuDingmodel[2],nil,self.confData.modle_id)
            modelObj:setRotationXYZ(0,0,0)
            modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight,10)
            --modelObj:setRotationXYZ(0,0,0)
        else
            --cache.PlayerCache:getSkins(Skins.huoban)
            modelObj = self:addModel(GuDingmodel[2],panel)
            modelObj:addWeaponEct(self.confData.modle_id.."_ui")
            modelObj:setRotationXYZ(0,200,0)
            modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight,10)
            
        end
    elseif self.index == 3 or self.index == 4 then --伙伴法宝
        self.effect = self:addEffect(self.confData.modle_id,panel)
        if self.index == 3 then
            self.t0:Play()
            self.effect.Scale = Vector3.New(300,300,300)
            self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight,10)
        elseif self.index == 4 then
            self.t0:Play()
            self.effect.Scale = Vector3.New(300,300,300)
            self.effect.LocalPosition = Vector3(panel.actualWidth/2,-panel.actualHeight-300,-500)
        end
    end

    local node = self.view:GetChild("n24")
    local effect = self:addEffect(4020109,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,100)
end

function HuobanUpView:setData(data_,bdata,items,power,index)
    self.data = data_
    self.items = items

    self.index = index

    local jie = (bdata.jie and bdata.jie > 0) and bdata.jie or 1
    self.jie = jie + 1
    self.confData = conf.HuobanConf:getSkinsByJie(bdata.jie+1,index)
    self:initModel()
    self.name.text = self.confData.name
    

    local nextData = conf.HuobanConf:getDataByLv(self.data.lev,index)
    local curData = conf.HuobanConf:getDataByLv(self.data.lev-1,index)
   

    for k ,v in pairs(self.rewardlist) do
        v.visible = false
    end

    if items  then
        for k ,v in pairs(items) do
            if k > 2 then
                break
            end
            
            local itemObj = self.rewardlist[k]
            itemObj.visible = true
            local param = {mid = v.mid,amount = v.amount , bind = v.bind,isquan = true}
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
end

--出现特效
function HuobanUpView:playEffect()
    self.oldTime = os.time()
    self.effect = self:addEffect(effectId, self.view:GetChild("n25"))
    mgr.SoundMgr:playSound(Audios[1])
end

function HuobanUpView:onSureCallBack()
    -- body
    local cdTime = os.time() - self.oldTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0

    local needtolv = {99,99}
    if self.index == 0 then 
        --伙伴
        needtolv = {3,4}
    elseif self.index == 1 then
        --灵羽
        needtolv = {3,4}
    elseif self.index == 2 then
        --灵兵
        needtolv = {3,4}
    elseif self.index == 3 then 
        --灵宝
        needtolv = {3,4}
    elseif self.index == 4 then
        --灵器
        needtolv = {3,4}
    end
    local confData = conf.VipChargeConf:getDataById(self.index+10)
    if needtolv[1] == self.jie or needtolv[2] == self.jie then
        --达到了档位要求 198元档的跳转
        local grade = 1
        if needtolv[2] == self.jie then
            grade = 2
        end
        if type(SkipType[GGetDayChargeDayTimes()]) == "table" then
            if (SkipType[GGetDayChargeDayTimes()][1] == (self.index+10) or SkipType[GGetDayChargeDayTimes()][2] == (self.index+10)) and GGetDayChargeState(4) then
                local param = {}
                param.mId = 221051004
                param.grade = grade
                param.isShow = true
                param.isDayFirst = true
                param.index = self.index+10
                if param.mId then
                    GGoBuyItem(param)
                end
            end
        end
    end

    self:closeView()
    -- if cdTime > confTime then
    --     GOpenAlert3(self.items)
    --     self:closeView()
    -- end
end

return HuobanUpView