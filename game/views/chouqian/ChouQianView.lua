--
-- Author: 
-- Date: 2018-06-20 20:24:16
--

local ChouQianView = class("ChouQianView", base.BaseView)

function ChouQianView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale

end

function ChouQianView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local ruleBtn = self.view:GetChild("n30")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    local title1 = self.view:GetChild("n26")
    title1.text = language.chouqian01
    local title2 = self.view:GetChild("n27")
    title2.text = language.chouqian02
    local title3 = self.view:GetChild("n11")
    title3.text = language.chouqian05


     --倒计时
    self.lastTime = self.view:GetChild("n8")
    self.lastTime.text = "00"

    --剩余签数
    self.lastCount = self.view:GetChild("n12")
    self.lastCount.text = ""

     --抽签记录
    self.listView = self.view:GetChild("n7")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

    self.listView.numItems = 0
    
    --普通奖励列表
    self.awardList = {} 
    for i=16,24 do
        local itemAward = self.view:GetChild("n"..i) 
        table.insert(self.awardList,itemAward)
    end
    --上上签奖励
    self.bestAward = self.view:GetChild("n15")
    self.titleIcon = self.view:GetChild("n0"):GetChild("n8")
    local _costConf = conf.ActivityConf:getHolidayGlobal("lucky_sign_cost")
    self.costConf = {}
    for k,v in pairs(_costConf) do
        self.costConf[v[1]] = v[2]
    end
    -- local cost1 = conf.ActivityConf:getHolidayGlobal("lucky_sign_one_cost2")
    -- local cost10 = conf.ActivityConf:getHolidayGlobal("lucky_sign_ten_cost2")
    -- --抽签一次
    -- local oneBtn = self.view:GetChild("n13")
    -- oneBtn.data = 1
    -- oneBtn.title = cost1
    -- oneBtn.onClick:Add(self.onClickChou,self)
    -- --抽签十次
    -- local tenBtn = self.view:GetChild("n14") 
    -- tenBtn.data = 2
    -- tenBtn.title = cost10
    -- tenBtn.onClick:Add(self.onClickChou,self)

end
function ChouQianView:setbtnTitle()
    local cost1
    local cost10
    if self.actId == 1084 then
        cost1 = conf.ActivityConf:getHolidayGlobal("lucky_sign_one_cost2")
        cost10 = conf.ActivityConf:getHolidayGlobal("lucky_sign_ten_cost2")
    elseif self.actId == 3064 then
        cost1 = self.costConf[self.mulConfData.award_pre*1000 + 1]
        cost10 = self.costConf[self.mulConfData.award_pre*1000 + 10]
    end
    --抽签一次
    local oneBtn = self.view:GetChild("n13")
    oneBtn.data = 1
    oneBtn.title = cost1
    oneBtn.onClick:Add(self.onClickChou,self)
    --抽签十次
    local tenBtn = self.view:GetChild("n14") 
    tenBtn.data = 2
    tenBtn.title = cost10
    tenBtn.onClick:Add(self.onClickChou,self)
end


function ChouQianView:setAwardItem()

    if self.actId == 1084 then
        -- print("1084")
        self.awardItem = conf.ActivityConf:getHolidayGlobal("lucky_sign_normal_awards2")
        for k,v in pairs(self.awardItem) do
        local itemData = {mid = v[1],amount = v[2],bind = v[3]}
        GSetItemData(self.awardList[k], itemData, true)
        end
    elseif self.actId == 3064 then
        self.awardItem = conf.ActivityConf:getHylq(self.mulConfData.award_pre)
        -- printt(self.awardItem)
        for k,v in pairs(self.awardItem[1].normal_awards) do
        local itemData = {mid = v[1],amount = v[2],bind = v[3]}
            GSetItemData(self.awardList[k], itemData, true)
        end
    end
    

end

function ChouQianView:cellData(index, obj)
    local data = self.data.records[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.chouqian07, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function ChouQianView:setData(data)
     -- printt("抽签",data)

    self.data = data
    if data.msgId == 5030251 then
        self.actId = 3064
          --多开活动配置
         self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
         local titleIconStr = self.mulConfData.title_icon or "lingqian_4"
         self.titleIcon.url = UIPackage.GetItemURL("chouqian" , titleIconStr)
    else
        self.actId = data.actId
    end  
    self.listView.numItems = #data.records


    self:setbtnTitle()
    self:setAwardItem();
    self.max = self:getMax() 


    self.listView:ScrollToView(0)
    self.lastCount.text = self.max - data.useSign

    -- local itemData = {mid = data.curr.mid,amount = data.curr.amount,bind = data.curr.bind,colorStarNum = data.curr.colorStarNum}
    GSetItemData(self.bestAward, data.curr, true)
    
    if data.reqType == 0 then
        self.time = data.lastTime
        if not self.actTimer then
            self:onTimer()
            self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
        end
    else
        local param = {}
        param.items = data.items
        param.type = 5
        param.titleUrl = "ui://_imgfonts/gonggongsucai_107" 
        local str = clone(language.chouqian03)
        local ss = language.chouqian06[2]
        local tt = ""
        -- print("param.select",data.select)
        if data.select ~= 0 then
            param.titleUrl = "ui://chouqian/chunjiehuodong_029" 
            ss = language.chouqian06[1]
            tt = str[3].text
        end
        str[2].text = string.format(str[2].text,ss)
        str[3].text = tt
        -- printt("str",str)

        param.richtext = mgr.TextMgr:getTextByTable(str)
        mgr.ViewMgr:openView2(ViewName.AwardsCaseView, param)
    end
end

function ChouQianView:getMax()
    local index = 0
    local condata
    if self.actId == 1084 then
        condata = conf.ActivityConf:getHolidayGlobal("lucky_sign_random2") 
        for k , v in pairs(condata) do
        index = index + v[2]
        end
        return index
    elseif self.actId == 3064 then
        for k , v in pairs(self.awardItem) do
        index = index + v.sign
        end
        return index
    end
    
end

function ChouQianView:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    -- self.lastTime.text = GTotimeString(self.time)
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end

function ChouQianView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function ChouQianView:onClickChou(context)
    local data = context.sender.data
    if (self.max - self.data.useSign) <= 0 then
        GComAlter(language.chouqian04)
        return
    end
    if self.actId == 1084 then
        local param = {}
        param.reqType = data
        param.actId = self.actId
        proxy.ActivityProxy:sendMsg(1030315,param)
    elseif self.actId == 3064 then
        local param = {}
        param.reqType = 1
        if data == 1 then
            param.times = 1
        else
            param.times = 10
        end
        proxy.ActivityProxy:sendMsg(1030251,param)
    end
   
end

function ChouQianView:onClickRule()
    GOpenRuleView(1089)
end

function ChouQianView:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return ChouQianView