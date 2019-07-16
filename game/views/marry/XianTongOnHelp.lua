--
-- Author: 
-- Date: 2018-07-23 17:08:09
--

local XianTongOnHelp = class("XianTongOnHelp", base.BaseView)

function XianTongOnHelp:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianTongOnHelp:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btnOnBatton = self.view:GetChild("n16")
    btnOnBatton.data = 1
    btnOnBatton.onClick:Add(self.onBatton,self)

    local btnOnBatton = self.view:GetChild("n17")
    btnOnBatton.data = 2
    btnOnBatton.onClick:Add(self.onBatton,self)

    self.friendlist = self.view:GetChild("n12")
    self.friendlist.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.friendlist.numItems = 0
    self.friendlist.onClickItem:Add(self.onCallBack,self)  

    self.xiantonglist = self.view:GetChild("n14")
    self.xiantonglist:SetVirtual()
    self.xiantonglist.itemRenderer = function(index,obj)
        self:cellXianTongdata(index, obj)
    end
    self.xiantonglist.numItems = 0
    self.xiantonglist.onClickItem:Add(self.onXtCallBack,self)  

    self.view:GetChild("n8").text = language.pet66
    self.view:GetChild("n11").text = language.xiantong32
end

function XianTongOnHelp:initData(data)
    -- body
    self.data = data
    self.pos = data.id
    local xiantongConf = conf.MarryConf:getXianTongZhuZhanById(data.id)
    self.zwType = xiantongConf.zw_type--阵位类型
    local zwConf = conf.MarryConf:getXianTongZhenWeiById(self.zwType)
    self.view:GetChild("n8").text = zwConf.battle_name
    local xiantongData = cache.MarryCache:getXTData()
    self.xiantongData = {}
    for k ,v in pairs(xiantongData) do
        self.xiantongData[v.xtRoleId] = v
    end
    self:setData()

    self:setposinfo()
    
end

function XianTongOnHelp:setData()
    self.friendlist.numItems = self.zwType
    self.friendlist:AddSelection(self.pos%100-1,false)
end

function XianTongOnHelp:onXtCallBack( context )
    -- body
    self.select = context.data.data
end

function XianTongOnHelp:cellXianTongdata( index, obj )
    -- body
    local data = self.listdata[index+1]
    obj.data = data
    local c1 = obj:GetController("c1")
    if not data then
        c1.selectedIndex = 1
        return
    end
    c1.selectedIndex = 0
    local condata = conf.MarryConf:getPetItem(data.xtId)
    local t = {}
    t.color = condata.color
    t.url = ResPath.iconRes(condata.src)
    t.isCase = true
    GSetItemData(obj:GetChild("n5"), t)
    local nameTxt = obj:GetChild("n1")
    nameTxt.text = mgr.TextMgr:getQualityStr1(condata.name, condata.color)

    local score = obj:GetChild("n4")
    score.text = data.power or 0
end

function XianTongOnHelp:celldata( index, obj )
    -- body
    local key = 10000 + self.zwType*100 + index+1
    local data = self.data.warXtData[key]
    local itemObj = obj:GetChild("n5")  
    itemObj.visible = false
    local c1 = obj:GetController("c1")
    if data then
        c1.selectedIndex = 0
        if self.xiantongData[data] then
            itemObj.visible = true
            local condata = conf.MarryConf:getPetItem(self.xiantongData[data].xtId)
            local t = {}
            t.color = condata.color
            t.url = ResPath.iconRes(condata.src)
            t.isCase = true
            GSetItemData(itemObj, t)
        end
    else
        c1.selectedIndex = 1
    end

    obj.selected = false
    obj.data = key
end

function XianTongOnHelp:onCallBack( context )
    -- body
    self.pos = context.data.data
    self:setposinfo()
    if not self.data.warXtData[self.pos] then
        local t = {}
        t.id = self.pos
        local xiantongConf = conf.MarryConf:getXianTongZhuZhanById(self.pos)
        if not xiantongConf.pre_id or (xiantongConf.pre_id and self.data.warXtData[xiantongConf.pre_id]) then
            mgr.ViewMgr:openView2(ViewName.XianTongOpenPos, t)
        else
            GComAlter(language.xiantong39)
        end
    end
end

function XianTongOnHelp:onBatton(context)
    -- body
    if not self.data then
        return
    end
    if not self.pos  then
        return
    end
    if not self.data.warXtData[self.pos] then
        return GComAlter(language.xiantong34)
    end
    
    local param = {}
    param.reqType = context.sender.data
    param.pos = self.pos 
    
    local reqType = context.sender.data
    if reqType == 2 then
        --召唤
        if self.data.warXtData[self.pos] == 0 then
            return GComAlter(language.xiantong41)
        end
        param.petId = self.data.warXtData[self.pos]
        proxy.MarryProxy:sendMsg(1390610,param)
        return
    end
    if not self.select then
        return GComAlter(language.xiantong33)
    end
    --上阵
    param.petId = self.select.xtRoleId 

    proxy.MarryProxy:sendMsg(1390610,param)
end

function XianTongOnHelp:setposinfo()
    -- body
    local info = conf.MarryConf:getXianTongZhuZhanById(self.pos)
    local t = {}
    for k , v in pairs(self.data.warXtData) do
        if v~= 0 then
            t[v] = 1
        end
    end
    --筛选
    self.listdata = {}
    for k ,v in pairs(self.xiantongData) do
        if v.xtRoleId ~= cache.MarryCache:getCurpetRoleId() and not t[v.xtRoleId] then
            table.insert(self.listdata,v)
        end
    end

    mgr.XianTongMgr:sortPet(self.listdata)

    local  number = #self.listdata
    number = math.max(4,math.ceil(number/4)*4) 

    self.xiantonglist.numItems = number
    self.xiantonglist:SelectNone()
end

function XianTongOnHelp:addMsgCallBack(data)
    -- body
    if data.msgId == 5390610 then
        self.data.warXtData = data.warXtData
        self.select = nil 
        self:setData()
        self:setposinfo()
    elseif data.msgId == 5390611  then
        self.data.warXtData[data.pos] = 0
        self:setData()
    end
end


return XianTongOnHelp