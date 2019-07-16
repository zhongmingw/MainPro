--
-- Author: bxp
-- Date: 2017-12-06 20:21:09
--

local LimitWareView = class("LimitWareView", base.BaseView)

function LimitWareView:ctor()
    LimitWareView.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function LimitWareView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    local getOutBtn = self.view:GetChild("n3") --一键取出
    getOutBtn.onClick:Add(self.onClickBtn,self)
    self.listView = self.view:GetChild("n1")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellWareData(index, obj)
    end

end

function LimitWareView:setData(data_)
    if not data_ then return end
    self.data = data_
    self.itemInfos = self.data.itemInfos
    if #self.itemInfos <= 32 then --32 临时仓库满屏item个数
        local subItem = 32 - #self.itemInfos
        for i=1,subItem do
            table.insert(self.itemInfos,{})
        end
        self.listView.numItems = #self.itemInfos
    -- end
    elseif #self.itemInfos > 32 then
        local subItem2 = 32 - #self.itemInfos%32
        for i=1,subItem2 do
            table.insert(self.itemInfos,{})
        end
        self.listView.numItems = #self.itemInfos
    end
    -- self.listView.numItems = #self.itemInfos
end

function LimitWareView:cellWareData(index,obj)
    --设置临时仓库里的item信息
    local frame = obj:GetChild("n6")
    local proObj = obj:GetChild("n5")--item
    proObj.visible = false
    local data = self.itemInfos--对应的数据
    if data and next(data[index+1])~=nil then
        frame.visible = false
        data[index+1].isquan = 0
        GSetItemData(proObj,data[index+1],true)
    else
        frame.visible = true
    end
end

--一键取出
function LimitWareView:onClickBtn()
    proxy.PackProxy:send(1030154,{reqType = 2})
end

return LimitWareView