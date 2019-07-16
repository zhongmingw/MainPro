--
-- Author: 
-- Date: 2018-02-26 14:52:21
--
--符文寻宝
local RuneXunbao = class("RuneXunbao",import("game.base.Ref"))

function RuneXunbao:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function RuneXunbao:initPanel()
    local panelObj = self.mParent.view:GetChild("n67")
    self.c1 = panelObj:GetController("c1")
    self.bg = panelObj:GetChild("n0")
    self.listView = panelObj:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    panelObj:GetChild("n10").text = language.rune10

    self.btnXunOne = panelObj:GetChild("n6")--寻宝一次
    self.btnXunOne.data = 1
    self.btnXunOne.onClick:Add(self.onClickXunbao,self)
    self.btnXunTen = panelObj:GetChild("n7")--寻宝10次
    self.btnXunTen.data = 10
    self.btnXunTen.onClick:Add(self.onClickXunbao,self)
    self.btnXun50 = panelObj:GetChild("n14")--寻宝50次
    self.btnXun50.data = 50
    self.btnXun50.onClick:Add(self.onClickXunbao,self)

    local btnPack = panelObj:GetChild("n8")
    btnPack.onClick:Add(self.onClickPack,self)
    local btnShop = panelObj:GetChild("n9")
    btnShop.onClick:Add(self.onClickShop,self)

    self.freeDesc = panelObj:GetChild("n11")
end
--寻宝信息
function RuneXunbao:setData(data)
    self.leftFreeTimes = data.leftFreeTimes or 0--剩余免费次数
    self:setXunbaoCount()
    self.lastUpdateTime = data and data.lastUpdateTime or 0--上次免费次数更新时间
    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    end
    self.packRune = {}
    local towerMaxLevel = data.towerMaxLevel
    self.towerMaxLevel = towerMaxLevel
    if towerMaxLevel >= conf.RuneConf:getFuwenGlobal("fuwen_double_pass") then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
    self.fwTypes = conf.RuneConf:getFuwenGlobal("fuwen_fwtypes")
    self.listView.numItems = #self.fwTypes
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    self.imgPath = UIItemRes.rune01
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end
--设置寻宝次数
function RuneXunbao:setXunbaoCount()
    local xunbaoId = conf.RuneConf:getFuwenGlobal("fuwen_xunbao_itemid")
    local packData = cache.PackCache:getPackDataById(xunbaoId)
    local amount = packData and packData.amount or 0
    self.haveKeyAmount = amount
    --10次
    local color = 14
    if amount >= 10 then color = 7 end 
    self.btnXunTen.title = mgr.TextMgr:getTextColorStr(amount, color).."/"..mgr.TextMgr:getTextColorStr(10, 7)
    --50次
    local color = 14
    if amount >= 50 then color = 7 end 
    self.btnXun50.title = mgr.TextMgr:getTextColorStr(amount, color).."/"..mgr.TextMgr:getTextColorStr(50, 7)
    if self.leftFreeTimes > 0 then
        self.btnXunOne:GetController("c1").selectedIndex = 1
        self.btnXunOne.title = mgr.TextMgr:getTextColorStr(language.rune11, 7)
    else
        self.btnXunOne:GetController("c1").selectedIndex = 0
        local color = 7
        if amount < 1 then--1次
            color = 14
            mgr.GuiMgr:redpointByVar(attConst.A10259,0)
            self.mParent:refreshRed()
        end 
        self.btnXunOne.title = mgr.TextMgr:getTextColorStr(amount, color).."/"..mgr.TextMgr:getTextColorStr(1, 7)
    end
end
--寻宝返回
function RuneXunbao:severXunbao(data)
    self.leftFreeTimes = data.leftFreeTimes or 0--剩余免费次数
    self:setXunbaoCount()
    data.index = 2
    mgr.ViewMgr:openView2(ViewName.RuenDekaronView, data)
    proxy.RuneProxy:send(1500201) --符文寻宝
end
--已解锁的符文
function RuneXunbao:cellData(index,obj)
    local fwType = self.fwTypes[index + 1]
    local listView = obj:GetChild("n5")
    local data = conf.ItemConf:getRuneItemsByType(fwType,self.towerMaxLevel)
    listView.itemRenderer = function(index,item)
        local holeInfo = data[index + 1]
        local rune = item:GetChild("n0")
        rune:GetController("c1").selectedIndex = 2
        rune.icon = mgr.ItemMgr:getItemIconUrlByMid(holeInfo.id)
        local color = conf.ItemConf:getQuality(holeInfo.id)
        local name = conf.ItemConf:getName(holeInfo.id)
        item:GetChild("n1").text = mgr.TextMgr:getQualityStr1(name.."Lv.1",color)
        item.visible = true
        item.data = holeInfo
        item.onClick:Add(self.onClickRune,self)
    end
    listView.numItems = #data
end

function RuneXunbao:getTowerMaxLevel()
    return self.towerMaxLevel or 0
end

function RuneXunbao:onClickRune(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.RuneIntroduceView, data)
end

function RuneXunbao:clear()
    self.bg.url = ""
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function RuneXunbao:onTimer()
    local sec = conf.RuneConf:getFuwenGlobal("fuwen_free_time_refresh")[2]
    local time = self.lastUpdateTime + sec - mgr.NetMgr:getServerTime()
    if time < 0 then
        time = 0
    end
    self.freeDesc.text = mgr.TextMgr:getTextColorStr(GTotimeString(time), 7)..language.rune12
end
--寻宝
function RuneXunbao:onClickXunbao(context)
    local index = context.sender.data
    local alertSelect = cache.ActivityCache:getXunBaoAlert()
    local data = {haveKeyAmount = self.haveKeyAmount,needKeyAmount = index , times = index,msg = 1500203,mid = conf.RuneConf:getFuwenGlobal("fuwen_xunbao_itemid") ,moduleId = 1217,alertSelect = alertSelect}
    if index == 1 then
        if self.leftFreeTimes > 0 then
            proxy.RuneProxy:send(1500203,{times = index})
            return
        end
    end
    if self.haveKeyAmount < index and not alertSelect then
        mgr.ViewMgr:openView2(ViewName.HintView,data)--提示弹窗
    else
        proxy.RuneProxy:send(1500203,{times = index})
    end
end

function RuneXunbao:onClickPack()
    mgr.ViewMgr:openView2(ViewName.RunePackView)
end

function RuneXunbao:onClickShop()
    GOpenView({id = 1214})
end

return RuneXunbao