--
-- Author: 
-- Date: 2018-09-20 11:23:57
--

local ShengYinRank = class("ShengYinRank", base.BaseView)

function ShengYinRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ShengYinRank:init()
    -- -- body
    --  local actData = cache.ActivityCache:get5030111()
    if self.data.msgId == 5030252 then
        self.confdata = conf.ActivityConf:getShengyinRankeAward()
    elseif  self.data.msgId == 5030419 then
        self.confdata = conf.ActivityConf:getShengyinRankeAward1()
    end

    table.sort(self.confdata,function(a,b)
    -- body
        return a.id <b.id
    end)
    printt(self.confdata)
    self.rewardlist.numItems = #self.confdata

    self.c1.selectedIndex = 0
    self:onController()
    if self.actTimer then
        self:removeTimer(self.actTimer)
        self.actTimer = nil 
    end
    self.actTimer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function ShengYinRank:initView()
    local btn = self.view:GetChild("n33")
    self:setCloseBtn(btn)
    self.shengYinRankView = self.view:GetChild("n36") --圣印排行

    self.c1 = self.view:GetController("c1")
    
    self.c1.onChanged:Add(self.onController,self)

    self.labTime = self.shengYinRankView:GetChild("n7")
    self.labmyRanke = self.shengYinRankView:GetChild("n10")

    self.rewardlist = self.shengYinRankView:GetChild("n1")
    self.rewardlist.itemRenderer = function(index,obj)
        self:cellAwardData(index, obj)
    end

   
    local btn1 = self.shengYinRankView:GetChild("n5") --提升战力
    btn1.onClick:Add(self.onBtnCallBack,self)

    local btn2 = self.shengYinRankView:GetChild("n16") --查看规则
    btn2.onClick:Add(self.onBtnCallBack,self)

    self.ranklist = self.shengYinRankView:GetChild("n15")
    self.ranklist.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.ranklist:SetVirtual()
    self.ranklist.numItems = 0

    local dec1 = self.shengYinRankView:GetChild("n7")
    dec1.text = language.syph1 
    local dec2 = self.shengYinRankView:GetChild("n8")
    dec2.text = language.syph2
end 

function ShengYinRank:onTimer()
    -- body
    if not self.data then return end
    if self.c1.selectedIndex == 0 then
        self.data.lastTime = math.max(self.data.lastTime-1,0)
        if self.data.lastTime <= 0 then
            self:closeView()
            return
        end
        if self.data.lastTime >= 86400 then
            self.labTime.text = language.syph1.. mgr.TextMgr:getTextColorStr(GGetTimeData3(self.data.lastTime), 7)
        else
            self.labTime.text = language.syph1.. mgr.TextMgr:getTextColorStr(GGetTimeData4(self.data.lastTime), 7)
        end
    end
end

function ShengYinRank:onController()
    -- body
    if self.c1.selectedIndex == 0 then
        local actData = cache.ActivityCache:get5030111()
        if actData[5012] and actData[5012] == 1 then
            proxy.ActivityProxy:sendMsg(1030252)
        elseif  actData[1191] and actData[1191] == 1 then
            proxy.ActivityProxy:sendMsg(1030419)
        end
    end
end

function ShengYinRank:onBtnCallBack(context)
    -- body
    if not self.data then return end
    local btn = context.sender
    local data = btn.data 

    if "n5" == btn.name then
        GOpenView({id = 1348})
    elseif "n16" == btn.name  then
        GOpenRuleView(1146)
    end
end

function ShengYinRank:cellAwardData( index, obj )
    -- body
    local data = self.confdata[index+1]
    local lab = obj:GetChild("n6")
    if data.rank[1] == data.rank[2] then
        lab.text = data.rank[1]
    else 
        lab.text = string.format("%dg%d",data.rank[1],data.rank[2])
    end


    local rewardlist = obj:GetChild("n4")
    rewardlist.itemRenderer = function(_index,_obj)
        local info = data.awards[_index+1]
        local t = {}
        t.mid =  info[1]
        t.amount = info[2]
        t.bind = info[3] or 0 
        GSetItemData(_obj, t, true)
    end
    rewardlist.numItems = #data.awards
end

function ShengYinRank:cellData( index, obj  )
    -- body
    local data = self.data.rankInfos[index+1]
    local labrank = obj:GetChild("n6")
    local _labrank = obj:GetChild("n8")
    local labname = obj:GetChild("n0")
    local labpower = obj:GetChild("n2")
    local c1 = obj:GetController("c1")
    local kuaFuIcon = obj:GetChild("n9")
    if index < 3 then
        c1.selectedIndex = index
        labrank.visible = true
        _labrank.visible = false 
    else
        c1.selectedIndex = 3
        labrank.visible = false
        _labrank.visible = true 
    end
    if data then
        labrank.text = data.rank
        _labrank.text = data.rank

        -- if data.rank <= 3 then
        --     c1.selectedIndex = data.rank - 1
        -- end
        labname.text = data.name 
        labpower.text = data.power
        local uId = string.sub(data.roleId,1,3)
        kuaFuIcon.visible = cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(data.roleId) > 10000
    else
        labrank.text = index + 1
        _labrank.text = index+1
        labname.text = language.kuafu104
        labpower.text = 0
        kuaFuIcon.visible = false
    end

end

function ShengYinRank:addMsgCallBack(data)

    if data.msgId == 5030252 then
        self.data = data 
        printt("圣印排行>>",data)
        if data.myRank == 0 then
            self.labmyRanke.text = mgr.TextMgr:getTextColorStr(language.kuafu50, 14) 
        else
            self.labmyRanke.text = data.myRank
        end
        local rankConf = conf.ActivityConf:getHolidayGlobal("shengyin_max_rank")
        self.ranklist.numItems = rankConf 
    elseif  data.msgId == 5030419 then --合服
        self.data = data 
        printt("圣印排行>>",data)
        if data.myRank == 0 then
            self.labmyRanke.text = mgr.TextMgr:getTextColorStr(language.kuafu50, 14) 
        else
            self.labmyRanke.text = data.myRank
        end
        -- local rankConf = conf.ActivityConf:getHolidayGlobal("shengyin_max_rank")
        self.ranklist.numItems = 20 
    end
    self:init()
end

return ShengYinRank