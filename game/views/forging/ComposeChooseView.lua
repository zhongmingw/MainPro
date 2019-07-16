--
-- Author: 
-- Date: 2017-09-24 15:05:03
--

local ComposeChooseView = class("ComposeChooseView", base.BaseView)

function ComposeChooseView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true 
end

function ComposeChooseView:initView()
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

    self.titleicon = self.view:GetChild("n4")

end

function ComposeChooseView:initData(data)
    -- body
    self.data = data
    self.listdata = {}
    for k ,v in pairs(data.listdata) do
        for i , j in pairs(v) do
            table.insert(self.listdata,j)
        end
    end

    self._selectlist = {}
    for k ,v in pairs(data.btnlist) do
        if v.data.data then
            self._selectlist[v.data.data.index] = v.data.data
        end
    end


    self.listView.numItems = #self.listdata

    self.maxNum = 5
    self.titleicon.url = "ui://forging/hecheng_008"
    if self.data.composedata and self.data.composedata.type == 18 then
        self.maxNum = 3
        self.titleicon.url = "ui://forging/hecheng_0027"
    elseif self.data.composedata.type == 23 or self.data.composedata.type == 24 
            or self.data.composedata.type == 25 then
        self.maxNum = 3
    elseif self.data.composedata and self.data.composedata.type == 21 or self.data.composedata.type == 22
        or (self.data.composedata.type == 6 and self.data.composedata.color == 7) then
        self.maxNum = 3
    elseif self.data.composedata and self.data.composedata.type == 7 and self.data.composedata.color == 7 then
        self.maxNum = 1
    end

end

function ComposeChooseView:check(data)
    -- body
    if not data then
        return false
    end
    --local color =  conf.ItemConf:getStagelvl(data.mid)
    local confdata = conf.ItemConf:getItem(data.mid)
    for k ,v in pairs(self._selectlist) do
        if v then
            local _cc  = conf.ItemConf:getItem(v.mid)
            if _cc.color == confdata.color and confdata.stage_lvl == _cc.stage_lvl  then
                return true
            else
                return false
            end
        end
    end

    return true
end

function ComposeChooseView:celldata(index, obj)
    -- body
    local data = self.listdata[index+1]
    local itemObj = obj:GetChild("n0")
    local _t = clone(data)--{mid = data.mid,amount = 1,bind = 0}
    _t.isquan = true 
    GSetItemData(itemObj,_t)
    local condata = conf.ItemConf:getItem(data.mid)

    local name = obj:GetChild("n1")
    name.text = mgr.TextMgr:getColorNameByMid(data.mid)

    local lab = obj:GetChild("n2")
    if condata.type == Pack.equipType then 
        lab.text = string.format(language.equip01,condata.stage_lvl)
    elseif condata.type == Pack.equippetType then 
        lab.text = language.gonggong83..data.level
    else
        lab.text = ""
    end

    local radio = obj:GetChild("n6") 
    if self._selectlist[data.index] then
        radio.selected = true
    else
        radio.selected = false
    end
    radio.data = data
    radio.onClick:Clear()
    radio.onClick:Add(self.onClickRadio, self)
end

function ComposeChooseView:onClickRadio(context)
    -- body
    local radio = context.sender
    local data = radio.data


    if radio.selected then
        if table.nums(self._selectlist) >= self.maxNum then
            radio.selected = false
            GComAlter(language.forging50)
            return
        end
        if self:check(data) then
            self._selectlist[data.index] = clone(data)
        else
            radio.selected = false
            GComAlter(language.forging52)
        end
    else
        self._selectlist[data.index] = nil 
    end
end

function ComposeChooseView:setData(data_)

end

function ComposeChooseView:onCloseView( ... )
    -- body
    --物品信息设置
    self.data.callback(clone(self._selectlist))
    self:closeView()
end

return ComposeChooseView