--
-- Author: ohf
-- Date: 2017-02-11 10:02:28
--
--装备道具区域
local PropsEquipPanel = class("PropsEquipPanel",import("game.base.Ref"))

function PropsEquipPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function PropsEquipPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n14")
    self.pageList = panelObj:GetChild("n31")
    self.pageList:SetVirtual()
    self.pageList.itemRenderer = function(index,obj)
        self:cellPackData(index, obj)
    end
    self.pageList.scrollPane.onScrollEnd:Add(self.onPackScrollPage, self)

    self.pageBtnList = panelObj:GetChild("n32")--分页按钮列表
    self.pageBtnList:SetVirtual()
    self.pageBtnList.itemRenderer = function(index,btnObj)
        btnObj.data = index
    end
    self.pageBtnList.onClickItem:Add(self.onClickPackPage,self)

    local btnForging = panelObj:GetChild("n19")
    if g_ios_test then   --EVE 屏蔽锻造按钮
        btnForging.visible = false
    end 
    btnForging.onClick:Add(self.onClickForg,self)
    btnForging:GetChild("title").visible = true
    btnForging.title = "合 成"
    btnForging:SetScale(0,0) --EVE 屏蔽
end

function PropsEquipPanel:setData()
    self.mData = cache.PackCache:getPackEquipData(true)
    -- printt(self.mData)
    local numItems = #self.mData
    if numItems <= 0 then
        numItems = 1
    end
    --数据列表
    self.pageList.numItems = numItems
    --按钮列表
    self.pageBtnList.numItems = numItems

    self:onPackScrollPage()
end

function PropsEquipPanel:cellPackData(pageIndex,cell)
    local itemList = cell:GetChild("n0")
    itemList.itemRenderer = function(index, iconObj)
        local unlockObj = iconObj:GetChild("n4")--密码锁
        unlockObj.visible = false
        local proObj = iconObj:GetChild("n5")--item
        proObj.visible = false
        local data = self.mData[pageIndex + 1]--获取分页的数据
        local iconIndex = index + 1
        if data and data[iconIndex] then
            local _tt = clone(data[iconIndex])
            _tt.isquan = true
            GSetItemData(proObj,_tt,true)--设置道具信息
        end
    end
    itemList.numItems = Pack.iconNum--默认数量
end
--选页
function PropsEquipPanel:onClickPackPage(context)
    local btnObj = context.data
    local index = btnObj.data
    self.pageList:ScrollToView(index,true)
end

function PropsEquipPanel:onPackScrollPage()
    local index = self.pageList.scrollPane.currentPageX
    if self.pageBtnList.numItems > 0 then
        self.pageBtnList:AddSelection(index,true)
    end
end

function PropsEquipPanel:onClickForg()
    GOpenView({id = 1033})
    self.mParent:closeView()
end

return PropsEquipPanel