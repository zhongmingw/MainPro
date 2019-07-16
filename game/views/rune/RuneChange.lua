--
-- Author: 
-- Date: 2018-02-22 14:35:09
--
--符文兑换
local RuneChange = class("RuneChange",import("game.base.Ref"))

function RuneChange:ctor(mParent,moduleId)
    self.mParent = mParent
    self.moduleId = moduleId
    self:initPanel()
end

function RuneChange:initPanel()
    local panelObj = self.mParent:getChoosePanelObj(self.moduleId)
    self.listView = panelObj:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.spText = panelObj:GetChild("n5")
    self.spText.text = 0
    panelObj:GetChild("n2").text = language.rune09
end

function RuneChange:setData(data)
    self.spNum = data and data.spNum or 0
    self.spText.text = self.spNum
    self.towerMaxLevel = data and data.towerMaxLevel or 0
    self.shops = conf.RuneConf:getFuwenShops()
    self.listView.numItems = #self.shops
    GOpenAlert3(data.items)
end

function RuneChange:cellData(index,obj)
    local data = self.shops[index + 1]
    local item = data.item
    local mid = item[1]
    local item = obj:GetChild("n0")
    item:GetController("c1").selectedIndex = 2
    item.icon = mgr.ItemMgr:getItemIconUrlByMid(mid)
    obj:GetChild("n6").text = mgr.TextMgr:getColorNameByMid(mid)
    local color = conf.ItemConf:getQuality(mid)
    local type = conf.ItemConf:getFwType(mid)
    local id = mgr.RuneMgr:getAttiId(color,type,1)
    local confData = conf.RuneConf:getFuwenlevelup(id)
    local attriTexts = {}
    table.insert(attriTexts, obj:GetChild("n1"))--符文属性加成1
    table.insert(attriTexts, obj:GetChild("n2"))--符文属性加成2
    attriTexts[1].text = ""
    attriTexts[2].text = ""
    local t = GConfDataSort(confData)
    for k,v in pairs(t) do
        attriTexts[k].text = conf.RedPointConf:getProName(v[1]).."+"..mgr.TextMgr:getTextColorStr(GProPrecnt(v[1],v[2]), 7)
    end
    local needfwsp = data.need_fwsp or 0
    local tabStr = {
        {text = "【",color = 6},
        {url = UIPackage.GetItemURL("rune" , "fuwen_019")},
        {text = needfwsp,color = 7},
        {text = "】",color = 6},
    }
    obj:GetChild("n4").text = mgr.TextMgr:getTextByTable(tabStr)
    local btn = obj:GetChild("n3")
    btn.data = data
    btn.onClick:Add(self.onClickChange,self)
    if self.spNum >= needfwsp then
        btn.enabled = true
    else
        btn.enabled = false
    end
    if self.towerMaxLevel < data.fw_tower then
        obj:GetChild("n7").text = string.format(language.rune31, data.fw_tower)
    else
        obj:GetChild("n7").text = ""
    end
end

function RuneChange:onClickChange(context)
    local data = context.sender.data
    if self.towerMaxLevel < data.fw_tower then
        GComAlter(string.format(language.rune31, data.fw_tower))
        return
    end
    proxy.RuneProxy:send(1500202,{reqType = 2, cid = data.id,amount = 1})
end

return RuneChange