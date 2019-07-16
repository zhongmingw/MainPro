--
-- Author: 
-- Date: 2017-11-27 10:51:54
--

local HomeSpringView = class("HomeHouse", base.BaseView)

local _type = 3001
local _level = "hotSpringLev"
local _tilteicon = "jiayuan_105"

function HomeSpringView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomeSpringView:initView()
    self.window4 = self.view:GetChild("n0")
    local btnClose = self.window4:GetChild("n2")
    self:setCloseBtn(btnClose)

    self.window4.icon = UIItemRes.home2.._tilteicon

    local btnUp = self.view:GetChild("n4")
    btnUp.onClick:Add(self.onHouseUp,self)

    local btnPlus = self.view:GetChild("n3")
    btnPlus.onClick:Add(self.onPlus,self)

    self.listView = self.view:GetChild("n12")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItemCall,self)
    self.listView.numItems = 0

    self:initDec()
end

function HomeSpringView:initDec()
    -- body
    local dec1 = self.view:GetChild("n12")
    dec1.text = language.home02

    local dec1 = self.view:GetChild("n14")
    dec1.text = language.home133

    local dec1 = self.view:GetChild("n15")
    dec1.text = language.home04

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.home05

    local dec1 = self.view:GetChild("n21")
    dec1.text = language.home104 

    self.homename = self.view:GetChild("n17")
    self.homename.text = ""

    self.homelv = self.view:GetChild("n18")
    self.homelv.text = ""

    self.homeneed = self.view:GetChild("n19")
    self.homeneed.text = ""

    self.cost = self.view:GetChild("n20") 
    self.cost.text = ""

    self.money = self.view:GetChild("n22")
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.home)

    self.desc = self.view:GetChild("n23") 
    self.desc.text = ""
end

function HomeSpringView:initData()
    -- body
    self:setData()
end

function HomeSpringView:cellData(index, obj)
    -- body
    local data = self.listinfo[index+1]
    local icon = obj:GetChild("n0") 
    icon.url = UIItemRes.home2..data.icon

    local lv = data.id % 1000

    local title = obj:GetChild("n1") 
    title.text = data.name

    obj.data = data
end

function HomeSpringView:setData(data_)
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.home)
    self.data = cache.HomeCache:getData()

    
    self.condata = conf.HomeConf:getHomeLev(_type,self.data[_level])

    self.homename.text = self.data.homeName
    self.homelv.text = string.format(language.home64,self.data[_level])
    --print("id",id)
    local nextcondata = conf.HomeConf:getHomeLev(_type,self.data[_level]+1)
    local s = ""
    if nextcondata  then
        if nextcondata.con then
            for k , v in pairs(nextcondata.con) do
                s = s..string.format(language.home65[v[1]],v[2])..";"
            end
        end
        self.cost.text = self.condata.cost and self.condata.cost[2] or ""
    else
        self.cost.text = language.skill08
    end 
    self.homeneed.text = s

    --self.cost.text = self.condata.cost and self.condata.cost[2] or ""

    local _cc = conf.HomeConf:getSkins(_type*1000+self.data[_level]) 
    self.desc.text = _cc.desc or ""


    local condata = conf.HomeConf:getHomeThing(_type)
    self.listinfo = {}
    for i = condata.lev , condata.maxlv do
        local index = _type * 1000 + i
        local _iii = conf.HomeConf:getSkins(index)
        table.insert(self.listinfo,_iii)
    end
    self.listView.numItems =  condata.maxlv

    local index = math.min(self.data[_level]-1,self.listView.numItems-1)
    self.listView:ScrollToView(math.max(0,index),false)
end

function HomeSpringView:onClickItemCall(context)
    -- body
    local data = context.data.data
end

function HomeSpringView:onHouseUp()
    -- body
    if not self.data then
        return
    end
   local nextconfdata = conf.HomeConf:getHomeLev(_type,self.data[_level]+1)
    if not nextconfdata then
        GComAlter(language.home66)
        return
    end

    if not mgr.HomeMgr:checkComponentCon(nextconfdata,self.data,true) then
        return
    end

    local function callback()
        -- body
        local sendParam = {}
        sendParam.reqType = _type
        proxy.HomeProxy:sendMsg(1460105,sendParam)
        self:closeView()
    end

    if self.condata.cost then
        local ss = clone(language.home117)
        ss[2].text = string.format(ss[2].text,self.condata.cost[2])

        local param = {}
        param.type = 2
        param.richtext = mgr.TextMgr:getTextByTable(ss)
        param.sure = function()
            -- body
            callback()
        end
        GComAlter(param)
    else
        callback()
    end 
end

function HomeSpringView:onPlus()
    -- body
    if not self.data then
        return
    end
    GOpenView({id = 1159})
end




return HomeSpringView