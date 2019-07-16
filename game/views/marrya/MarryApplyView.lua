--
-- Author: Your Name
-- Date: 2017-11-25 14:21:06
--

local MarryApplyView = class("MarryApplyView", base.BaseView)

function MarryApplyView:ctor()
    self.super.ctor(self)
    self.sharePackage = {"marryshare"}
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function MarryApplyView:initView()
    local btnClose = self.view:GetChild("n22"):GetChild("n7")
    self:setCloseBtn(btnClose)
    self.view:GetChild("n22"):GetChild("n6").visible = true
    self.c1 = self.view:GetController("c1")
    self.c3 = self.view:GetController("c3")
    self.myIcon = self.view:GetChild("n1"):GetChild("n2"):GetChild("n3")
    self._icon = self.view:GetChild("n2")
    self.topicon = self._icon:GetChild("n2"):GetChild("n3")
    self.topicon.onClick:Add(self.onFriendlist,self)

    self.flistBtn = self.view:GetChild("n29")
    self.flistBtn.onClick:Add(self.onFriendlist,self)

    local btnClose2 = self.view:GetChild("n16"):GetChild("n2")
    btnClose2.onClick:Add(self.onViewCall,self)

    self.selectName = self.view:GetChild("n28")

    self.btn = self.view:GetChild("n6")
    self.btn.onClick:Add(self.onBtnClick,self)

    self.list = {}
    --当前选定的标记
    self.sign = 1
    for i = 3 , 5 do
        local item = self.view:GetChild("n"..i)
        item.onClick:Add(self.onItemCall,self)
        self:initItem(item,i-3)
        table.insert(self.list,item)
    end

    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
    self.listView.onClickItem:Add(self.onCallBack,self)

    local dec1 = self.view:GetChild("n32")
    local dec2 = self.view:GetChild("n34")
    local dec3 = self.view:GetChild("n36")
    local dec4 = self.view:GetChild("n38")
    dec1.text = language.marryiage44
    dec2.text = language.marryiage45
    dec3.text = language.marryiage46
    dec4.text = language.marryiage47
end

function MarryApplyView:initData(data)
    self.topicon.url = nil 
    self.selectName.text = language.kuafu35
    self.selectdata = nil 
    local myNameTxt = self.view:GetChild("n26")
    myNameTxt.text = cache.PlayerCache:getRoleName()

    local myRoleId = cache.PlayerCache:getRoleId()
    local myIcon = cache.PlayerCache:getRoleIcon()
    local t = GGetMsgByRoleIcon(myIcon,myRoleId,function(tab)
        if tab then
            self.myIcon.url = tab.headUrl
        end
    end)
    self.myIcon.url = t.headUrl
    
    self.data = cache.PlayerCache:getData()
    if self.data.coupleName ~= "" then
        self.flistBtn.visible = false
        self.topicon.touchable = false
        self.selectName.text = self.data.coupleName
        self.c3.selectedIndex = 1
        self._icon.visible = true
        proxy.MarryProxy:sendMsg(1390305,nil,4)
    elseif data and data.roleId then
        self.flistBtn.visible = true
        self.topicon.touchable = true
        self.selectdata = data
        self.selectName.text = data.name
        self.c3.selectedIndex = 1
        self:setIcon(data)
    else
        self.c3.selectedIndex = 0
        self.flistBtn.visible = true
        self.topicon.touchable = true
        self._icon.visible = true
    end
    self:onController3()
end

function MarryApplyView:initItem(item,i)
    -- body
    item.data = i
    -- local img22 = item:GetChild("n22") 
    -- if i == 1 then
    --     item.sortingOrder = 100
    --     --item.alpha = 1
    --     item:SetScale(1,1)
    --     img22.visible = false
    -- else
    --     item:SetScale(0.7,0.7)
    --     item.sortingOrder = 99
    --     --item.alpha = 0.6
    --     img22.visible = true

    -- end
    if self.sign == i+1 then
        item:GetChild("n27").visible = true
    else
        item:GetChild("n27").visible = false
    end

    local c1 = item:GetController("c1")
    c1.selectedIndex = i 

    local condata = conf.MarryConf:getGradeItem(i+1)
    -- local cost = item:GetChild("n10") 
    -- cost.text = condata.cost

    local cost2 = item:GetChild("n24") 
    cost2.text = condata.oldcost

    --local img4 = item:GetChild("n4")  
    local dec = item:GetChild("n25")
    dec.text = condata.cost --language.marryiage24
    -- item:GetChild("n26").text  = language.marryiage25

    local c2 = item:GetController("c2")
    if condata.zekou then
        c2.selectedIndex = 1

        local zeimg =  item:GetChild("n38")
        zeimg.url = "ui://marryshare/Ajiehun_0"..(82+condata.zekou)
    else
        c2.selectedIndex = 0 
    end

    local banquetCount = item:GetChild("n29")
    banquetCount.text = condata.wedding_banquet_count
    if i == 0 then
        cost2.text = condata.cost
        item:GetChild("n38").text =language.marryiage24
        item:GetChild("n41").text =condata.cost
        item:GetChild("n23").visible = false
        item:GetChild("n24").visible = false
        item:GetChild("n42").visible = false
        --img4.x = dec.width + dec.x + 2
    else
        item:GetChild("n24").visible = true
        --img4.x = item:GetChild("n23").x  
    end

    local itemObj = {}
    table.insert(itemObj,item:GetChild("n6"))
    table.insert(itemObj,item:GetChild("n7"))
    table.insert(itemObj,item:GetChild("n34"))
    table.insert(itemObj,item:GetChild("n35"))

    for k ,v in pairs(itemObj) do
        v.visible = false
    end
    if condata.show then
        for k ,v in pairs(condata.show) do
            local cell = itemObj[k]
            if cell then
                local t = {mid=v[1],amount=v[2],bind=v[3]}
                GSetItemData(cell,t,true)
            end
        end
    end
    --专属昵称
    self:initName(item)
end

function MarryApplyView:initName(item)
    -- body
    local lab1 = item:GetChild("n12")
    local lab2 = item:GetChild("n13")
    local sex = cache.PlayerCache:getSex()
    local _tname = cache.PlayerCache:getRoleName()
    local str = string.split(_tname,".")
    local name = ""
    if #str == 2 then
        name = str[2]
    else
        name = _tname
    end
    local i = item:GetController("c1").selectedIndex

    local var = language.kuafu85
    if self.data and self.data.coupleName ~="" then
        local str = string.split(self.data.coupleName,".")
        if #str == 2 then
            var = str[2]
        else
            var = self.data.coupleName
        end
    elseif self.selectdata then
        local str = string.split(self.selectName.text,".")
        if #str == 2 then
            var = str[2]
        else
            var = self.selectName.text
        end
    end
    if sex == 1 then
        lab1.text = string.format(language.kuafu78[i+1][1], var)
        lab2.text = string.format(language.kuafu78[i+1][2],name)
    else
        lab1.text = string.format(language.kuafu78[i+1][1],name or "")
        lab2.text = string.format(language.kuafu78[i+1][2],var)
    end
end

function MarryApplyView:onItemCall( context )
    -- body
    local data = context.sender.data
    self.sign = data + 1
    for i = 3 , 5 do
        local item = self.view:GetChild("n"..i)
        if i == self.sign + 2 then
            item:GetChild("n27").visible = true
        else
            item:GetChild("n27").visible = false
        end
    end
end

function MarryApplyView:onController3()
    -- body
    if self.c3.selectedIndex == 0 then
        self.btn.touchable = false
    else
        self.btn.touchable = true
    end
end

function MarryApplyView:setIcon(data)
    -- body
    local t = GGetMsgByRoleIcon(data.roleIcon,data.roleId,function(tab)
        if tab then
            self.topicon.url = tab.headUrl
        end
    end)
    self.topicon.url = t.headUrl
end

function MarryApplyView:onFriendlist(context)
    -- body
    context:StopPropagation()
    if self.c1.selectedIndex == 1 then
        return
    end
    self.c1.selectedIndex = 1
    proxy.MarryProxy:sendMsg(1390108)
end

function MarryApplyView:onBtnClick()
    -- body 求婚
    local param = {}
    if self.data.coupleName == "" then
        if not self.selectdata then
            GComAlter(language.kuafu31)
            return
        end
        param.objRoleId = self.selectdata.roleId
    else
        param.objRoleId = 0
    end
    -- local index = 0
    -- for k ,v in pairs(self.list) do
    --     if v.data == 1 then
    --         index = k - 1
    --         break 
    --     end
    -- end

    param.weddingGrade = self.sign--self.c2.selectedIndex + 1
    if param.weddingGrade == 1 then
        --检测元宝 和 绑元是否足够
        local money = cache.PlayerCache:getTypeMoney(MoneyType.gold)
        -- money = money + cache.PlayerCache:getTypeMoney(MoneyType.bindGold)
        local condata = conf.MarryConf:getGradeItem(param.weddingGrade)
        if money < condata.cost then
            -- local distance = condata.cost - money
            -- local str = clone(language.marryiage23)
            -- str[2].text = string.format(str[2].text ,distance)

            -- local param = {}
            -- param.richtext = mgr.TextMgr:getTextByTable(str)
            -- param.sure = function()
            --     -- body
            --     GOpenView({id = 1042})
            -- end
            -- param.type = 2
            -- GComAlter(param)

            -- return
            GComAlter(language.gonggong18)
        end
    end

    proxy.MarryProxy:sendMsg(1390102,param)
    self:onBtnClose()
end

function MarryApplyView:onViewCall()
    -- body
    self.c1.selectedIndex = 0
end

function MarryApplyView:celldata( index,obj )
    local data = self.oppoFriends[index+1]
    obj.data = data

    local dec = obj:GetChild("n1")
    dec.text = data.name
end

function MarryApplyView:onCallBack(context)
    local data = context.data.data
    self.c1.selectedIndex = 0
    self.selectName.text = data.name
    self.selectdata = data
    self.c3.selectedIndex = 1
    self:setIcon(data)

    for k,v in pairs(self.list) do
        self:initName(v)
    end
end

function MarryApplyView:add5390108( data )
    -- body
    self.oppoFriends = data.oppoFriends
    self.listView.numItems = #self.oppoFriends
    if self.listView.numItems == 0 then
        GComAlter(language.kuafu36)
    end
end

function MarryApplyView:onBtnClose()
    -- body
    self:closeView()
end

return MarryApplyView