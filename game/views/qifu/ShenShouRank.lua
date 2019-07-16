--
-- Author: 
-- Date: 2018-09-06 20:15:31
--

local ShenShouRank = class("ShenShouRank", base.BaseView)

function ShenShouRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
    self.openTween = ViewOpenTween.scale
    self.isBlack = true  
end

function ShenShouRank:initView()
    local btn = self.view:GetChild("n4"):GetChild("n4")
    self:setCloseBtn(btn)

    local dec1 = self.view:GetChild("n16")
    dec1.text = language.shenshourank01
    local dec1 = self.view:GetChild("n12")
    dec1.text = language.shenshourank03
    local dec1 = self.view:GetChild("n14")
    dec1.text = language.shenshourank04
    local dec1 = self.view:GetChild("n19")
    dec1.text = language.shenshourank02
    local dec1 = self.view:GetChild("n20")
    dec1.text = language.shenshourank05
    local dec1 = self.view:GetChild("n24")
    dec1.text = language.shenshourank06
    local dec1 = self.view:GetChild("n25")
    dec1.text = language.shenshourank07

    self.labtime = self.view:GetChild("n13")
    self.labmyrank = self.view:GetChild("n15")

    local btn1 = self.view:GetChild("n17")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n18")
    btn2.onClick:Add(self.onBtnCallBack,self) --1337

    self.confdata = conf.ActivityConf:getShenshourank()
    table.sort(self.confdata,function(a,b)
        -- body
        return a.id < b.id 
    end)
    self.listView = self.view:GetChild("n11")
    self.listView.itemRenderer = function(index,obj)
        self:cellBaseData(index, obj)
    end
    self.listView.numItems = #self.confdata

    self.listViewrank = self.view:GetChild("n26")
    self.listViewrank.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listViewrank.numItems = 0
end

function ShenShouRank:onBtnCallBack(context)
    local btn = context.sender 
    local data = btn.data
    if "n17" == btn.name then
        GOpenRuleView(1138)
    elseif "n18" == btn.name then
        GOpenView({id = 1337})
    end
end

function ShenShouRank:cellBaseData(index, obj)
    -- body
    local data = self.confdata[index +1]
    local labrank = obj:GetChild("n1") 
    if data.rank[1] == data.rank[2] then
        labrank.text = string.format(language.shenshourank08,tostring(data.rank[1]))
    else
        labrank.text = string.format(language.shenshourank08,data.rank[1].."-"..data.rank[2])
    end

    local listView = obj:GetChild("n2")
    listView.itemRenderer = function(_index,_obj)
        local info = data.awards[_index + 1]
        local t ={}
        t.mid = info[1]
        t.amount = info[2]
        t.bind = info[3] or 1
        GSetItemData(_obj, t, true)
    end
    listView.numItems = #data.awards
end

function ShenShouRank:cellData( index, obj )
    -- body
    local data = self.data.rankInfos[index+1]
    local c1 = obj:GetController("c1")
    local labrank = obj:GetChild("n3")
    local labname = obj:GetChild("n4")
    local labpower = obj:GetChild("n5")
    local imgkua = obj:GetChild("n7")
    if data then
        if data.rank <= 3 then
            c1.selectedIndex = data.rank  - 1
        else
            c1.selectedIndex = 3
        end
        labrank.text = data.rank
        labpower.text = data.power
        labname.text = data.name

        local uId = string.sub(data.roleId,1,3)
        imgkua.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(data.roleId) > 10000
    else
        c1.selectedIndex = 3
        labrank.text = index + 1
        labname.text = language.kuafu104 
        labpower.text = 0
        imgkua.visible = false
    end
end

function ShenShouRank:onTimer( ... )
    -- body
    if not self.data then return end
    self.data.lastTime = math.max(self.data.lastTime - 1,0) 
    if self.data.lastTime <= 0 then
        self:closeView()
        return
    end
    self.labtime.text = GGetTimeData2(self.data.lastTime)
end

function ShenShouRank:initData(data)
    -- body
    if data then
        self:addMsgCallBack(data)
    end
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"ShenShouRank")
end

function ShenShouRank:addMsgCallBack( data )
    -- body
    self.data = data 

    self.labmyrank.text = data.myRank > 0 and data.myRank or language.kuafu50

    self.listViewrank.numItems = 20
end

return ShenShouRank