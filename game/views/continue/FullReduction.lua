--
-- Author: 
-- Date: 2018-10-29 19:53:31
--

local FullReduction = class("FullReduction", base.BaseView)

function FullReduction:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level2
    self.openTween = ViewOpenTween.scale  
end

function FullReduction:initView()
    local window = self.view:GetChild("n0")
    local closeBtn = window:GetChild("n7")
    self:setCloseBtn(closeBtn)

    local ruleBtn = self.view:GetChild("n31")
    ruleBtn.onClick:Add(self.ruleBtnClick,self)
    
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    self.c1.selectedIndex = 0

    self.fullReductionList = self.view:GetChild("n21")
    self.fullReductionList.itemRenderer = function (index,obj)
        self:setfullReductionData(index,obj)
    end
    self.fullReductionList.numItems = 0
    self.fullReductionList:SetVirtual()

    self.freeList = self.view:GetChild("n28")
    self.freeList.itemRenderer = function (index,obj)
        self:setfreeData(index,obj)
    end
    self.freeList.numItems = 0
    self.freeList:SetVirtual()

    self.decText = self.view:GetChild("n29")
    local dec1Text = self.view:GetChild("n32") 
    dec1Text.text = language.doubleball09
    self.dec2Text = self.view:GetChild("n33")
    
    self.actCountDownText = self.view:GetChild("n37")

end
--[[
变量名：reqType 说明：0：显示 1：购买满减 2：购买免单
变量名：cid 说明：配置id
变量名：leftTime    说明：活动剩余时间
变量名：gotNum  说明：道具已经购买的数量   
变量名：items   说明：购买的物品
变量名：costSum 说明：消费总数
变量名：freeMax 说明：当前最大免单额度
变量名：curDay  说明：当前第几天
--]]
function FullReduction:initData(data)
    GOpenAlert3(data.items)

    self.data = data
    self.actCountDown = data.leftTime
	
	local confdata = conf.ActivityConf:getValue("mjzc_cost")
    local more 
    for k ,v in pairs(confdata) do
        local flag = true
        for i , j in pairs(self.data.costNums) do
            if j == v[1] then
                flag = false --使用过当前减免
                break
            end
        end
        if flag then
            more = v 
            break
        end
    end
    if more  then
        local dec1Table = {
            {text = language.manjian01,color = 6},
            {text = tostring(data.costSum),color = 7},
            {text = language.manjian02,color = 6},
            {text = language.manjian03,color = 6},
            {text = tostring(more[1] - data.costSum),color = 7},
            {text = language.manjian04,color = 6},
            {text = tostring(more[2]),color = 7},
            {text = language.manjian10,color = 6},
        }
        self.decText.text = mgr.TextMgr:getTextByTable(dec1Table)
    else
        self.decText.text = language.manjian05
    end


    

    self.dec2Text.text = string.format(language.doubleball08,#self.data.frees) 

    self.maxfrees = 0
    self.minfrees = nil 
    --printt("self.data.frees",self.data.frees)
    table.sort(self.data.frees,function( a,b)
        -- body
        return a<b
    end)

    for k ,v in pairs(self.data.frees) do
        self.maxfrees = math.max(self.maxfrees,v)
        if not self.minfrees then
            self.minfrees = v 
        else
            self.minfrees = math.min(self.minfrees,v)
        end
    end

    self:onController()

    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
    end
    if not self.actTimer then
        self:onTimer()
        self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
    end
end

function FullReduction:onController()
    -- body
    if not self.data then
        return
    end
    if self.c1.selectedIndex == 0 then
        self.confData1 = conf.ActivityConf:getFullReduction(1,self.data.curDay)
        table.sort(self.confData1,function( a,b )
            -- body
            return a.id <b.id
        end)
        self.fullReductionList.numItems = #self.confData1


    else
        --print("self.data.curDay",self.data.curDay)
        self.confData2 = conf.ActivityConf:getFullReduction(2,self.data.curDay)
         table.sort(self.confData2,function( a,b )
            -- body
            return a.id <b.id
        end)
        self.freeList.numItems = #self.confData2
    end
end

function FullReduction:setfullReductionData(index,obj)
    local awardData = self.confData1[index + 1]
    local itemData = {}
    local itemObj = obj:GetChild("n1")
    local originalPrice = obj:GetChild("n5")
    local nowPrice = obj:GetChild("n8")
    local quota = obj:GetChild("n10")
    local itemName = obj:GetChild("n2")
    local dis = obj:GetChild("n13") -- 折扣 TODO
    local buyBtn = obj:GetChild("n9") 
    --
    local t = {}
    t.mid = awardData.items[1][1]
    t.amount = awardData.items[1][2]
    t.bind = awardData.items[1][3]
    GSetItemData(itemObj, t, true)

    itemName.text = mgr.TextMgr:getColorNameByMid(t.mid)

    originalPrice.text = awardData.cost
    nowPrice.text = awardData.discount
    dis.text = awardData.zekou 

    local str = language.manjian06
    local number = self.data.gotNum[awardData.id] or 0
    if number >= awardData.limit_num then
        str = str .. mgr.TextMgr:getTextColorStr(number, 14)
        buyBtn.grayed = true
        buyBtn.touchable = false
    else
        str = str .. mgr.TextMgr:getTextColorStr(number, 7)
        buyBtn.grayed = false
        buyBtn.touchable = true
    end
    quota.text = str..mgr.TextMgr:getTextColorStr("/"..awardData.limit_num, 6)


    buyBtn.data = awardData
    buyBtn.onClick:Add(self.btnOnClick,self)
end

function FullReduction:setfreeData(index,obj)
    local awardData = self.confData2[index + 1]
    local itemData = {}
    local itemObj = obj:GetChild("n1")
    local buyPrice = obj:GetChild("n5") -- 购买价格
    local freePrice = obj:GetChild("n8") -- 免单价格
    local itemName = obj:GetChild("n2")
    local img = obj:GetChild("n14") 
    local buyBtn = obj:GetChild("n9") 

    local t = {}
    t.mid = awardData.items[1][1]
    t.amount = awardData.items[1][2]
    t.bind = awardData.items[1][3]
    GSetItemData(itemObj, t, true)

    itemName.text = mgr.TextMgr:getColorNameByMid(t.mid)
    buyPrice.text = awardData.discount
    freePrice.text = awardData.free

    img.visible = awardData.free <= self.maxfrees

    buyBtn.data = awardData
    buyBtn.onClick:Add(self.freeBtnOnClick,self)
	
	buyBtn.grayed = self.data.gotNum[awardData.id] and true or false
    if buyBtn.grayed then
        buyBtn.touchable = false
        img.visible = false
    else
        buyBtn.touchable = true
    end
end

function FullReduction:btnOnClick(context)
    local btn = context.sender
    local data = btn.data
    local param = {}
    param.reqType = 1
    param.cid = data.id
    local number = self.data.gotNum[data.id] or 0
    if number >= data.limit_num then
        return GComAlter(language.manjian07)
    end
    --检测是否激活了满减
    local str = ""
    local money = 0 --累计可以减
    local confdata = conf.ActivityConf:getValue("mjzc_cost")

    --printt("self.data.costNums",self.data.costNums)

    for k ,v in pairs(confdata) do
        local flag = v[1] <= data.discount + self.data.costSum
        if flag then
            for i , j in pairs(self.data.costNums) do

                if j == v[1] then
                    flag = false --使用过当前减免
                   
                    break
                end
            end
        end
        if  flag then
            if str ~= "" then
                str = str .. ","
            end
            str = str .. language.manjian08 .. mgr.TextMgr:getTextColorStr(v[1], 7) .. language.manjian09 .. mgr.TextMgr:getTextColorStr(v[2], 7)..language.manjian10

            money = money + v[2] 
        end
    end
    
    --print("money",money)

    if money > 0 then
        local kongge = "       "

        local var = language.manjian11 .. str ..language.manjian12
        var = var .."\n" .. language.manjian13 .. mgr.TextMgr:getTextColorStr(math.max(data.discount - money ,0), 7)..language.manjian14
        var = var .."\n" .. mgr.TextMgr:getColorNameByMid(data.items[1][1])..language.manjian15..mgr.TextMgr:getTextColorStr(tostring(money), 7)
        var = var .. language.manjian16
        var = var .."\n" .. kongge..kongge..mgr.TextMgr:getTextColorStr(language.manjian17, 14) 

        local info = {}
        info.sure = function( ... )
            -- body
            proxy.ActivityProxy:sendMsg(1030647,param)
        end
        info.richtext =  var

        mgr.ViewMgr:openView2(ViewName.Fullreductips, info)
    else
        proxy.ActivityProxy:sendMsg(1030647,param)
    end
end

function FullReduction:freeBtnOnClick(context)
    local btn = context.sender
    local data = btn.data
    if btn.grayed then
        return --GComAlter("购买达到上限了")
    end

    if  self.maxfrees>=data.free then
        --免单激活
        -- local var = 0
        -- for k ,v in pairs(self.data.frees) do
        --     if data.free <= v then
        --         var = v 
        --         break
        --     end
        -- end
        local varcc = 0
        for k ,v in pairs(self.data.frees) do
            if data.free == v then
                varcc = v 
                break
            end
        end

        if varcc ~= 0 then
            local str = language.manjian18
            local str1 = language.manjian19
            str = string.format(str,mgr.TextMgr:getTextColorStr(tostring(varcc), 7), mgr.TextMgr:getColorNameByMid(data.items[1][1]))
            local param = {}
            param.richtext = str.."\n"..str1
            param.sure = function( ... )
                -- body
                 proxy.ActivityProxy:sendMsg(1030647,{reqType = 2,cid = data.id})
            end
            mgr.ViewMgr:openView2(ViewName.Fullreductips, param)
        else 
            local var = 0
            for k ,v in pairs(self.data.frees) do
                if data.free == v then
                    var = v 
                    break
                end
            end
            if var == 0 then var = self.minfrees end
            local str = language.manjian20
            local str1 = language.manjian21
            local str2 = language.manjian22
            print("data.free",data.free)
            str = string.format(str,mgr.TextMgr:getTextColorStr(tostring(data.free), 7))

			str1 = string.format(str1,mgr.TextMgr:getTextColorStr(tostring(var), 7))
            
            str2 = string.format(str2,mgr.TextMgr:getTextColorStr(tostring(var), 7))
            local param = {}
            param.richtext = str.."\n"..str1.."\n"..str2
            param.sure = function()
                -- body
                GOpenView({id = 1042})
            end
            param.sureicon = "ui://continue/manjianzhuanchang_007"
            param.cancel = function()
                -- body
                proxy.ActivityProxy:sendMsg(1030647,{reqType = 2,cid = data.id})
            end
            param.cancelicon = "ui://continue/manjianzhuanchang_008"
            mgr.ViewMgr:openView2(ViewName.Fullreductips, param)         
        end
    else
        local str = language.manjian23
        local name = mgr.TextMgr:getColorNameByMid(data.items[1][1])
        local money = mgr.TextMgr:getTextColorStr(tostring(data.discount), 7) 

        local condata = conf.ActivityConf:getValue("mjzc_free")
        local min = 0
        for k ,v in pairs(condata) do
            if data.free <= v then
                min = v 
                break
            end
        end

        
        local param = {}
        param.sure = function()
            -- body
            GOpenView({id = 1042})
        end
        param.sureicon = "ui://continue/manjianzhuanchang_007"
        param.richtext = string.format(str,name,money,mgr.TextMgr:getTextColorStr(min,7),money)
        param.cancel = function()
            -- body
            proxy.ActivityProxy:sendMsg(1030647,{reqType = 2,cid = data.id})
        end
        param.cancelicon = "ui://continue/manjianzhuanchang_009"
        mgr.ViewMgr:openView2(ViewName.Fullreductips, param)
    end
end

function FullReduction:ruleBtnClick()
    GOpenRuleView(1153)
end

function FullReduction:onTimer()
    if not self.data then return end
    self.actCountDown = math.max(self.actCountDown-1,0)
    if self.actCountDown <= 0 then
        self:removeTimer(self.actTimer)
        self.actTimer = nil
        self:closeView()
        return
    end
    if self.actCountDown >= 86400 then
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData3(self.actCountDown),7)        
    else
        self.actCountDownText.text = mgr.TextMgr:getTextColorStr(GGetTimeData4(self.actCountDown),7)  
    end
end

return FullReduction