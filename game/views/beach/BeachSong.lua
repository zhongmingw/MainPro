--
-- Author: 
-- Date: 2018-01-03 17:03:44
--
local effectId = 4020137
local BeachSong = class("BeachSong", base.BaseView)

function BeachSong:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
end

function BeachSong:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)
    --self:setCloseBtn(btnClose)

    self.title =  self.view:GetChild("n9")
    self.title.text = ""

    local btn1 = self.view:GetChild("n4")
    btn1.data = 1
    btn1.onClick:Add(self.onClickLiwu,self)
    self.value1 = self.view:GetChild("n12")
    self.value1.text = ""
    self.condata1 = conf.BeachConf:getPresentcost(1)
    if self.condata1 then
        self.value1.text = string.format(language.beach18,self.condata1.ml_value)
    end

    local btn2 = self.view:GetChild("n5")
    btn2.data = 2
    btn2.onClick:Add(self.onClickLiwu,self)
    self.value2 = self.view:GetChild("n11")
    self.value2.text = ""
    self.condata2 = conf.BeachConf:getPresentcost(2)
    if self.condata2 then
        self.value2.text = string.format(language.beach18,self.condata2.ml_value)
    end

    self._yaamount = self.view:GetChild("n15")
    self._yaamount.text = "0"
    self._feizaoamount = self.view:GetChild("n16")
    self._feizaoamount.text = "0"

    local btnSong = self.view:GetChild("n1")
    btnSong.onClick:Add(self.onSong,self)

    local dec1 = self.view:GetChild("n10")
    dec1.text = language.beach17
    local dec1 = self.view:GetChild("n13")
    dec1.text = language.beach19
    local dec1 = self.view:GetChild("n14")
    dec1.text = language.beach20

    self._panel1 = self.view:GetChild("n19")
    --self:setEffect(self._panel1)
    self._panel2 = self.view:GetChild("n18")
    --self:setEffect(self._panel2)
end

function BeachSong:setEffect( _panel )
    -- body
    if self.effect then
        self:removeUIEffect(self.effect)
        self.effect = nil 
    end

    self.effect = self:addEffect(effectId, _panel)
    self.effect.LocalPosition = Vector3.New(_panel.width/2,0,0)
end

function BeachSong:initData(data)
    -- body
    self.selectedIndex = 2 --默认选择小黄鸭
    self:setEffect(self._panel1)

    self.data = data

    local _str = clone(language.beach16)
    _str[2].text = string.format(_str[2].text,data.name)
    self.title.text = mgr.TextMgr:getTextByTable(_str)

    self:setData()
    
end

function BeachSong:setData()
    -- body
    --小黄鸭数量
    self._yadata = cache.BeachCache:getXiaoYazi()
    --self._yaamount.text = self._yadata.amount
    local color = 7
    if self.condata1.present_cost > self._yadata then
        color = 14
    else
        color = 7
    end
    self._yaamount.text = mgr.TextMgr:getTextColorStr(self._yadata, color)
    --肥皂数量
    self._feidata =  cache.BeachCache:getFeizhao()
    if self.condata2.present_cost > self._feidata then
        color = 14
    else
        color = 7
    end
    self._feizaoamount.text = mgr.TextMgr:getTextColorStr(self._feidata, color)
end

function BeachSong:onClickLiwu(context)
    -- body
    if not self.data then
        return
    end
    local btn = context.sender
    local data = btn.data
    if not data then
        return
    end
    self.selectedIndex = tonumber(data)
    --print("self.selectedIndex",self.selectedIndex)
    if self.selectedIndex == 1 then
        self:setEffect(self._panel2)
    else
        self:setEffect(self._panel1)
    end
end

function BeachSong:onSong()
    -- body
    if not self.data then
        return
    end
    local param = {}
    param.reqType = 1
    param.roleId = self.data.roleId
    param.cid = self.selectedIndex 
    if self.selectedIndex == 1 then
        if self.condata1.present_cost > self._yadata then
            GComAlter(language.beach21)
            return    
        end
    else
        if self.condata2.present_cost > self._feidata then
            GComAlter(language.beach22)
            return
        end
    end

    proxy.BeachProxy:sendMsg(1020423,param)
    --self:closeView()
end

function BeachSong:addMsgCallBack(data)
    -- body
    if data.msgId == 5020423 then
        self:setData()
    end
end

function BeachSong:onCloseView()
    -- body
    local view = mgr.ViewMgr:get(ViewName.BeachRank)
    if view then
        view:onController1()
    end
    self:closeView()
end



return BeachSong