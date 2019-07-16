local XiaoNianRank = class("XiaoNianRank", base.BaseView)

local rankNum = conf.XiaoNianConf:getValue("xn_xycc_rank")
function XiaoNianRank:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function XiaoNianRank:initView()
    self:setCloseBtn(self.view:GetChild("n58"))
    self.List1 = self.view:GetChild("n65")
    self.List1.itemRenderer = function (index,obj)
        self:cellData1(index,obj)
    end
    self.List1.numItems = 0
    self.List2 = self.view:GetChild("n54")
    self.List2.itemRenderer = function (index,obj)
        self:cellData2(index,obj)
    end

    self.c1 = self.view:GetController("c1")
    self.text1 = self.view:GetChild("n67")
    self.text2 = self.view:GetChild("n70")
    self.confData = conf.XiaoNianConf:getXiangYaoData(1)
    self.List2.numItems = #self.confData
end

function XiaoNianRank:initData(data)
    printt(data)
    print(data.mine.score,data.mine.ranking)
    self.data = data
    self.text1.text = string.format(language.xiaonian2019_10,data.mine.score or 0) 
    self.text2.text = data.mine.ranking or 0
    self.List1.numItems = #data.rankInfos <= rankNum and rankNum or #data.rankInfos
    


end

function XiaoNianRank:cellData1(index,obj)
    local  data = self.data.rankInfos[index + 1] or nil
    local txt01 = obj:GetChild("n62")
    local txt02 = obj:GetChild("n63")
    local txt03 = obj:GetChild("n64")
    if data then
        txt01.text = string.format(language.xiaonian2019_11,data.ranking)
        txt02.text = data.roleName
        txt03.text = data.score.."分"
    else
        txt01.text = string.format(language.xiaonian2019_11,index + 1)
        txt02.text = "虚位以待"
        txt03.text = "无"
    end

end

function XiaoNianRank:cellData2(index,obj)
    local  data = self.confData[index + 1]
    local txt01 = obj:GetChild("n56")
    local  list = obj:GetChild("n57")

    if data.cond[1] == data.cond[2] then
        txt01.text = "第[color=#7df130]"..data.cond[1].."[/color]名"
    else
        txt01.text = "第[color=#7df130]"..data.cond[1].."~"..data.cond[2].."[/color]名"
    end
    list.itemRenderer = function (index, obj)
        local  data = data.items[index + 1]
        local itemInfo = {mid =data[1],amount =data[2],bind =data[3]}
        GSetItemData(obj, itemInfo, true)
    end
    list.numItems = #data.items
end

return XiaoNianRank