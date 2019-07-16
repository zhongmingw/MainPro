--
-- Author: 
-- Date: 2017-08-09 17:52:35
--

local PanelWar = class("PanelWar",import("game.base.Ref"))

function PanelWar:ctor(param)
    self.view = param
    self:initView() 
end

function PanelWar:initView()
    -- body
    self.bg = self.view:GetChild("n3")

    local dec1 = self.view:GetChild("n5")
    dec1.text = language.kuafu114
    local dec2 = self.view:GetChild("n6")
    dec2.text = language.kuafu115
    local dec3 = self.view:GetChild("n7")
    dec3.text = language.kuafu116
    --开启等级
    local dec4 = self.view:GetChild("n8")
    dec4.text = string.format(language.kuafu117,conf.KuaFuConf:getValue("sanjie_limit_level") or 1)
    local dec5 = self.view:GetChild("n13")
    dec5.text = language.kuafu118

    local dec6 = self.view:GetChild("n12")
    -- local condata = conf.RuleConf:getRuleById(1044)
    -- local ruleDesc = condata.desc
    -- local str="[color="..ruleDesc[2][1][1].."]"..ruleDesc[2][1][3].."[/color]"
    --dec6.text = mgr.TextMgr:getTextByTable(param) --language.kuafu119

    dec6.text = mgr.TextMgr:getTextColorStr(language.zhangchang04,10,"") --str --EVE
    dec6.onClickLink:Add(self.onClickGuize,self)

    local dec7 = self.view:GetChild("n14")
    dec7.text = language.kuafu121

    local dec8 = self.view:GetChild("n19")
    dec8.text = language.kuafu120

    self.money = self.view:GetChild("n20")

    local btnOnWar = self.view:GetChild("n17")
    btnOnWar.onClick:Add(self.onWar,self)

    local btnShop = self.view:GetChild("n22")
    btnShop.onClick:Add(self.onShop,self)

    self.listView = self.view:GetChild("n16")
    --self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
end

--EVE 新添规则弹窗
function PanelWar:onClickGuize()
    GOpenRuleView(1044)
end

function PanelWar:setBg()
    -- body
    self.bg.url =  UIItemRes.kuafu .. "sanjiezhengba_015"
end

function PanelWar:setWillOpen()
    -- body
    self.willopen = true
    local temp = os.date("*t",cache.KuaFuCache:isWillOpenByid(3)) 
    local str = ""
    str = str .. temp.month .. language.gonggong79
    str = str .. temp.day  .. language.gonggong80 ..language.kuafu109

    self.str = str
end

function PanelWar:cellData( index, obj )
    -- body
    local data = self.reward[index+1]
    local _t = {mid = data[1],amount = data[2] ,bind =data[3]}
    GSetItemData(obj,_t,true)
end
function PanelWar:onTimer( ... )
    -- body
    if not self.data then
        return
    end
    if self.data.openSign == 0 then
        self.data.openLeftTime = math.max(0,self.data.openLeftTime - 1) 
        if self.data.openLeftTime == 0 and not self.requst then
            self.requst = true
            proxy.KuaFuProxy:sendMsg(1410101)
        end
    end
end
function PanelWar:onWar()
    -- body
    if self.willopen then
        GComAlter(self.str)
        return
    end
    if not self.data then
        plog("self.jhBtn")
        return
    end
    
    local var = cache.PlayerCache:getRoleLevel()
    local openlv = conf.KuaFuConf:getValue("sanjie_limit_level") or 1
    if openlv > var then
        GComAlter( string.format(language.gonggong07,openlv) )
        return
    end
    if self.data.openSign == 0 then
        GComAlter(language.kuafu144)
        return
    end

    mgr.FubenMgr:gotoFubenWar(Fuben.kuafuwar)
end

function PanelWar:setData()
    -- body
    

    --设置奖励
    self.reward = conf.KuaFuConf:getValue("sanjie_reward")
    if self.reward then
        self.listView.numItems = #self.reward 
    else
        self.listView.numItems = 0
    end
    --设置功勋
    self.money.text = cache.PlayerCache:getTypeMoney(MoneyType.sw)
end

function PanelWar:onShop()
    -- body
    GOpenView({id = 1119})
end

function PanelWar:addMsgCallBack( data)
    -- body
    self.willopen = false 
    if data.msgId == 5410101 then
        self.data = data
        if self.data.openSign == 0 then
            self.requst = false
        end
        self:setData()
    end
end
return PanelWar