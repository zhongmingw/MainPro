--
-- Author: wx
-- Date: 2018-09-04 15:54:48
--
local pairs = pairs
local ActXunBaoRank = class("ActXunBaoRank", base.BaseView)

function ActXunBaoRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ActXunBaoRank:initView()
    local btn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(btn)

    self.titleicon = self.view:GetChild("n0"):GetChild("icon")
    self.icon1 = self.view:GetChild("n17")
    self.panel = self.view:GetChild("n19")

    local dec1 = self.view:GetChild("n8")
    dec1.text = string.format(language.xbpa01,conf.ActivityConf:getHolidayGlobal("xunbao_rank_min_cost") )
    self.dec2 = self.view:GetChild("n9")
    self.dec3 = self.view:GetChild("n3")
    self.dec4 = self.view:GetChild("n4")

    self.listView = self.view:GetChild("n5")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self.listView.numItems = 0

    self.listViewRank = self.view:GetChild("n13")
    self.listViewRank.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    --self.listViewRank:SetVirtual()
    self.listViewRank.numItems = 0

    local btn1 = self.view:GetChild("n20")
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.view:GetChild("n6")
    btn2.onClick:Add(self.onBtnCallBack,self)

    self.c1 = self.view:GetController("c1")

    self.condata = conf.ActivityConf:getWholeAward()
    table.sort(self.condata,function(a,b)
        -- body
        return a.cost < b.cost
    end)
end

function ActXunBaoRank:initData(data)
    -- body
    self.model = nil 

    if data then
        self:addMsgCallBack(data)
    end
    if self.timer then
        self.removeTimer(self.timer)
    end
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer),"ActXunBaoRank")
end

function ActXunBaoRank:onTimer( data )
    -- d
    if not self.data then return end 
    self.data.lastTime = math.max(self.data.lastTime - 1,0)
    if self.data.lastTime <= 0 then
        self:closeView()
        return
    end
    self.dec2.text = string.format(language.xbpa02,GGetTimeData2(self.data.lastTime))  
end

function ActXunBaoRank:cellData( index, obj )
    -- body
    local data = self.curdata.awards[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[2] or 0
    GSetItemData(obj, t, true)
end


function ActXunBaoRank:cellRankData( index, obj )
    -- body
    local data = self.data.rankInfo[index+1]
    local n9 = obj:GetChild("n9")
    n9.visible = false
    local c1 = obj:GetController("c1")
    c1.selectedIndex = 3
    local labrank = obj:GetChild("n1")
    local labname = obj:GetChild("n2")
    local labyb = obj:GetChild("n3")
    if data then
        if data.rank <= 3 then
            c1.selectedIndex = data.rank - 1
        end
        labrank.text = data.rank
        labname.text = data.roleName
        labyb.text = data.cost
    else
        labrank.text = index + 1
        labname.text = language.rank03
        labyb.text = "0"
    end
end

function ActXunBaoRank:onBtnCallBack(context)
    local btn = context.sender
    local data = btn.data 
    if not self.data then
        return
    end
    if "n20" == btn.name then
        mgr.ViewMgr:openView2(ViewName.MarryRankAwardCon, self.data)
    elseif "n6" == btn.name then
        if self.c1.selectedIndex == 0 then
            return GComAlter(language.skill11)
        elseif self.c1.selectedIndex == 1 then
            local param = {}
            param.reqType = 1
            param.cid = self.curdata.id
            proxy.ActivityProxy:sendMsg(1030249,param)
        end
        
    end
end
function ActXunBaoRank:initModel(v)
    -- body
    --print(v.skins,"v")
    if not self.model then
        self.model = self:addModel(GuDingmodel[1],self.panel)
        self.model:setSkins(GuDingmodel[1], nil, v.skins)
        self.model:setRotationXYZ(0,303,0)--180
        self.model:setPosition(52,-419,500)
        self.model:setScale(150)
    end
end

function ActXunBaoRank:addMsgCallBack(data)
    -- body
    GOpenAlert3(data.items)
    self.data = data 
    self.isget = {}
    for k ,v in pairs(data.gotData) do
        self.isget[v] = true
    end
    local max = #self.condata
    local index = max
    for k ,v in pairs(self.condata) do
        if not self.isget[v.id] then
            index = k
            break
        end
    end
    self.curdata = self.condata[index]
    self.listView.numItems = #self.curdata.awards
    self.dec3.text = string.format(language.xbpa03,index,max)
    self.dec4.text = string.format(language.xbpa04,data.wholeCost,self.curdata.cost)
    if self.isget[self.curdata.id] then
        self.c1.selectedIndex = 2
    else
        if data.wholeCost >= self.curdata.cost then
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 0
        end
    end
    --排行
    if data.reqType == 0 then
        self.listViewRank.numItems = math.max(#self.data.rankInfo,10)
    end

    if 1 == self.c1.selectedIndex then
        mgr.GuiMgr:redpointByVar(20207,1,1)
    else
        mgr.GuiMgr:redpointByVar(20207,0,1)
    end

    local ff = conf.ActivityConf:getXunBaoRankAwardById(1)
    self:initModel(ff)
end

return ActXunBaoRank