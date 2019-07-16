--
-- Author: 
-- Date: 2017-07-11 15:51:47
--

local KuaFuTeamPanel = class("KuaFuTeamPanel",import("game.base.Ref"))

function KuaFuTeamPanel:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function KuaFuTeamPanel:initPanel()
    self.nameText = self.mParent.nameText
end

function KuaFuTeamPanel:onTimer()
    -- body
    if not self.data then
        return
    end
    if not self.timeText then
        return
    end
    if self.data.msgId~=5380201 then --只有是跨服组队副本才进入
        return
    end

    --开始倒计时
    local var = mgr.NetMgr:getServerTime() - self.data.firstTime
    --plog(".var.",var)
    local leftTime = (self.Sconf.over_time/1000) - var
    if leftTime == 0 then
        leftTime = 0
        self:releaseTimer()
    end
    self.timeText.text = language.fuben20.." "..mgr.TextMgr:getTextColorStr(GTotimeString(leftTime), 10)
end

function KuaFuTeamPanel:setPassData( data )
    -- body

    if not data or not data.passId or not data.conMap then
        return
    end
    for i = 1 , 3 do
        local lab = self._compent2:GetChild("n"..i)
        lab.text = ""
    end
    local sId = cache.PlayerCache:getSId()
    --plog("data.passId",data.passId)
    cache.FubenCache:setCurrPass(data.passId)
    local fubenData = conf.FubenConf:getPassDatabyId(data.passId)
    if not fubenData then
        return
    end
    if #fubenData.pass_con <= 2 then
        self._compent2.height = 70
    else
        self._compent2.height = 90
    end
    for k ,v in pairs(fubenData.pass_con) do
        if k > 3 then
            break
        end 
        local mConf = conf.MonsterConf:getInfoById(v[1])
        local str =  k .. "." .. language.fuben09
        str = str .. mgr.TextMgr:getTextColorStr(mConf.name, 10)
        str = str .. "(".. (data.conMap[v[1]] or 0) .."/" .. v[2].. ")"


        local lab = self._compent2:GetChild("n"..k)
        lab.text = str
        lab.visible = true
    end
end

function KuaFuTeamPanel:addreward(_compent3,reward)
    -- body
    local listview = _compent3:GetChild("n7")
    listview.itemRenderer = function(index,cell)
        -- body
        local v = reward[index+1]
        local t = {mid = v[1],amount=v[2],bind = v[3]}
        GSetItemData(cell,t,true)
    end
    listview.numItems = #reward
end

function KuaFuTeamPanel:initMsg(data)
    -- body
    self.data = data
    local sId = cache.PlayerCache:getSId()
    self.Sconf = conf.SceneConf:getSceneById(sId)
    self.nameText.text = self.Sconf.name 

    --清理列表
    self.listView.numItems = 0
    --添加倒计时
    local _compent1 = self.listView:AddItemFromPool(UIPackage.GetItemURL("track" , "BossTrack1"))
    self.timeText = _compent1:GetChild("n2")
    
    if self.timer then
        self.mParent:removeTimer(self.timer)  
    end
    self:onTimer()
    self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    --添加通过条件
    local _compent2 = UIPackage.GetItemURL("track" , "TrackItem2")
    self._compent2 = self.listView:AddItemFromPool(_compent2)
    self:setPassData(self.data)
    --添加首次通过奖励
    -- local fubenData = conf.FubenConf:getPassDatabyId(data.passId)
    -- if self.data.isFrist == 1 and fubenData and fubenData.first_pass_award then
    --     local var = UIPackage.GetItemURL("track" , "TrackItem4")
    --     local _compent3 = self.listView:AddItemFromPool(var)
    --     local labdec = _compent3:GetChild("n3")
    --     labdec.text = language.fuben15

    --     self:addreward(_compent3,fubenData.first_pass_award)
    -- end
    --添加通关奖励
    -- if fubenData and fubenData.normal_drop then
    --     local var = UIPackage.GetItemURL("track" , "TrackItem4")
    --     local _compent3 = self.listView:AddItemFromPool(var)

    --     local labdec = _compent3:GetChild("n3")
    --     labdec.text = language.fuben36
    --     self:addreward(_compent3,fubenData.normal_drop)
    -- end
    --添加boss几率奖励
    -- if self.Sconf.normal_drop then
    --     local var = UIPackage.GetItemURL("track" , "TrackItem4")
    --     local _compent3 = self.listView:AddItemFromPool(var)

    --     local labdec = _compent3:GetChild("n3")
    --     labdec.text = language.fuben80
    --     self:addreward(_compent3,self.Sconf.normal_drop)
    -- end
    --添加伤害排名
    local var = UIPackage.GetItemURL("track" , "BossTrack6")
    local _compent4 =  self.listView:AddItemFromPool(var)
    _compent4:GetChild("n2").text = language.fuben79
    _compent4:GetChild("n3").text = language.fuben81
    _compent4:GetChild("n4").text = language.fuben82
    --plog("5555555555")
    local var = UIPackage.GetItemURL("track" , "BossTrack6")
    self.roleitem = self.listView:AddItemFromPool(var)
    local teamdata = cache.KuaFuCache:getFubenData()
    -- self.roleitem = {}
    local t ={rank = "",roleName="",hurt = ""}
    if teamdata and teamdata.teamMembers then
        local number = #teamdata.teamMembers
        for k ,v in pairs(teamdata.teamMembers) do
            t.rank = t.rank .. "0"
            t.roleName = t.roleName .. v.roleName 
            t.hurt = t.hurt .. "0"
            if k ~= number then
               t.rank = t.rank .. "\n"
               t.roleName = t.roleName .. "\n"
               t.hurt = t.hurt .. "\n"
            end
        end
    end
    self:setItemText(t)
end

function KuaFuTeamPanel:setItemText(t)
    -- body
    if not self.roleitem then
        return
    end
    self.roleitem:GetChild("n2").text = mgr.TextMgr:getTextColorStr(tostring(t.rank), 10) 
    self.roleitem:GetChild("n3").text = mgr.TextMgr:getTextColorStr(tostring(t.roleName), 10)  
    self.roleitem:GetChild("n4").text = mgr.TextMgr:getTextColorStr(tostring(t.hurt), 10) 
end

--刷新伤害排行
function KuaFuTeamPanel:resetRank(data)
    -- body
    if not data then return end
    table.sort(data.ranks,function(a,b)
        -- body
        return a.rank < b.rank
    end)
    --printt("data.ranks",data.ranks)
    local t ={rank = "",roleName="",hurt = ""}
    local number = #data.ranks
    for k ,v in pairs(data.ranks) do
        t.rank = t.rank..mgr.TextMgr:getTextColorStr(tostring(v.rank), 10) 
        t.roleName =t.roleName..mgr.TextMgr:getTextColorStr(tostring(v.roleName), 10)
        if tonumber(v.hurt/100000) >= 1 then
            t.hurt = t.hurt..mgr.TextMgr:getTextColorStr(string.format("%.01f",v.hurt/100000)..language.gonggong53, 10)
        else
            t.hurt = t.hurt..mgr.TextMgr:getTextColorStr(math.floor(v.hurt/10)..language.gonggong52, 10)
        end 
        if k ~= number then
           t.rank = t.rank .. "\n"
           t.roleName = t.roleName .. "\n"
           t.hurt = t.hurt .. "\n"
        end
    end

    --printt(t)
    self:setItemText(t)
end

function KuaFuTeamPanel:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end
function KuaFuTeamPanel:endFuben()
    self:releaseTimer()
end
function KuaFuTeamPanel:onClickQuit()
    self:releaseTimer()
    mgr.FubenMgr:quitFuben()
end
return KuaFuTeamPanel