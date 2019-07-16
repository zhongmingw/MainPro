--
-- Author: 
-- Date: 2018-08-09 11:09:48
--

local XianTongDelete = class("XianTongDelete", base.BaseView)

function XianTongDelete:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function XianTongDelete:initView()
    local btn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(btn)
    local btn = self.view:GetChild("n4")
    self:setCloseBtn(btn)

    self.dec = self.view:GetChild("n2") 

    self.listView = self.view:GetChild("n3")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    --self.listView:SetVirtual()
    self.listView.numItems = 0

    local btnsure = self.view:GetChild("n5")
    btnsure.onClick:Add(self.onBtnCallBack,self)
end

function XianTongDelete:celldata(index, obj)
    -- body
    local data = self.release_reback_item[index+1]
    GSetItemData(obj, data, true)
end

function XianTongDelete:initData(data)
    self.data = data 
    local confdata = conf.MarryConf:getPetItem(self.data.xtId)
    self.dec.text = string.format(language.xiantong18,self.data.name)
    --本身释放返回
    self.release_reback_item = {}
    if confdata.release_reback_item then
        for k , v in pairs(confdata.release_reback_item) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(self.release_reback_item,_t)
        end
    end
    --+等级返回
    local colorData = conf.MarryConf:getXTlev(self.data.level)
    if colorData and colorData.release_reback_item then
        for k , v in pairs(colorData.release_reback_item) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(self.release_reback_item,_t)
        end
    end
    --装备返回
    for i ,j in pairs(self.data.equipInfo) do
        local confdata = conf.MarryConf:getEquipByLev(i,j)
        for k , v in pairs(confdata.release_reback_item) do
            local _t = {mid =v[1],amount = v[2]  ,bind = v[3]}
            table.insert(self.release_reback_item,_t)
        end
    end


    self.listView.numItems = #self.release_reback_item 
end

function XianTongDelete:onBtnCallBack()
    -- body
    local param = {}
    param.xtRoleId = self.data.xtRoleId
    proxy.MarryProxy:sendMsg(1390607,param)
    self:closeView()
end

return XianTongDelete