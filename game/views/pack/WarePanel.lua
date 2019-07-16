--仓库区域
local WarePanel = class("WarePanel",import("game.base.Ref"))

local cleanCDTime = 10

function WarePanel:ctor(mParent)
	self.mParent = mParent
    self:initPanel()
end

function WarePanel:initPanel()
    self.oldCleanCdTime = 0
    local panelObj = self.mParent.view:GetChild("panel_ware")
	self.wareList = panelObj:GetChild("n19")
    self.wareList:SetVirtual()
    self.wareList.itemRenderer = function(index,obj)
        self:cellWareData(index, obj)
    end
    self.wareList.scrollPane.onScrollEnd:Add(self.onPackScrollPage, self)

    self.pageBtnList = panelObj:GetChild("n18")
    self.pageBtnList:SetVirtual()
    self.pageBtnList.itemRenderer = function(index,btnObj)
        btnObj.data = index
    end
    self.pageBtnList.onClickItem:Add(self.onClickPackPage,self)
    local btnClean = panelObj:GetChild("n13")
    btnClean.onClick:Add(self.onClickClean, self)
    self.prosCdImg = btnClean:GetChild("n6").asImage
    self.prosCdImg.fillAmount = 0
end

function WarePanel:refreshCleanWare()
    self.oldCleanCdTime = mgr.NetMgr:getServerTime()
    self:setData()
end

function WarePanel:setData()
    if not self.cdTimer then--整理cd
        self.cdActionTime = cleanCDTime - (mgr.NetMgr:getServerTime() - self.oldCleanCdTime)
        self:onTimer()
        self.cdTimer = self.mParent:addTimer(0.2, -1, handler(self,self.onTimer))
    end
    self.mData = cache.PackCache:getWareData()
    local numItems = self:getNumItems()
    if numItems <= 0 then
        numItems = 1
    end
    -- GComAlter({type = 9,close = true})
    self.girdOpenNum = cache.PackCache:getGridKeyData(attConst.wareNum)--上一次仓库开启的格子
    self.lastOpenTime = cache.PackCache:getGridKeyData(attConst.wareTime)--上一次仓库开启的时间
    self.wareSec = cache.PackCache:getGridKeyData(attConst.wareSec)
    --数据列表
    self.wareList.numItems = numItems
    --分页btn
    self.pageBtnList.numItems = numItems
    if self.pageIndex then
        self:setScorllToView(self.pageIndex)
    end
    self:onPackScrollPage()
end

function WarePanel:cellWareData( pageIndex, iconPanel )
    local itemList = iconPanel:GetChild("n0")
    local iconInitNum = conf.SysConf:getValue("init_house_grid")
    local girdOpenNum = self.girdOpenNum + iconInitNum
    for i=1,Pack.iconNum do
        local girdNum = i + pageIndex * 16--当前第几格
        local iconObj = iconPanel:GetChild("n"..i)
        local frame = iconObj:GetChild("n6")
        local unlockObj = iconObj:GetChild("n4")--密码锁
        local proObj = iconObj:GetChild("n5")--item
        proObj.visible = false
        frame.visible = true
        if girdNum <= girdOpenNum then
            unlockObj.visible = false
            local data = self.mData--对应的数据
            local iconIndex = Pack.ware + pageIndex * Pack.iconNum + i
            
            if data and data[iconIndex] then
                frame.visible = false
                local _t = clone(data[iconIndex])
                _t.isquan = true
                --_t.isneed = cache.PlayerCache:getIsNeed(_t.mid)
                _t.isdone = cache.PlayerCache:getIsNeed(_t.mid)
                if _t.isdone == 1 then
                    --背包只显示是否多余
                    _t.isdone = 1
                else
                    _t.isdone = nil
                end

                GSetItemData(proObj,_t,true)--设置道具信息
            end
        else
            local girdIndex = girdNum - girdOpenNum
            self:unlockBar(unlockObj,girdIndex)
        end
    end
end

function WarePanel:unlockBar(obj,index)
    obj.visible = true
    obj.data = {timer = 0,index = index}
    local curValue = 0
    local maxValue = 100
    obj.onClick:Add(self.onClickOpen,self)
    obj.value = curValue
    obj.max = maxValue
end

function WarePanel:getNumItems()
    local num = 0
    for _,data in pairs(self.mData) do
        num = num + 1
    end
    local iconMaxNum = conf.SysConf:getValue("max_house_grid")
    return math.ceil(iconMaxNum / Pack.iconNum)
end
--选页
function WarePanel:onClickPackPage(context)
    local btnObj = context.data
    local index = btnObj.data
    self:setScorllToView(index)
end

function WarePanel:setScorllToView( index )
    self.wareList:ScrollToView(index,true)
end

function WarePanel:onPackScrollPage()
    local index = self.wareList.scrollPane.currentPageX
    if self.pageBtnList.numItems > 0 then
        self.pageBtnList:AddSelection(index,true)
        self.pageIndex = index
    end
end

function WarePanel:onClickClean()
    local params = {seq = Pack.ware}
    proxy.PackProxy:sendCleanPackMsg(params)
end

--手动开启
function WarePanel:onClickOpen(context)
    local index = context.sender.data.index
    local money = 0
    local items = {}
    for i=1,index do
        local id = self.girdOpenNum + i
        local data = conf.PackConf:getWareGird(id)
        if data.items then
            for k,v in pairs(data.items) do--统计道具
                if not items[v[1]] then
                    items[v[1]] = 0
                end
                items[v[1]] = items[v[1]] + v[2]
            end
        end
        local costMoney = data and data.cost_gold or  0
        money = money + costMoney
    end
    --获得道具描述
    local str = language.getDec2
    for k,v in pairs(items) do
        str = str..v..conf.ItemConf:getName(k)
    end

    local text = string.format(language.gonggong15, money, index)
    local param = {type = 9,richtext = mgr.TextMgr:getTextColorStr(text, 11),sure = function()
        proxy.PackProxy:sendOpenGird({reqType = 4,openNum = index})
    end}
    GComAlter(param)
end

function WarePanel:releaseTimer()
    if self.cdTimer then
        self.mParent:removeTimer(self.cdTimer)
        self.cdTimer = nil
    end
end

--cd倒计时
function WarePanel:onTimer()
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

return WarePanel