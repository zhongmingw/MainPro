--
-- Author: 
-- Date: 2018-09-04 16:46:39
--

local MarryRankAwardCon = class("MarryRankAwardCon", base.BaseView)

function MarryRankAwardCon:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function MarryRankAwardCon:initView()
    local btn = self.view:GetChild("n10")
    self:setCloseBtn(btn)

    self.condata = conf.ActivityConf:getXunBaoRankAward()
    table.sort(self.condata,function(a,b)
        -- body
        return a.id < b.id 
    end)

    self.listView = self.view:GetChild("n6")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = #self.condata
end

function MarryRankAwardCon:cellData(index, obj)
    local data = self.condata[index+1]

    local labrank = obj:GetChild("n1")
    if data.rank[1] == data.rank[2] then
        labrank.text = data.rank[1]
    else
        labrank.text = string.format("%d-%d",data.rank[1],data.rank[2])
        if index == 1 then
            labrank.text = "[color=#C227BD]"..labrank.text.."[/color]"
        elseif index == 2 then
            labrank.text = mgr.TextMgr:getTextColorStr(labrank.text, 1)
        elseif index == 3 then
            labrank.text = mgr.TextMgr:getTextColorStr("参与奖", 7)
        end
    end

    local listView =obj:GetChild("n3")
    listView.itemRenderer = function(_index,_obj)
        local info = data.awards[_index+1]
        local t = {}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[2] or 0
        GSetItemData(_obj, t, true)
    end
    listView.numItems = #data.awards


end

return MarryRankAwardCon