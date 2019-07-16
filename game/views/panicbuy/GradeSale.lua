--
-- Author: 
-- Date: 2017-07-27 20:03:18
--

local GradeSale = class("GradeSale", import("game.base.Ref"))

function GradeSale:ctor(mParent,panelObj)
    self.mParent = mParent
    self.panelObj = panelObj
    self:initPanel()
end

function GradeSale:initPanel()
    --text 当前等级
    self.grade = self.panelObj:GetChild("n3")
    --list Item
    self.listView = self.panelObj:GetChild("n1")
    self:initListView()
end
function GradeSale:onTimer( ... )
    -- body
end

function GradeSale:initListView()
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0
end

function GradeSale:celldata(index, obj)
    local data = self.tempData[index+1]
    local itemList = obj:GetChild("n12")
    itemList.numItems = 0
    for k,v in pairs(data.items) do
        local mId = v[1]
        local number = v[2]
        local bind = v[3]     --2017/6/27
        local info = {mid=mId,amount=number,bind = bind}
        local url = UIPackage.GetItemURL("_components" , "ComItemBtn")
        local obj1 = itemList:AddItemFromPool(url)
        GSetItemData(obj1,info,true)
    end

    local needGrade = obj:GetChild("n1")
    needGrade.text = string.format(language.welfare24, data.lev) --data.lev 需求等级

    local oldPrice = obj:GetChild("n8")
    oldPrice.text = data.old_price    -- 原价
    local newPrice = obj:GetChild("n9")
    newPrice.text = data.price[2]    -- 现价
    --花费货币类型
    local ingotType01 = obj:GetChild("n6")
    local ingotType02 = obj:GetChild("n7")
    if tonumber(data.price[1]) == 1 then
        ingotType01.url = ResPath.iconRes("gonggongsucai_103") --UIPackage.GetItemURL("_icons","gonggongsucai_103")
        ingotType02.url = ResPath.iconRes("gonggongsucai_103") --UIPackage.GetItemURL("_icons","gonggongsucai_103")
    elseif tonumber(data.price[1]) == 2 then
        ingotType01.url = ResPath.iconRes("gonggongsucai_108")--UIPackage.GetItemURL("_icons","gonggongsucai_108")
        ingotType02.url = ResPath.iconRes("gonggongsucai_108")-- UIPackage.GetItemURL("_icons","gonggongsucai_108")
    end

    --领取状态 0已购买 1购买 2不可购买
    local c1 =  obj:GetController("c1")
    local curLevel = cache.PlayerCache:getRoleLevel()
    
    if data.lev > curLevel then
        c1.selectedIndex = 2
    else
        c1.selectedIndex = 1
        for k,v in pairs(self.data.signs) do
            if v == data.id then
                c1.selectedIndex = 0
            end
        end
    end

    local btnGet = obj:GetChild("n5")
    local data = {status = c1.selectedIndex,id = data.id}  --,id = data.id
    btnGet.data = data --按钮的状态 
    if data.status == 2 then
        btnGet.touchable = false
    else
        btnGet.touchable = true
    end
    btnGet.onClick:Add(self.onClickBuy,self)
end
--按钮：购买
function GradeSale:onClickBuy(context)
    local cell = context.sender
    local data = cell.data    --C1 控制器状态 
    proxy.ActivityProxy:send(1030141,{cfgId = data.id}) --购买请求
end

function GradeSale:setData(data)
    self.data = data
    -- --领取弹窗
    -- if data.items and #data.items>0 then
    --     GOpenAlert3(data.items)
    -- end
    --配置表
    self.tempData = conf.ActivityConf:getGradeSaleData()
    local curLevel = cache.PlayerCache:getRoleLevel()
    for k,v in pairs(self.tempData) do
        if v.lev > curLevel then
            self.tempData[k].sign = 2 --不可领取
        else
            self.tempData[k].sign = 1 --可领取
            for _,value in pairs(self.data.signs) do
                if value == v.id then
                    self.tempData[k].sign = 3 --已领取
                end
            end
        end
    end
    table.sort(self.tempData,function(a,b)
        if a.sign ~= b.sign then
            return a.sign < b.sign
        elseif a.lev ~= b.lev then
            return a.lev < b.lev
        end
    end)
    self.listView.numItems = #self.tempData
end

function GradeSale:setVisible(visible)
    self.panelObj.visible = visible
    self.grade.text = cache.PlayerCache:getRoleLevel()
end

function GradeSale:sendMsg()
    -- 发送请求
    proxy.ActivityProxy:send(1030141,{cfgId = 0})
end

function GradeSale:clear()
  
end


return GradeSale