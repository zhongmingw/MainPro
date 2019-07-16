--
-- Author: 
-- Date: 2017-07-20 15:23:35
--

local MarrySongHuaView = class("MarrySongHuaView", base.BaseView)

function MarrySongHuaView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarrySongHuaView:initData(data)
    -- body
    self.radio.selected = false
    --选择的是什么花
    self.data = data
    --初始化花列表
    self:initHuaList()
    --当前送的数量
    self.count = 1
    self:setCount()
    
    if data and type(data) == "table" then
        self.selectdata = data
        self.selectName.text = data.roleName
    else
        --默认选择配偶
        if cache.PlayerCache:getCoupleName() ~= "" then
            self.selectdata = {roleId = 0}
            self.selectName.text = cache.PlayerCache:getCoupleName()
        else
            self.selectdata = nil
            self.selectName.text = language.kuafu27
        end

        --
        --
    end
    self.c1.selectedIndex = 0
    if cache.ActivityCache:getFlowerRankCome() then --从鲜花榜打开的，名字按钮不能点击
        self.btnName.touchable = false
    else
        self.btnName.touchable = true
    end
end

function MarrySongHuaView:initView()
    self.c1 = self.view:GetController("c1")

    local btnClose = self.view:GetChild("n13")
    btnClose.onClick:Add(self.onBtnClose,self)
    --何种花
    self.itemObj = self.view:GetChild("n1")
    self.checkBox = self.view:GetChild("n12")
    self.flowername = self.checkBox:GetChild("title")
    self.flowername.text = ""
    self.checkBox.onClick:Add(self.onCheckBox,self)
    self.countlab = self.view:GetChild("n9")

    local btnPlus = self.view:GetChild("n4")
    btnPlus.onClick:Add(self.onPlus,self)

    local btnReduce = self.view:GetChild("n3")
    btnReduce.onClick:Add(self.onReduce,self)

    local btnMax = self.view:GetChild("n5")
    btnMax.onClick:Add(self.onMax,self)

    self.radio = self.view:GetChild("n2")
    self.radio.onClick:Add(self.onBtnRadio,self)
    local dec = self.view:GetChild("n10")
    self.dec = dec
    dec.text = language.kuafu26

    --
    self.btnName =  self.view:GetChild("n17") 
    self.btnName.onClick:Add(self.onFriendlist,self)
    self.selectName = self.btnName:GetChild("title")
    --好友
    self.listView = self.view:GetChild("n18")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)
    --花
    self.listflower = self.view:GetChild("n26")
    self.listflower:SetVirtual()
    self.listflower.itemRenderer = function(index,obj)
        self:cellflowerdata(index, obj)
    end
    self.listflower.numItems = 0
    self.listflower.onClickItem:Add(self.onCallflowerBack,self)

    --
    local btnIngore = self.view:GetChild("n21"):GetChild("n2")
    btnIngore.onClick:Add(self.onbtnIngore,self)

    local btnSong = self.view:GetChild("n20")
    btnSong.onClick:Add(self.onbtnSong,self)
end

function MarrySongHuaView:cellflowerdata(index,cell)
    -- body
    local data = self.flower[index + 1]
    local itemObj = cell:GetChild("n1")
    local t = {mid = data[1],amount = 1}
    GSetItemData(itemObj,t)

    local name = cell:GetChild("n2")
    name.text = conf.ItemConf:getName(data[1])

    local labcout = cell:GetChild("n5")
    local _t = cache.PackCache:getPackDataById(data[1])
    labcout.text = GTransFormNum(_t.amount) --string.format(language.kuafu112,) 

    cell.data = data
end

function MarrySongHuaView:onCallflowerBack(context)
    -- body
    context:StopPropagation()
    self:initFlower(context.data.data)
    self.c1.selectedIndex = 0
end

function MarrySongHuaView:initFlower(data)
    -- body
    local t = {mid = tonumber(data[1]),amount = 1, bind = 1}
    GSetItemData(self.itemObj,t,true)

    self.mId = t.mid

    self.flowername.text = conf.ItemConf:getName(data[1])

    --计算最大值
    self.price = conf.ItemConf:getBuyPrice(t.mid)
    self.buytype = conf.ItemConf:getBuyType(t.mid)
    self.max = 0
    if self.price and self.price>0 and self.buytype  then
        self.radio.visible = true
        self.dec.visible = true
        for k ,v in pairs(self.buytype) do
            local money = cache.PlayerCache:getTypeMoney(v)
            self.max = self.max + math.floor(money/self.price)
        end

        self.max = math.min(self.max,9999)
    else
        self.radio.selected = false
        self.radio.visible = false
        self.dec.visible = false
    end
end

function MarrySongHuaView:initHuaList()
    -- body
    self.flower = conf.MarryConf:getValue("flower_list")
    self.listflower.numItems = #self.flower
    --默认选择
    local selectedIndex = 0
    local data = self.flower[1]
    for k ,v in pairs(self.flower) do
        if self.data and type(self.data) == "number" and self.data == v[1] then
            selectedIndex = k -1 
            data = v
            break
        end
    end
    self.listflower:AddSelection(0,false)

    self:initFlower(data)
end

function MarrySongHuaView:onCheckBox()
    -- body
    --设置花
    if self.c1.selectedIndex == 2 then
        return
    end
    self.c1.selectedIndex = 2
end

function MarrySongHuaView:setData(data_)

end

function MarrySongHuaView:setCount()
    -- body
    self.count = math.max(self.count,1)
    self.countlab.text = self.count
end

function MarrySongHuaView:onPlus()
    -- body --加
    local var = cache.PackCache:getPackDataById(tonumber(self.mId))
    if self.radio.selected then
        if self.count < self.max + var.amount then
            self.count = self.count + 1
            self:setCount()
        else
            GComAlter(language.kuafu28)
        end
    else
        
        if self.count < var.amount then
            self.count = self.count + 1
            self:setCount()
        else
            GComAlter(language.kuafu28)
        end
    end
end

function MarrySongHuaView:onReduce()
    -- body --减
    --local var = cache.PackCache:getPackDataById(self.checkBox.value)
    if self.count > 1 then
        self.count = self.count - 1
        self:setCount()
    else
        GComAlter(language.kuafu29)
    end
end

function MarrySongHuaView:onMax()
    -- body
    local mid = tonumber(self.mId)
    if self.radio.selected then
        self.count = self.max + cache.PackCache:getPackDataById(mid).amount
    else
        self.count = cache.PackCache:getPackDataById(mid).amount
    end
    self:setCount()
end

function MarrySongHuaView:onbtnSong()
    -- body
    if not self.selectdata then
        GComAlter(language.kuafu31)
        return
    end
    if checkint(self.mId) == 0   then
        return
    end
    local count = cache.PackCache:getPackDataById(self.mId).amount
    if  not self.radio.selected and self.count > count then
        GComAlter(language.gonggong11)
        return
    end

    local param = {}
    param.roleId = self.selectdata.roleId
    param.mid = self.mId--tonumber(self.checkBox.value)
    param.amount = self.count
    param.auto = self.radio.selected and 1 or 0
    -- param.source = self.data.source and self.data.isFriend or 0

    if param.amount == 0 then
        GComAlter(language.kuafu30)
        return
    end
    if self.data and type(self.data) == "table" then
        if self.data and  self.data.isFriend and self.data.isFriend == 0 then --不是好友
            param.source = 1
            -- if cache.ActivityCache:getFlowerRankCome() then-- 从鲜花榜进来
            --     local selfSex = cache.PlayerCache:getSex()
            --     if self.data.sex and self.data.sex == selfSex then
            --         local t = {}
            --         t.type = 14
            --         t.richtext = language.flower12
            --         t.sure = function()
            --             proxy.MarryProxy:sendMsg(1390101,param)
            --         end
            --         GComAlter(t)
            --         return
            --     else
            --         proxy.MarryProxy:sendMsg(1390101,param)
            --         self:onBtnClose()
            --         return
            --     end
            -- end
        else
            param.source = 0
        end
    end
    proxy.MarryProxy:sendMsg(1390101,param)
    --
    self:onBtnClose()
    -- self.count = 1
    -- self:setCount()
end

--
function MarrySongHuaView:onFriendlist(context)
    -- body
    --请求一下好友列表
    context:StopPropagation()

    if self.c1.selectedIndex == 1 then
        return
    end
    self.c1.selectedIndex = 1

    local param = {}
    param.page = 1
    proxy.FriendProxy:sendMsg(1070101,param)
end

function MarrySongHuaView:celldata(index,obj)
    -- body
    if index + 1 >= self.listView.numItems then
        if self.data.page ~= self.data.totalSum then
            proxy.FriendProxy:sendMsg(1070101,{page = self.data.page + 1})
        end
    end

    local data = self.data.friendList[index+1]
    obj.data = data

    local dec = obj:GetChild("n1")
    dec.text = data.name
end

function MarrySongHuaView:onCallBack(context)
    -- body
    local data = context.data.data
    self.selectName.text = data.name
    self.selectdata = data

    self.c1.selectedIndex = 0
end

function MarrySongHuaView:onBtnRadio()
    -- body
    if not self.radio.selected then
        local var = cache.PackCache:getPackDataById(tonumber(self.mId))
        if self.count > var.amount then
            self.count = var.amount 
            self:setCount()
        end
    end
end

function MarrySongHuaView:onbtnIngore()
    -- body
    self.c1.selectedIndex = 0
end

function MarrySongHuaView:onBtnClose()
    -- body
    cache.ActivityCache:setFlowerRankCome(false)
    self:closeView()
end

function MarrySongHuaView:addCallBack(data)
    -- body
    if 5070101 == data.msgId then --好友列表返回
        if data.page == 0 then
            return
        end
        if data.page == 1 then 
            self.data = {} 
            self.data.page = data.page
            self.data.totalSum = data.totalSum
            self.data.friendList = data.friendList
        else
            if data.page ~= self.data.page then 
                self.data.page =  data.page
                self.data.totalSum = data.totalSum
                for k ,v in pairs(data.friendList) do 
                    table.insert(self.data.friendList,clone(v))
                end
            end
        end 
        self.listView.numItems = #self.data.friendList
    end
end

return MarrySongHuaView