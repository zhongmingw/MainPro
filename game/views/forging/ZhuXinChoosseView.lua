--
-- Author: 
-- Date: 2017-12-06 20:53:44
--

local ZhuXinChoosseView = class("ComposeChooseView", base.BaseView)

function ZhuXinChoosseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true 
end

function ZhuXinChoosseView:initView()
    local btnClose = self.view:GetChild("n0"):GetChild("n2")
    btnClose.visible = false
    --btnClose.onClick:Add(self.onCloseView,self)

    local btnSure = self.view:GetChild("n6")
    btnSure.onClick:Add(self.onCloseView,self)

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0
end

function ZhuXinChoosseView:initData(data)
    -- body
    self.cc = data.selectdata 
    self.data = data.data
    self.callback = data.callback
    --获取指定部位的装备
    self.info = data.info
    local pack = cache.PackCache:getPackData()
    self.listdata = {}

    local _info = conf.ItemConf:getItem(self.info.mid)
    for k ,v in pairs(pack) do
        local confdata = conf.ItemConf:getItem(v.mid)
        if confdata.part == _info.part 
        and mgr.ItemMgr:getColorBNum(v) == 1 
        and confdata.stage_lvl == _info.stage_lvl
        and confdata.color == _info.color then
            table.insert(self.listdata,v)
        end
    end

    self.listView.numItems = #self.listdata
end

function ZhuXinChoosseView:celldata( index, obj )
    -- body
    local data = self.listdata[index+1]
    local itemObj = obj:GetChild("n0")
    local _t = clone(data)
    _t.index = 0
    _t.isquan = true 
    GSetItemData(itemObj,_t,true)
    local condata = conf.ItemConf:getItem(data.mid)

    local name = obj:GetChild("n1")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local lab = obj:GetChild("n2")
    lab.text = string.format(language.equip01,condata.stage_lvl)

    
    local radio = obj:GetChild("n6") 
    radio.data = data
    radio.onClick:Clear()
    radio.onClick:Add(self.onClickRadio, self)
    if self.cc and self.cc.index == data.index then
        radio.selected = true
    else
        radio.selected = false
    end

end

function ZhuXinChoosseView:onClickRadio(context)
    -- body
    local radio = context.sender
    local data = radio.data

    if radio.selected then
        if self.cc and self.cc.index == data.index then 
            return
        end
        self.cc = data
        self:onCloseView()
    else
        self.cc = nil 
    end
end

function ZhuXinChoosseView:setData(data_)
    

    
end

function ZhuXinChoosseView:onCloseView()
    -- body
    --物品信息设置
    if self.callback then
        self.callback(self.cc)
    end

    self:closeView()
end

return ZhuXinChoosseView