--
-- Author: EVE
-- Date: 2018-01-26 15:12:04
--

local DumplingsView = class("DumplingsView", base.BaseView)

function DumplingsView:ctor()
    DumplingsView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function DumplingsView:initView()
    --关闭
    local closeBtn = self.view:GetChild("n6"):GetChild("n3")
    closeBtn.onClick:Add(self.onClickClose,self)
    --煮一次
    self.onceBtn = self.view:GetChild("n15")
    self.onceBtn.data = {status = 1}
    self.onceBtn.onClick:Add(self.goCook,self)
    --烹煮所有
    self.allBtn = self.view:GetChild("n14")
    self.allBtn.data = {status = 2}
    self.allBtn.onClick:Add(self.goCook,self)
    --饺子材料数量
    self.amountList = {}
    for i=25,28 do
        local amount = self.view:GetChild("n"..i)
        table.insert(self.amountList,amount)
    end
    --饺子特效位置
    self.effectImg = self.view:GetChild("n5")
end

function DumplingsView:initData()
    self.isEnough = false --材料是否齐全的标志位
    self.materialData = conf.ActivityConf:getHolidayGlobal("dumplings_material")
    self:refreshAmount()
end

function DumplingsView:goCook(context)  
    local status = context.sender.data.status

    if not self.isEnough then --材料不足
        GComAlter(language.lunaryear04)

    else                      --材料充足
        local effectId = 4020154
        self.effect = self:addEffect(effectId,self.effectImg) --特效idTODO， self.effectImg
        local confEffectData = conf.EffectConf:getEffectById(effectId)
        local confTime = confEffectData and confEffectData.durition_time or 1

        mgr.TimerMgr:addTimer(confTime-1.7, 1, function()
            -- print("动效播放完之后在发送请求",confTime)
            proxy.ActivityProxy:sendMsg(1030312, {reqType = status})
        end)       
    end
end

function DumplingsView:refreshAmount()
    local count = 0
    local totalCount = #self.materialData --总材料数量
    for i=1, totalCount do
        local awardData = self.materialData[i]
        local amount = cache.PackCache:getPackDataById(awardData[1]).amount
        self.amountList[i].text = amount

        if amount > 0 then 
            count = count + 1
        end
    end

    --判断材料是否充足
    if count >= totalCount then
        self.isEnough = true
    else
        self.isEnough = false
    end
end

function DumplingsView:onClickClose()
    self:closeView()
end

return DumplingsView