--
-- Author: 
-- Date: 2018-07-09 16:43:20
--

local MarryChengHao = class("MarryChengHao", base.BaseView)

function MarryChengHao:ctor()
    MarryChengHao.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function MarryChengHao:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onBtnClose,self)

    local dec1 = self.view:GetChild("n18")
    dec1.text = language.marryChengHao01

    local dec2 = self.view:GetChild("n19")
    dec2.text = language.marryChengHao02

    local dec3 = self.view:GetChild("n13")
    dec3.text = language.marryChengHao03

    local goTiQinBtn = self.view:GetChild("n9")  
    goTiQinBtn.onClick:Add(self.goTiQin,self)

    self.lastTime = self.view:GetChild("n4")
    self.lastTime.text = ""

    self.rankList = self.view:GetChild("n20")
    self.rankList.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rankList:SetVirtual()

    self.gradeBtnList = {}
    for i=14,16 do
        local btn = self.view:GetChild("n"..i)
        table.insert(self.gradeBtnList,btn)
    end

    local ruleBtn = self.view:GetChild("n26")  
    ruleBtn.onClick:Add(self.onClickRule,self)


    
end
function MarryChengHao:initData()
    local chenghaoId
    local data = cache.ActivityCache:get5030111()
    if data.acts[1108] and data.acts[1108] == 1 then --开服
        chenghaoId = conf.ActivityConf:getHolidayGlobal("marry_title_rank_titleid")
    elseif data.acts[3062] and data.acts[3062] == 1 then --限时
        chenghaoId = conf.ActivityConf:getHolidayGlobal("marry_title_rank_titleid1")
    end

    local chengHaoIcon = self.view:GetChild("n17")
    local confdata = conf.RoleConf:getTitleData(chenghaoId)
    if not confdata then
        plog("@策划 称号配置里面没有",chenghaoId)
    else
        chengHaoIcon.url = UIPackage.GetItemURL("head" , tostring(confdata.scr))
    end   
end

function MarryChengHao:cellData(index,obj)
    if index + 1 >= self.rankList.numItems then
        if not self.data.rankInfo then
            return
        end
        if self.data.page < self.data.maxPage then 
           proxy.ActivityProxy:send(1030323,{actId = self.data.actId , page = self.data.page + 1})
        end
    end
    local data = self.data.rankInfo[index + 1]
    local name1 = obj:GetChild("n0")
    local name2 = obj:GetChild("n1")
    local rank = obj:GetChild("n6")
    rank.text = index+1
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    if data then
        name1.text = data.firstName
        name2.text = data.secondName
    else
        name1.text = language.shenqirank05
        name2.text = language.shenqirank05
    end
end

function MarryChengHao:setData(data)
    printt("结婚称号",data)
    self.data = data
    self.time = data.lastTime
    self.rankList.numItems = #data.rankInfo > 10 and #data.rankInfo or 10
    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
    for k,v in pairs(self.gradeBtnList) do
        if data.gradeData[k] and data.gradeData[k] == 0 then
            v.selected = true
        else
            v.selected = false
        end
    end
end

function MarryChengHao:goTiQin()
    mgr.ViewMgr:openView2(ViewName.MarryApplyView)
    self:onBtnClose()
end

function MarryChengHao:onTimer()
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

function MarryChengHao:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function MarryChengHao:onClickRule()
    GOpenRuleView(1099)
end

function MarryChengHao:onBtnClose()
    self:releaseTimer()
    self:closeView()
end

return MarryChengHao