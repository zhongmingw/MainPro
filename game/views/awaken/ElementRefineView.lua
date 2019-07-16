-- --
-- -- Author:bxp 
-- -- Date: 2018-10-30 10:47:22
-- --元素精炼(不做这个功能)

-- local table = table
-- local pairs = pairs

-- local ElementRefineView = class("ElementRefineView", base.BaseView)

-- local Img = {
--     [1] = "bamenxitong_012",
--     [2] = "bamenxitong_013",
--     [3] = "bamenxitong_014",
--     [4] = "bamenxitong_015",
--     [5] = "bamenxitong_016",
--     [6] = "bamenxitong_017",
-- }



-- function ElementRefineView:ctor()
--     self.super.ctor(self)
--     self.uiLevel = UILevel.level3 
--     self.isBlack = true
--     self.openTween = ViewOpenTween.scale
-- end

-- function ElementRefineView:initView()
--     self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))

--     self.listView = self.view:GetChild("n3")
--     self.listView.itemRenderer = function ( index,obj )
--         self:cellData(index,obj)
--     end
--     self.listView.onClickItem:Add(self.onClickSelect,self)
--     self.listView:SetVirtual()
--     self.listView.numItems = 0
--     self.view:GetChild("n19").text = language.eightgates06[1]
--     self.c1 = self.view:GetController("c1")
--     --所选元素
--     self.choseItem = self.view:GetChild("n4")
--     --消耗材料
--     self.proItem = self.view:GetChild("n16")
--     --消耗数量
--     self.costNum = self.view:GetChild("n17")

--     local refineBtn = self.view:GetChild("n18")
--     refineBtn.onClick:Add(self.onRefineCallBack,self)
--     --当前品级
--     self.curLv = self.view:GetChild("n9")
--     --当前属性
--     self.curArr = self.view:GetChild("n10")

--     --下级品级
--     self.nextLv = self.view:GetChild("n13")
--     --下级属性
--     self.nextArr = self.view:GetChild("n14")
--     --提示美术字
--     self.hintImg = self.view:GetChild("n21")

-- end

-- function ElementRefineView:initData()
--     local data = cache.AwakenCache:getEightGatesData()
--     -- self.info = data.info
--     self.listView.numItems = #language.eightgates04
--     self:choseFirstCell()
-- end

-- function ElementRefineView:choseFirstCell()
--     for k = 1,#language.eightgates04 do
--         local cell = self.listView:GetChildAt(k - 1)
--         if cell then
--             cell.onClick:Call()
--             break
--         end
--     end
-- end


-- function ElementRefineView:cellData(index,obj)
    
-- end

-- function ElementRefineView:onClickSelect(context)
--     local cell = context.data
--     local data = cell.data
-- end


-- function ElementRefineView:setData(data_)

-- end

-- function ElementRefineView:onRefineCallBack()

-- end

-- return ElementRefineView