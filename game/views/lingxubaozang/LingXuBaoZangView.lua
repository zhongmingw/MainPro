--
-- Author: 
-- Date: 2018-08-28 20:24:19
--

local LingXuBaoZangView = class("LingXuBaoZangView", base.BaseView)

function LingXuBaoZangView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale 
end

function LingXuBaoZangView:initView()
    self.titleIcon = self.view:GetChild("n39")
    self.closeBtn = self.view:GetChild("n50")
    self.closeBtn.onClick:Add(self.onClickClose,self)

    self.oneTaoBao = self.view:GetChild("n22")
    self.oneCostText = self.view:GetChild("n26"):GetChild("title")
    self.oneTaoBao.data = 1
    self.oneTaoBao.onClick:Add(self.onClickBtn,self)

    self.tenTaoBao = self.view:GetChild("n23")
    self.tenCostText = self.view:GetChild("n27"):GetChild("title")
    self.tenTaoBao.data = 2
    self.tenTaoBao.onClick:Add(self.onClickBtn,self)

    self.fiftyTaoBao = self.view:GetChild("n24")
    self.fiftyCostText = self.view:GetChild("n28"):GetChild("title")
    self.fiftyTaoBao.data = 3
    self.fiftyTaoBao.onClick:Add(self.onClickBtn,self)

    self.actLeftTimeText = self.view:GetChild("n42")
    self.leftYbText = self.view:GetChild("n33")
    self.freeTaoBaoText = self.view:GetChild("n30")

    self.cancelAct = self.view:GetChild("n52")
    self.zhiZhen = self.view:GetChild("n43")--转盘指针

    self.c1 = self.view:GetController("c1")

    self.awardList = self.view:GetChild("n47")
    self.awardList.itemRenderer = function (index,obj)
        self:cellShowAwardData(index,obj)
    end
    self.awardList:SetVirtual()

    self.oneTaoBao.touchable = true
end

function LingXuBaoZangView:initData()
    self.leftYbText.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function LingXuBaoZangView:setData(data)
    self.request = nil 
    self.data = data
    self:setCost()
    self.zhiZhen.rotation = -45
    self.oneTaoBao.touchable = true

    --活动倒计时
    self.timer = self.data.actLeftTime
    --剩余可免费抽取时间倒计时
    self.leftFreeTime = self.data.freeLeftTime
    
    --多开
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActiveId)
    local titleIconStr = self.mulConfData.title_icon or "lingxubaozang_003"
    self.titleIcon.url = UIPackage.GetItemURL("lingxubaozang" , titleIconStr)
    --奖励展示
    self.awardData = conf.ActivityConf:getMulactiveshow(self.data.mulActiveId)
    self.awardList.numItems = #self.awardData.awards

    if self.data.reqType == 1 then
        self:turn()
    else
        if self.data.reqType == 2 or self.data.reqType == 3 then 
            GOpenAlert3(self.data.items)
        end 
    end

    self.leftYbText.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    
end

--抽奖消耗
function LingXuBaoZangView:setCost()
    self.oneCostConf = conf.ActivityConf:getValue("lxbz_one_cost")
    self.oneCostText.text = tostring(self.oneCostConf[2])

    self.tenCostConf = conf.ActivityConf:getValue("lxbz_ten_cost")
    self.tenCostText.text = tostring(self.tenCostConf[2])  

    self.oneCostConf = conf.ActivityConf:getValue("lxbz_fifty_cost")
    self.fiftyCostText.text = tostring(self.oneCostConf[2]) 
end

function LingXuBaoZangView:cellShowAwardData(index,obj)   
    local data = self.awardData.awards[index+1]
    if data then
        local t = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,t,true)
    end
end

function LingXuBaoZangView:onClickBtn(context)
    local data = context.sender.data
    proxy.ActivityProxy:sendMsg(1030516,{reqType = data})
    if cache.PlayerCache:getTypeMoney(MoneyType.gold) <= 0 then
        if self.c1.selectedIndex ~= 1 then
            GOpenView({id = 1042})
        end
    end
end

function LingXuBaoZangView:turn()
    if self.cancelAct.selected then 
        GOpenAlert3(self.data.items)
    else
        local curIndex = self.data.curIndex
        local num = math.random(9)
        self.zhiZhen:TweenRotate(360+num*45,3)
        self.oneTaoBao.touchable = false
        self:addTimer(3, 1, function()
            GOpenAlert3(self.data.items)
            self.oneTaoBao.touchable = true
        end)
    end
end

function LingXuBaoZangView:onTimer()
    if not self.data then return end
    self.timer = self.timer - 1
    self.timer = math.max(self.timer,0)
    if self.timer <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    if self.timer > 86400 then
        self.actLeftTimeText.text = GTotimeString7(self.timer)
    else
        self.actLeftTimeText.text = GTotimeString(self.timer)
    end

    if self.data.freeCount > 0 then
        self.freeTaoBaoText.text = "00:00:00"
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
        self.leftFreeTime = self.leftFreeTime - 1
        self.leftFreeTime = math.max(self.leftFreeTime,0)
        if self.leftFreeTime <= 0 and not self.request then
            self.request = true
            self:addTimer(1, 1, function( ... )
                -- body
                proxy.ActivityProxy:sendMsg(1030516,{reqType = 0})
            end)
        else
            if self.leftFreeTime > 86400 then
                self.freeTaoBaoText.text = GTotimeString7(self.leftFreeTime)
            else
                self.freeTaoBaoText.text = GTotimeString(self.leftFreeTime)
            end
        end
    end  
end

function LingXuBaoZangView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function LingXuBaoZangView:onClickClose()
    self:closeView()
end

return LingXuBaoZangView