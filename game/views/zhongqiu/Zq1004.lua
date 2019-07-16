--
-- Author: 
-- Date: 2018-09-11 10:37:12
--

local Zq1004 = class("Zq1004",import("game.base.Ref"))

function Zq1004:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Zq1004:onTimer()
    if not self.data then return end
end

function Zq1004:initView()
    self.actTimeText = self.view:GetChild("n3")
    self.actDecText = self.view:GetChild("n4")
    self.awardList = self.view:GetChild("n6")
    self.awardList.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.awardList.numItems = 0
    self.getBtn = self.view:GetChild("n16")
    self.getBtn.onClick:Add(self.btnClick,self)
    self.redIcon = self.getBtn:GetChild("red")
    self.openTenToggle = self.view:GetChild("n17")
    self.moudle = self.view:GetChild("n13")
    self.effectImage = self.view:GetChild("n21")--抽奖特效

    local dec = self.view:GetChild("n18")
    dec.text = language.zq07
    self.dec3 = self.view:GetChild("n3")
    local dec4 = self.view:GetChild("n4")
    dec4.text = language.zq03
    self.dec1 = self.view:GetChild("n19")
    self.dec2 = self.view:GetChild("n20")

    local model = self.view:GetChild("n13")
    local modelId = conf.ZhongQiuConf:getGlobal("zq_zhongqiuhaoli_model")[1]
    local model1 = self.parent:addModel(modelId,model)
    model1:setPosition(60,-268,411)
    model1:setRotationXYZ(346,164,2.1)
    model1:setScale(221,221,221)
end

--[[
变量名：reqType          说明：0：显示 1：抽一次 2：抽十次
变量名：lotteryCount     说明：已抽奖次数
变量名：items            说明：获得的奖励
变量名：needCzSum        说明：还需充值的元宝数
变量名：leftLotteryCount 说明：剩余可抽奖次数
--]]

function Zq1004:addMsgCallBack(data)
    if data.msgId == 5030610 then
        self.data = data
        self.num = 0
        GOpenAlert3(data.items)
        self.zxAward = conf.ZhongQiuConf:getGlobal("zq_zx_item")--珍稀奖励
        self.awardList.numItems = #self.zxAward
        --GSetItemData(obj, {mid = zxAward[1][1],amount = zxAward[1][2],bind = zxAward[1][3]}, true)
        self.dec3.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)

        self.dec1.text = string.format(language.zq05, self.data.needCzSum)
        self.dec2.text = string.format(language.zq06, self.data.leftLotteryCount)

        if data.leftLotteryCount > 0 then
            self.getBtn.title = "开启宝箱"
        else
            self.getBtn.title = "前往充值"
        end

        self.redIcon.visible = data.leftLotteryCount > 0

        if data.leftLotteryCount > 0 then
            self.num = self.num + 1
        end
        mgr.GuiMgr:redpointByVar(30210,self.num,1)
    end
end

function Zq1004:cellData(index,obj)
    local data = self.zxAward[index+1]
    local itemData = {}
    itemData.mid = data[1]
    itemData.amount = data[2]
    itemData.bind = data[3]
    GSetItemData(obj, itemData, true)
end

function Zq1004:btnClick()
    if not self.data then return end

    if self.data.leftLotteryCount <= 0 then
        GOpenView({id = 1042})
    else
        if self.openTenToggle.selected then
            if self.data.leftLotteryCount >= 10 then
                self.effect = self.parent:addEffect(4020172, self.effectImage)
                self.effect.Scale = Vector3.New(100,100,100)
                proxy.ZhongqiuProxy:sendMsg(1030610,{reqType = 2})
            else
                GComAlter("条件未达成")
            end
        else
            if self.data.leftLotteryCount >= 1 then
                self.effect = self.parent:addEffect(4020172, self.effectImage)
                self.effect.Scale = Vector3.New(100,100,100)
                proxy.ZhongqiuProxy:sendMsg(1030610,{reqType = 1})
            end
        end
    end
end

return Zq1004