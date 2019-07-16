--
-- Author: Your Name
-- Date: 2017-11-08 21:11:12
--

local DayFirstChargeOther = class("DayFirstChargeOther", base.BaseView)
local DANGCI = 9
local BtnIconUpTab = {
    [1] = "meirishouchong_111",
    [2] = "meirishouchong_112",
    [3] = "meirishouchong_113",
    [4] = "meirishouchong_114",
    [5] = "meirishouchong_139",
    [6] = "meirishouchong_130",
    [7] = "meirishouchong_142",
    [8] = "meirishouchong_191",
    [9] = "meirishouchong_193",
    [10] = "meirishouchong_148",
}

local BtnIconDownTab = {
    [1] = "meirishouchong_131",
    [2] = "meirishouchong_132",
    [3] = "meirishouchong_133",
    [4] = "meirishouchong_134",
    [5] = "meirishouchong_140",
    [6] = "meirishouchong_138",
    [7] = "meirishouchong_141",
    [8] = "meirishouchong_192",
    [9] = "meirishouchong_194",
    [10] = "meirishouchong_147",
}

function DayFirstChargeOther:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function DayFirstChargeOther:initView()
    local closeBtn = self.view:GetChild("n1"):GetChild("n7")
    closeBtn.onClick:Add(self.onClickClose,self)
    self.controllerC = self.view:GetController("c1")
    self.controllerC.onChanged:Add(self.onController,self)

    self.chargeBtn = self.view:GetChild("n2")
    self.chargeBtn.onClick:Add(self.onClickCharge,self)

    --每日累充奖励列表
    self.listView = self.view:GetChild("n5")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    --按钮列表
    self.btnList = self.view:GetChild("n14")
    self.btnList.numItems = 0
    self.btnList.itemRenderer = function (index,obj)
        self:btnCelldata(index, obj)
    end
    self.btnList:SetVirtual()
    self.btnList.onClickItem:Add(self.onClickBtnItem,self)
    self.btnList.numItems = DANGCI
    --累积天数奖励
    self.totalList = self.view:GetChild("n6")
    self.totalList.numItems = 0
    self.totalList.itemRenderer = function (index,obj)
        self:totalCell(index, obj)
    end
    self.totalList:SetVirtual()

    self.icon = self.view:GetChild("n3")
end

function DayFirstChargeOther:onController()
    if not self.data or #self.confData == 0 then
        return
    end
    --档次信息
    -- self.btnList:AddSelection(self.controllerC.selectedIndex,true)
    -- print("档次信息",#self.confData,self.controllerC.selectedIndex)
    self.nowConfData = self.confData[self.controllerC.selectedIndex+1]
    if self.nowConfData.title then
        self.icon.url = UIPackage.GetItemURL("activity" , self.nowConfData.title)
    else
        self.icon.url = nil 
    end

    self:setData()
end

function DayFirstChargeOther:initData(data)
    self.index = data.index or 0
    proxy.ActivityProxy:sendMsg(1030121,{reqType = 0})
end

function DayFirstChargeOther:celldata( index,obj )
    local data = self.awardsData[index+1]
    local mId = data[1]
    local amount = data[2]
    local bind = data[3]
    local info = {mid = mId,amount = amount,bind = bind}
    GSetItemData(obj,info,true)
end

function DayFirstChargeOther:btnCelldata( index,obj )
    local upIcon = obj:GetChild("n1")
    local downIcon = obj:GetChild("n2")
    upIcon.url = UIPackage.GetItemURL("activity" , BtnIconUpTab[index+1])
    downIcon.url = UIPackage.GetItemURL("activity" , BtnIconDownTab[index+1])
    obj.data = index
end

function DayFirstChargeOther:onClickBtnItem(context)
    local cell = context.data
    local index = cell.data
    self.controllerC.selectedIndex = index
end

function DayFirstChargeOther:totalCell( index,obj )
    -- body
    local lctimsData = self.lctimsAwards[index + 1]
    if lctimsData then
        local awardsData = lctimsData.awards
        local list = obj:GetChild("n2")
        list.numItems = 0
        
        for num = 1,#awardsData do
            local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
            local item = list:AddItemFromPool(url)
            local awards = awardsData[num]
            local mId = awards[1]
            local amount = awards[2]
            local bind = awards[3]
            local info = {mid = mId,amount = amount,bind = bind}
            GSetItemData(item,info,true)
        end
        --累积奖励领取情况
        local lcDays = self.data.lcDays
        local gotLcList = self.data.gotLcList
        local getBtn = obj:GetChild("n3")
        local c1 = obj:GetController("c1")
        if lcDays >= lctimsData.days then
            if gotLcList[index+1] then
                c1.selectedIndex = 2
            else
                c1.selectedIndex = 1
            end
        else
            c1.selectedIndex = 0
        end
        getBtn.data = {status = lctimsData.id,canGet = lcDays >= lctimsData.days}
        getBtn.onClick:Add(self.onClickGetLctims,self)
        --累计%d天累充%d元宝(%d/%d)
        local decText = obj:GetChild("n0")
        local needCharge = conf.ActivityConf:getValue("lc_quota_dc")
        decText.text = string.format(language.active36,lctimsData.days,needCharge,lcDays,lctimsData.days)--,needCharge,
    end
end

function DayFirstChargeOther:setData()
    --充值领取按钮设置
    local status = self.data.ItemStatus[self.nowConfData.id]
    if status == 0 then
        self.chargeBtn.touchable = true
        self.chargeBtn.grayed = false
        self.chargeBtn:GetChild("red").visible = false
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "chongdianxiaoqian")
    elseif status == 1 then
        self.chargeBtn.touchable = true
        self.chargeBtn.grayed = false
        self.chargeBtn:GetChild("red").visible = true
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_034")
    elseif status == 2 then
        self.chargeBtn.grayed = true
        self.chargeBtn.touchable = false
        self.chargeBtn:GetChild("red").visible = false
        self.chargeBtn:GetChild("icon").url = UIPackage.GetItemURL("activity" , "sanshitiandenglu_035")
    end
    self.chargeBtn.data = status

    --设置奖励列表
    local len = 0
    self.awardsData = {}
    if self.nowConfData then
        self.awardsData = self.nowConfData.awards
        len = #self.awardsData
    end
    self.listView.numItems = len
    
    local hasCharge = self.view:GetChild("n13")
    local YbNum = self.data.YbNum or 0
    local textData = {
                    {text = language.gonggong88,color = globalConst.DayFirstChargeOther02},
                    {text = YbNum,color = globalConst.DayFirstChargeOther01},
            }
    hasCharge.text = mgr.TextMgr:getTextByTable(textData)
end

function DayFirstChargeOther:add5030121(data)
    self.data = data
    -- printt("返回数据",data)
    if self.data.reqType == 0 then
        self.confData = {}
        --获取当前天的奖励配置
        local confData = conf.ActivityConf:getDaliyChargeData()

        for k,v in pairs(confData) do
            if data.day >= v.day[1] and data.day <= v.day[2] then
                table.insert(self.confData,v)
            end
        end
        
        table.sort(self.confData,function(a,b)
            return a.id < b.id
        end)
        -- --按档次显示
        -- self:onController()
    else
        --刷新
        GOpenAlert3(data.Items)
    end
    --累积奖励
    self.lctimsAwards = conf.ActivityConf:getDaliyAwardsData(self.data.cycle)
    self.totalList.numItems = #self.lctimsAwards
end

--领取成功后跳转到下一个页签
function DayFirstChargeOther:skipToNextPage(data)
    print("当前页签",self.index,self.controllerC.selectedIndex)
    if self.index ~= 0 then
        if self.index == self.controllerC.selectedIndex then
            self.index = 0
            self:onController()
        else
            self.controllerC.selectedIndex = self.index
        end
        return
    end

    local conf = conf.ActivityConf:getDaliyChargeData()
    local confData = {}
    local oldIndex = self.controllerC.selectedIndex
    for k,v in pairs(conf) do
        if data.day >= v.day[1] and data.day <= v.day[2] then
            table.insert(confData,v)
        end
    end
    table.sort(confData,function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
    end)
    for k,v in pairs(confData) do
        local flag = false
        if data.ItemStatus[v.id] == 2 then
            flag = true
        end
        if not flag then
            self.controllerC.selectedIndex = k - 1
            break
        else
            if k ~= DANGCI then
                self.controllerC.selectedIndex = k
            else
                self.controllerC.selectedIndex = k - 1
            end
        end
    end

    if oldIndex == self.controllerC.selectedIndex then
        self:onController()
    end
end

function DayFirstChargeOther:onClickCharge( context )
    -- body
    local cell = context.sender
    local status = cell.data
    if status == 0 then
        GOpenView({id = 1042})
    elseif status == 1 then
        proxy.ActivityProxy:sendMsg(1030121,{reqType = 1,awardId = self.nowConfData.id})
    end
end

function DayFirstChargeOther:onClickGetLctims( context )
    local cell = context.sender
    local data = cell.data
    local status = data.status
    local canGet = data.canGet
    if canGet then
        proxy.ActivityProxy:sendMsg(1030121,{reqType = 2,awardId = status})
    else
        GComAlter("累充天数不够")
    end

end

function DayFirstChargeOther:onClickClose()
    self:closeView()
end

return DayFirstChargeOther