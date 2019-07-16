--
-- Author:j 
-- Date: 2018-07-23 14:11:16
--

local DevilFashionView = class("DevilFashionView",base.BaseView)

function DevilFashionView:ctor()
    DevilFashionView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function DevilFashionView:initView()
    --关闭Button
    local  closeBtn = self.view:GetChild("n6")
    self:setCloseBtn(closeBtn)
    --规则Button
    local ruleBtn = self.view:GetChild("n37")
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.lastTime = self.view:GetChild("n17")
    -- 全服记录
    self.listView = self.view:GetChild("n23")
    self.listView.itemRenderer = function ( index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
    self.modelPanel=self.view:GetChild("n36")

    self:initBtn()
    --奖励列表
    self:setAwardItem()

end

function DevilFashionView:initData()

    -- self.effectImg = self.view:GetChild("n35")
    -- self.effect = self:addEffect(4020160, self.effectImg)
    -- self.effect.Scale = Vector3.New(100,100,100)
    self:initModel()

   
end   
function DevilFashionView:initModel()
    local sex = cache.PlayerCache:getSex()
    local boyShiZhuang = conf.ActivityConf:getHolidayGlobal("emsz_boy_suit_id")
    local modelId = boyShiZhuang    --恶魔模型
    if sex ~= 1 then 
        local girlShiZhuang = conf.ActivityConf:getHolidayGlobal("emsz_girl_suit_id")
        modelId = girlShiZhuang
    end
    printt("@@@",modelId)
    local modelObj = self:addModel(modelId[1],self.modelPanel)
    modelObj:setSkins(modelId[1], modelId[2])
    modelObj:setScale(147) --TODO
    modelObj:setPosition(47,-119,108)
    modelObj:setRotationXYZ(0,170,0)


end
function  DevilFashionView:initBtn()
    self.coust = conf.ActivityConf:getHolidayGlobal("emo_fashion_cost")
    self.oneBtn = self.view:GetChild("n10")
    -- self.oneBtn.icon = UIItemRes.devilFashion[1]
    self.oneBtn.data = 1
    self.oneBtn.title = self.coust[1][2]
    self.oneBtn.onClick:Add(self.goFind,self)
    self.allBtn = self.view:GetChild("n11")
    -- self.allBtn.icon = UIItemRes.devilFashion[2]
    self.allBtn.data = 2
    self.allBtn.title = self.coust[2][2]
    self.allBtn.onClick:Add(self.goFind,self)
end
--初始化奖励物品
function DevilFashionView:setAwardItem()
    
    self.listAward = self.view:GetChild("n19"):GetChild("n1")
    self.listAward.itemRenderer = function ( index,obj )
        self:itemData(index,obj)
    end
    self.awardItem = conf.ActivityConf:getHolidayGlobal("emsz_awards_show")
    self.listAward.numItems = #self.awardItem
end
--奖励物品
function DevilFashionView:itemData(index,obj)
    local data = self.awardItem[index+1]
    if data then
        local itemData = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj, itemData, true)
    end
end
function DevilFashionView:goFind(context)
    local data = context.sender.data

    local myYb = cache.PackCache:getPackDataById(PackMid.gold)
    if data == 1 then

        if myYb.amount >=self.coust[1][2] then
            proxy.ActivityProxy:sendMsg(1030223,{reqType = 1,times = 1})
        else
             GComAlter(language.gonggong18)
        end
    elseif data == 2 then
         if myYb.amount >= self.coust[2][2] then
            proxy.ActivityProxy:sendMsg(1030223,{reqType = 1,times = 10})
         else
             GComAlter(language.gonggong18)
        end
    end
end

function DevilFashionView:setData(data)
    self.data = data
    if   #data.items >2 then

    GOpenAlert3(data.items,true)
    end
    printt("恶魔时装限时活动>>>",data)
    self.time = data.lastTime
    self.listView.numItems = #data.records
    self.listView:ScrollToView(0)
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end


function DevilFashionView:onTimer()
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


function DevilFashionView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function DevilFashionView:cellData( index,obj )
    local data = self.data.records[index+1]
    local strTab = string.split(data,"|")
    local rolename = string.sub(strTab[1],6,#strTab[1])
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.devilfashion, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function DevilFashionView:onClickRule()
    GOpenRuleView(1110)
end

function DevilFashionView:onBtnClose()
       self:releaseTimer()
       self:closeView()
end

return DevilFashionView