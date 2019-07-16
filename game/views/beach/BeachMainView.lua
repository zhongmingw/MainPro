--
-- Author: wx
-- Date: 2018-01-03 15:10:11
--魅力沙滩

local BeachMainView = class("BeachMainView", base.BaseView)

function BeachMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
end

function BeachMainView:initView()
    self.fubenName = self.view:GetChild("n0"):GetChild("n355")

    self.listView = self.view:GetChild("n2")
    self:initList()

    local btnOut = self.view:GetChild("n11")
    btnOut.title = language.gonggong119
    btnOut.onClick:Add(self.onCloseView,self)

    local btnReward = self.view:GetChild("n14")
    btnReward.onClick:Add(self.onReaward,self)
    self.meilivalue = self.view:GetChild("n16")
    self.meilivalue.text = ""

    local btnRank = self.view:GetChild("n13")
    btnRank.onClick:Add(self.onRank,self)

    self.redImg = btnRank:GetChild("red")
end
function BeachMainView:onTimer()
    -- body
    self.redImg.visible = G_BeachItem()
    if not self.data then
        return
    end

    if self.starindex % conf.BeachConf:getValue("requestTime") == 0 then
        proxy.BeachProxy:sendMsg(1020421)
        return
    end
    self.starindex = self.starindex + 1
    
   
    if self.var1 then
        self.data.leftTime =math.max(self.data.leftTime - 1 , 0) 
        --print("self.data.leftTime",self.data.leftTime)

        local param = clone(language.beach01)
        param[2].text = string.format(param[2].text,GTotimeString(self.data.leftTime))
        self.var1.text = mgr.TextMgr:getTextByTable(param)

        if self.data.leftTime == 0 then
            self:onCloseView()
        end
    end
end
function BeachMainView:initData()
    -- body
    self.varlist = {} --刚进入副本是否默认无皮肤

    -- local confRewad = conf.BeachConf:getRewardAll()
    -- self.number  = #confRewad
    --隐藏任务面板
    self:setMainView(false)
    --场景名字
    self.sId = cache.PlayerCache:getSId()
    local Sconf = conf.SceneConf:getSceneById(self.sId)
    if not Sconf then
        print("场景不存在",self.sId)
        self:onCloseView()
        return
    end
    self.fubenName.text = Sconf.name 
    --定时器
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil 
    end
    self.starindex = 1
 
    self.timer = self:addTimer(1,-1,handler(self, self.onTimer))
    if self.updater then
        self:removeTimer(self.updater)
        self.updater = nil 
    end
    self.updater = self:addTimer(0.5,-1, handler(self,self.update))

    proxy.BeachProxy:sendMsg(1020421)
end

function BeachMainView:changeBody(player)
    -- body
    if not player then
        return
    end
    if player:getStateID() == RoleAI.fly then
        return
    end

    local var = player:getGridValue()
    --print("var",var,player.data.roleName,player.data.roleId)
    if self.varlist[player.data.roleId] and  self.varlist[player.data.roleId] == var then
        return
    end

    self.varlist[player.data.roleId] = var

    if var == 7 then
        player:setHome(true)
    else
        
        player:setHome(false)
    end
end

function BeachMainView:clearList()
    -- body

    local c = 0 
    if gRole then
       c = self.varlist[gRole.data.roleId]
    end
    self.varlist = {}
    if c and c ~= 0 and gRole then
        self.varlist[gRole.data.roleId] = c
    end
end

function BeachMainView:resetPlayer(player)
    -- body
    if player then
        self.varlist[player.data.roleId] = nil
    end
end

function BeachMainView:update()
    -- body

    if gRole then self:changeBody(gRole) end
    local players = mgr.ThingMgr:objsByType(ThingType.player)
    local list = {}
    for k, v in pairs(players) do
        if v then
            self:changeBody(v)
        end
        -- list[v.data.roleId] = v 
        -- -- if v then
        -- --     self:changeBody(v)
        -- -- end
    end 

    -- for k ,v in pairs(self.varlist) do
    --     if not list[v] then
    --         self.varlist[v] = nil 
    --     end
    -- end

    -- for k , v in pairs(list) do
    --     self:changeBody(v)
    -- end

    -- if not gRole then
    --     return
    -- end
    -- --检测当前位置是否需要改变皮肤
    -- local var = gRole:getGridValue()
    -- if self.var and self.var == var then
    --     return
    -- end 
    -- self.var = var
    -- print("当前格子属性",var) 
    -- if self.var == 7 then
    --     gRole:setHome(true)
    -- else
    --     gRole:setHome(false)
    -- end
end

function BeachMainView:addComponent3()
    -- body
    local var = UIPackage.GetItemURL("beach" , "Component3")
    local _compent1 = self.listView:AddItemFromPool(var)
    return _compent1:GetChild("n0")
end

function BeachMainView:initList()
    -- body
    self.listView.numItems = 0
    ----剩余时间
    self.var1 = self:addComponent3()
    self.var1.text = ""
    --累积经验
    self.var2 = self:addComponent3()
    self.var2.text = ""
    --当前魅力值
    self.var3 = self:addComponent3()
    self.var3.text = ""
    --当前排名
    self.var4 = self:addComponent3()
    self.var4.text = ""
end

function BeachMainView:setMsg()
    -- body
    if not self.data then
        return
    end
    local param = clone(language.beach02)
    param[2].text = string.format(param[2].text,self.data.sumExp)
    self.var2.text = mgr.TextMgr:getTextByTable(param)
    
    local param = clone(language.beach03)
    param[2].text = string.format(param[2].text,self.data.curMl)
    self.var3.text = mgr.TextMgr:getTextByTable(param)

    local param = clone(language.beach04)
    param[2].text = string.format(param[2].text,self.data.curRanking)
    self.var4.text = mgr.TextMgr:getTextByTable(param)

    local index = 0
    local max = 0
    for k ,v in pairs(self.data.gotAwardList) do
        index = index + 1
        max = math.max(v,max)
    end

    local str =self.data.curMl.. "/" --self.number
    local color = 14
    local rewardconf = conf.BeachConf:getMlRewardById(max+1)

    if rewardconf then
        --检测是否达成领取
        if rewardconf.ml_value <= self.data.curMl then
            color = 4
        else
            color = 14
        end
        str = str .. rewardconf.ml_value
    else
        color = 4
        local condata =  conf.BeachConf:getMlRewardById(max)
        if condata then
            str = str ..  condata.ml_value
        end
    end
    self.meilivalue.text = mgr.TextMgr:getTextColorStr(str, color)
end

function BeachMainView:setData(data_)

end

---隐藏主界面任务面板
function BeachMainView:setMainView(visible)
    -- body
    local mv = mgr.ViewMgr:get(ViewName.MainView)
    if mv then
        mv.view:GetChild("n208").visible = visible
        mv.view:GetChild("n209").visible = visible
        mv.view:GetChild("n224").visible = visible
        mv:setTeamBtnVisible(visible)
        local selectedIndex = 1
        if visible then
            selectedIndex = 0
        end
        mv.c6.selectedIndex = selectedIndex
        mv.c4.selectedIndex = selectedIndex
        mv.c7.selectedIndex = selectedIndex
        if mv.taskorTeam then
            mv.taskorTeam:gotoWar()
        end
    end
end

function BeachMainView:onCloseView()
    -- body
    self:closeView()
    mgr.FubenMgr:quitFuben()
end

function BeachMainView:onReaward()
    -- body
    --查看奖励
    mgr.ViewMgr:openView2(ViewName.BeachReward,self.data)
end

function BeachMainView:onRank()
    -- body --看排行
    mgr.ViewMgr:openView2(ViewName.BeachRank)
end

function BeachMainView:addMsgCallBack(data)
    -- body
    self.starindex = 1
    if data.msgId == 5020421 then
        self.data = data

        self:setMsg()
    end
end
return BeachMainView