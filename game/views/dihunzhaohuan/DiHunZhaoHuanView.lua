--
-- Author: 
-- Date: 2018-11-27 21:51:31
--

local DiHunZhaoHuanView = class("DiHunZhaoHuanView", base.BaseView)
local TitleBtnIconUp = {
    --[面具，帝魂]
    [1] = {"dihunzhaohuan_027","dihunzhaohuan_016"},
    [2] = {"dihunzhaohuan_026","dihunzhaohuan_017"},
    [3] = {"dihunzhaohuan_025","dihunzhaohuan_018"},
}
local TitleBtnIconDown = {
    --[面具，帝魂]
    [1] = {"dihunzhaohuan_024","dihunzhaohuan_013"},
    [2] = {"dihunzhaohuan_023","dihunzhaohuan_014"},
    [3] = {"dihunzhaohuan_022","dihunzhaohuan_015"},
}

function DiHunZhaoHuanView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale 
end

function DiHunZhaoHuanView:initView()

    self.windowC1 = self.view:GetChild("n0"):GetController("c1")--0:面具，1帝魂
    local c2 = self.view:GetController("c2")
    c2.selectedIndex = self.windowC1.selectedIndex
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local btn1 = self.view:GetChild("n31")
    btn1.data = 1
    btn1.onClick:Add(self.clickChange,self)
    local btn2 = self.view:GetChild("n32")
    btn2.data = 2
    btn2.onClick:Add(self.clickChange,self)
    for i = 11,13 do 
        local btn = self.view:GetChild("n"..i)
        btn.data = i-10
        btn.onClick:Add(self.click,self)
        --根据背景窗口里的控制器设置标签按钮  bxp2019/1/10
        btn.icon = UIPackage.GetItemURL("dihunzhaohuan" , TitleBtnIconUp[btn.data][self.windowC1.selectedIndex+1])
        btn.selectedIcon  = UIPackage.GetItemURL("dihunzhaohuan" , TitleBtnIconDown[btn.data][self.windowC1.selectedIndex+1])
    end

    self.itemBtn = {}
    for i = 18,25 do 
        local btn = self.view:GetChild("n"..i)
        self.itemBtn[i-17] = btn
    end
     self.lastTime =  self.view:GetChild("n15")
     self.view:GetChild("n11").onClick:Call()
     self.onecost = self.view:GetChild("n28")
     self.tencost = self.view:GetChild("n30")
    
    self.dajiangList = {}
    for k,v in pairs(conf.ActivityConf:DiHunZhaoHuanBigAward()) do
        self.dajiangList[v.items[1]] = 1
    end
end

function DiHunZhaoHuanView:setData(data)
    -- printt("地魂召唤",data)
    self.data = data
    local isBigAward = false
    if #data.items ~= 0 then
        for k,v in pairs(data.items) do

            if self.dajiangList[v.mid] then

                isBigAward = true
                break
            end
        end
    end
    if #data.items ~= 0 then
        if isBigAward then
            self.effect1 = self.view:GetChild("n36")
            local effect = self:addEffect(4020185, self.effect1)
            effect.LocalPosition = Vector3(0,0,0)
            effect.Scale = Vector3.New(170,170,170)
            print("播放effect")
             self:addTimer(1, 1, function ()
                GOpenAlert3(data.items,true)
              
            end)
        else
            GOpenAlert3(data.items,true)
        end
    end
    self:releaseTimer()
    self.time = self.data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function  DiHunZhaoHuanView:clickChange( context)
    local data = context.sender.data
    local money =  cache.PlayerCache:getTypeMoney(MoneyType.gold)
    local price = 0
    if data ==1 then
        price =self.cost1
    elseif data == 2 then
        price =self.cost2
    end
    if money < price then
        GComAlter(language.qmbz07)
        return
    else   

        proxy.ActivityProxy:send(1030659,{reqType = data ,cid = self.choujiangtype })
    end

end

function  DiHunZhaoHuanView:click( context)
    local data = context.sender.data
    self.choujiangtype = data
    -- 4020214 4020185
   

    self.view:GetChild("n28").text = conf.ActivityConf:getValue("dihunzhaohuan_one_cost")[data][2]
    self.view:GetChild("n30").text = conf.ActivityConf:getValue("dihunzhaohuan_ten_cost")[data][2]
    self.cost1 = conf.ActivityConf:getValue("dihunzhaohuan_one_cost")[data][2]
    self.cost2 = conf.ActivityConf:getValue("dihunzhaohuan_ten_cost")[data][2]
    self.confData = {}
    self.confData = conf.ActivityConf:DiHunZhaoHuan(data)
    self:setItems()
end

function DiHunZhaoHuanView:setItems ()
    -- print(#self.confData)
    for i = 1,#self.itemBtn do 
         local itemData = {mid = self.confData[i].items[1],amount = self.confData[i].items[2],bind = self.confData[i].items[3]}
        
        GSetItemData( self.itemBtn[i],itemData,true)  
    end 
end

function DiHunZhaoHuanView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function DiHunZhaoHuanView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
    end
    self.time = self.time - 1
end

return DiHunZhaoHuanView