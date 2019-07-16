--
-- Author: 
-- Date: 2018-12-13 11:36:09
--

local JiYiJiaoYanRank = class("JiYiJiaoYanRank", base.BaseView)

function JiYiJiaoYanRank:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function JiYiJiaoYanRank:initView()
     local closeBtn = self.view:GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView1 = self.view:GetChild("n5")

    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.confData = conf.DongZhiConf:getRankData()
     self.listView1.numItems = #self.confData 
end

function JiYiJiaoYanRank:initData(data)
    self.scoreRankings = data.scoreRankings
end

function JiYiJiaoYanRank:cell1data(index,obj)
    local data = self.confData[index +1]
    local c1 = obj:GetController("c1") 
    c1.selectedIndex = index
    local list = obj:GetChild("n4")
    local  data1 = data.awards
      list.itemRenderer = function (index,obj)
       local item = data1[index + 1]
       local itemData  =  {mid = item[1],amount = item[2],bind = item [3]}
        GSetItemData(obj, itemData, true)
    end
     list.numItems = #data1
end

return JiYiJiaoYanRank