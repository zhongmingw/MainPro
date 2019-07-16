--
-- Author: 
-- Date: 2018-07-09 19:52:01
--合服基金

local HeFuFundView = class("HeFuFundView", base.BaseView)

function HeFuFundView:ctor()
    HeFuFundView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HeFuFundView:initView()
    local closeBtn = self.view:GetChild("n1")
    closeBtn.onClick:Add(self.onBtnClose,self)

    self.lastTime = self.view:GetChild("n12")
    self.lastTime.text = ""

    self.listView = self.view:GetChild("n14")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()

    self.goFundBtn = self.view:GetChild("n13")
    self.goFundBtn.onClick:Add(self.goFund,self)
    self.fundImg = self.view:GetChild("n15")
    self.fundImg.visible = false

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.c2 = self.view:GetController("c2")
    local gradeBtnList = {}
    for i=8,10 do
        local gradeBtn = self.view:GetChild("n"..i)
        table.insert(gradeBtnList,gradeBtn)
    end
    -- local fundGrade = conf.ActivityConf:getHolidayGlobal("fund_merge_grade")
    -- for k,v in pairs(fundGrade) do
    --     gradeBtnList[k].title = v[1]..language.gonggong115[1]
    -- end
    self.vipLimtTxt = self.view:GetChild("n16")
    self.vipLimtTxt.text = ""
    self:onController1()
end

function HeFuFundView:onController1()
    local hefuGrade = conf.ActivityConf:getHolidayGlobal("fund_merge_grade")
    if self.data and self.data.msgId == 5030326 then
        hefuGrade = conf.ActivityConf:getHolidayGlobal("fund_merge_grade2")
    end
    self.vipLvLimt = hefuGrade[self.c1.selectedIndex+1][3] or 0
    self.vipLimtTxt.text = string.format(language.heFuFund04,self.vipLvLimt)
    if self.data and self.data.msgId == 5030325 then
        proxy.ActivityProxy:sendMsg(1030325,{reqType = 0,invType = self.c1.selectedIndex,invId = 0})
    elseif self.data and self.data.msgId == 5030326 then
        proxy.ActivityProxy:sendMsg(1030326,{reqType = 0,invType = self.c1.selectedIndex,invId = 0})
    end
    self.listView:ScrollToView(0,false)
end
--投资状态
function HeFuFundView:setFundState()
    --已投资档位
    self.isInv = {}
    for k,v in pairs(self.data.invType) do
        if v then
            self.isInv[v] = 1
        end
    end
    if self.isInv[self.c1.selectedIndex+1] and self.isInv[self.c1.selectedIndex+1] == 1 then --当前档位已投资
        self.goFundBtn.visible = false
        self.fundImg.visible = true
    else
        self.goFundBtn.visible = true
        self.fundImg.visible = false
    end
end

function HeFuFundView:cellData(index,obj)
    local data = self.confData[index+1]
    local c1 = obj:GetController("c1")
    local dec1 = obj:GetChild("n1")
    local dec2 = obj:GetChild("n2")
    local getAawrdBtn = obj:GetChild("n4")
    getAawrdBtn.data = data
    getAawrdBtn.onClick:Add(self.getAward,self)
    if data then
        local str
        if tonumber(data.id)%1000 == 7 then
            str = language.heFuFund03
        else
            str = language.heFuFund01
        end
        dec1.text = string.format(str,tonumber(data.id)%1000)
        local t = clone(language.heFuFund02)
        t[2].text = string.format(t[2].text,tonumber(data.interest))
        dec2.text = mgr.TextMgr:getTextByTable(t)

        local awardList = obj:GetChild("n8")
        GSetAwards(awardList,data.awards)
        if self.isInv[self.c1.selectedIndex+1] and self.isInv[self.c1.selectedIndex+1] == 1 then--已投资
            if self.hasGet[data.id] then 
                if self.hasGet[data.id] == 1 then 
                    c1.selectedIndex = 2--已领取
                end
            else
                if self.data.mergeDay >= tonumber(data.id)%1000 then 
                    c1.selectedIndex = 0--可领取
                else
                    c1.selectedIndex = 1--不可领
                end
            end
        else
            c1.selectedIndex = 1--不可领
        end
    end
end
--投资
function HeFuFundView:goFund()
    local vipLv = cache.PlayerCache:getVipLv()
    if vipLv < self.vipLvLimt then
        GComAlter(language.heFuFund05)
        return
    else
        if self.data and self.data.msgId == 5030325 then
            proxy.ActivityProxy:sendMsg(1030325,{reqType = 1,invType = self.c1.selectedIndex+1,invId = 0})
        elseif self.data and self.data.msgId == 5030326 then
            proxy.ActivityProxy:sendMsg(1030326,{reqType = 1,invType = self.c1.selectedIndex+1,invId = 0})
        end
    end
end

function HeFuFundView:getAward(context)
    local data = context.sender.data
    if not self.hasGet[data.id] then
        if self.data and self.data.msgId == 5030325 then
            proxy.ActivityProxy:sendMsg(1030325,{reqType = 2,invType = self.c1.selectedIndex+1,invId = data.id})
        elseif self.data and self.data.msgId == 5030326 then
            proxy.ActivityProxy:sendMsg(1030326,{reqType = 2,invType = self.c1.selectedIndex+1,invId = data.id})
        end
    end
end

function HeFuFundView:setData(data)
    -- printt("合服基金",data)
    self.data = data
    self.time = data.lastTime

    self:setFundState()

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    if data.msgId == 5030325 then
        self.c2.selectedIndex = 0
        self.confData = conf.ActivityConf:getFundByType(self.c1.selectedIndex+1)
    elseif data.msgId == 5030326 then
        self.c2.selectedIndex = 1
        self.confData = conf.ActivityConf:getFund2ByType(self.c1.selectedIndex+1)
    end
    --已领取列表
    self.hasGet = {}
    for k,v in pairs(self.data.gotList) do
        if v then
            self.hasGet[v] = 1
        end
    end
    for k,v in pairs(self.confData) do
        if self.hasGet[v.id] then 
            if self.hasGet[v.id] == 1 then 
                self.confData[k].sort = 2--已领取
            end
        else
            self.confData[k].sort = 0
        end
    end
    table.sort(self.confData,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.listView.numItems = #self.confData

end

function HeFuFundView:onTimer()
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

function HeFuFundView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function HeFuFundView:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return HeFuFundView