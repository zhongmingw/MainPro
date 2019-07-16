--
-- Author: 
-- Date: 2018-01-11 11:44:04
--

local LabaZhouView = class("LabaZhouView", base.BaseView)

function LabaZhouView:ctor()
    LabaZhouView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LabaZhouView:initView()
    local closeBtn = self.view:GetChild("n6"):GetChild("n3")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.onceBtn = self.view:GetChild("n15")
    self.onceBtn.data = {status = 1}
    self.onceBtn.onClick:Add(self.goCook,self)
    self.allBtn = self.view:GetChild("n14")
    self.allBtn.data = {status = 2}
    self.allBtn.onClick:Add(self.goCook,self)
    -- self.iconList = {}
    self.amountList = {}
    -- for i=16,19 do
    --     local icon = self.view:GetChild("n"..i)
    --     table.insert(self.iconList, icon)
    -- end
    for i=25,28 do
        local amount = self.view:GetChild("n"..i)
        table.insert(self.amountList,amount)
    end
    self.effectImg = self.view:GetChild("n5")
end
function LabaZhouView:initData()
    self.materialData = conf.ActivityConf:getHolidayGlobal("laba_porridge_material")
    -- for i=1,#self.materialData do
    --     local awardData = self.materialData[i]
    --     local itemData = {mid = awardData[1],amount = awardData[2],bind = awardData[3],isquan = 0}
    --     GSetItemData(self.iconList[i],itemData, true)
    --     self.amountList[i].text = cache.PackCache:getPackDataById(awardData[1]).amount
    -- end
    self:refreshAmount()
end

function LabaZhouView:goCook(context)
    
    local status = context.sender.data.status
    local isEnough = false
    -- local isFinish = false
    self.onceBtn.touchable = false
    self.allBtn.touchable = false
    for k,v in pairs(self.materialData) do
        local amount = cache.PackCache:getPackDataById(v[1]).amount
        if amount == 0 then 
            GComAlter(language.labazhou05)
            self.onceBtn.touchable = true
            self.allBtn.touchable = true
            return
        else
            isEnough = true
        end
    end
    if isEnough then 
        local effectId = 4020153
        self.effect = self:addEffect(effectId,self.effectImg) --特效idTODO， self.effectImg
        local confEffectData = conf.EffectConf:getEffectById(effectId)
        local confTime = confEffectData and confEffectData.durition_time or 1
            mgr.TimerMgr:addTimer(confTime-1.7,1,function()
            -- print("动效播放完之后在发送请求",confTime)
            proxy.ActivityProxy:sendMsg(1030306, {reqType = status})
            -- isFinish = true
            self.onceBtn.touchable = true
            self.allBtn.touchable = true
         end)
    end
end

function LabaZhouView:refreshAmount()
    for i=1,#self.materialData do
        local awardData = self.materialData[i]
        self.amountList[i].text = cache.PackCache:getPackDataById(awardData[1]).amount
    end
end

function LabaZhouView:onClickClose()
    self:closeView()
end

return LabaZhouView