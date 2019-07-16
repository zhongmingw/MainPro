--
-- Author: bxp
-- Date: 2018-12-10 14:20:17
--许愿圣诞树

local XuYuanShengDanShu = class("XuYuanShengDanShu", base.BaseView)

function XuYuanShengDanShu:ctor()
    XuYuanShengDanShu.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function XuYuanShengDanShu:initView()
    local btn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btn)

    -- local ruleBtn = self.view:GetChild("n42")
    -- ruleBtn.onClick:Add(self.onBtnCallBack,self)

    local oneCost = conf.ShengDanConf:getValue("wish_tree_one_cost")
    local tenCost = conf.ShengDanConf:getValue("wish_tree_ten_cost")

    local btn1 = self.view:GetChild("n20")
    btn1.title = oneCost[2]
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n21")
    btn2.title = tenCost[2]
    btn2.onClick:Add(self.onBtnCallBack,self)

    self.lastTime = self.view:GetChild("n6")
    self.lastTime.text = ""


    self.logsList = self.view:GetChild("n8")
    self.logsList.numItems = 0
    self.logsList.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
    self.logsList:SetVirtual()

    self.itemlist = {}
    for i = 1 , 10 do
        local btn = self.view:GetChild("n"..(i+8))
        btn.data = i
        -- GSetItemData(btn,{})
        table.insert(self.itemlist,btn)
    end
end

function XuYuanShengDanShu:initData()
    --配置设置奖励展示
    local confData = conf.ShengDanConf:getValue("wish_tree_award_show")
    for k,v in pairs(self.itemlist) do
        local item = confData[v.data]
        local t = {}
        if item then
            t.mid = item[1]
            t.amount = item[2]
            t.bind = item[3]
            GSetItemData(v,t,true)
        end
    end
end

function XuYuanShengDanShu:addMsgCallBack(data)
    self.data = data
    self.time = data.leftTime

    self:releaseTimer()
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

    self.logsList.numItems = #data.logs

end


function XuYuanShengDanShu:cellData(index,obj)
    local data = self.data.logs[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.houWang04, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)
end

function XuYuanShengDanShu:onBtnCallBack(context)
    if not self.data then return end
    local btn = context.sender
    local reqType = 0
    if "n20" == btn.name then
        reqType = 1
    elseif "n21" == btn.name then
        reqType = 2
    end 
    proxy.ShengDanProxy:sendMsg(1030669,{reqType = reqType})
end

function XuYuanShengDanShu:onTimer()
    self.lastTime.text = GGetTimeData2(self.time)
    if self.time <= 0 then
        self:releaseTimer()
    end
    self.time = self.time - 1
end

function XuYuanShengDanShu:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

return XuYuanShengDanShu