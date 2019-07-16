--
-- Author: Your Name
-- Date: 2018-07-31 11:31:06
--趣味挖矿
local ActWaKuangView = class("ActWaKuangView", base.BaseView)

function ActWaKuangView:ctor()
    self.super.ctor(self)
    self.sharePackage = {"yaoqianshu"}
    self.uiLevel = UILevel.level2
end

function ActWaKuangView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local guizeBtn = self.view:GetChild("n8")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    --矿石列表
    self.kuangList = {}
    for i=26,30 do
        local item = self.view:GetChild("n"..i)
        item.visible = false
        table.insert(self.kuangList,item)
    end
    --刷新倒计时
    self.refreshTimeTxt = self.view:GetChild("n22")
    self.leftRefTime = 0
    --活动倒计时
    self.actLastTimeTxt = self.view:GetChild("n19")
    self.actLeftTime = nil
    --刷新消耗
    self.refreshCostTxt = self.view:GetChild("n17")
    --免费挖矿次数
    self.freeCountTxt = self.view:GetChild("n23")
    --全服累计挖矿数量
    self.wkSumTxt = self.view:GetChild("n25")
    --刷新按钮
    self.refreshBtn = self.view:GetChild("n15")
    self.refreshBtn.onClick:Add(self.onClickRefresh,self)
    --vip目标奖励进度条
    self.barList = {}
    for i=31,36 do
        local bar = self.view:GetChild("n"..i)
        table.insert(self.barList,bar)
    end
    --vip目标奖励箱子
    self.vipAwardsList = {}
    for i=9,14 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.vipAwardsList,item)
    end
    self.checkBtn = self.view:GetChild("n37")
    self.checkBtn.onChanged:Add(self.selelctCheck,self)
    --标题
    self.titleIcon = self.view:GetChild("n0"):GetChild("icon")
end

function ActWaKuangView:selelctCheck()
    if self.checkBtn.selected then
        cache.ActivityCache:setWkAlertFlag(false)
    else
        cache.ActivityCache:setWkAlertFlag(true)
    end
end

function ActWaKuangView:initData()
    local refcost = conf.ActivityConf:getValue("qwwk_ref_cost")[2]
    self.refreshCostTxt.text = refcost
end

-- 变量名：reqType 说明：0:显示1:挖2:换矿3:兑换4：领取vip奖励
-- 变量名：cfgId   说明：配置id
-- array<SimpleItemInfo>   变量名：items   说明：获得的道具
-- 变量名：wkSum   说明：全服累计挖矿数量
-- 变量名：targetAwardSigns    说明：挖矿目标奖励已领取标识
-- 变量名：wkStatus    说明：挖矿状态key->配置id valuie:1已挖掉
-- 变量名：actLeftTime 说明：活动剩余时间
-- 变量名：leftFreeWkCount 说明：剩余免费挖矿次数
-- 变量名：nextRefreshTime 说明：下次刷新的时间点
-- 变量名：mulActiveId 说明：多开活动id
function ActWaKuangView:setData(data)
    -- printt("挖矿活动>>>>>>>",data)
    self.data = data
    self.mulActiveId = data.mulActiveId
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActiveId)
    if mulActConf.title_icon then
        self.titleIcon.url = UIPackage.GetItemURL("rechargedraw" , mulActConf.title_icon)
    end
    --矿石列表
    self.wkStatus = {}
    for k,v in pairs(data.wkStatus) do
        table.insert(self.wkStatus,{id = v.index,value = v.open,cfgId = v.cfgId})
    end
    table.sort(self.wkStatus,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end) 
    for k,v in pairs(self.kuangList) do
        if self.wkStatus[k] and self.wkStatus[k].value ~= 1 then--已刷新
            v.visible = true
            local icon = v:GetChild("n0")
            local nameTxt = v:GetChild("n2")
            local confData = conf.ActivityConf:getActWaKuangData(self.wkStatus[k].cfgId)
            local name = conf.ItemConf:getName(confData.item[1][1])
            nameTxt.text = name
            -- local src = conf.ItemConf:getSrc(confData.item[1][1])
            icon.url = UIPackage.GetItemURL("rechargedraw" , confData.icon)
            v.data = self.wkStatus[k]
            v.onClick:Add(self.onClickScoop,self)
        else
            v.visible = false
        end
    end

    local freeCount = conf.ActivityConf:getValue("qwwk_free_count")
    local leftFreeWkCount = data.leftFreeWkCount > 0 and data.leftFreeWkCount or 0
    self.freeCountTxt.text = leftFreeWkCount .. "/" .. freeCount
    self.wkSumTxt.text = data.wkSum

    --活动倒计时
    self.actLeftTime = data.actLeftTime
    self.actLastTimeTxt.text = GGetTimeData2(self.actLeftTime)
    --刷新倒计时
    local netTime = mgr.NetMgr:getServerTime()
    self.leftRefTime = self.data.nextRefreshTime - netTime
    self.refreshTimeTxt.text = GTotimeString(self.leftRefTime)
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    --兑换列表
    self:initList()
    --vip目标奖励
    self:setVipAwards(data)
end

--兑换列表
function ActWaKuangView:initList()
    local confData = conf.ActivityConf:getMulActById(self.mulActiveId)
    self.convertData = conf.ActivityConf:getConversionList(confData.award_pre)
    self.listView.numItems = #self.convertData
end

--vip目标奖励
function ActWaKuangView:setVipAwards(data)
    local confData = conf.ActivityConf:getMulActById(self.mulActiveId)
    self.vipAwards = conf.ActivityConf:getVipAwardsData(confData.award_pre)
    for k,v in pairs(self.vipAwards) do
        local item = self.vipAwardsList[k]
        local numTxt = item:GetChild("n1")
        local light = item:GetChild("n2")
        local icon = item:GetChild("n0")
        icon.url = UIPackage.GetItemURL("rechargedraw" , "yaoqian_009")
        light.visible = false
        numTxt.text = v.wk_count
        local flag = false--是否领取过
        for k,cfgId in pairs(data.targetAwardSigns) do
            if cfgId == v.id then
                flag = true
            end
        end
        if data.wkSum >= v.wk_count and not flag then
            local vipLv = cache.PlayerCache:getVipLv()
            if vipLv >= v.vip_con then
                light.visible = true
                icon.url = UIPackage.GetItemURL("rechargedraw" , "yaoqian_008")
            end
        end
        --进度条
        local bar = self.barList[k]
        if self.vipAwards[k-1] then
            local leftCount = self.vipAwards[k-1].wk_count--上一个目标奖励所需挖矿数
            bar.value = data.wkSum - leftCount
            bar.max = v.wk_count - leftCount
        else--第一个进度条
            bar.value = data.wkSum
            bar.max = v.wk_count
        end
        item.data = {cfgId = v.id,needCount = v.wk_count,wkSum = data.wkSum,flag = flag,vipLv = v.vip_con,item = v.item}
        item.onClick:Add(self.onClickGetAwards,self)
    end
end

function ActWaKuangView:onTimer()
    if self.actLeftTime then 
        if self.actLeftTime > 0 then
            self.actLastTimeTxt.text = GGetTimeData2(self.actLeftTime)
            self.actLeftTime = self.actLeftTime - 1
        else
            self:closeView()
        end
    end
    if self.leftRefTime > 0 then
        self.refreshTimeTxt.text = GTotimeString(self.leftRefTime)
        self.leftRefTime = self.leftRefTime - 1
    else
        proxy.ActivityProxy:sendMsg(1030506,{reqType = 0,cfgId = 0})
    end
end

function ActWaKuangView:onClickScoop(context)
    local data = context.sender.data
    if data then
        local confData = conf.ActivityConf:getActWaKuangData(data.cfgId)
        local needYb = confData.cost_money[2]
        local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        if self.data.leftFreeWkCount > 0 then
            proxy.ActivityProxy:sendMsg(1030506,{reqType = 1,cfgId = data.id})
        else
            local alertFlag = cache.ActivityCache:getWkAlertFlag()
            if alertFlag then
                local param = {}
                param.type = 2
                param.sure = function()
                    if myYb >= needYb then
                        proxy.ActivityProxy:sendMsg(1030506,{reqType = 1,cfgId = data.id})
                    else
                        GComAlter(language.gonggong18)
                    end
                end
                local t = clone(language.active63)
                t[2].text = string.format(t[2].text,needYb)
                param.richtext = mgr.TextMgr:getTextByTable(t)
                GComAlter(param)
            else
                if myYb >= needYb then
                    proxy.ActivityProxy:sendMsg(1030506,{reqType = 1,cfgId = data.id})
                else
                    GComAlter(language.gonggong18)
                end
            end
        end
    end
end

function ActWaKuangView:onClickRefresh()
    if not self.data then
        return
    end
    local flag = true
    for k,v in pairs(self.data.wkStatus) do
        if v.open == 0 then
            flag = false
        end
    end
    if flag then
        local refcost = conf.ActivityConf:getValue("qwwk_ref_cost")[2]
        local myYb = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        -- local param = {}
        -- param.type = 2
        -- param.sure = function()
            if myYb >= refcost then
                proxy.ActivityProxy:sendMsg(1030506,{reqType = 2})
            else
                GComAlter(language.gonggong18)
            end
        -- end
        -- local t = clone(language.active64)
        -- t[2].text = string.format(t[2].text,refcost)
        -- param.richtext = mgr.TextMgr:getTextByTable(t)
        -- GComAlter(param)
    else
        GComAlter(language.active62)
    end
end

function ActWaKuangView:celldata(index,obj)
    local data = self.convertData[index+1]
    if data then
        local getItem = obj:GetChild("n2")
        local itemInfo = {mid = data.item[1][1],amount = data.item[1][2],bind = data.item[1][3]}
        GSetItemData(getItem, itemInfo, true)
        local kuangIcon = obj:GetChild("n1")
        kuangIcon.url = UIPackage.GetItemURL("rechargedraw" , tostring(data.icon))
        local needNum = data.cost_item[2]
        local hasNum = cache.PackCache:getPackDataById(data.cost_item[1]).amount
        local numTxt = obj:GetChild("n5")
        local textData = {
            {text = hasNum,color = 14},
            {text = "/" .. needNum,color = 7},
        }
        local getBtn = obj:GetChild("n6")
        local flag = false--是否可兑换
        getBtn:GetChild("n3").visible = false
        if hasNum >= needNum then
            textData[1].color = 7
            flag = true
            getBtn:GetChild("n3").visible = true
        end
        numTxt.text = mgr.TextMgr:getTextByTable(textData)

        getBtn.data = {cfgId = data.id,flag = flag}
        getBtn.onClick:Add(self.onClickConvert,self)
    end
end

function ActWaKuangView:onClickConvert(context)
    local data = context.sender.data
    if data.flag then
        proxy.ActivityProxy:sendMsg(1030506,{reqType = 3,cfgId = data.cfgId})
    else
        GComAlter(language.active59)
    end
end

function ActWaKuangView:onClickGetAwards(context)
    local data = context.sender.data
    if data then
        if data.wkSum >= data.needCount then
            local vipLv = cache.PlayerCache:getVipLv()
            if data.flag then
                GComAlter(language.redbag20)
            elseif vipLv < data.vipLv then
                mgr.ViewMgr:openView2(ViewName.RewardView,data.item)
            else
                proxy.ActivityProxy:sendMsg(1030506,{reqType = 4,cfgId = data.cfgId})
            end
        else
            mgr.ViewMgr:openView2(ViewName.RewardView,data.item)
        end
    end
end

function ActWaKuangView:onClickGuize()
    local mulActConf = conf.ActivityConf:getMulActById(self.mulActiveId)
    if mulActConf and mulActConf.rule_id then
        GOpenRuleView(mulActConf.rule_id)
    else
        GOpenRuleView(1115)
    end
end

return ActWaKuangView