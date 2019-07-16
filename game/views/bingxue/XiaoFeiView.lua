--
-- Author: 
-- Date: 2019-01-09 21:53:06
--

local XiaoFeiView = class("XiaoFeiView", base.BaseView)

function XiaoFeiView:ctor()
    XiaoFeiView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XiaoFeiView:initView()
    local closeBtn =self.view:GetChild("n8")
    self:setCloseBtn(closeBtn)

    self.modelPanel = self.view:GetChild("n31")
    local ruleBtn = self.view:GetChild("n23")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.czBtn = self.view:GetChild("n39")
    self.btnController = self.czBtn:GetController("c1")
    self.red = self.czBtn:GetChild("red")
    --活动倒计时
    self.timeText = self.view:GetChild("n16")
    --该活动已经充值总数
    self.costAmount = self.view:GetChild("n20")
    self.decText = self.view:GetChild("n34")
    --当前已充值元宝数(扣除领取礼包后的消费额)
    self.costYbAmountText =self.view:GetChild("n35")
    --需要再充值元宝数
    self.needYbText =self.view:GetChild("n36")
    --当前可领取数
    self.canGetText =self.view:GetChild("n37")
    self.model = self.view:GetChild("n45")
    self.awardList= self.view:GetChild("n44")
    self.czSlider = self.view:GetChild("n38")
    self:initAwardList()
end

function XiaoFeiView:initData()
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self:setModel()
end

function XiaoFeiView:setData(data)
    self.data= data
    local modelIdData =conf.BingXueConf:getValue("model_id")
    local modelStateData =conf.BingXueConf:getValue("model_scale_pos_rot")
    --local modelSkinIdData =conf.BingXueConf:getValue("model_skinid")
    if modelIdData and modelStateData then
        --模型参数
        self.modelId = modelIdData
        --print("ID data:"..self.modelId[1])
        self.modelParam = modelStateData[1]
        --print("data:"..self.modelParam[2][1])
        self.modelSkinId = modelSkinIdData
        self:initModel()
    end

    self.endTime = mgr.NetMgr:getServerTime()+self.data.leftTime
    self.xfData = conf.BingXueConf:getXiaoFeiData()
    local costYb = conf.BingXueConf:getValue("cost_yb") --达到领取条件所需消费额
    self.decText.text = string.format(language.xfccl01,costYb) 
    local hasGetCount = self.data.gotTimes and self.data.gotTimes or 0 --已经领取个数
    local costSum = self.data.costSum and self.data.costSum or 0 --消费总额
    self.costAmount.text = costSum..""
    local currentCost = costSum-costYb*hasGetCount --当前消费总额（扣除领取礼包后的消费额）
    self.czSlider.value = currentCost
    
    local neeYb = costYb-currentCost>=0 and (costYb-currentCost) or (costYb- math.fmod(currentCost,costYb)) --达到领取礼包还差的消费额
    if costYb-currentCost >=0 then
        self.costYbAmountText.text = string.format(language.xfccl02,currentCost,costYb)
    else
        self.costYbAmountText.text = string.format(language.xfccl06,currentCost,costYb)
    end
    
    self.needYbText.text = string.format(language.xfccl03,neeYb)
    local canGetCount = math.floor(currentCost/costYb)
    if canGetCount == 0 then 
        self.canGetText.text = string.format(language.xfccl07,canGetCount)
    else
        self.canGetText.text = string.format(language.xfccl04,canGetCount)
    end 
    
    self.awardList.numItems=#self.xfData[1].items
    if not self.timer then
        self:timeTick()
        self.timer = self:addTimer(1, -1, handler(self,self.timeTick))
    end
    local canGet =false
    if canGetCount>0 then
        self.btnController.selectedIndex = 0
        self.red.visible =true
        canGet =true
    else
        self.btnController.selectedIndex = 1
        self.red.visible =false
        canGet =false
    end
    self.czBtn.data = {canGet = canGet}
    self.czBtn.onClick:Add(self.onClickCz,self)
end
function XiaoFeiView:initAwardList()
    -- body
    self.awardList.itemRenderer=function(index, obj)
        self:cellData(index,obj)
    end
    self.awardList:SetVirtual()
    self.awardList.numItems=0
end

function XiaoFeiView:cellData(index, obj)
    local data = self.xfData[1].items[index+1]
    local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
    --printt("礼物列表集合：",itemInfo)
    GSetItemData(obj, itemInfo, true)
end

function XiaoFeiView:onClickRule()
    -- body
    GOpenRuleView(1176)
end

function XiaoFeiView:onClickCz(context)
    -- body
    local data = context.sender.data
    if data.canGet then
        proxy.BingXueProxy:sendMsg(1030702,{reqType = 1})
    else
        GComAlter(language.xfccl05)
        -- GGoVipTequan(0)  --充值
        -- self:closeView()
    end
end

function XiaoFeiView:initModel()
    -- printt("标记",self.modelId)
    -- if self.modelId[2] and self.modelId[2] == 2 then--展示是特效
    --     local effect = nil
    --     local _scale = self.modelParam[1][1]
    --     -- print("id",self.modelId[1])
    --     effect = self:addEffect(self.modelId[1], self.modelPanel)
    --     -- effect.Scale = Vector3.New(_scale,_scale,_scale)
    --     effect.LocalPosition = Vector3.New(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])
    -- else
    --     local obj = nil
    --     if self.modelId[2] and self.modelId[2] == 1 then--模型是翅膀
    --         obj = self:addModel(GuDingmodel[1],self.modelPanel)
    --         obj:setSkins(nil,nil,self.modelId[1])
    --     else
    --         print(self.modelId[1])
    --         obj = self:addModel(self.modelId[1], self.modelPanel)
    --     end
    --     print("设置结束")
    --     obj:setScale(self.modelParam[1][1])
    --     obj:setPosition(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])
    --     obj:setRotationXYZ(self.modelParam[3][1],self.modelParam[3][2],self.modelParam[3][3])
    -- end
    if self.modelId then
        -- local modelObj = self:addModel(self.modelId,self.model)
        -- modelObj:setSkins(self.modelId, self.modelSkinId)
        -- modelObj:setScale(self.modelParam[1][1]) --TODO
        -- modelObj:setRotationXYZ(self.modelParam[3][1],self.modelParam[3][2],self.modelParam[3][3])
        -- modelObj:setPosition(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])

        local effect = self:addEffect(self.modelId,self.model)
        effect.LocalRotation = Vector3.New(self.modelParam[3][1],self.modelParam[3][2],self.modelParam[3][3])
        effect.Scale = Vector3.New(self.modelParam[1][1],self.modelParam[1][1],self.modelParam[1][1])
        effect.LocalPosition = Vector3.New(self.modelParam[2][1],self.modelParam[2][2],self.modelParam[2][3])

    end

end

function XiaoFeiView:timeTick()
    local nowTime = mgr.NetMgr:getServerTime()
    --local leftTimes = self.data.leftTime
    local leftTimes = self.endTime - nowTime
    -- local str1 = GToTimeString8(nowTime)
    -- print("现在时间",str1)
    --print(self.data.leftTime)
    if leftTimes > 86400 then 
        self.timeText.text = GTotimeString7(leftTimes)
    else
        self.timeText.text = GTotimeString2(leftTimes)
    end
    if leftTimes <= 0 then 
        self:closeView()
    end
end

function XiaoFeiView:setModel()
    -- body
end

return XiaoFeiView