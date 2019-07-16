--
-- Author: 
-- Date: 2017-02-22 16:17:05
--
--在线送首冲
local FirstChargeView = class("FirstChargeView", base.BaseView)


function FirstChargeView:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
end

function FirstChargeView:initData()
    self.click = true
    self.effectImg = self.view:GetChild("n45")
    self.effectImg2 = self.view:GetChild("n46")
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    if self.effect2 then
        self:removeUIEffect(self.effect2)
        self.effect2 = nil
    end
    self.effectImg.visible = true
    self.effectImg2.visible = false

    self.effect = self:addEffect(4020130, self.effectImg)
    self.t1 = self.view:GetTransition("t1")
    self.showPanel = self.view:GetChild("n44")
    local btnClose = self.showPanel:GetChild("n7")
    btnClose.onClick:Add(self.onClickClose,self)
    -- local timePlat = self.showPanel:GetChild("n14")
    local timeSi = self.showPanel:GetChild("n15")
    self.second = self.showPanel:GetChild("n16")
    self.min = self.showPanel:GetChild("n17")

    self.btnGet = self.showPanel:GetChild("n4")
    self.btnGet.onClick:Add(self.onClickGet,self)
    self.flag=true

    local confdata=conf.VipChargeConf:getVipAwardById(1)
    local awardConf=confdata.online_awards

    local titleImg= self.btnGet:GetChild("n3")
    local time=GgetOnLineTime()
    -- print("在线时间",time,confdata.online_time)
    if cache.PlayerCache:getRoleLevel() >=30 then
        titleImg.url=UIPackage.GetItemURL("firstcharge","songshouchong_005")
        self.flag=false
        -- self.second.text=""
        -- self.min.text=""
        -- -- timePlat.visible=false
        -- timeSi.visible=false
        self.btnGet:GetChild("red").visible = true
    else
        self.btnGet:GetChild("red").visible = false
    end
    self:refreshTime(confdata.online_time-time)

    self.signT = 0
    local signTimer = self:addTimer(1.2,1,function()
        self.signT = self.signT + 1
    end)


    self.timer=self:addTimer(1,-1,function()
        time=GgetOnLineTime()
        if time>=confdata.online_time then
            -- titleImg.url=UIPackage.GetItemURL("firstcharge","songshouchong_005")
            -- self.flag=false
            self:removeTimer(self.timer)
        else
            -- self.flag=true
            self:refreshTime(confdata.online_time-time)
        end
    end)


    
    local listView = self.showPanel:GetChild("n35")
    listView.numItems = 0
    for k,v in pairs(awardConf) do
        local mid = v[1]
        local amount = v[2]
        -- local bind = conf.ItemConf:getBind(mid) or 0
        local bind = v[3]
        local url = UIPackage.GetItemURL("firstcharge" , "item")
        local obj = listView:AddItemFromPool(url)
        local info = {mid = mid,amount = amount,bind = bind}
        local item = obj:GetChild("n0")
        local nameTxt = obj:GetChild("n1")
        GSetItemData(item,info,true)
        -- if amount <= 0 then
        --     nameTxt.text = conf.ItemConf:getName(mid)
        -- else
            nameTxt.text = conf.ItemConf:getName(mid)
        -- end
    end
end

function FirstChargeView:refreshTime(time)
    if time > 0 then
        --print("时间",time)
        self.second.text=string.format("%02d",time%60)
        self.min.text=math.floor(time/60)..""
    else
        self.second.text = "00"
        self.min.text = "00"
    end
end

function FirstChargeView:add5130102(data)
    --printt(data)
    -- GOpenAlert3(data.items)
    if GGetFirstChargeState(1) and GGetFirstChargeState(2) and GGetFirstChargeState(3) then
    else
        GOpenView({id = 1054})
    end
    self:onCloseView()
end

function FirstChargeView:setData(data)
    self.restNum = data.restNum
    -- print("剩余分数",self.restNum)
    self.showPanel:GetChild("n43").text = self.restNum
end

function FirstChargeView:onClickGet()
    if self.flag then
        if self.click and self.signT >= 1 then
            self:endEffect()
        end
    else
        proxy.ActivityProxy:send1130102()
    end
end

function FirstChargeView:onClickClose()
    if self.click and self.signT >= 1 then
        self:endEffect()
    end
end

function FirstChargeView:endEffect(  )
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effectImg.visible = false
    self.effectImg2.visible = true
    self.effect2 = self:addEffect(4020131, self.effectImg2)
    self:removeBlackbg()
    self.t1:Play()
    self.click = false
    self:addTimer(1.5, 1, function()
        GgoToMainTask()
        self:removeTimer(self.timer)
        self:onCloseView()
    end)
end

function FirstChargeView:onCloseView()
    self:closeView()
end

function FirstChargeView:closeView()
    -- body
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    if self.effect2 then
        --print("11111111111")
        self:removeUIEffect(self.effect2)
        self.effect2 = nil
    end
    if self.effectImg2 then
        self.effectImg2.visible = false
    end

    self.super.closeView(self)
end

return FirstChargeView