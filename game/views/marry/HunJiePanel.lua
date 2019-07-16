--
-- Author: 
-- Date: 2018-08-13 11:07:20
--

local HunJiePanel = class("HunJiePanel",import("game.base.Ref"))

function HunJiePanel:ctor(mParent)
    self.mParent = mParent
    self.view = self.mParent.view:GetChild("n13")
    self:initView()
end

function HunJiePanel:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c2 = self.view:GetController("c2")
    self.c3 = self.view:GetController("c3")

    self.hunjiename = self.view:GetChild("n10")
    self.curjie = self.view:GetChild("n12")
    self.icon = self.view:GetChild("n63")
    self.icon1 = self.view:GetChild("n59")
    self.cupname = self.view:GetChild("n60")

    self.power = self.view:GetChild("n21")

    self.btn1 = self.view:GetChild("n489")
    self.btn1.data = -1 
    self.btn1.onClick:Add(self.onBtnClickCallBack,self)

    self.btn2 = self.view:GetChild("n488")
    self.btn2.data = 1
    self.btn2.onClick:Add(self.onBtnClickCallBack,self)

    self.listpro = self.view:GetChild("n41")
    self.listpro.itemRenderer = function(index,obj)
        self:cellprodata(index, obj)
    end
    self.listpro.numItems = 0

    self.xing = self.view:GetChild("n99"):GetController("c1")
    self.itemObj = self.view:GetChild("n46")
    self.itemName = self.view:GetChild("n47")
    self.itemneed = self.view:GetChild("n48")
    self.btnPlus = self.view:GetChild("n49")
    self.btnPlus.onClick:Add(self.onBtnClickCallBack,self)
    local btn = self.view:GetChild("n50")
    self.btnjie = btn
    btn.onClick:Add(self.onBtnClickCallBack,self)

    local btnGuize = self.view:GetChild("n37")
    btnGuize.onClick:Add(self.onBtnClickCallBack,self)

    self.jihuotext = self.view:GetChild("n64")
end

function HunJiePanel:setVisible(flag)
    -- body
    self.view.visible = flag
end

function HunJiePanel:onBtnClickCallBack(context)
    -- body
    if not self.data then return end
    local btn = context.sender
    local data = btn.data 
    if btn.name == "n489" or "n488" ==  btn.name then
        local index = math.max(self.index + data,1)
        index = math.min(index,self.max)
        --按阶跳转
        self:setData(index)
    elseif btn.name == "n49" then
        local param = {}
        param.mId = data
        GGoBuyItem(param)
    elseif btn.name == "n50" then
        --跳转到进阶
        if self.data.ringLev == 0 then
            proxy.MarryProxy:sendMsg(1390202)
        else
            self.mParent:goToUPpanel()
        end
    elseif btn.name == "n37" then
        GOpenRuleView(1128)
    end
end

function HunJiePanel:cellprodata( index, obj)
    -- body
    local data = self.protable[index+1]
    local lab = obj:GetChild("n1")

    local dec = conf.RedPointConf:getProName(data[1]) .. " ".. GProPrecnt(data[1],checkint(data[2]))
    lab.text = dec
end

function HunJiePanel:setModel( id )
    -- body
    if self.effect then
        self.mParent:removeUIEffect(self.effect)
        self.effect = nil 
    end

    self.effect = self.mParent:addEffect(id, self.icon)
    self.effect.Scale = Vector3.New(100,100,100)
    self.effect.LocalPosition = Vector3(50,-77,500)
end

function HunJiePanel:setData(index)
    -- body
    if not index then
        index = 1
    elseif index < 1 then
        index = 1
    end
    self.c3.selectedIndex = index
    self.index = index
    local condata = conf.MarryConf:getRingItemByJie(index)
    self.hunjiename.text = condata.name
    self.curjie.text = string.format(language.huoban24,language.gonggong21[index])

    self:setModel(condata.icon)
    --self.icon.url = "ui://marry/"..condata.icon
    self.icon1.url = "ui://marry/"..condata.icon1
    
    if index<= 1 then
        self.btn1.visible = false
    else
        self.btn1.visible = true  
    end

    if index >= self.max then
        self.btn2.visible = false
    else
        self.btn2.visible = true  
    end
end


function HunJiePanel:addMsgCallBack(data)
    -- body
    if 5390201 == data.msgId then
        self.data = data 
    elseif 5390202 == data.msgId then  
        self.data.ringLev = data.ringLev
    end
    
    self.max = conf.MarryConf:getValue("endjie") 
    self.condata = conf.MarryConf:getRingItem(self.data.ringLev)
    --策划要求 0级 读取一级属性
    if self.data.ringLev == 0 then
        local condata = conf.MarryConf:getRingItem(1)
        self.protable = GConfDataSort(condata)
    else
        self.protable = GConfDataSort(self.condata)
    end
    self.listpro.numItems = #self.protable

    self.power.text = self.condata.power
    self:setData(self.condata.step)

    local str = cache.PlayerCache:getCoupleName()
    if str == "" then
        str = language.hunjie02
    end
    if cache.PlayerCache:getSex() == 1 then
        str = str .. language.hunjie03
    else
        str = str .. language.hunjie04
    end
    self.cupname.text = str

    if self.condata.star == 0 then
        self.xing.selectedIndex = 0
    else
        if 5390201 == data.msgId then
            self.xing.selectedIndex = self.condata.star + 10
        else
            self.xing.selectedIndex = self.condata.star
        end
    end

    if cache.MarryCache:getIsNext() then
        self.c1.selectedIndex = 0
        local t = {}
        if self.condata.item_cost then
            t.mid = self.condata.item_cost[1]
            t.isquan = true
            t.amount = 1
            self.btnPlus.data = t.mid
            self.itemName.text = mgr.TextMgr:getColorNameByMid(t.mid)
            local packdata = cache.PackCache:getPackDataById(t.mid)
            local ss = ""
            if packdata.amount >= self.condata.item_cost[2] then
                ss = mgr.TextMgr:getTextColorStr(packdata.amount, 7)
                self.btnjie:GetChild("red").visible = true
            else
                ss = mgr.TextMgr:getTextColorStr(packdata.amount, 14)
                self.btnjie:GetChild("red").visible = false
            end
            ss = ss .. "/"..mgr.TextMgr:getTextColorStr(self.condata.item_cost[2], 7)
            self.itemneed.text = ss

            local str = language.zuoqi81 .. mgr.TextMgr:getTextColorStr(self.condata.item_cost[2], 7)
            str = str .. mgr.TextMgr:getColorNameByMid(t.mid)
            self.jihuotext.text = str
        else
            self.btnPlus.data = nil
            self.itemName.text = ""
            self.itemneed.text = ""
            self.jihuotext.text = ""
        end
        if self.btnPlus.data then
            self.btnPlus.visible = true
        else
            self.btnPlus.visible = false
        end

        GSetItemData(self.itemObj,t,true)

        if self.data.ringLev == 0 then
            self.c2.selectedIndex = 0
            self.view:GetChild("n99").visible = false
            self.jihuotext.visible = true
        else
            self.c2.selectedIndex = 1
            self.view:GetChild("n99").visible = true
            self.jihuotext.visible = false
        end
    else
        self.c1.selectedIndex = 1
        self.btnPlus.visible = false
    end

    --刷新一下红点
    local num = 0
    if self.c1.selectedIndex == 0 and self.btnjie:GetChild("red").visible then
        num = 1
    end
    mgr.GuiMgr:redpointByVar(10264,num,2)
end

return HunJiePanel