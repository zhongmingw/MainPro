local PackView = class("PackView", base.BaseView)
--背包界面
local EquipPanel = import(".EquipPanel") --装备区域

local ShopPanel = import(".ShopPanel") --商店区域

local WarePanel = import(".WarePanel") --仓库区域

local cleanCDTime = 10--整理cd

function PackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2           --窗口层级
    self.oldCleanCdTime = 0
    self.uiClear = UICacheType.cacheForever
end

function PackView:initData(data)
    self.see = 0
    self:releaseTimer()
    self.equipPanel:clear()
    self.warePanel:releaseTimer()
    self:nextStep(data.index)
    GSetMoneyPanel(self.window2,self:viewName())
    self.view:GetChild("n31"):GetChild("n24").visible = mgr.ModuleMgr:CheckView({id = 1325})
    self.btn.visible = mgr.ModuleMgr:CheckView({id = 1325})
    self.xianselectbtn.selected = cache.FeiShengCache:getIsSelect() > 0

    proxy.PackProxy:sendMsgTunshi({reqType=1,type=0})
end
--主界面
function PackView:initView()
	self.mainController = self.view:GetController("tab1")--主控制器
	self.mainController.onChanged:Add(self.selelctPage,self)--给控制器获取点击事件
    self:initPackPanel()--道具区域
    self.equipPanel = EquipPanel.new(self)--装备区域
    self.shopPanel = ShopPanel.new(self)--商店区域
    self.warePanel = WarePanel.new(self)--仓库区域
    --self.equipxianPanel = EquipPanel1.new(self)--仙装备区域

    self.btn = self.view:GetChild("n33")
    self.btn.onClick:Add(self.onBtnCallBack,self)

    self.view:GetChild("n4").visible = false
    self.window2 = self.view:GetChild("window2")
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    local starAttrBtn = self.view:GetChild("n32")
    starAttrBtn.onClick:Add(self.onClickStarAtt,self)

    
end

--初始化道具信息--道具 武器 宠物
function PackView:initPackPanel()
	local packPanel = self.view:GetChild("n31")

    self.xianselectbtn = packPanel:GetChild("n46")
    self.xianselectbtn.selected = false
    self.xianselectbtn.onClick:Add(self.onBtnCallBack,self)
    packPanel:GetChild("n45").text = language.fs25

	self.packController = packPanel:GetController("tabl")--道具控制器
	self.packController.onChanged:Add(self.prosPage,self)
    self.eqSelectController = packPanel:GetController("c1") --装备吞噬控制器
    self.eqSelectController.onChanged:Add(self.eqSelect,self)
   
    self.prosBtnList = {}
    for i=1,4 do
        local btn = packPanel:GetChild("n2"..i)
        table.insert(self.prosBtnList, btn)
    end
	self.pageList = packPanel:GetChild("n31")
    self.pageList:SetVirtual()
    self.pageList.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.pageList.scrollPane.onScrollEnd:Add(self.onPackScrollPage, self)

    self.pageBtnList = packPanel:GetChild("n32")--分页按钮列表
    self.pageBtnList:SetVirtual()
    self.pageBtnList.itemRenderer = function(index,btnObj)
        btnObj.data = index
    end
    self.pageBtnList.onClickItem:Add(self.onClickPackPage,self)

	local btnClean = packPanel:GetChild("n19")--整理按钮
    self.prosClean = btnClean
    self.prosCdImg = btnClean:GetChild("n6").asImage
    self.prosCdImg.fillAmount = 0
	btnClean.onClick:Add(self.onClickClean, self)

    local btnSynthesis01 = packPanel:GetChild("n43") --EVE 一键吞噬
    btnSynthesis01.onClick:Add(self.onClickSynthesis,self)

     if g_is_banshu then
        packPanel:GetChild("n41").visible = false
        packPanel:GetChild("n42").visible = false
        packPanel:GetChild("n35").visible = false
        packPanel:GetChild("n36").visible = false
        packPanel:GetChild("n34").visible = false
        packPanel:GetChild("n37").visible = false
        packPanel:GetChild("n38").visible = false    
    end
end

function PackView:setData()
	self.mData = self:getSelectPackData()
    if self.isJump then
        self.mainController.selectedIndex = self.mainIndex
    end
    if not self.cdTimer then--整理cd
        self.cdActionTime = cleanCDTime - (mgr.NetMgr:getServerTime() - self.oldCleanCdTime)
        self:onTimer()
        self.cdTimer = self:addTimer(0.2, -1, handler(self,self.onTimer))
    end
    self.isJump = nil
    self:selelctPage()
end

function PackView:nextStep(id)
    self.mainIndex = id - 1
    self.isJump = true
    self:setData()
end
--刷新整理背包数据
function PackView:refreshPackClean()
    self.oldCleanCdTime = mgr.NetMgr:getServerTime()
    self:setData()
end

--设置道具页数信息
function PackView:setPackPageData()
    local selectedIndex = self.packController.selectedIndex
    local numItems = self:getNumItems()
    if numItems <= 0 then
        numItems = 1
    end
    self.girdOpenNum = cache.PackCache:getGridKeyData(attConst.packNum)--上一次背包开启的格子
    self.lastOpenTime = cache.PackCache:getGridKeyData(attConst.packTime)--上一次背包开启的时间
    self.packSec = cache.PackCache:getGridKeyData(attConst.packSec)
    -- end
    --数据列表
    self.pageList.numItems = numItems
    --按钮列表
    self.pageBtnList.numItems = numItems
    if self.selectedIndex and selectedIndex ~= self.selectedIndex then
        self.pageList.scrollPane.currentPageX = 0
    end
    self:onPackScrollPage()
end

--道具信息
function PackView:cellPackData( pageIndex, iconPanel )
    local iconInitNum = conf.SysConf:getValue("init_pack_grid")
	local selectedIndex = self.packController.selectedIndex
    local girdOpenNum = self.girdOpenNum + iconInitNum
    for i=1,Pack.iconNum do
        local girdNum = i + pageIndex * Pack.iconNum--当前第几格
        local iconObj = iconPanel:GetChild("n"..i)
        local unlockObj = iconObj:GetChild("n4")--密码锁
        local proObj = iconObj:GetChild("n5")--item
        local frame = iconObj:GetChild("n6")
        frame.visible = true
        -- if girdNum <= girdOpenNum then
            unlockObj.visible = false
            local data = {}--对应的数据
            local iconIndex = 0
            if selectedIndex == 0 then--显示全部
                data = self.mData
                iconIndex = Pack.pack + pageIndex * Pack.iconNum + i
            else--分类背包显示
                data = self.mData[pageIndex + 1]--获取分页的数据
                iconIndex = i
            end
            
            if data and data[iconIndex] then
                data[iconIndex].isquan = true
                data[iconIndex].isArrow = true
                if cache.PlayerCache:getIsNeed(data[iconIndex].mid) == 1 then
                    --背包只显示是否多余
                    data[iconIndex].isdone = 1
                end
                --data[iconIndex].isneed = cache.PlayerCache:getIsNeed(data[iconIndex].mid,true)
                --data[iconIndex].isneed = cache.PlayerCache:getIsNeed(data[iconIndex].mid) 
                GSetItemData(proObj,data[iconIndex],true)--设置道具信息
            else
                proObj.visible = false
                frame.visible = true
            end
        -- else
        --     proObj.visible = false
        --     local girdIndex = girdNum - girdOpenNum
        --     unlockObj.visible = true
        --     unlockObj.max = 100
        --     if girdIndex == 1 then
        --         unlockObj.value = self.timeInterval or 0
        --         unlockObj.max = self.maxInter or 100
        --     else
        --         unlockObj.value = 0
        --     end
        --     local time = self.timeInterval or 0
        --     unlockObj.data = {timer = 0,index = girdIndex,time = time}
        --     unlockObj.onClick:Add(self.onClickOpen,self)
        -- end
    end
end

--选页
function PackView:onClickPackPage(context)
    local btnObj = context.data
    local index = btnObj.data
    self.pageList:ScrollToView(index,true)
end

function PackView:onPackScrollPage()
    local index = self.pageList.scrollPane.currentPageX
    if self.pageBtnList.numItems > 0 then
        self.pageBtnList:AddSelection(index,true)
        self.prosIndex = index
    end
end

--道具，装备，宠物切换
function PackView:prosPage()
    self.mData = self:getSelectPackData()
    self:setPackPageData()
    self.selectedIndex = self.packController.selectedIndex
end

--装备吞噬选择
function PackView:eqSelect()
    -- body
    proxy.PackProxy:sendMsgTunshi({reqType=2,type=self.eqSelectController.selectedIndex})
end
function PackView:setTunshiType(Type)
    -- body
    self.eqSelectController.selectedIndex = Type or 0
end
--根据控制器返回对应的数据
function PackView:getSelectPackData()
    local selectedIndex = self.packController.selectedIndex
    local data = {}
    if selectedIndex == 0 then--全部
        data = cache.PackCache:getPackData()
        self.prosClean.visible = true
    elseif selectedIndex == 1 then--道具
        data = cache.PackCache:getPackProsData(true)
        self.prosClean.visible = false
    elseif selectedIndex == 2 then--装备
        data = cache.PackCache:getPackEquipData(true)
        self.prosClean.visible = false
    -- elseif selectedIndex == 3 then--宝石
    --     data = cache.PackCache:getPackGemData(true)
    --     self.prosClean.visible = false
    elseif selectedIndex == 3 then--仙装备
        data = cache.PackCache:getPacXiankEquipData(true)
        self.prosClean.visible = false
    end
    return data
end

function PackView:getNumItems()
    local selectedIndex = self.packController.selectedIndex
    local data = {}
    local iconMaxNum = conf.SysConf:getValue("max_pack_grid")
    if selectedIndex == 0 then--全部
        local index = Pack.pack
        for k,v in pairs(self.mData) do
            if v and v.index > index then
                index = v.index
            end
        end
        local num = index - Pack.pack
        if num <= iconMaxNum then
            num = iconMaxNum
        end
        return math.ceil(num / Pack.iconNum)
    else
        local num = 0
        for _,data in pairs(self.mData) do
            for _,v in pairs(data) do
                num = num + 1
            end
        end
        if num < iconMaxNum then
            return math.ceil(iconMaxNum / Pack.iconNum)
        else
            return #self.mData
        end
        
    end
end

function PackView:selelctPage()
	local selectedIndex = self.mainController.selectedIndex
    mgr.ItemMgr:setPackIndex(0)
	if selectedIndex == 0 then--装备区域
        self:prosBtnEnbled()
        self:refreshEquipPanel()

        if self.see == 0 then
            self.btn.icon = "ui://pack/beibao_102"
            
        else
            self.btn.icon = "ui://_buttons/huoban_027"
        end

        mgr.ItemMgr:setPackIndex(Pack.equipIndex)
        self:setPackPageData()
	elseif selectedIndex == 1 then--商店区域
        self:prosBtnEnbled()
        self:refreshShopPanel()
        mgr.ItemMgr:setPackIndex(Pack.shopIndex)
        self:setPackPageData()
	elseif selectedIndex == 2 then--仓库区域
        self:prosBtnEnbled()
        if #cache.PackCache:getWareData() <= 0 then
           proxy.PackProxy:sendWareMsg() 
        else
            self:refreshWarePanel()
        end
        mgr.ItemMgr:setPackIndex(Pack.wareIndex)
        self:setPackPageData()
	end
end

function PackView:prosBtnEnbled(key)
   for k,v in pairs(self.prosBtnList) do
        v.enabled = true
        if key then
            if k ~= key then
                v.enabled = false
                v.selected = false
                local ctrl = v:GetController("button")
                ctrl.selectedIndex = 0
            else
                v.selected = true
            end
        end
    end
end

--刷新装备区域
function PackView:refreshEquipPanel()
    if self.see == 0 then
        self.equipPanel:setData()
    else
        -- print(table.nums(cache.PackCache:getXianEquipData()),"@@@")
        -- local t =cache.PackCache:getXianEquipData()
        -- for k ,v in pairs(t) do
        --     print(k,v)
        -- end
        self.equipPanel:setData(cache.PackCache:getXianEquipData() or {})
    end
end
--刷新商店区域
function PackView:refreshShopPanel()
    self.shopPanel:setData()
end
--刷新仓库区域
function PackView:refreshWarePanel()
    self.warePanel:setData()
end
--整理仓库
function PackView:refreshCleanWare()
    self.warePanel:refreshCleanWare()
end
--手动开启
function PackView:onClickOpen(context)
    local index = context.sender.data.index
    local money = 0
    local text = ""
    if index > 1 then
        local items = {}
        for i=1,index do
            local id = self.girdOpenNum + i
            local data = conf.PackConf:getPackGird(id)
            for k,v in pairs(data.items) do--统计道具
                if not items[v[1]] then
                    items[v[1]] = 0
                end
                items[v[1]] = items[v[1]] + v[2]
            end
            local costMoney = data and data.cost_gold or  0
            money = money + costMoney
        end

        local str = language.getDec2
        for k,v in pairs(items) do
            str = str..v..conf.ItemConf:getName(k)
        end
        text = string.format(language.gonggong15, money, index)..","..str
    else--如果是时间格子
        local id = self.girdOpenNum + index
        local data = conf.PackConf:getPackGird(id)
        local str = ""
        for k,v in pairs(data.items) do
            str = str..v[2]..conf.ItemConf:getName(v[1])
        end
        local time = data.cost_sec - context.sender.data.time
        local timeStr = GTotimeString(time)
        text = string.format(language.pack13, timeStr,data.cost_gold)..str
    end
    local param = {type = 9,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        proxy.PackProxy:sendOpenGird({reqType = 2,openNum = index})
    end}
    GComAlter(param)
end

--密码锁
function PackView:onClickPwd()
	mgr.ViewMgr:openView(ViewName.PasswordView)
end
--整理
function PackView:onClickClean()
	local params = {seq = Pack.pack}
	proxy.PackProxy:sendCleanPackMsg(params)
end
--EVE 一键吞噬
function PackView:onClickSynthesis()
    --屏蔽了~~
    -- GOpenView({id = 1006,childIndex = 1})
    if self.packController.selectedIndex == 3 then
        mgr.ViewMgr:openView2(ViewName.FSFenJieView)
    else
        mgr.ViewMgr:openView2(ViewName.HuobanExpPop,{})
    end
   
end

function PackView:releaseTimer()
    if self.cdTimer then
        self:removeTimer(self.cdTimer)
        self.cdTimer = nil
    end
end

--cd倒计时
function PackView:onTimer()
    local leftTime = mgr.NetMgr:getServerTime() - self.oldCleanCdTime
    if leftTime >= cleanCDTime then
        self:releaseTimer()
        self.prosCdImg.fillAmount = 0
        return
    end
    if self.cdActionTime then
        self.cdActionTime = self.cdActionTime - 0.2
        self.prosCdImg.fillAmount = self.cdActionTime / cleanCDTime
    end
end

--装备星级属性
function PackView:onClickStarAtt()
    mgr.ViewMgr:openView2(ViewName.StarAttrView, {})
end

function PackView:closeView()
    self.pageList.numItems = 0
    mgr.ItemMgr:setPackIndex(0)
    self.equipPanel:clear()
    self.super.closeView(self)
end

function PackView:onClickClose()
    self:closeView()
end

function PackView:setTimeInterval(timeInterval,maxInter)
    self.timeInterval = timeInterval
    self.maxInter = maxInter
    self:setPackPageData()
end

function PackView:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if "n33" == btn.name then
        --仙装
        if self.see == 0 then
            self.see = 1
            btn.icon = "ui://_buttons/huoban_027"
        else
            self.see = 0
            btn.icon = "ui://pack/beibao_102" 
        end
        self:refreshEquipPanel()
    elseif "n46" == btn.name then
        --print("是否勾选")
        local number = 0
        if btn.selected then
            number = 1
        end
        proxy.FeiShengProxy:sendMsg(1580103,{reqType = 2,type = number })
    end
end

function PackView:addMsgCallBack(data)
    -- body
    if 5580101 == data.msgId or 5580102 ==  data.msgId then
        --刷新一下
        self:prosPage()
        self:refreshEquipPanel()
        self.view:GetChild("n31"):GetChild("n24").visible = mgr.ModuleMgr:CheckView({id = 1325})
        self.btn.visible = mgr.ModuleMgr:CheckView({id = 1325})
    elseif 5580103 ==  data.msgId then
        self.xianselectbtn.selected = data.type
    end
end

return PackView