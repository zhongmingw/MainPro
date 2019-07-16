--
-- Author: wx
-- Date: 2017-10-19 20:13:41
-- 批量删除

local BangPlChooseView = class("BangPlChooseView", base.BaseView)

function BangPlChooseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BangPlChooseView:initView()
    local btnClose = self.view:GetChild("n1"):GetChild("n2")
    btnClose.onClick:Add(self.onCloseView,self)

    local btnLevel = self.view:GetChild("n3")
    btnLevel.onClick:Add(self.onLevelCall,self)

    local btnColor = self.view:GetChild("n4")
    btnColor.onClick:Add(self.onColorCall,self)

    local btnStart = self.view:GetChild("n5")
    btnStart.onClick:Add(self.onStartCall,self)
    --筛选组件
    self.Panel = self.view:GetChild("n17")
    self._bgPanle = self.view:GetChild("n11")
    
    self.listPanel = self.view:GetChild("n18")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)

    self.listView = self.view:GetChild("n7")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    self.listView.scrollPane.onScroll:Add(self.doSpecialEffectPack, self)

    self.pageText = self.view:GetChild("n9")
    self.pageText.text = ""
end

function BangPlChooseView:initData(data)
    -- body
    self.data = data

    self:setData()
end

function BangPlChooseView:setData(data_)
    self.call = nil 
    self.level = 1 --
    self.color = 0 --所有品质
    self.Panel.visible = false

    self.packinfo = clone(self.data)
    self:setListViewData()
end

function BangPlChooseView:setListViewData()
    -- body
    self.listView.numItems = math.max(1,math.ceil(#self.packinfo/16)) 
    self.listView:ScrollToView(0,false)
    self:doSpecialEffectPack()
end

function BangPlChooseView:cellData( index, obj )
    -- body
    local _16data = {} --16个格子数据
    local start = (index)*16+1
    for i = start , start + 16 do
        if not self.packinfo[i] then
            break
        end
        table.insert(_16data,self.packinfo[i])
    end
    local number = #_16data

    local listView = obj:GetChild("n0")
    listView.itemRenderer = function(_index,_obj)
        local c1 = _obj:GetController("c1")
        local _data = _16data[_index+1]
        _obj.data = _data
        if _index + 1 <= number and _data and _data.amount>0 then
            c1.selectedIndex = 1 --有道具
            local t = clone(_data)
            GSetItemData(_obj:GetChild("n0"),t)
        else
            c1.selectedIndex = 0
        end
    end
    listView.numItems = 16
    --listView.onClickItem:Add(self.onCallBackPack,self)
end

function BangPlChooseView:doSpecialEffectPack()
    -- body
    local index = self.listView.scrollPane.currentPageX
    self.pageText.text = (index + 1).."/"..self.listView.numItems
end

function BangPlChooseView:choose()
    -- body
    --开始筛选
    self.packinfo = {}
    self.indexs = {}
    for k ,v in pairs(self.data) do
        local flag = true
        local confdata = conf.ItemConf:getItem(v.mid)
        if self.level and self.level ~= 1 then
            --限制装备阶
            if (confdata.stage_lvl or 0) > (self.level+2)  then
                flag = false --不满足
            end 
        end

        if flag and self.color and self.color ~= 0 then
            if (confdata.color or 0) ~= self.color + 3 then
                flag = false
            end
        end

        if flag then
            table.insert(self.indexs,v.index)
            table.insert(self.packinfo,v)
        end 
    end

    self:setListViewData()
end

function BangPlChooseView:cellPanelData(index, obj)
    -- body
    obj.data = index + 1 
    obj.title = language.bangpai163[self.call][index+1]
end



function BangPlChooseView:onlistPanel(context)
    -- body
    local data = context.data.data
    if self.call == 1 then
        self.level = data
    else
        self.color = data
    end
    self:choose(self.level,self.color)
    self.Panel.visible = false
end

function BangPlChooseView:callset( btn )
    -- body
    self.Panel.x = btn.x + (btn.width - self.Panel.width)/2
    self.Panel.y = btn.y + btn.height + 2
    self.Panel.visible = true

    self.listPanel.numItems = #language.bangpai163[self.call]
    if self.call == 1 then
        self._bgPanle.height = 383
        if self.level then
            self.listPanel:AddSelection(self.level-1,false)
        end
    else
        self._bgPanle.height = 142

        if self.color then
            self.listPanel:AddSelection(self.color-1,false)
        end
    end
end

function BangPlChooseView:onLevelCall(context)
    -- body
    local btn = context.sender 
    if self.call and self.call == 1 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 1
    self:callset(btn)
end

function BangPlChooseView:onColorCall(context)
    -- body 品质
    local btn = context.sender 
    if self.call and self.call == 2 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 2
    self:callset(btn)
end

function BangPlChooseView:onStartCall()
    -- body
    if not self.indexs then
        GComAlter(language.bangpai151)
        return
    end
    if #self.indexs <= 0 then
        GComAlter(language.bangpai151)
        return
    end
    local param = {
    type = 2,
    richtext = mgr.TextMgr:getTextColorStr(language.bangpai150, 6)
    ,sure = function()
        proxy.BangPaiProxy:send(1250408,{reqType = 1,tars = self.indexs})
        self:onCloseView()
    end}
    GComAlter(param)
end

function BangPlChooseView:onCloseView()
    -- body
    self:closeView()
end

return BangPlChooseView