--
-- Author: Your Name
-- Date: 2018-07-02 22:32:47
--充值翻牌
local RechargeDrawView = class("RechargeDrawView", base.BaseView)
local CardType = {
    [1] = "fanpan_013",
    [2] = "fanpan_011",
}
local CardBg = {
    [1] = "fanpan_014",
    [2] = "fanpan_012",
}
function RechargeDrawView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function RechargeDrawView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n36")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.cardsList = {}--翻牌列表
    for i=1,9 do
        local item = self.view:GetChild("n"..(i+6))
        table.insert(self.cardsList,item)
    end

    self.awardsList = {}--奖励列表
    for i=1,6 do
        local item = self.view:GetChild("n"..(i+26))
        table.insert(self.awardsList,item)        
    end

    self.yijianBtn = self.view:GetChild("n16")
    self.yijianBtn.onClick:Add(self.onClickYiJian,self)

    self.scoreTxt = self.view:GetChild("n23")
    self.scoreTxt.text = ""

    self.timeTxt = self.view:GetChild("n3")
    self.score = 0--剩余积分
    self:initAwards()

    self.rolePanel = self.view:GetChild("n34")
    self.modelPanel = self.view:GetChild("n33")

    self.bar = self.view:GetChild("n39"):GetChild("n0")
    self.barTxt = self.view:GetChild("n39"):GetChild("n2")

    self.dec1 = self.view:GetChild("n37")
    self.dec2 = self.view:GetChild("n38")
    self.dec1.text = language.active51
    self.dec2.text = language.active52
    --屏蔽左下角内容 bxp 2018/7/24 策划要求
    self.bar.visible = false
    self.barTxt.visible = false
    self.dec1.visible = false
    self.dec2.visible = false
end

function RechargeDrawView:initData()
    self:setModel()
    self.bar.value = 0
end

function RechargeDrawView:initAwards()
    for k,v in pairs(self.awardsList) do
        local awardData = conf.ActivityConf:getCardsAwardsById(k)
        if awardData then
            local awards = awardData.awards
            local itemInfo = {mid = awards[1][1],amount = awards[1][2],bind = awards[1][3]}
            GSetItemData(v, itemInfo, true)
        end
    end
end

-- 变量名：reqType 说明：0:显示1:翻牌2:一键翻牌3:重置
-- 变量名：openIndex   说明：开启下标，最顶为1，从左到右，从上到下，依次递增
-- 变量名：dayFreeCount    说明：今日剩余免费次数
-- 变量名：actLeftTime 说明：活动剩余时间
-- 变量名：score   说明：当前积分
-- 变量名：opens   说明：已翻的牌,key:牌index,value:配置奖励id
-- 变量名：indexTypes  说明：key:牌的下标1~7，value:1低级牌2:高级牌
-- 变量名：lastOpens   说明：翻牌操作之前打开过的东西，用于动画展示
-- 变量名：needXyb 说明：还需要x元宝可加1次
-- 变量名：curBless    说明：当前祝福值
function RechargeDrawView:setData(data)
    self.data = data
    -- self.score = data.scores
    -- self.scoreTxt.text = self.score
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.leftTime = data.actLeftTime
    self.bar.value = data.curBless
    local maxValue = conf.ActivityConf:getValue("czfp_need_zfz")
    self.bar.max = maxValue
    self.barTxt.text = data.curBless .. "/" .. maxValue
    self.timeTxt.text = GGetTimeData3(self.leftTime)
    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
    local textData = clone(language.active48)
    -- textData[2].text = string.format(textData[2].text,data.needXyb)
    self.view:GetChild("n18").text = mgr.TextMgr:getTextByTable(textData)
    local costYb = conf.ActivityConf:getValue("czfp_cost")
    self.view:GetChild("n20").text = costYb[2]
    if data.lastOpens and #data.lastOpens > 0 then
        for k,v in pairs(self.cardsList) do
            local CardBgImg = v:GetChild("n0")
            local coverImg = v:GetChild("n3")
            local itemObj = v:GetChild("n1")
            local nameTxt = v:GetChild("n2")
            if data.lastOpens[k] then
                coverImg.visible = false
                local id = data.lastOpens[k]
                local confData = conf.ActivityConf:getChargeCardsById(id)
                local mid = confData.item[1][1]
                local amount = confData.item[1][2]
                local bind = confData.item[1][3]
                nameTxt.text = conf.ItemConf:getName(mid)
                local itemInfo = {mid = mid,amount = amount,bind = bind}
                GSetItemData(itemObj, itemInfo, true)
                v.onClick:Clear()
            end
        end
        self.yijianBtn.onClick:Clear()
        mgr.TimerMgr:addTimer(2,1,function()
            self.data.lastOpens = {}
            self:setData(self.data)
            self.yijianBtn.onClick:Add(self.onClickYiJian,self)
        end) 
    else
        for k,v in pairs(self.cardsList) do
            local CardBgImg = v:GetChild("n0")
            local coverImg = v:GetChild("n3")
            local itemObj = v:GetChild("n1")
            local nameTxt = v:GetChild("n2")
            if data.indexTypes[k] == 1 then
                CardBgImg.url = UIPackage.GetItemURL("rechargedraw" , CardBg[1])
                coverImg.url = UIPackage.GetItemURL("rechargedraw" , CardType[1])
            else
                CardBgImg.url = UIPackage.GetItemURL("rechargedraw" , CardBg[2])
                coverImg.url = UIPackage.GetItemURL("rechargedraw" , CardType[2])
            end
            if data.opens[k] then
                coverImg.visible = false
                local id = data.opens[k]
                local confData = conf.ActivityConf:getChargeCardsById(id)
                local mid = confData.item[1][1]
                local amount = confData.item[1][2]
                local bind = confData.item[1][3]
                nameTxt.text = conf.ItemConf:getName(mid)
                local itemInfo = {mid = mid,amount = amount,bind = bind}
                GSetItemData(itemObj, itemInfo, true)
                v.onClick:Clear()
            else
                coverImg.visible = true
                v.data = {index = k}
                v.onClick:Add(self.onClickCard,self)
            end
        end
    end
end

function RechargeDrawView:setModel()
    local _id_ = cache.PlayerCache:getSkins(Skins.clothes)
    self.zuoqi = self:addModel(_id_,self.rolePanel)
    self.zuoqi:setScale(100)
    self.zuoqi:setPosition(0,-100,300)
    self.zuoqi:setRotationXYZ(0,150,0)
    local modelId = conf.ActivityConf:getValue("czfp_modelid") or 3040202
    -- print("当前模型id>>>>>>>>",_id_,modelId)
    self.model = self:addModel(modelId,self.modelPanel)
    self.model:setScale(100)
    self.model:setPosition(0,-250,500)
    self.model:setRotationXYZ(0,135,0)
end

function RechargeDrawView:timerClick()
    if self.leftTime > 0 then
        self.leftTime = self.leftTime - 1
        self.timeTxt.text = GGetTimeData3(self.leftTime)
    else
        self.timeTxt.text = language.acthall02
    end
end

function RechargeDrawView:onClickCard(context)
    local data = context.sender.data
    local index = data.index
    print("当前翻牌>>>>>>>>",index)
    local costYb = conf.ActivityConf:getValue("czfp_cost")
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if myYb >= costYb[2] then
        proxy.ActivityProxy:sendMsg(1030412,{reqType = 1,openIndex = index})
    else
        GComAlter(language.gonggong18)
    end
end

function RechargeDrawView:onClickYiJian()
    local costYb = conf.ActivityConf:getValue("czfp_cost")
    local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local num = 9
    for k,v in pairs(self.data.opens) do
        num = num - 1
    end
    if myYb >= costYb[2]*num then
        proxy.ActivityProxy:sendMsg(1030412,{reqType = 2})
    else
        GComAlter(language.gonggong18)
    end
end

function RechargeDrawView:onClickGuize()
    GOpenRuleView(1096)
end

return RechargeDrawView