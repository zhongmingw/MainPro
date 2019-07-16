--
-- Author: 
-- Date: 2018-07-11 21:14:22
--

local GoldTreeView = class("GoldTreeView", base.BaseView)
local MoneyShowIcon = {
    [8] = "chongzhivip_002",--小元宝
    [7] = "chongzhivip_003",
    [6] = "chongzhivip_004",
    [5] = "chongzhivip_005",
    [4] = "chongzhivip_006",
    [3] = "chongzhivip_007",
    [2] = "chongzhivip_008",
    [1] = "chongzhivip_009",--龙
}
--组件对应动画名字
local TranName = {
    ["n42"] = 0,
    ["n41"] = 1,
    ["n40"] = 2,
    ["n39"] = 3,
    ["n38"] = 4,
    ["n37"] = 5,
    ["n36"] = 6,
    ["n35"] = 7,
}


math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))

function GoldTreeView:randomIndex(var)
    for i=1,#var do
        local index = math.random(1,#var)
        var[i],var[index] = var[index],var[i]
    end
    return var
end

function GoldTreeView:ctor()
    GoldTreeView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function GoldTreeView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n6")
    closeBtn.onClick:Add(self.onBtnClose,self)

end
function GoldTreeView:initData()
    self.isPlaying = false
    local dec1 = self.view:GetChild("n6")
    dec1.text = language.goldTree01
    local dec2 = self.view:GetChild("n7")
    dec2.text = language.goldTree02
    local dec3 = self.view:GetChild("n8")
    dec3.text = language.goldTree03

    self.idleTree = self.view:GetChild("n50")
    self.moveTree = self.view:GetChild("n51")
    self.moveTree.visible = false

    self:idelEffect()

    -- self:moveEffect()


    local ruleBtn = self.view:GetChild("n26")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    local chargeBtn = self.view:GetChild("n22")
    chargeBtn.onClick:Add(self.goCharge,self)

    self.lastTime = self.view:GetChild("n9")
    self.lastTime.text = ""
    self.czNum = self.view:GetChild("n12")
    self.flNum = self.view:GetChild("n13")

    self.logsList = self.view:GetChild("n23")
    self.logsList.itemRenderer = function(index,obj)
        self:cellLogData(index, obj)
    end
    self.logsList:SetVirtual()

    self.showList = self.view:GetChild("n24")
    self.showList.itemRenderer = function(index,obj)
        self:cellShowData(index, obj)
    end
    self.showList:SetVirtual()

    self.yaoBtn = self.view:GetChild("n43")
    self.redImg = self.yaoBtn:GetChild("red")
    self.yaoBtn.onClick:Add(self.onClickYao,self)

    self.ybList = {}
    for i=35,42 do
        local ybCom = self.view:GetChild("n"..i)
        table.insert(self.ybList,ybCom)
    end
    self.c1 = self.view:GetController("c1")
    self.needYb = self.view:GetChild("n44"):GetChild("n45")

    self.tList = {}
    for i=0,7 do
        local tran = self.view:GetTransition("t"..i)
        table.insert(self.tList,tran)
    end
   
end


function GoldTreeView:setData(data)
    printt("摇钱树",data)
    self.data = data
    self.time = data.actLeftTime
    self.czNum.text = data.czSum
    self.flNum.text = data.backSum
    self.logsList.numItems = #data.logs
    self.lastIndex = data.lastIndex--抽中的位置
    --充值档位
    self.backsKey = {}
    for k,v in pairs(data.maxBacks) do
        table.insert(self.backsKey,k)
    end
    table.sort(self.backsKey)
    self.showList.numItems = #self.backsKey
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    
    if data.reqType == 1 then
        self:playEff()
    elseif data.reqType == 0 then
        self:setYbShow()
    end

    if data.leftCount > 0 then--可抽奖
        self.c1.selectedIndex = 1
        self.redImg.visible = true
        if self.isPlaying then--正在播放
            self.yaoBtn.touchable = false
        else
            self.yaoBtn.touchable = true
        end
    else
        self.yaoBtn.touchable = false
        self.redImg.visible = false
        local isMax = true
        local need = 0
        for k,v in pairs(self.backsKey) do
            if v > data.czSum then 
                isMax = false
                need = v - data.czSum 
                break
            end
        end
        if isMax then
            self.c1.selectedIndex = 2 --到上限
        else
            self.c1.selectedIndex = 0 --不可抽
            self.needYb.text = need
        end
    end
    
end

function GoldTreeView:playEff()
    self.isPlaying = true--动画是否正在播放

    print("抽到奖励",self.data.lastIndex)
    local comName
    for k,v in pairs(self.ybList) do
        local ybNum = v:GetChild("n1")
        if tonumber(ybNum.text) == self.lastIndex then
            comName = v.name
            break
        end
    end
    comName = comName and comName or "n42"
    --动画下标
    local tranIndex = TranName[comName] +1
    --播放晃动效果
    self:moveEffect()
    self:addTimer(0.2, 1, function ()
        self.tList[tranIndex]:Play()
        self:addTimer(1.5, 1, function ()
            local awardItem = {{mid = PackMid.gold,amount = self.lastIndex ,bind = 0}}
            GOpenAlert3(awardItem)
            self:setYbShow()
            self.yaoBtn.touchable = self.c1.selectedIndex == 1 and true or false
            self.isPlaying = false
        end)
    end)
end

--树待机状态
function GoldTreeView:idelEffect()
    self.idleTree.visible = true
    self.moveTree.visible = false
    local effectId = 4020158--树待机
    self.effect = self:addModel(effectId,self.idleTree)
    self.effect:setScale(60)
    self.effect:setRotationXYZ(20,0,0)
    self.effect:setPosition(0,-15,100)
end
--树晃动状态
function GoldTreeView:moveEffect()
    self.moveTree.visible = true
    self:addTimer(0.1, 1, function ( )
        self.idleTree.visible = false
    end)
    local effectId = 4020159--树晃动
    self.effect = self:addModel(effectId,self.moveTree)
    self.effect:setScale(60)
    self.effect:setRotationXYZ(20,0,0)
    self.effect:setPosition(0,-15,100)
end


--设置摇钱树上的显示
function GoldTreeView:setYbShow()
    table.sort(self.data.cfgs,function (a,b)
        return a > b
    end)
    self.temp = {}
    local tempCfgs = clone(self.data.cfgs)
    for k,v in pairs(tempCfgs) do
        local t = {}
        t["img"] = k
        t["money"] = v
        table.insert(self.temp,t)
    end
    local var = self:randomIndex(self.temp)--随机
    for k,v in pairs(var) do
        local icon = self.ybList[k]:GetChild("n0")
        icon.url = UIPackage.GetItemURL("goldtree" , MoneyShowIcon[v.img])
        local ybNum = self.ybList[k]:GetChild("n1")
        ybNum.text = v.money
    end
end


function GoldTreeView:cellLogData(index, obj)
    local data = self.data.logs[index+1]
    local splitStr = string.split(data,ChatHerts.SYSTEMPRO) 
    local name = splitStr[1]
    local yb = splitStr[2]
    if data then
        local str = obj:GetChild("n1")
        str.text = string.format(language.goldTree04,name,yb)
    end
    -- print(">>>>>",language.goldTree04)
end

function GoldTreeView:cellShowData(index,obj)
    local data = self.backsKey[index+1]
    if data then
        local cz = obj:GetChild("n1")
        local fl = obj:GetChild("n4")
        cz.text = data
        fl.text = self.data.maxBacks[data]
    end
end

function GoldTreeView:onClickYao()
    self.yaoBtn.touchable = false
    proxy.ActivityProxy:sendMsg(1030504,{reqType = 1})
end

function GoldTreeView:goCharge()
    GGoVipTequan(0)
    self:onBtnClose()
end

function GoldTreeView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:onBtnClose()
    end

    self.time = self.time - 1
end


function GoldTreeView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function GoldTreeView:onClickRule()
    GOpenRuleView(1100)
end

function GoldTreeView:onBtnClose()
    self:releaseTimer()
    self:closeView()
end
return GoldTreeView