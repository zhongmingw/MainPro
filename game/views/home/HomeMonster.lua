--
-- Author: 
-- Date: 2017-11-25 10:47:50
--

local HomeMonster = class("HomeMonster", base.BaseView)
local _type = 4001
local _level = "zooLev"
function HomeMonster:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function HomeMonster:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n2")
    self:setCloseBtn(btnClose)

    local btn1 = self.view:GetChild("n33")
    btn1.title = language.home79

    local btn1 = self.view:GetChild("n34")
    btn1.title = language.home80

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    --饲养灵兽
    local btnGuize = self.view:GetChild("n39")
    btnGuize.onClick:Add(self.onGuize,self)

    self._name = self.view:GetChild("n40")
    self._name.text = ""

    local btnLeft = self.view:GetChild("n30")
    btnLeft.data = -1
    btnLeft.onClick:Add(self.onDirCall,self)

    local btnright = self.view:GetChild("n29")
    btnright.data = 1
    btnright.onClick:Add(self.onDirCall,self)

    self.img1 = self.view:GetChild("n60")
    self.img2 = self.view:GetChild("n61")

    self.listView = self.view:GetChild("n43")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0

    self.bar = self.view:GetChild("n48")
    self.bar.value = 0
    self.bar.max = 0

    self.callcout = self.view:GetChild("n50") 
    self.callcout.text = ""
    local btnUp = self.view:GetChild("n44")
    btnUp.title = language.home84
    btnUp.onClick:Add(self.onCall,self)

    self.feed1 = self.view:GetChild("n46")
    self.feed1.onClick:Add(self.onFeedNormal,self)


    self.feed2 = self.view:GetChild("n45")
    self.feed2.onClick:Add(self.onFeed,self)

    self.dec1 = self.view:GetChild("n51") 
    self.dec1.text = language.home68 .. ":"
    self.icon1 = self.view:GetChild("n52") 
    self.dec2 = self.view:GetChild("n54") 
    self.dec2.text = language.home68 .. ":"
    self.icon2 = self.view:GetChild("n55") 

    self.add1 = self.view:GetChild("n62") 
    self.add1.text = ""
    self.add2 = self.view:GetChild("n63") 
    self.add2.text = ""

    self.need1 = self.view:GetChild("n53") 
    self.need1.text = ""
    self.need2 = self.view:GetChild("n56")
    self.need2.text = ""

    self.panel = self.view:GetChild("n59")
    --升级兽园
    local dec1 = self.view:GetChild("n16") 
    dec1.text = language.home02
    local dec1 = self.view:GetChild("n17") 
    dec1.text = language.home82
    local dec1 = self.view:GetChild("n18") 
    dec1.text = language.home04
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.home05
    local dec1 = self.view:GetChild("n24")
    dec1.text = language.home83 --home83 

    self.homename = self.view:GetChild("n20")
    self.homename.text = ""

    self.homelv = self.view:GetChild("n21")
    self.homelv.text = ""

    self.homeneed = self.view:GetChild("n22")
    self.homeneed.text = ""

    self.cost = self.view:GetChild("n23") 
    self.cost.text = ""

    self.money = self.view:GetChild("n25")
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.home)

    self.desc = self.view:GetChild("n31") 
    self.desc.text = ""

    -- self.listView_1 = self.view:GetChild("n32")
    -- self.listView_1.itemRenderer = function(index, obj)
    --     self:cellMonsterData(index, obj)
    -- end
    -- self.listView_1.numItems = 0

    local btnUp = self.view:GetChild("n14")
    btnUp.onClick:Add(self.onHouseUp,self)
    self.btnUp = btnUp

    local btnPlus = self.view:GetChild("n5")
    btnPlus.onClick:Add(self.onPlus,self)
end

function HomeMonster:cellData( index, obj )
    -- body
    local data = self.reward[index+1]
    local _t = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(obj,_t,true)
end

function HomeMonster:cellMonsterData( param, obj )
    -- body
    local data = param

    local panel = obj:GetChild("n1")
    local monsterId = data.mmid
    --print("monsterId",monsterId)
    local mConf = conf.MonsterConf:getInfoById(monsterId)
    if not obj.data then
        obj.data = self:addModel(mConf["src"],panel)--添加模型
        obj.data:setPosition(panel.actualWidth/2,-panel.actualHeight-200,500)
        obj.data:setRotation(180)
        obj.data:setScale(70)
    else
        obj.data:setSkins(mConf["src"])
    end
    
end

function HomeMonster:setModel(index)
    -- body
    local info1 = self.listinfo[index]
    local info2 = self.listinfo[index+1]
    
    self:cellMonsterData(info1,self.img1)
    self:cellMonsterData(info2,self.img2)
end

function HomeMonster:onDirCall(context)
    -- body
    local data = context.sender.data
    self.index = self.index + data 
    if self.index < 1 then
        self.index = 1
    elseif self.index >= self.max then
        self.index = self.max - 1
    end

    self:setModel(self.index)
end

function HomeMonster:initData(data)
    -- body
    self.model = nil 
    self.img1.data = nil 
    self.img2.data = nil 
    self.c1.selectedIndex = data or 0
    self:onController1()

    proxy.HomeProxy:sendMsg(1460114,{reqType = 0})
end

function HomeMonster:onController1()
    -- body
end

function HomeMonster:initModel(id)
    -- body
    local mConf = conf.MonsterConf:getInfoById(id)
    local bodySrc = mConf["src"]
    if not self.model then
        self.model = self:addModel(bodySrc, self.panel)
    else
        self.model:setSkins(bodySrc)
    end
    self.model:setScale(80)
    self.model:setRotation(180)
    self.model:setPosition(self.panel.actualWidth/2,-self.panel.actualHeight-200,500)
end



function HomeMonster:setData(data_)
    --饲养灵兽
    

    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.home)
    local confdata = conf.HomeConf:getBossLev(self.monster.lev)
    local mConf = conf.MonsterConf:getInfoById(confdata.monster_ref[1])
    self._name.text = mConf.name 

    self:initModel(confdata.monster_ref[1])
    self.add1.text ="+"..conf.HomeConf:getValue("boss_item_exp")
    self.add2.text ="+"..confdata.add_exp

    local nextconfdata = conf.HomeConf:getBossLev(self.monster.lev+1)

    self.reward = confdata.hate_items or {}
    self.listView.numItems = #self.reward  

    self.bar.value = self.monster.exp
    self.bar.max = nextconfdata and nextconfdata.need_exp or self.bar.value

    self.maxcout = conf.HomeConf:getValue("day_boss_call_max")
    self.callcout.text = language.home81..self.monster.callCount .. "/"..self.maxcout

    local _condatacost = conf.HomeConf:getValue("boss_item_cost") 
    --print("_condatacost[1]",_condatacost[1])
    local aa = cache.PackCache:getPackDataById(_condatacost[1][1])
    self.need1.text = aa.amount.."/".._condatacost[1][2]
    if aa.amount < _condatacost[1][2] then
        self.needitem = true
    else
        self.needitem = false
    end

    if nextconfdata then
        self.feed1.visible = true
        self.dec1.text = language.home68 .. ":"
        self.icon1.visible = true

        if confdata.cost_money then
            local aa = cache.PlayerCache:getTypeMoney(MoneyType.gold)
            self.need2.text = aa.."/"..confdata.cost_money
            if aa < confdata.cost_money then
                self.needmoney = true
            else
                self.needmoney = false
            end
            self.feed2.visible = true
            self.dec2.text = language.home68 .. ":"
            self.icon2.visible = true
        else
            self.need2.text = ""
            self.feed2.visible = false
            self.dec1.text = ""
            self.icon2.visible = false
        end
    else
        self.need1.text = ""
        self.feed1.visible = false
        self.dec1.text = ""
        self.icon1.visible = false

        self.need2.text = ""
        self.feed2.visible = false
        self.dec2.text = ""
        self.icon2.visible = false
    end

    

    --升级兽园
    self.homename.text = self.data.homeName
    self.homelv.text = string.format(language.home64,self.data.zooLev)

    self.condata = conf.HomeConf:getHomeLev(_type,self.data.zooLev)
    --print(_type,self.data.zooLev)
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
    self.max = condata.maxlv
    for i = condata.lev , self.max do
        local index = _type * 1000 + i
        local _iii = conf.HomeConf:getSkins(index)
        table.insert(self.listinfo,_iii)
    end
    -- self.listView_1.numItems =  condata.maxlv
    -- local index = math.min(self.data.zooLev,self.listView_1.numItems-1)
    -- self.listView_1:AddSelection(index,false)
    self.index = self.data.zooLev
    if self.index >= self.max then
        self.index = 1
    end
    self:setModel(self.index)

    if self.data.zooLev + 1 > self.max then
        self.btnUp.visible = false
    else
        self.btnUp.visible = true
    end
    
end

function HomeMonster:onFeedNormal()
    -- body
    if not self.monster then
        return
    end
    local confdata = conf.HomeConf:getBossLev(self.monster.lev+1)
    if not confdata then
        GComAlter(language.home108)
        return
    end
    if self.monster.lev >= self.data[_level] then
        GComAlter(language.home126)
        return
    end
    local param = {}
    param.reqType = 1
    proxy.HomeProxy:sendMsg(1460114,param)
end


function HomeMonster:onFeed()
    -- body
    if not self.monster then
        return
    end
    local confdata = conf.HomeConf:getBossLev(self.monster.lev+1)
    if not confdata then
        GComAlter(language.home108)
        return
    end
    if self.monster.lev >= self.data[_level] then
        GComAlter(language.home126)
        return
    end

    local param = {}
    param.reqType = 2
    proxy.HomeProxy:sendMsg(1460114,param)
end

function HomeMonster:onCall()
    -- body
    if not self.data then
        return
    end
    if self.monster.lev == 0 then
        GComAlter(language.home101)
        return
    elseif self.maxcout == self.monster.callCount then
        GComAlter(language.home102)
        return
    end

    local param = {}
    param.reqType = 3 
    proxy.HomeProxy:sendMsg(1460114,param)
    self:closeView()
end

function HomeMonster:onGuize()
    -- body
    GOpenRuleView(1063)
end

function HomeMonster:onHouseUp()
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


    -- if not self.data then
    --     return
    -- end

    -- local condata = conf.HomeConf:getHomeLev(4001,self.data.zooLev+1)
    -- if not condata then
    --     GComAlter(language.home66)
    --     return
    -- end
    -- if not G_HomeComponstCon(condata,self.data,true) then
    --     return
    -- end


    -- local param = {}
    -- param.reqType = _type
    -- proxy.HomeProxy:sendMsg(1460105,param)
end

function HomeMonster:add5460114(data)
    -- body
    self.data = cache.HomeCache:getData()
    self.monster = data

    self:setData()
end


function HomeMonster:add5460105()
    -- body
    self.data = cache.HomeCache:getData()
    self:setData()
end

function HomeMonster:onPlus()
    -- body
    if not self.data then
        return
    end
    GOpenView({id = 1159})
end





return HomeMonster