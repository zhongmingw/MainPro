--
-- Author: 
-- Date: 2018-02-22 16:49:59
--
--符文背包
local RunePackView = class("RunePackView", base.BaseView)

function RunePackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
    self.openTween = ViewOpenTween.scale
end

function RunePackView:initView()
    local closeBtn = self.view:GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.onClickItem:Add(self.onClickItem,self)

    self.packCount = self.view:GetChild("n8")--背包容量

    local runeBtn = self.view:GetChild("n9")
    runeBtn.onClick:Add(self.onClickRune,self)
end

function RunePackView:initData(data)
    proxy.RuneProxy:send(1500101)
    self.mData = data
    
end

function RunePackView:setData(data)
    self.fwDatas = data and data.fwDatas or cache.RuneCache:getPackData()
    self.listView.numItems = #self.fwDatas
    
    local maxCount = conf.RuneConf:getFuwenGlobal("fuwen_pack_max_size")
    self.packCount.text = language.rune06..mgr.TextMgr:getTextColorStr(#self.fwDatas.."/"..maxCount, 7)
end

function RunePackView:cellData(index, obj)
    local data = self.fwDatas[index + 1]
    local item = obj:GetChild("n0")
    item:GetController("c1").selectedIndex = 2
    item.icon = mgr.ItemMgr:getItemIconUrlByMid(data.mid)
    obj:GetChild("n3").text = mgr.RuneMgr:getRuneName(data)
    local id = mgr.RuneMgr:getDataAttiId(data)
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
    local text = obj:GetChild("n7")
    local cons = conf.ItemConf:getContainType(data.mid)
    local equip = cache.RuneCache:getEquipFwDataByType(cons)
    if equip then
        text.visible = true
    else
        text.visible = false
    end
    obj.data = data
end

function RunePackView:onClickItem(context)
    if self.mData then
        local data = context.data.data
        proxy.RuneProxy:send(1500102,{reqType = 1,srcIndexs = {data.index},dstIndexs = {self.mData.hole}})
        self:closeView()
    end
end

function RunePackView:onClickRune()
    GOpenView({id = 1218})
end

return RunePackView