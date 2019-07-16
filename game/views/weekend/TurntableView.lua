--
-- Author: 
-- Date: 2018-01-15 17:21:26
--
--幸运转盘
local TurntableView = class("TurntableView", base.BaseView)

local angleTimes = {0.5,0.75,1,1.25,1.5,1.75,2,2.25,2.5}

function TurntableView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function TurntableView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)

    self.titleIcon = self.view:GetChild("n0"):GetChild("n5")
    self.timeText = self.view:GetChild("n11")
    self.listView = self.view:GetChild("n15")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.awardsList = {}
    for i=1,8 do
        table.insert(self.awardsList, self.view:GetChild("n"..i))
    end
    local ruleBtn = self.view:GetChild("n20")
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.oneBtn = self.view:GetChild("n17")--抽奖1次
    self.oneBtn:GetChild("n1").url = UIItemRes.week01[1]
    self.oneBtn.onClick:Add(self.onClickOne,self)
    self.tenBtn = self.view:GetChild("n32")--抽奖10次
    self.tenBtn:GetChild("n1").url = UIItemRes.week01[2]
    self.tenBtn.onClick:Add(self.onClickTen,self)

    self.poolMoney = self.view:GetChild("n31"):GetChild("n6")--奖池元宝

    self.t0 = self.view:GetTransition("t0")--旋转动作
    self.tList = {}
    for i=1,8 do
        table.insert(self.tList, self.view:GetTransition("t"..i))
    end
    self.arrow = self.view:GetChild("n10")--旋转箭头
end

function TurntableView:initData(data)
    self.moduleId = data.id
    self.isAct = false
    self:releaseTimer()
    local xyzpCost = conf.ActivityConf:getValue("xyzp_cost")
    self.oneBtn.title = xyzpCost[2]
    self.oneBtn.icon = UIItemRes.moneyIcons[xyzpCost[1]]
    local zhekou = conf.ActivityConf:getValue("xyzp_ten_zk")
    self.tenBtn.title = xyzpCost[2] * (zhekou/100)*10
    self.tenBtn.icon = UIItemRes.moneyIcons[xyzpCost[1]]
    
    self:sendMsg(0)
end


function TurntableView:sendMsg(reqType)
    if self.isAct then return end
    if self.moduleId == 1190 then
        -- print("转盘1>>>>>>>>>>>>>>>>>")
        proxy.ActivityProxy:send(1030310,{reqType = reqType})
    elseif self.moduleId == 1233 then
        -- print("转盘2>>>>>>>>>>>>>>>>>")
        proxy.ActivityProxy:send(1030402,{reqType = reqType})
    end
end
--服务器返回
function TurntableView:setData(data)
    self.mData = data
    printt("幸运转盘=>",data)
    if data.reqType == 0 then
        self.time = data.actLeftTime
        if not self.actTimer then
            self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
        end
        self:setInfoData()
        self:setAwards()
    else
        self:actionEffect()
    end
end

function TurntableView:setAwards()
    if not self.mData then return end
    --多开
    self.mulConfData = conf.ActivityConf:getMulActById(self.mData.mulActId)
    for i=1,#self.awardsList do
        local obj = self.awardsList[i]
        local confData
        if self.moduleId == 1233 then
            confData = conf.ActivityConf:getXyzp00(i,self.moduleId)
            self.titleIcon.url = UIPackage.GetItemURL("weekend" , "zhoumokuanghuan_004")
        elseif self.moduleId == 1190 then
            if self.mulConfData then
                local titleIconStr = self.mulConfData.title_icon or "zhoumokuanghuan_004"
                self.titleIcon.url = UIPackage.GetItemURL("weekend" , titleIconStr)
                local award_pre = self.mulConfData.award_pre
                local mulId = award_pre*1000+i
                confData = conf.ActivityConf:getXyzp00(mulId,self.moduleId)
            end
        end
        if confData then
            local type = confData.type or 0 
            local c1 = obj:GetController("c1")--主控制器
            if type == 1 then--奖池50%
                c1.selectedIndex = 1
                obj:GetChild("n1").text = language.weekend05
            else
                c1.selectedIndex = 0
                local item = {}
                local colorStarNum = 0
                local isquan = false
                if type == 2 then--装备
                    if not self.mData.equipInfo then 
                        item = confData.equips and confData.equips[1] or {}
                    else
                        item = {
                            self.mData.equipInfo.mid,
                            self.mData.equipInfo.amount,
                            self.mData.equipInfo.bind
                        }
                        local condata = conf.ItemConf:getItem(self.mData.equipInfo.mid)
                        colorStarNum = self.mData.equipInfo and self.mData.equipInfo.colorStarNum
                        if condata.real_mid and condata.real_mid > 0 and colorStarNum <= 0 then
                            colorStarNum = condata.star_count or 0 
                        end                        
                        --print("装备星级数",self.mData.equipInfo.colorStarNum)
                    end
                elseif type == 3 then--道具
                    isquan = true
                    item = confData.items and confData.items[1] or {}
                end
                local itemData = {mid = item[1],amount = item[2], bind = item[3],isquan = isquan,eStar = colorStarNum}
                GSetItemData(obj:GetChild("n0"), itemData, true)
            end
        else
            obj.visible = false
        end
    end
end

--执行旋转
function TurntableView:actionEffect()
    self.arrow.rotation = 0
    self.t0:Play()
    self.isAct = true
    if self.moduleId == 1190 then
        self:addTimer(2.25, 1, function()
        local awardIndex = self.mData.awardIndex
        local str = tostring(awardIndex)
        local num = string.sub(str,7,7)
        self.tList[tonumber(num)]:Play()
        self:addTimer(angleTimes[tonumber(num)], 1, function()
                self.isAct = false
                GOpenAlert3(self.mData.items)--弹窗奖励
                self:setInfoData()
                self:setAwards()
                cache.ActivityCache:setTurnTable(false)
            end)
        end)
    end
    if self.moduleId == 1233 then
        self:addTimer(2.25, 1, function()
        local awardIndex = self.mData.awardIndex
        self.tList[tonumber(awardIndex)]:Play()
        self:addTimer(angleTimes[tonumber(awardIndex)], 1, function()
                self.isAct = false
                GOpenAlert3(self.mData.items)--弹窗奖励
                self:setInfoData()
                self:setAwards()
                cache.ActivityCache:setTurnTable(false)
            end)
        end)
    end
    -- self:addTimer(2.25, 1, function()
    --     local awardIndex = self.mData.awardIndex
    --     local str = tostring(awardIndex)
    --     local num = string.sub(str,7,7)
    --     self.tList[tonumber(num)]:Play()
    --     self:addTimer(angleTimes[tonumber(num)], 1, function()
    --         self.isAct = false
    --         GOpenAlert3(self.mData.items)--弹窗奖励
    --         self:setInfoData()
    --         self:setAwards()
    --         cache.ActivityCache:setTurnTable(false)
    --     end)
    -- end)
end

function TurntableView:setInfoData()
    self.poolMoney.text = self.mData.poolMoney
    self.listView.numItems = #self.mData.logs
    -- print("记录>>>>>>>>>>>>>>>>>>>>",#self.mData.logs)
    -- printt(self.mData.logs)
end

function TurntableView:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function TurntableView:onTimer()
    self.timeText.text = GTotimeString(self.time)
    if self.time <= 0 then
        self:releaseTimer()
        self:closeView()
        return
    end
    self.time = self.time - 1
end

function TurntableView:cellData(index,obj)
    local msgText = obj:GetChild("n0")
    local str = self.mData.logs[index + 1]
    local strTab = string.split(str,"|")
    local type = tonumber(strTab[1])
    local roleName = strTab[2] or ""
    local mid = strTab[3] or 0
   
    local awardsStr = ""
    if type == 1 then--奖池
        local amount = mid--奖池的数量
        awardsStr = mgr.TextMgr:getTextColorStr(language.weekend05..amount..language.gonggong115[2], 3) 
    elseif type == 2 then 
        local colorStr = strTab[4] or "0,0"
        local hert = ChatHerts.SYSTEMPRO..mid..ChatHerts.SYSTEMPRO..colorStr..ChatHerts.SYSTEMPRO
        local name = conf.ItemConf:getName(mid)
        local color = conf.ItemConf:getQuality(mid)
        awardsStr = mgr.TextMgr:getQualityStr1(name, color, hert)
    else 
        local amount = strTab[4] or "x1"
        local hert = ChatHerts.SYSTEMPRO..mid..ChatHerts.SYSTEMPRO
        local name = conf.ItemConf:getName(mid)
        local color = conf.ItemConf:getQuality(mid)
        awardsStr = mgr.TextMgr:getQualityStr1(name, color, hert)
        awardsStr = awardsStr .. amount;
    end
    msgText.text = string.format(language.weekend06, mgr.TextMgr:getTextColorStr(roleName,7), awardsStr)
    msgText.onClickLink:Add(self.onClickLinkText,self)
end
--转盘记录
function TurntableView:onClickLinkText(context)
    local str = string.sub(context.data, 1,1)
    if str == ChatHerts.SYSTEMPRO then
        mgr.ChatMgr:onLinkRecordPros(context.data)
    end
end

function TurntableView:onClickRule()
    GOpenRuleView(1079)
end

function TurntableView:onClickOne()
    self:sendMsg(1)
    cache.ActivityCache:setTurnTable(true) --设置一个抽奖的flag
end

function TurntableView:onClickTen()
    self:sendMsg(2)
    cache.ActivityCache:setTurnTable(true) --设置一个抽奖的flag
end

return TurntableView