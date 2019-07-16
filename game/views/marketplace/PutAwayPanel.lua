local PutAwayPanel = class("PutAwayPanel", base.BaseView)

function PutAwayPanel:ctor(  )
    self.super.ctor(self)
    self.uiLevel = UILevel.level2           --窗口层级
    self.isBlack = true
    self.num = 0        --物品数量
    self.price = 0      --物品单价
    self.sumPrice = 0   --物品总价
    self.referPrice = 0 --参考单价
    self.uiClear = UICacheType.cacheTime
    --self.openTween = ViewOpenTween.scale
end

function PutAwayPanel:refreshPanel()
    -- body
    self.num = 0        --物品数量
    self.price = 0      --物品单价
    self.sumPrice = 0   --物品总价
    self.referPrice = 0 --参考单价
    self.mid = nil
    self.numTxt.text = self.num
    self.priceTxt.text = self.price
    self.sumPriceTxt.text = self.sumPrice
    self.referPriceTxt.text = self.referPrice
    self.itemIcon:GetChild("n1").url =ResPath.iconRes("beibaokuang_001")-- UIPackage.GetItemURL("_icons" , "beibaokuang_001")
    local nameTxt = self.view:GetChild("n15")
    nameTxt.text = language.sell17
    self.itemIcon.visible = false
    self.itemImg.visible = true
end

function PutAwayPanel:initData()
    -- body
    local btnClose = self.view:GetChild("n4")
    btnClose.onClick:Add(self.onClickClose,self)

    self.itemIcon = self.view:GetChild("n14")
    self.itemImg = self.view:GetChild("n35")
    self.itemIcon.visible = false
    self.itemImg.visible = true
    self.view:GetChild("n15").text = language.sell20
    self.numTxt = self.view:GetChild("n33")
    self.numTxt.onChanged:Add(self.timerClick,self)
    self.sumPriceTxt = self.view:GetChild("n29")
    self.priceTxt = self.view:GetChild("n32")
    self.priceTxt.onChanged:Add(self.timerClick,self)
    self.referPriceTxt = self.view:GetChild("n30")
    self.numTxt.text = self.num
    self.priceTxt.text = self.price
    self.sumPriceTxt.text = self.sumPrice
    self.referPriceTxt.text = self.referPrice
    self.listView = self.view:GetChild("n34")
    self.petList = self.view:GetChild("n39")
    --数量加减号
    local btnSubtract = self.view:GetChild("n24")
    local btnAdd = self.view:GetChild("n25")
    btnSubtract.onClick:Add(self.onClickSubtract,self)
    btnAdd.onClick:Add(self.onClickAdd,self)
    --设置密码按钮
    local passWordBtn = self.view:GetChild("n36")
    passWordBtn.onClick:Add(self.onClickSetPassWord,self)
    --上架按钮
    local btnPutAway = self.view:GetChild("n31")
    btnPutAway.onClick:Add(self.onClickPutAway,self)
    self:initListView()
    self:initPetListView()

    self.c1 = self.view:GetController("c1")

    -- self.timer = self:addTimer(0.1, -1, handler(self, self.timerClick))

    --交易密码
    self.passWord = nil
    self.isSetTxt = self.view:GetChild("n37")
    self.isSetTxt.text = language.sell33
    --税率
    self.rateTxt = self.view:GetChild("n38")
    local rate = conf.SysConf:getValue("market_trade_tax_rate")
    if cache.PlayerCache:VipIsActivate(3) then
        self.rateTxt.text = string.format(language.sell36[4],rate[4])
    elseif cache.PlayerCache:VipIsActivate(2) then
        self.rateTxt.text = string.format(language.sell36[3],rate[3])
    elseif cache.PlayerCache:VipIsActivate(1) then
        self.rateTxt.text = string.format(language.sell36[2],rate[2])
    else
        self.rateTxt.text = string.format(language.sell36[1],rate[1])
    end
    self.super.initData()
end

function PutAwayPanel:initView()
    -- body
    
end

function PutAwayPanel:setPetListVisible(flag)
    if flag then--宠物
        self.petRoleId = nil
        self.listView.numItems = 0
        self.c1.selectedIndex = 1
    else--背包道具
        self.petRoleId = nil
        self.petList.numItems = 0
        self.c1.selectedIndex = 0
    end
end

--设置密码按钮
function PutAwayPanel:onClickSetPassWord()
    if cache.PlayerCache:VipIsActivate(3) then
        mgr.ViewMgr:openView2(ViewName.PasswordView,{Type = 1})
    else
        GComAlter(language.sell35)
    end
end

--修改交易密码
function PutAwayPanel:setPassword(passWord)
    self.passWord = passWord
    if passWord then
        self.isSetTxt.text = language.sell34
    end
end

--道具列表
function PutAwayPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end
--宠物列表
function PutAwayPanel:initPetListView()
    self.petList.numItems = 0
    self.petList.itemRenderer = function(index,obj)
        self:petItemData(index, obj)
    end
    self.petList:SetVirtual()
end

function PutAwayPanel:setData( data )
    -- body
    if self.c1.selectedIndex == 0 then--背包道具装备
        self.data = data
        self.listView.numItems = #self.data
    elseif self.c1.selectedIndex == 1 then--宠物
        self.data = mgr.PetMgr:getSelectCanSee() -- cache.PetCache:getData()
        self.petList.numItems = #self.data
    end

    --引导时特殊情况
    local index = nil
    for k,v in pairs(self.data) do
        if v.mid == conf.SysConf:getValue("market_yd_mid") then
            index = k
            break
        end
    end
    if index then
        local data = self.data[index]
        self.mid = data.mid
        self.index = data.index
        self.amount = data.amount
        local param = {mid = self.mid}
        proxy.MarketProxy:sendMarketMsg(1260107,param)
    end
end

function PutAwayPanel:itemData( index,obj )
    -- body
    local data = self.data[index+1]
    --printt("道具信息",data)
    local info = {mid = data.mid,amount = data.amount,colorAttris = data.colorAttris,level = data.level or 0}
    info.isdone = cache.PlayerCache:getIsNeed(info.mid)


    GSetItemData(obj,info,false)
    obj.data = data
    obj.onClick:Add(self.onClickShow,self)
end

function PutAwayPanel:petItemData( index,obj )
    -- body
    local data = self.data[index+1]
    local condata = conf.PetConf:getPetItem(data.petId)
    obj.data = data
    --local itemObj = obj
    --UIPackage.GetItemURL("_icon" , condata.src)
    local t = {isCase = true,color = condata.color,url = ResPath.iconRes(condata.src)}
    -- print("宠物图标",ResPath.iconRes(condata.src))
    -- t.func = function()
    --     -- body
    --     -- mgr.ViewMgr:openView2(ViewName.PetMsgView, data)
    --     --mgr.PetMgr:seeMarketInfo(data)
    -- end

    GSetItemData(obj,t,false)


    -- local info = {mid = data.mid,amount = data.amount,colorAttris = data.colorAttris}
    -- info.isdone = cache.PlayerCache:getIsNeed(info.mid)

    -- GSetItemData(obj,info,false)
    data.mid = data.petId
    obj.data = data
    obj.onClick:Add(self.onClickShow,self)
end

function PutAwayPanel:setSellInfo(data)
    -- body
    -- printt("111111111111",data)
    local name
    local color
    local info = {mid = self.mid,colorAttris = self.colorAttris,level = self.level}
    if self.c1.selectedIndex == 0 then
        GSetItemData(self.itemIcon,info,true)
        name = conf.ItemConf:getName(self.mid)
        color = conf.ItemConf:getQuality(self.mid)
        if data.price > 0 then
            self.referPrice = data.price
        else
            self.referPrice = conf.ItemConf:getItemTradePrice(self.mid)
        end
    else
        local info  = self.petData-- cache.PetCache:getPetData( self.petData--.petRoleId)
        local condata = conf.PetConf:getPetItem(info.petId)
        --local itemObj = obj
        name = info.name or condata.name
        color = condata.color
        local t = {isCase = true,color = condata.color,url = ResPath.iconRes(condata.src)}
        t.func = function()
            -- body
            mgr.ViewMgr:openView2(ViewName.PetMsgView, info)
            --mgr.PetMgr:seeMarketInfo(data)
        end
        GSetItemData(self.itemIcon,t,true)
        if data.price > 0 then
            self.referPrice = data.price
        else
            self.referPrice = 0--conf.ItemConf:getItemTradePrice(self.mid)
        end
    end
    self.itemIcon.visible = true
    self.itemImg.visible = false
   
    local nameTxt = self.view:GetChild("n15")
    nameTxt.text = mgr.TextMgr:getQualityStr1(name,color)
    
    self.referPriceTxt.text = self.referPrice
    self.price = 0--self.referPrice
    self.num = 1
    self.sumPrice = self.price*self.num
    self.numTxt.text = self.num
    self.priceTxt.text = self.price
    self.sumPriceTxt.text = self.sumPrice
end

function PutAwayPanel:onClickShow( context )
    -- body
    local cell = context.sender
    local data = cell.data
    self.mid = data.mid
    self.index = data.index or data.mid
    self.amount = data.amount
    self.level = data.level or 0
    self.colorAttris = data.colorAttris
    self.passWord = nil
    self.isSetTxt.text = language.sell33
    local param = {mid = self.mid}
    if self.c1.selectedIndex == 1 then
        self.petData = data
        self.petRoleId = self.petData.petRoleId
    end
    proxy.MarketProxy:sendMarketMsg(1260107,param)
end

function PutAwayPanel:onClickPutAway( context )
    -- body
    if self.mid then
        if self.c1.selectedIndex == 0 then
            local range = conf.ItemConf:getItemTradeRange(self.mid)
            if range then
                if range[1]<= tonumber(self.price) and range[2]>= tonumber(self.price) then
                    local param = {index = self.index, amount = self.num, price = self.price,passWord = self.passWord}
                    proxy.MarketProxy:sendMarketMsg(1260102,param)
                elseif range[1] > tonumber(self.price) then
                    GComAlter(language.sell12)
                elseif range[2] < tonumber(self.price) then
                    GComAlter(language.sell11)
                end
            else
                local param = {index = self.index, amount = self.num, price = self.price,passWord = self.passWord}
                proxy.MarketProxy:sendMarketMsg(1260102,param)
            end
        else
            if not mgr.PetMgr:isHaveEquip(self.petData,true) then
                if self.price > 0 then
                    local param = {petRoleId = self.petRoleId, price = self.price,passWord = self.passWord}
                    proxy.MarketProxy:sendMarketMsg(1260109,param)
                else
                    GComAlter(language.sell12)
                end
            else
                print("不能上架 咋回事。。。",self.petData)
            end
        end
    else
        GComAlter(language.sell13)
    end
end

function PutAwayPanel:onClickSubtract( context )
    -- body
    if self.index then
        local num = self.num -1
        if num < 1 then
            num = 1
            GComAlter(language.sell14)
        end
        self.numTxt.text = num
        self:timerClick()
    end
end

function PutAwayPanel:onClickAdd( context )
    -- body
    if self.index then
        local num = self.num +1
        if num > self.amount then
            num = self.amount
            GComAlter(language.sell15)
        end
        self.numTxt.text = num
        self:timerClick()
    end
end

function PutAwayPanel:timerClick()
    -- body
    local num = checkint(self.numTxt.text)
    -- if not num or num == "" then num = 0 end
    print("索引",self.index)
    if self.index and tonumber(num)>0 then
        self.amount = self.amount or 1
        if tonumber(num) > (self.amount or 1) then
            num = self.amount
        end
        self.num = num
        self.numTxt.text = self.num
        self.price = checkint(self.priceTxt.text)
        if self.price == "" or self.price == nil then
            self.price = 0
        end
        print("当前价格",self.price,self.num)
        self.sumPrice = tonumber(self.price)*self.num
        self.sumPriceTxt.text = self.sumPrice
    end
end

function PutAwayPanel:onClickClose()
    -- body
    self:refreshPanel()
    self:closeView()
end

return PutAwayPanel