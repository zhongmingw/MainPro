--
-- Author: 
-- Date: 2019-01-07 17:36:02
--

local XiaoNianJiZhao = class("XiaoNianJiZhao", base.BaseView)

function XiaoNianJiZhao:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function XiaoNianJiZhao:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    local ruleBtn = self.view:GetChild("n2")  
    ruleBtn.onClick:Add(self.onClickRule,self)
    self.lastTime = self.view:GetChild("n4")

    for i=45,47 do
        local Btn = self.view:GetChild("n"..i) 
        Btn.data = i
        Btn.onClick:Add(self.onClickGet,self)
    end
    self.items = {}
    for i=13,15 do
        local Btn = self.view:GetChild("n"..i) 
        Btn.data = i
        table.insert(self.items, Btn)
    end
    self.cost1 = conf.XiaoNianConf:getValue("xn_jz_one_cost")[2]
    self.cost10 = conf.XiaoNianConf:getValue("xn_jz_ten_cost")[2]
    self.cost50 = conf.XiaoNianConf:getValue("xn_jz_fifty_cost")[2]

    self.view:GetChild("n42").text = self.cost1
    self.view:GetChild("n43").text = self.cost10
    self.view:GetChild("n44").text = self.cost50

    self.personList = self.view:GetChild("n38") --个人记录
    self.personList.itemRenderer = function(index,obj)
        self:cellPerData(index, obj)
    end
    self.personList.numItems = 0
    self.quanFuList = self.view:GetChild("n34") --全服记录
    self.quanFuList.itemRenderer = function(index,obj)
        self:cellquanFuData(index, obj)
    end
    self.quanFuList.numItems = 0
    self.showList = self.view:GetChild("n19") --展示
    self.showList.itemRenderer = function(index,obj)
        self:cellshowData(index, obj)
    end
    self.showConfData = conf.XiaoNianConf:getValue("xn_jz_show")
    self.showList.numItems = #self.showConfData
    self.confData1 = conf.XiaoNianConf:getXiaoNianJiZhao(2)
end

function XiaoNianJiZhao:setData(data)
    printt(data)
    self.data = data
    GOpenAlert3(data.items,true)
    self.personList.numItems = #self.data.myRecord or 0
    self:RefreshItem()

    self:releaseTimer()
    self.time = self.data.leftTime
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end

end

function XiaoNianJiZhao:RefreshItem()
    self.quanFuList.numItems = #self.data.allRecord or 0

    for k,v in pairs( self.items ) do
        local item = v:GetChild("n12")
        local tex = v:GetChild("n13")
        local data =  self.confData1[k]
        local itemInfo = {mid =data.items[1][1],amount =data.items[1][2],bind =data.items[1][3]}
        GSetItemData(item, itemInfo, true)
        if self.data.numMap[data.id] then
            local num  = data.num -  self.data.numMap[data.id]
            tex.text = self:colorText(num ,data.num)-- "[color=#0b8109]".. num.."[/color]" 
            if num<= 0 then
                item.grayed = true
                tex.text = self:colorText(0,data.num)
            else
                item.grayed = false
            end
        else
            tex.text =self:colorText(data.num,data.num)
        end
    end
end

function XiaoNianJiZhao:onTimer()
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

function XiaoNianJiZhao:cellPerData(index,obj)
     local data = self.data.myRecord[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.xiaonian2019_12, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)

end

function XiaoNianJiZhao:cellquanFuData(index,obj)
    local data = self.data.allRecord[index+1]
    local strTab = string.split(data,"|")
    local rolename = strTab[1]
    local mid = strTab[2] or 0
    local proName = conf.ItemConf:getName(mid)
    local color = conf.ItemConf:getQuality(mid)
    local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
    local recordItem = obj:GetChild("n0")
    recordItem.text = string.format(language.xiaonian2019_12, mgr.TextMgr:getTextColorStr(rolename,7),awardsStr)

end

function XiaoNianJiZhao:cellshowData(index,obj)
    local data = self.showConfData[index+1]
    local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
     GSetItemData(obj, itemInfo, true)
end


function XiaoNianJiZhao:releaseTimer()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
end

function XiaoNianJiZhao:onClickRule()
    GOpenRuleView(1172)
        
end

function XiaoNianJiZhao:onClickGet(context)
    local  data = context.sender.data

    local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    if data == 45 then
        if money >= self.cost1 then
            proxy.XiaoNianProxy:sendMsg(1030707,{reqType = 1})
        else
            GComAlter(language.gonggong18)
        end
    elseif  data == 46 then
        if money >= self.cost10 then
            proxy.XiaoNianProxy:sendMsg(1030707,{reqType = 2})
        else
            GComAlter(language.gonggong18)
        end
    else
        if money >= self.cost50 then
            proxy.XiaoNianProxy:sendMsg(1030707,{reqType = 3})
        else
            GComAlter(language.gonggong18)
        end
    end
        
end

function XiaoNianJiZhao:colorText(num1,num2)

    local str = ""
    if num1 >= num2 then
   
        str = "[color=#0b8109]"..num1.."/"..  num2.."[/color]"
    else
        str ="[color=#da1a27]"..num1.."[/color]".."[color=#0b8109]".."/".. num2.."[/color]"
    end
    return str
end

return XiaoNianJiZhao