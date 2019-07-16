--
-- Author: 
-- Date: 2018-08-13 11:00:32
--

local ScratchActive = class("ScratchActive", base.BaseView)

local CardIcon = {
    [0] = "guaguale_012",--卡背
    [1] = "guaguale_001",--天
    [2] = "guaguale_002",--地
    [3] = "guaguale_003",--地
}

function ScratchActive:ctor()
    ScratchActive.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ScratchActive:initView()
    local closeBtn = self.view:GetChild("n4")
    self:setCloseBtn(closeBtn)

    local awardBtn = self.view:GetChild("n35")
    awardBtn.onClick:Add(self.onClickAwardBtn,self)
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.ggl03

    self.showAwardList = self.view:GetChild("n30")
    self.showAwardList.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end
    self.showAwardList:SetVirtual()
    self.titleIcon = self.view:GetChild("n37")

    self.lastTime = self.view:GetChild("n14")
    


    self.listView = self.view:GetChild("n34")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()

end

function ScratchActive:initData()
    -- self.confAwardData = conf.ScratchConf:getGGLShowAward()
    -- self.confAwardData = conf.ScratchConf:getValue("show_award")
  
 
    -- self.showAwardList.numItems = #self.confAwardData
    self.canClick = true--是否可点击按钮

end

function ScratchActive:cellAwardData(index, obj)
    local data = self.confAwardData[index+1]
    local title = obj:GetChild("n27")
    local dec = obj:GetChild("n28")
    dec.text = language.ggl02
    local list = obj:GetChild("n29")
    if data then
        if index  == 2 then
            title.text = language.ggl01_01
        else
            title.text = string.format(language.ggl01,language.gonggong21[3-index])
        end
        GSetAwards(list,data)
    end
end


function ScratchActive:setData(data)
    self.data = data
    printt("刮刮乐",data)
    self.time = data.lastTime

    self.cardList = {}
    self.isGot = 0
    local defult = {"0,0,0"}
    local strTab = string.split(data.record,"|")
    -- print(strTab[1] == "")
    for i=1,5 do
        if strTab[i] then
            if strTab[i] ~= "" then
                local temp = {}
                table.insert(temp,strTab[i])
                table.insert(self.cardList,temp)
                self.isGot = self.isGot + 1
            else
                table.insert(self.cardList,defult)
            end
        else
            table.insert(self.cardList,defult)
        end
    end

    --当前抽取的卡牌
    self.curCard = {}
    table.insert(self.curCard,data.curRecord)


    self.listView.numItems = #self.cardList
    if data.arg ~= 1 then
        self.canClick = true
    end
    --多开活动配置
    self.mulConfData = conf.ActivityConf:getMulActById(self.data.mulActId)
    self:initBtn()
    local titleIconStr = self.mulConfData.title_icon or "guaguale_009"
    self.titleIcon.url = UIPackage.GetItemURL("scratch" , titleIconStr)
    self.confAwardData = conf.ActivityConf:getMulactiveshow(self.data.mulActId).awards

    self.showAwardList.numItems = #self.confAwardData

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function ScratchActive:cellData(index,obj)
    local data = self.cardList[index+1]
    local icon1 = obj:GetChild("n31")
    local icon2 = obj:GetChild("n32")
    local icon3 = obj:GetChild("n33")
    local iconList = {}
    for i=1,3 do
        local icon = obj:GetChild("n3"..i)
        table.insert(iconList,icon)
    end
    if data then
        if self.data.arg == 1 then--抽取一次
            if index +1 == self.isGot then
                local num = 1
                self:addTimer(0.5,3,function ()
                    local strTab = string.split(self.curCard[1],",")
                    iconList[num].url = UIPackage.GetItemURL("scratch",CardIcon[tonumber(strTab[num])])
                    num  = num +1
                end)
            else 
                self:setCardIcon(iconList,data)
            end
            self:addTimer(2, 1, function ()
                if self.data.items then
                    GOpenAlert3(self.data.items)
                end
                self.canClick = true
                if self.isGot == 5 then
                    proxy.ActivityProxy:sendMsg(1030219,{reqType = 0,arg = 0})
                end
            end)
        else
            self:setCardIcon(iconList,data)
        end
    end
end

function ScratchActive:setCardIcon(iconList,data)
    local strTab = string.split(data[1],",")
    for k,v in pairs(iconList) do
        v.url = UIPackage.GetItemURL("scratch",CardIcon[tonumber(strTab[k])])
    end
end

function ScratchActive:onTimer()
    if self.time > 86400 then 
        self.lastTime.text = GTotimeString7(self.time)
    else
        self.lastTime.text = GTotimeString(self.time)
    end
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function ScratchActive:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end


function ScratchActive:onClickAwardBtn()
    mgr.ViewMgr:openView2(ViewName.ScratchRecordView,self.data.personalRecord)
end

function ScratchActive:goScratch(context)
    local data = context.sender.data
    local times = data.times
    local cost = data.cost
    local ybData = cache.PackCache:getPackDataById(PackMid.gold)
    if cost > ybData.amount then
        GComAlter(language.gonggong18)
        GGoVipTequan(0)
        return
    end
    if self.canClick then
        proxy.ActivityProxy:sendMsg(1030219,{reqType = 1,arg = times})
        self.canClick  = false
    end
    
end

function ScratchActive:initBtn()
    if not self.mulConfData then return end

    local id = self.mulConfData.award_pre
    for i=1,3 do
        local confData = conf.ScratchConf:getDataById(id*1000+ i)
        printt(confData,self.mulConfData.award_pre)
        local btn = self.view:GetChild("n"..(14+i))
        btn.onClick:Clear()
        btn.data = {times = confData.times,cost = confData.cost_yb}
        btn.onClick:Add(self.goScratch,self)
        local costTitle = self.view:GetChild("n2"..i)
        costTitle.text = confData.cost_yb
    end
   
end

return ScratchActive