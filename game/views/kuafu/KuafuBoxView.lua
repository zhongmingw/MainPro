--
-- Author: 
-- Date: 2017-10-16 10:47:32
--

local KuafuBoxView = class("KuafuBoxView", base.BaseView)

function KuafuBoxView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 

    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function KuafuBoxView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n5")
    btnClose.onClick:Add(self.onCloseView,self)

    self.c1 = self.view:GetController("c1")
    self.listbtn = {}
    for i = 4 , 8 do
        local btn = self.view:GetChild("n"..i)
        --self:setInfo(btn,i-6)
        table.insert(self.listbtn,btn)
    end

    local btnRandom = self.view:GetChild("n3")
    btnRandom.onClick:Add(self.onRandom,self)

    local btnSetMax = self.view:GetChild("n2")
    btnSetMax.onClick:Add(self.onSetMax,self)



    --寻宝次数
    self.curPass = self.view:GetChild("n14") 
    --需要元宝数量
    self.cost = self.view:GetChild("n12") 

    self:initDec()
end

function KuafuBoxView:initDec()
    -- body
    self.view:GetChild("n15").text = language.kuafu162
    self.view:GetChild("n16").text = language.kuafu163
    self.view:GetChild("n13").text = language.kuafu164
    self.view:GetChild("n11").text = language.kuafu137
end

function KuafuBoxView:initData()
    -- body
    self.level_coef = conf.KuaFuConf:getValue("box_level_coef")
    self.base_add = conf.KuaFuConf:getValue("box_base_add_value")
    self.max_box_cost = conf.KuaFuConf:getValue("max_box_cost")

    self.cost.text = self.max_box_cost
    for k ,v in pairs(self.listbtn) do
        self:setInfo(v,k)
    end

    self:setData()
end

function KuafuBoxView:setInfo(btn,i)
    -- body
    local condata = conf.KuaFuConf:getSjzbBox(i)
    if not condata then
        btn.visible = false
        plog("配置丢失",i)
        return
    end
    btn.visible = true

    local _color = {5,10,1,15,3}
    
    local _name = btn:GetChild("n7")
    _name.text = mgr.TextMgr:getTextColorStr(condata.name, _color[i]) 

    btn:GetController("c1").selectedIndex = i - 1

    local _gongxun = btn:GetChild("n8") 
    local _icon1 = btn:GetChild("n4")

    if condata.finish_item and condata.finish_item[1] then
        _gongxun.text = condata.finish_item[1][2]
        _icon1.visible = true
    else
        _gongxun.text = ""
        _icon1.visible = false
    end

    local _exp = btn:GetChild("n9") 
    local _icon2 = btn:GetChild("n5")
    
    _icon2.visible = true
    local level = cache.PlayerCache:getRoleLevel()
    local expvalue = math.floor((level*self.level_coef+self.base_add)*condata.exp_coef/100)
    _exp.text = string.format("%.1f",expvalue/10000)..language.gonggong52
end

function KuafuBoxView:setData(data_)
    self.zone = cache.KuaFuCache:getZone()
    self.data = cache.KuaFuCache:getTaskCache(3)
    local _t = conf.KuaFuConf:getSjzbTask(3)
    self.maxPass = _t and _t.limit_count or 1
    --当前完成了几次
    self.curPass.text = self.data.curCount.."/"..self.maxPass

end

function KuafuBoxView:onRandom()
    -- body --随机寻宝
    if not self.data then
        return
    end

    local param = {}
    param.type = 1
    proxy.KuaFuProxy:sendMsg(1410203,param)

    self:onCloseView()
end

function KuafuBoxView:onSetMax()
    -- body --高级寻宝
    if not self.data then
        return
    end

    local param = {}
    param.type = 2
    proxy.KuaFuProxy:sendMsg(1410203,param)

    self:onCloseView()
end

function KuafuBoxView:onCloseView( ... )
    -- body
    self:closeView()
end

return KuafuBoxView