--
-- Author: wx
-- Date: 2017-01-09 14:13:55
--

local TaskAwardView = class("TaskAwardView", base.BaseView)

function TaskAwardView:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function TaskAwardView:initData()
    -- body
    self.daily = false
    self.gang = false
end

function TaskAwardView:initView()
    self.view.onClick:Add(self.onBtnClose,self)

    local btnClose = self.view:GetChild("n11"):GetChild("n2")
    btnClose.onClick:Add(self.onBtnClose,self)

    --EVE
    local btnClose02 = self.view:GetChild("n32")
    btnClose02.onClick:Add(self.onBtnClose,self)
    --EVE end

    self.dec1 = self.view:GetChild("n19")
    self.dec2 = self.view:GetChild("n20")
    self.dec3 = self.view:GetChild("n25")
    --消耗
    self.money = self.view:GetChild("n24")
    -- self.money2 = self.view:GetChild("n29")
    self.moneyIcon = self.view:GetChild("n23")

    local btnfinsh = self.view:GetChild("n21")
    btnfinsh.onClick:Add(self.onBtnFinsh,self)
    self.btnfinsh = btnfinsh

    self.listView = self.view:GetChild("n15")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.listView1 = self.view:GetChild("n18")
    self.listView1.itemRenderer = function(index,obj)
        self:celldata1(index, obj)
    end
    self.listView1.numItems = 0

    -- --快速完成
    -- local btnFast = self.view:GetChild("n4")
    -- btnFast:GetChild("title").text  = language.task01
    -- btnFast.onClick:Add(self.onbtnFastCallBack)
    -- --全部完成
    -- local btnAll = self.view:GetChild("n5")
    -- btnAll:GetChild("title").text  = language.task02
    -- btnAll.onClick:Add(self.onbtnAllCallBack)


    -- local dec = self.view:GetChild("n7")
    -- dec.text = language.task03

    -- self.reward1 = self.view:GetChild("n8")
    -- self.reward1.visible = false

    -- self.reward2 = self.view:GetChild("n9")
    -- self.reward2.visible = false
end

function TaskAwardView:initDec()
    -- body
    self.dec1.text = ""
    self.dec2.text = ""
    self.dec3.text = ""
    self.money.text = ""
    -- self.money2.text = ""
    self.moneyIcon.url = nil
end

function TaskAwardView:initItem(data,obj)
    -- body
    local t = {mid = data[1], amount = data[2], bind = data[3]}
    GSetItemData(obj,t,true)
end

function TaskAwardView:celldata(index,obj)
    -- body
    local t = self.confData1.awards[index+1]
    self:initItem(t,obj)
end

function TaskAwardView:celldata1(index,obj)
    -- body
    local t = self.confData2.awards[index+1]
    self:initItem(t,obj)
end

function TaskAwardView:setDatadaily(data)
    -- body
    self.daily = true
    self.dec1.text = language.mian02
    --最大轮
    local max = conf.TaskConf:getValue("daily_finish_max")
    self.dec2.text = string.format(language.mian03,max) 
   
    self.dec3.text = language.mian04 
    --单轮
    self.confData1 = conf.TaskConf:getTaskDailyAward(cache.PlayerCache:getRoleLevel())
    self.listView.numItems = (self.confData1 and self.confData1.awards) and #self.confData1.awards  or 0
    --全部完成
    self.confData2 = conf.TaskConf:getTaskDailyexTaward()
    self.listView1.numItems = (self.confData2 and self.confData2.awards) and #self.confData2.awards or 0
    --设置消耗
    local money = conf.TaskConf:getValue("daily_finish_per_cost")
    self.count = max - cache.TaskCache:getdailyFinishCount()

    --plog("self.count",self.count,money)
    local use = money*self.count
    self.use = use
    self.moneyIcon.url = UIItemRes.icon01[MoneyType.gold]
    --plog("我的元宝",cache.PlayerCache:getTypeMoney(MoneyType.gold),"需要的元宝",use)
    local myGold = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if myGold >= use then
        self.isget = true
        self.money.text = mgr.TextMgr:getTextColorStr(use, 7)
    else
        self.isget = false
        self.money.text = mgr.TextMgr:getTextColorStr(use, 14)
    end
    -- self.money2.text = use

    if self.count > 0 then
        self.btnfinsh.visible = true
    else
        self.btnfinsh.visible = false
    end
end

function TaskAwardView:setDataGang()
    -- body
    self.gang = true

    self.dec1.text = language.mian02
    --最大轮
    local max = conf.TaskConf:getValue("gang_finish_max")
    self.dec2.text = string.format(language.mian03,max) 
   
    self.dec3.text = language.mian04 
    --单轮
    self.confData1 = conf.TaskConf:getTaskGangAward(self.data.taskId)
    self.listView.numItems = (self.confData1 and self.confData1.awards) and #self.confData1.awards  or 0
    --全部完成
    self.confData2 = conf.TaskConf:getTaskGangexTaward()
    self.listView1.numItems = (self.confData2 and self.confData2.awards) and #self.confData2.awards or 0
    --设置消耗
    local money = conf.TaskConf:getValue("gang_finish_per_cost")
    self.count = max - cache.TaskCache:getgangFinishCount()

    --plog("self.count",self.count,money)
    local use = money*self.count
    self.use = use
    self.moneyIcon.url = UIItemRes.icon01[MoneyType.gold]
    if use <= cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        self.isget = true
        self.money.text = mgr.TextMgr:getTextColorStr(use, 7)
    else
        self.isget = false
        self.money.text = mgr.TextMgr:getTextColorStr(use, 14)
    end
    -- self.money2.text = use
    if self.count > 0 then
        self.btnfinsh.visible = true
    else
        self.btnfinsh.visible = false
    end
end

function TaskAwardView:setData(data)
    -- body
    self.data = data
    local index = tonumber(string.sub(data.taskId,1,1))
    if index == 4 then
        self:setDatadaily()
    elseif index == 5 then
        self:setDataGang()
    end
end

function TaskAwardView:onBtnFinsh(context)
    context:StopPropagation()
    -- body 
    if not self.isget then
        GComAlter(language.gonggong18)
        return
    end
    --一件完成
    if self.daily then
        local param = {}
        param.type = 2
        param.sure = function()
            -- body
            local data = {}
            data.taskId = self.data.taskId
            data.reqType = 3 
            proxy.TaskProxy:send(1050201,data)
            self:closeView()
        end

        local t =  clone(language.mian05)
        t[2].text = string.format(t[2].text,tonumber(self.use))
        t[4].text = string.format(t[4].text,tonumber(self.count))
        param.richtext = mgr.TextMgr:getTextByTable(t)
        GComAlter(param)
    elseif self.gang then
        local param = {}
        param.type = 2
        param.sure = function()
            -- body
            local data = {}
            data.taskId = self.data.taskId
            data.reqType = 3 
            proxy.TaskProxy:send(1050301,data)
            self:closeView()
        end

        local t =  clone(language.mian09)
        t[2].text = string.format(t[2].text,tonumber(self.use))
        t[4].text = string.format(t[4].text,tonumber(self.count))
        param.richtext = mgr.TextMgr:getTextByTable(t)
        GComAlter(param)
    end
end

function TaskAwardView:onBtnClose()
    -- body
    self:closeView()
end

return TaskAwardView