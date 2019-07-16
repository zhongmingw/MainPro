--
-- Author: 
-- Date: 2017-07-21 21:12:14
--

local MarryFubenRank = class("MarryFubenRank", base.BaseView)

function MarryFubenRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function MarryFubenRank:initData(data)
    -- body
    self.data = clone(data)

    if data.myRankInfo.rank == 0 then
        self.rank.text = language.kuafu47..mgr.TextMgr:getTextColorStr(language.kuafu50, 7)
    else
        self.rank.text = language.kuafu47..mgr.TextMgr:getTextColorStr(data.myRankInfo.rank, 7)
    end
    local len = #self.data.ranking
    if len <= 10 then
        for i=1,10 - len do
            local data = {
                rank = len + i
                ,manName = language.rank03
                ,ladyName = language.rank03}
            table.insert(self.data.ranking, data)
        end
    end
    self.listView.numItems = #self.data.ranking
end

function MarryFubenRank:initView()
    self.listView = self.view:GetChild("n6")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local dec = self.view:GetChild("n6")
    dec.text = language.kuafu59

    local dec = self.view:GetChild("n10")
    dec.text = language.kuafu60

    local dec = self.view:GetChild("n6")
    dec.text = language.kuafu59

    local dec = self.view:GetChild("n11")
    dec.text = language.kuafu61

    local dec = self.view:GetChild("n12")
    dec.text = language.kuafu62

    self.rank = self.view:GetChild("n7")
    self.rank.text = language.kuafu47..mgr.TextMgr:getTextColorStr(language.kuafu50, 7)

    local btn = self.view:GetChild("n1"):GetChild("n2")
    btn.onClick:Add(self.onBtnClose,self)
end

function MarryFubenRank:celldata( index,obj )
    -- body
    local data = self.data.ranking[index+1]
    local lab1 = obj:GetChild("n1")
    local lab2 = obj:GetChild("n2")
    local lab3 = obj:GetChild("n3")
    local lab4 = obj:GetChild("n4")
    lab1.text = data.rank
    if not data.passSec then
        lab2.text = language.rank03
        lab3.text = 0
        lab4.text = 0
    else
        lab3.text = data.maxBo
        lab4.text = GTotimeString(data.passSec)

        local param = {}
        local t1 = {color = 6 , text = data.manName}
        table.insert(param,t1)
        local t2 = {url = "ui://marry/jiehun_018",width = 29,height = 26}
        table.insert(param,t2)
        local t3 = {color = 6 , text = data.ladyName}
        table.insert(param,t3)
        lab2.text = mgr.TextMgr:getTextByTable(param)
    end
end

function MarryFubenRank:setData(data_)

end

function MarryFubenRank:onBtnClose()
    -- body
    self:closeView()
end

return MarryFubenRank