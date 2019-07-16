--
-- Author: 
-- Date: 2017-03-20 17:18:03
--

local TradeMainView = class("TradeMainView", base.BaseView)

function TradeMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true  
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function TradeMainView:initData()
    --金钱管理
    self.suo = false
    self.leftdata = {}
    self.rightdata = {}
    self.maxTrade = conf.SysConf:getValue("trade_onec_nums")
    for i = 1 , self.maxTrade do
        local t = {mid = 0,amount = 0,index = 0 }
        table.insert(self.leftdata,clone(t))
        table.insert(self.rightdata,clone(t))
    end
    GSetMoneyPanel(self.view,self:viewName())

    
    self.money1.text = ""
    self.money2.text = ""
    self.money3.text = ""
    self.money4.text = ""
    self.money4.editable = true
    --self.money4.focusable = true
    -- plog("focused",self.money4.focused)
    -- plog("enabled",self.money4.enabled) 
    -- plog("size",self.money4.size) 
    -- plog("editable",self.money4.editable)

    self.leftName.text = ""
    self.rightName.text = ""
    self.leftList.numItems = #self.leftdata
    self.rightList.numItems = #self.rightdata

    self.c2.selectedIndex = 2
    self:onController1()--设置背包信息
end

function TradeMainView:initView()

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    --锁定
    self.c2 = self.view:GetController("c2")
    
    --交易玩家和武平
    self.leftName = self.view:GetChild("n27")
    self.rightName = self.view:GetChild("n28")

    self.leftList = self.view:GetChild("n6")
    self.leftList.itemRenderer = function(index,obj)
        self:leftcelldata(index, obj)
    end
    self.leftList:SetVirtual()
    
    --钱
    self.money1 = self.view:GetChild("n39")
    self.money2 = self.view:GetChild("n41")
    self.money3 = self.view:GetChild("n40")
    --self.money3.onFocusOut:Add(self.onTongqian,self)
    self.money4 = self.view:GetChild("n42")
    self.money4.onFocusOut:Add(self.onYuanbao,self)
    --self.size4 = self.money4.

    self.rightList = self.view:GetChild("n7")
    self.rightList.itemRenderer = function(index,obj)
        self:rightcelldata(index, obj)
    end
    self.rightList:SetVirtual()

    
    --锁定
    self.btnSuoding = self.view:GetChild("n37")
    self.btnSuoding.onClick:Add(self.onSuoDing,self)

    local btnCancel =  self.view:GetChild("n38")
    btnCancel.onClick:Add(self.onCancel,self)

    local btnCancel =  self.view:GetChild("n2"):GetChild("n2")
    btnCancel.onClick:Add(self.onBtnClose,self)

    self.listView = self.view:GetChild("n49")
    self.listView.itemRenderer = function(index,obj)
        self:cellItemData(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = 0

    self:initDec()

    
end

function TradeMainView:initDec()
    -- body
    
    -- self.money1.text = ""
    -- self.money2.text = ""
    -- self.money3.text = ""
    -- self.money4.text = ""
end

function TradeMainView:cellItemData(index,obj)
    -- body
    --刷新格子信息
    local _16data = {} --16个格子数据
    local start = (index)*16+1
    for i = start , start + 16 do
        if not self.packinfo[i] then
            break
        end
        table.insert(_16data,self.packinfo[i])
    end
    local number = #_16data

    local listView = obj:GetChild("n0")
    listView.itemRenderer = function(_index,_obj)
        local c1 = _obj:GetController("c1")
        local _data = _16data[_index+1]
        _obj.data = _data
        if _index + 1 <= number and _data and _data.amount>0 then
            c1.selectedIndex = 1 --有道具
            --local t = {mid = _data.mid,amount=_data.amount,color}
            local _t = clone(_data)
            _t.isdone = cache.PlayerCache:getIsNeed(_data.mid)

            GSetItemData(_obj:GetChild("n0"),_t)
        else
            c1.selectedIndex = 0
        end
    end
    listView.numItems = 16
    listView.onClickItem:Add(self.onCallBackPack,self)
end

function TradeMainView:onCallBackPack(context)
    -- body
    local cell = context.data
    local data = cell.data
    --plog("data",data.mid)
    if self.suo then
        GComAlter(language.trade01)
        return
    end

    if data then
        local number = 0
        for k ,v in pairs(self.rightdata) do
            if v.amount > 0 then
                number = number + 1
            end
        end

        if number == self.maxTrade then
            local flag = false
            for k ,v in pairs(self.rightdata) do
                if v.index == data.index then
                    flag = true
                    break
                end
            end 

            if not flag then
                GComAlter(language.trade13)
                return
            end
        end

        --local  t = {mid = data.mid,index = data.index}

        mgr.ViewMgr:openView(ViewName.BagInOut,function(view)
            -- body
            view:setTradeIn()
        end,data)
    end
end

function TradeMainView:onController1()
    -- body
    self.packinfo = {}
    local t = {}
    if self.c1.selectedIndex == 0 then --全部
        t = cache.PackCache:getPackData()
    elseif self.c1.selectedIndex == 1 then --道具
        t = cache.PackCache:getPackProsData() 
    else --装备
        t = cache.PackCache:getPackEquipData()
    end
    local pairs = pairs
    for k , v in pairs(t) do
        ---刷选 
        local confdata = conf.ItemConf:getItem(v.mid)
        --day_jy_num 交易数量
        if v.bind == 0 and confdata.day_jy_num and confdata.day_jy_num>0 then --非绑定的，可以交易的
            table.insert(self.packinfo,clone(v))
        end
    end
    --排除已经添加的
    for k ,v in pairs(self.packinfo) do
        for i,j in pairs(self.rightdata) do
            if j.index == v.index then
                self.packinfo[k].amount = v.amount - j.amount
                break
            end
        end
    end
    --排个序
    table.sort(self.packinfo,function(a,b)
        -- body
        local acolor = conf.ItemConf:getQuality(a.mid)
        local bcolor = conf.ItemConf:getQuality(b.mid)
        if acolor == bcolor then
            return a.index < b.index
        else
            return acolor>bcolor
        end
    end)

    local number = math.ceil(table.nums(self.packinfo) /16)
    if number <= 0 then
        number = 1
    end
    self.listView.numItems = number
    self.listView.scrollPane:ScrollTop()
end
function TradeMainView:initItem(obj,data)
    -- body
    local _t = clone(data)
    -- local t = {mid = data.mid,amount = data.amount,func = data.func,colorAttris = data.colorAttris}
    -- printt("t",t)
    --local _t = clone(_data)
    _t.isdone = cache.PlayerCache:getIsNeed(_t.mid)
    -- if _t.isdone  and _t.isdone > 1 then
    --     --交易物品排除背包
    --     -- if cache.PackCache:getPackDataById(info.mid).amount > 0 then 
    --     --     _t.isdone = nil 
    --     -- end
    -- end
    GSetItemData(obj,_t,true)
end

--左边交易物品
function TradeMainView:leftcelldata(index,obj)
    -- body
    local data = self.leftdata[index+1]
    local itemObj = obj:GetChild("n1")
    local c1 = itemObj:GetController("c1")
    local btnDelete =  obj:GetChild("n3")
    btnDelete.visible = false

    local name = obj:GetChild("n2")
    --printt("left data",data)
    if data.mid~=0 and data.amount>0 then
        --printt("left data",data)

        name.text = mgr.TextMgr:getColorNameByMid(data.mid)
        self:initItem(itemObj:GetChild("n0"),data)
        c1.selectedIndex = 1
    else
        c1.selectedIndex = 0
        name.text = ""
    end
end
--全部取出
function TradeMainView:ondelete(context)
    -- body
    local data = context.sender.data
    local param = {}
    param.tradeType = 2
    param.index = data.index
    param.amount = data.amount
    proxy.TradeProxy:send(1260203,param)
end
--右边交易物品
function TradeMainView:rightcelldata(index,obj)
    -- body
    local data = self.rightdata[index+1]
    local itemObj = obj:GetChild("n1")
    local c1 = itemObj:GetController("c1")
    local btnDelete =  obj:GetChild("n3")
    btnDelete.data = data
    btnDelete.onClick:Add(self.ondelete,self)
    btnDelete.visible = false

    local name = obj:GetChild("n2")
    if data.mid~=0 and data.amount>0 then
        btnDelete.visible = true
        --printt("data",data)
        local t = clone(data)
        t.func = function()
            -- body
            if self.suo then
                GComAlter(language.trade01)
                return
            end
            mgr.ViewMgr:openView(ViewName.BagInOut,function(view)
                -- body
                view:setTradeOut()
            end,data)
        end

        -- local  t = {mid =data.mid,amount = data.amount,colorAttris = data.colorAttris,func = function()
        --     -- body
        --     if self.suo then
        --         GComAlter(language.trade01)
        --         return
        --     end
        --     mgr.ViewMgr:openView(ViewName.BagInOut,function(view)
        --         -- body
        --         view:setTradeOut()
        --     end,data)
        -- end}
        name.text = mgr.TextMgr:getColorNameByMid(data.mid)
        self:initItem(itemObj:GetChild("n0"),t)
        c1.selectedIndex = 1
    else
        btnDelete.visible = false
        c1.selectedIndex = 0
        name.text = ""
    end
end

function TradeMainView:setData(data_)
    --设置右边自己的信息
    self.data = cache.PlayerCache:getData()
    self.rightName.text = self.data.roleName
end
function TradeMainView:setOtherData(data)
    -- body
    self.otherPlayer = data

    if cache.PlayerCache:getRoleId() == data.originRoleId then 
        self.leftName.text = data.invitedRoleName
    else
        self.leftName.text = data.roleName
    end
end

--锁定交易物品
function TradeMainView:onSuoDing()
    -- body
    if self.suo then
        GComAlter(language.trade01)
        return
    end
    
    --发送锁定消息
    local param = {}
    proxy.TradeProxy:send(1260204)
end
---取消交易
function TradeMainView:onCancel()
    -- body
    self.money3.editable = true
    self.money4.editable = true
    self.suo = false
    --
    proxy.TradeProxy:send(1260205,{tradeType = 2})
    cache.TradeCache:removeTimer()
    self:closeView()
end
--铜钱输入完成判定
function TradeMainView:onTongqian()
    -- body
    if checkint(self.money3.text) > cache.PlayerCache:getTypeMoney(MoneyType.copper) then
        GComAlter(language.gonggong05)
        self.money3.text = cache.PlayerCache:getTypeMoney(MoneyType.copper)
        return
    end
    local param = {}
    param.copper = checkint(self.money3.text)
    param.gold = checkint(self.money4.text)
    proxy.TradeProxy:send(1260206,param)
end
--元宝判定
function TradeMainView:onYuanbao()
    -- body
    local var = conf.SysConf:getValue("day_trade_gold") --每天交易上线
    if not self.money4.text then
        --plog("not self.money4.text ")
        return
    end
    if self.money4.text == "" then
        --plog("not self.money4. == ")
        return
    end
    if tonumber(self.money4.text)>cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        self.money4.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
    end

    --当前交易余额
    local a10305 =  var-(cache.PlayerCache:getAttribute(10305) or 0)
    --plog("a10305",a10305)
    if checkint(self.money4.text) > a10305 then
        GComAlter(language.trade03)
        self.money4.text = a10305
        --return
    elseif checkint(self.money4.text) > cache.PlayerCache:getTypeMoney(MoneyType.gold) then
        GComAlter(language.gonggong18)
        self.money4.text = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        --return
    end 
    --plog("发送的消息")
    local param = {}
    param.copper = checkint(self.money3.text)
    param.gold = checkint(self.money4.text)
    proxy.TradeProxy:send(1260206,param)
end

function TradeMainView:onBtnClose()
    -- body
    cache.TradeCache:removeTimer()
    self:onCancel()
    self:closeView()
end

--对方放入的物品锁定
function TradeMainView:otherTrade(data)
    -- body
    GComAlter(language.trade10)
    self.c2.selectedIndex = 1
end
--双方都锁定了
function TradeMainView:sendMsg(msgId, param)
    -- body
    proxy.TradeProxy:send(msgId,param)
end

function TradeMainView:twoSuo(data)
    -- body= 
    self.c2.selectedIndex = 3
    local param = {}
    param.type = 2
    param.richtext = mgr.TextMgr:getTextByTable(language.trade11)
    param.sure = function()
        -- body
        self:sendMsg(1260205,{tradeType = 1})
        
    end
    param.cancel = function()
        -- body\
        self:sendMsg(1260205,{tradeType = 2})
        --proxy.TradeProxy:send(1260205,{tradeType = 2})
    end
    param.closefun = function()
        -- body
        self:sendMsg(1260205,{tradeType = 2})
    end
    GComAlter(param)
end


--添加物品 或者 移除物品
function TradeMainView:add5260203(data)
    -- body
    if data.tradeType == 1 then--纯如
        for k ,v in pairs(self.packinfo) do
            if v.index == data.index then
                self.packinfo[k].amount =  v.amount - data.amount
                break
            end
        end
        local flag = false
        for k,v in pairs(self.rightdata) do
            if v.index == data.index then
                self.rightdata[k].index = data.index
                self.rightdata[k].mid = data.mid
                --self.rightdata[k].amount +
                self.rightdata[k].amount =  self.rightdata[k].amount + data.amount
                self.rightdata[k].colorAttris = data.colorAttris
                flag = true
                break
            end
        end
        if not flag then --找空格子
            for k , v in pairs(self.rightdata) do
                if v.amount ==  0 then
                    self.rightdata[k].index = data.index
                    self.rightdata[k].mid = data.mid
                    self.rightdata[k].amount = data.amount
                    self.rightdata[k].colorAttris = data.colorAttris
                    break
                end
            end
        end
        self.rightList:RefreshVirtualList()
        self.listView:RefreshVirtualList()
    else
        for k ,v in pairs(self.packinfo) do
            if v.index == data.index then
                self.packinfo[k].amount =  self.packinfo[k].amount + data.amount
                break
            end
        end
        for k,v in pairs(self.rightdata) do
            if v.index == data.index then
                self.rightdata[k].index = data.index
                self.rightdata[k].mid = data.mid
                --
                self.rightdata[k].amount =  self.rightdata[k].amount - data.amount 
                self.rightdata[k].colorAttris = data.colorAttris
                break
            end
        end
        self.rightList:RefreshVirtualList()
        self.listView:RefreshVirtualList()
    end
end
--锁定成功
function TradeMainView:add5260204()
    -- body
    self.money3.editable = false
    self.money4.editable = false
    self.suo = true
    self.c2.selectedIndex = 0
end
--交易物品变化
function TradeMainView:add8070102(data)
    -- body
    --printt("data",data)
    if data.opType == 1 then
        local flag = false
        for k,v in pairs(self.leftdata) do
            if v.index == data.changeItem.index then
                self.leftdata[k].index = data.changeItem.index
                self.leftdata[k].mid = data.changeItem.mid
                self.leftdata[k].amount =  data.changeItem.amount
                self.leftdata[k].colorAttris = data.changeItem.colorAttris
                flag = true
                break
            end
        end
        if not flag then --找空格子
            for k , v in pairs(self.leftdata) do
                if v.amount ==  0 then
                    self.leftdata[k].index = data.changeItem.index
                    self.leftdata[k].mid = data.changeItem.mid
                    self.leftdata[k].amount = data.changeItem.amount
                    self.leftdata[k].colorAttris = data.changeItem.colorAttris
                    break
                end
            end
        end
        self.leftList:RefreshVirtualList()
    else
        for k,v in pairs(self.leftdata) do
            if v.index == data.changeItem.index then
                self.leftdata[k].index = data.changeItem.index
                self.leftdata[k].mid = data.changeItem.mid
                self.leftdata[k].amount = data.changeItem.amount 
                self.leftdata[k].colorAttris = data.changeItem.colorAttris
                break
            end
        end
        self.leftList:RefreshVirtualList()
    end
end

function TradeMainView:add8070103(data)
    -- body
    self.money1.text = data.copper
    self.money2.text = data.gold
end



return TradeMainView