--
-- Author: 
-- Date: 2017-07-14 11:14:17
-- Remarks: EVE加入限时特卖快捷入口 807
-- Remarks: EVE加入变强提示 809
--下方冒泡提示
local BubblePanel = class("BubblePanel",import("game.base.Ref"))

local BtnMoveTime = 0.0--按钮移动时间
local BtnFadeTime = 0.7--按钮出现时间
local PrivateMax = 2--最多接受两个私聊提示

--排序改这里（[]里是UI的顺序，值是想要的顺序）
local setSort = {
    [1] = 9,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 1,
    [10] = 10,
}

--设置开启等级(值的第一个数为模块ID，第二个为顺序)
local setOpenLv = {
    [1] = {1226,1}         --变强提示
}

function BubblePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end
--1.好友 2.邮件 3.大红包 4.私聊 5.私聊 7.限时特卖
function BubblePanel:initPanel()
    self.privateList = {}
    self.mBubbleList = {}
    self.teamList = {}
    self.mPosXs = {}
    self.mPosYs = {}
    for i=1,10 do 
        local btn = self.mParent.view:GetChild("n"..(800+i))
        btn.visible = false
        btn.alpha = 0
        if i == 4 or i == 5 then
            btn.onClick:Add(self.onClickChat,self)
        elseif i == 6 then--队伍
            btn.onClick:Add(self.onClickTeam,self)
        elseif i == 7 then--EVE 限时特卖
            btn.onClick:Add(self.onClickFlashSale,self)
        elseif i == 8 then--boss信息
            btn.onClick:Add(self.onClickBossNews,self)
            local redImg = btn:GetChild("n6")
            redImg.visible = false
        elseif i == 9 then --EVE 变强提示
            btn.onClick:Add(self.onClickGrowthTips,self)
        elseif i == 10 then--帝王将相仙位被抢提示
            btn.onClick:Add(self.onClickDiWangTips,self)
        end
        table.insert(self.mBubbleList, btn)
        local posx = btn.x
        table.insert(self.mPosXs, posx)
        local posy = btn.y
        table.insert(self.mPosYs, posy)
    end
    --特殊处理 变强提示要放到第一个位置
    self.mBubbleList[1],self.mBubbleList[9] = self.mBubbleList[9],self.mBubbleList[1]
end

--设置开启等级
function BubblePanel:setOpenLevel()
    local confLv = 0                                        --配置配的等级
    local curLv =  cache.PlayerCache:getRoleLevel()         --当前等级
    local notOpenModule = {}                                --没有开启的模块(保存顺序下标)

    for k,v in pairs(setOpenLv) do
        confLv = conf.SysConf:getModuleById(v[1]).seelv
        if confLv > curLv then 
            -- table.remove(self.mBubbleList, v[2])
            table.insert(notOpenModule,v[2])
        end
    end
    return notOpenModule
end

function BubblePanel:setAllVisble()
    for k,btn in pairs(self.mBubbleList) do
        if k ~= 1 or k ~= 9 then
            btn.visible = false
            btn.alpha = 0
        end
    end
end
--出现按钮
function BubblePanel:appearBtn(i)
    local index = setSort[i]
    
    --判断当前模块是否开启
    local notOpenModule = self:setOpenLevel()
    for k,v in pairs(notOpenModule) do
        if index == v then
            -- print("冒泡窗口，当前模块没有开启：",v)
            return
        end
    end

    self:setBtnVisible(true,index)
    self:setBtnPos()
end
--消失按钮
function BubblePanel:hideBtn(index)
    local index = setSort[index]
    self:setBtnVisible(false,index)
    self:setBtnPos()
end

--私聊来了
function BubblePanel:setPrivateChat(data)
    local confData = conf.ChatConf:getChatData(7)
    local openlv = confData and confData.open_lv or 1
    local chatName = confData and confData.name or ""
    local chatVipLv = conf.SysConf:getValue("vip_not_limit_chat")
    if cache.PlayerCache:getRoleLevel() < openlv and cache.PlayerCache:getVipLv() < chatVipLv then
        return
    end
    if #self.privateList >= PrivateMax then
        return
    end
    if data.roleId ~= cache.PlayerCache:getRoleId() then--不是自己发的私聊
        if #self.privateList <= 0 then
            table.insert(self.privateList, data)
        else
            local isFind = false
            for k,v in pairs(self.privateList) do
                if v.roleId == data.roleId then
                    self.privateList[k] = data
                    isFind = true
                    break
                end
            end
            if not isFind then
                table.insert(self.privateList, data)
            end
        end
    end
    local index = 4
    for k,v in pairs(self.privateList) do
        local bubble = self.mBubbleList[index]
        local icon = bubble:GetChild("n1"):GetChild("n3")
        local playerData = GGetMsgByRoleIcon(v.roleIcon,v.roleId,function(t)
            if icon then
                icon.url = t.headUrl
            end
        end)
        local bubbleData = conf.ChatConf:getChatBubbleData(playerData.pid)
        --print("playerData.pid",playerData.pid)

        icon.url = playerData.headUrl--头像
        bubble:GetChild("n7").url = UIPackage.GetItemURL("main" , bubbleData.icon_img)--框风格
        bubble.data = {index = index,chatData = v}
        if not self.mBubbleList[index].visible then
            self:appearBtn(index)
        end
        index = index + 1
    end
end

--队伍
function BubblePanel:setTeamJoin(data)
    table.insert(self.teamList, data)
    cache.TeamCache:addJoinTeamList(data)
    local view = mgr.ViewMgr:get(ViewName.TeamJoinListView)
    if view then
        view:setData()
    else
        self:appearBtn(6)
    end
    if not self.teamTimer then
        self:onTipTeamTimer()
        self.teamTimer = self.mParent:addTimer(2, -1, handler(self, self.onTipTeamTimer))
    end
end

function BubblePanel:onTipTeamTimer()
    if #self.teamList <= 0 then
        self.mParent:removeTimer(self.teamTimer)
        self.teamTimer = nil
        return
    end
    local data = table.remove(self.teamList,1)
    local title = ""
    if data.type == 1 then--1.来自别人的申请，2.来自别人的邀请
        title = data.roleName..language.team15
    else
        title = data.roleName..language.team16
    end
    self.mBubbleList[6]:GetChild("n1").title = title
    self.mBubbleList[6]:GetTransition("t0"):Play()
end

function BubblePanel:setBtnVisible(visible,index)
    for k,btn in pairs(self.mBubbleList) do
        if k == index then
            btn.visible = visible
            if not visible then
                btn.alpha = 0
            end
        end
    end
end
--重新排版
function BubblePanel:setBtnPos()
    local index = 1
    local count = 1
    local max = 7
    for k,btn in pairs(self.mBubbleList) do
        if btn.visible then
            -- self.mParent.chatSite.touchable = false
            -- self.mParent.chatTouch.touchable = false
            -- UTransition.TweenMove(btn, Vector2.New(self.mPosXs[index], btn.y), BtnMoveTime, true,function()
            --     btn:TweenFade(1,BtnFadeTime) 
            --     self.mParent.chatSite.touchable = true
            --     self.mParent.chatTouch.touchable = true
            -- end)
            count = count + 1
            btn.x = self.mPosXs[index]
            btn.y = self.mParent.dazuoBtn.y - 56
            if k > max and count > max then
                btn.y = self.mParent.dazuoBtn - 118
            end
            btn:TweenFade(1,BtnFadeTime) 
            index = index + 1
        end
    end
end
--重置聊天按钮（比如第4个按钮点没了，那么第5个按钮的下标就变成4）
function BubblePanel:resetChatBtn()
    -- if #self.privateList == 1 and self.mBubbleList[5].visible then
    --     mgr.TimerMgr:addTimer(BtnMoveTime + BtnFadeTime, 1, function ()
    --         local chatData = self.privateList[1]
    --         local playerData = GGetMsgByRoleIcon(chatData.roleIcon)
    --         local bubbleData = conf.ChatConf:getChatBubbleData(playerData.pid)
    --         local bubble = self.mBubbleList[4]
    --         local icon = bubble:GetChild("n1"):GetChild("n3")
    --         local playerData = GGetMsgByRoleIcon(chatData.roleIcon,chatData.roleId,function(t)
    --             if icon then
    --                 icon.url = t.headUrl
    --             end
    --         end)
    --         icon.url = playerData.headUrl--头像
    --         bubble:GetChild("n7").url = UIPackage.GetItemURL("main" , bubbleData.icon_img)--框风格
    --         bubble.data = {index = 4,chatData = chatData}
    --     end)
    -- end
end
--点击私聊头像
function BubblePanel:onClickChat(context)
    local btn = context.sender
    local data = btn.data
    local chatData = data.chatData
    if not chatData then return end--
    local btnIndex = data.index
    local data  = {roleIcon = chatData.roleIcon,roleId = chatData.roleId,roleName = chatData.roleName,level = chatData.level,relation = chatData.relation}
    local param = {id = 1011,roleData = data}
    GOpenView(param)
    self:hideBtn(btnIndex)
    local role = cache.ChatCache:getSendPrivateRole(chatData.roleId)
    if not role then--还没请求过的留言玩家
        cache.ChatCache:setPrivateRoleData(data)
        proxy.ChatProxy:send(1060104,{roleId = chatData.roleId,roleName = chatData.roleName})
    end
    if btnIndex == 4 then
        table.remove(self.privateList,1)
    else
        if #self.privateList >= PrivateMax then
            table.remove(self.privateList,PrivateMax)
        else
            table.remove(self.privateList,1)
        end
    end
    -- self:resetChatBtn()--重置聊天按钮
end

function BubblePanel:onClickTeam()
    mgr.ViewMgr:openView2(ViewName.TeamJoinListView)
end

function BubblePanel:onClickFlashSale()
    -- self:hideBtn(7)
    GOpenView({id = 1074})
end
--Boss战斗信息
function BubblePanel:onClickBossNews()
    mgr.ViewMgr:openView2(ViewName.BossNewsView)
end

function BubblePanel:onClickGrowthTips()
    -- body
    -- print("变强提示~~~biubiubiu")
    local view = mgr.ViewMgr:get(ViewName.GrowthTips)
    if not view then
        mgr.ViewMgr:openView2(ViewName.GrowthTips)
    end
end

function BubblePanel:onClickDiWangTips()
    mgr.ViewMgr:openView2(ViewName.DiWangLootedTips, {})
end

function BubblePanel:checkPrivate()
    if #self.privateList == 1 then
        for i=4,5 do
            local roleData = self.privateList[1]
            local button = self.mBubbleList[i]
            local data = button.data
            if data then
                local chatData = button.data.chatData
                if roleData.roleId == chatData.roleId then
                    button.visible = true
                end
            end
        end
    elseif #self.privateList == 2 then
        self.mBubbleList[4].visible = true
        self.mBubbleList[5].visible = true
    end
end

return BubblePanel