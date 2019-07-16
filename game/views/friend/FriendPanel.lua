--
-- Author: wx
-- Date: 2017-01-12 19:52:10
--
local ListMyFriend = import(".ListMyFriend") --好友列表
local ListAddFriend = import(".ListAddFriend") --添加好友 
local ListFrindShenQing = import(".ListFrindShenQing") --申请列表
local ListHeiMingDan = import(".ListHeiMingDan") --黑名单列表
local ListChouRen = import(".ListChouRen") --仇人列表

local FriendPanel = class("FriendPanel", import("game.base.Ref"))

function FriendPanel:ctor(compent)
    self.view = compent

    self:initView()
end

function FriendPanel:initView()
    -- body
    --好友控制器
    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)
    --位置控制器
    self.controllerC2 = self.view:GetController("titlepos")

    self.titleList = {}
    for i = 101, 106 do 
        local label = self.view:GetChild("n"..i)
        --label.text = ""
        table.insert(self.titleList,label)
    end
    self.titleicon = self.view:GetChild("n8")

    self:initLeftList() --列表初始化
    --
    self:initDec()
    --EVE 好友数量显示
    self.friendNum = self.view:GetChild("n50")
    self.friendNum.text = ""
    --EVE tips
    -- self.tips = self.view:GetChild("n52")
    -- local btnCloseTips = self.tips:GetChild("n4"):GetChild("n2")
    -- btnCloseTips.onClick:Add(self.onCloseTips,self)
    -- self.tips.visible = false
    -- self.tipsBlack = self.view:GetChild("n53")
    -- self.tipsBlack.visible = false

    --EVE 按照王帅要求：不显示亲密度、魅力的地方改成显示战斗力
    local dec = self.view:GetChild("n107")
    dec.scaleX = 0
end
--EVE 好友数量显示
function FriendPanel:friendNumShow()
    self.num = self.num -1
    self:setFriendcout()
end

function FriendPanel:setFriendcout()
    -- body
    local var = conf.SysConf:getValue("friend_count_limit")
    local max = var[1]
    if cache.PlayerCache:VipIsActivate(2) then
        max = var[2]
    end
    self.friendNum.text = self.num.."/"..max
end
--EVE 可领取爱心数量更新
function FriendPanel:renewalOfLove()
    self.loveNum = self.loveNum -1
    self.dec1.text = string.format(language.friend28, self.leftPresentCnt, self.loveNum) 
end
-- --EVE 关闭tips
-- function FriendPanel:onCloseTips()
--     self.tips.visible = false
--     self.tipsBlack.visible = false
-- end

function FriendPanel:initDec()
    -- body
    --好友列表
    local btnOneKeyTips = self.view:GetChild("n24")
    btnOneKeyTips.onClick:Add(self.onOneKeyTips,self)

    local btnOneKeyGet = self.view:GetChild("n23")
    btnOneKeyGet.onClick:Add(self.onOneKeyGet,self)

    local btnOneKeySend = self.view:GetChild("n20")
    btnOneKeySend.onClick:Add(self.onOneKeySend,self)

    self.dec1 = self.view:GetChild("n19")
    self.dec1.text = ""
    --添加好友
    local btnSearch = self.view:GetChild("n35")
    btnSearch.onClick:Add(self.onSearch,self)

    local btnSearchNext = self.view:GetChild("n32")
    btnSearchNext.onClick:Add(self.onSearchNext,self)

    local btnOneKeyAdd = self.view:GetChild("n31")
    btnOneKeyAdd.onClick:Add(self.onOneKeyAdd,self)

    self.inputText = self.view:GetChild("n36")
    --好友申请
    local btnIngore = self.view:GetChild("n28") 
    btnIngore.onClick:Add(self.onIngoreAll,self)

    local btnArgee = self.view:GetChild("n27") 
    btnArgee.onClick:Add(self.onArgeeAll,self)
    --没有好友的时候
    local dec = self.view:GetChild("n38")
    dec.text = language.friend05

    local btnToAdd = self.view:GetChild("n39")
    btnToAdd.onClick:Add(self.onBtnToAdd,self)

    self.dayFrienddec = self.view:GetChild("n52")
    self.dayFrienddec.text = ""
   --= language.friend53
    --=  dec1 

    self.dayFriendNum = self.view:GetChild("n53")
    self.dayFriendNum.text = ""

    self.controllerC1.selectedIndex = 6
end

function FriendPanel:initLeftList()
    -- body
    self.leftList = self.view:GetChild("n2")
    self.leftList:SetVirtual()
    self.leftList.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.leftList.numItems = 0
    self.leftList.onClickItem:Add(self.onItemCallBack,self)
end

function FriendPanel:celldata(index,obj)
    -- body
    obj:GetChild("title").text = language.friend03[index+1] or ""
    obj.data = index 
    --注册红点
    if index == 2 then
        local redImg = obj:GetChild("n5")
        local param = {panel = redImg,ids = {10227}}
        mgr.GuiMgr:registerRedPonintPanel(param,"friend.FriendView.1")
    elseif index == 0 then
        local redImg = obj:GetChild("n5")
        local param = {panel = redImg,ids = {10234}}
        mgr.GuiMgr:registerRedPonintPanel(param,"friend.FriendView.1")
    end

end
--[[
    "好友列表",
    "添加好友",
    "申请列表",
    "黑 名 单",
    "仇    人",
]]
function FriendPanel:onItemCallBack(context)
    -- body
    local index = context.data.data
    --self.controllerC1.selectedIndex = index
    self.selectedIndex = index
    self:send()
end

function FriendPanel:send( )
    -- body
    if 0 == self.selectedIndex  then 
        proxy.FriendProxy:sendMsg(1070101,{page =  1})
    elseif 1 == self.selectedIndex then 
        --plog("send 1070102")
        proxy.FriendProxy:sendMsg(1070102,{roleName = ""})
    elseif 2 == self.selectedIndex then 
        proxy.FriendProxy:sendMsg(1070104)
    elseif 3 == self.selectedIndex then 
        proxy.FriendProxy:sendMsg(1070201,{page =  1})
    elseif 4 == self.selectedIndex then
        proxy.FriendProxy:sendMsg(1070203,{page =  1})
    elseif 5 == self.selectedIndex then --没有任何好友的时候

    end

end

function FriendPanel:AutoClick(index)
    -- body
    if g_is_banshu then
        self.leftList.numItems = 3
    else
        self.leftList.numItems = 5
    end
    
    self.selectedIndex = index or 0
    self.leftList:AddSelection(self.selectedIndex,false)
    self:send()
end
--列表的title 显示
function FriendPanel:initTitle()
    -- body
    if self.controllerC1.selectedIndex > 4 then
        return
    end

    for k , v in pairs(self.titleList) do 
        v.text = ""
    end
    self.titleicon.url = UIItemRes.friend[self.controllerC1.selectedIndex+1]

    for k , v in pairs(language.friend04[self.controllerC1.selectedIndex+1]) do 
        if self.titleList[k] then
            self.titleList[k].text = v 
        else
            break
        end 
    end 
end
--
function FriendPanel:onController1()
    --body
    --plog(self.controllerC1.selectedIndex)
    self.controllerC2.selectedIndex = self.controllerC1.selectedIndex < 5 and self.controllerC1.selectedIndex or 0
    self:initTitle()
    --[[if 0 == self.controllerC1.selectedIndex  then 
        proxy.FriendProxy:sendMsg(1070101,{page =  1})
    elseif 1 == self.controllerC1.selectedIndex then 
        proxy.FriendProxy:sendMsg(1070102,{roleName = ""})
    elseif 2 == self.controllerC1.selectedIndex then 
        proxy.FriendProxy:sendMsg(1070104)
    elseif 3 == self.controllerC1.selectedIndex then 
        proxy.FriendProxy:sendMsg(1070201,{page =  1})
    elseif 4 == self.controllerC1.selectedIndex then
        proxy.FriendProxy:sendMsg(1070203,{page =  1})
    elseif 5 == self.controllerC1.selectedIndex then --没有任何好友的时候
    end]]--
end

--一键领取红点刷新
function FriendPanel:refreshRedPoint()
    -- body
    if self.recCount > 0 then
        self.view:GetChild("n23"):GetChild("red").visible = true
    else
        self.view:GetChild("n23"):GetChild("red").visible = false
    end
end

--刷新可领取次数
function FriendPanel:RefRecCount(num)
    --print("剩余领取次数",num)
    self.recCount = num
end
function FriendPanel:getRecCount()
    return self.recCount
end

function FriendPanel:setData(data,param)
    -- body
    if 5070101 == data.msgId then --好友列表返回
        --当前页面不是好友列表
        self.presentCount = data.presentCount
        self.recCount = data.recCount
        self:refreshRedPoint()
        if 0 ~= self.selectedIndex  then
            return
        end

        if data.page == 0 then
            return
        end
        local cur
        if data.page == 1 then 
            self.data = {} 
            self.data.page = data.page
            self.data.totalSum = data.totalSum
            self.data.friendList = data.friendList
            self.num = data.friendNum
            self.loveNum = data.leftRecvCnt
            self.leftPresentCnt = data.leftPresentCnt
            --self.friendNum.text = self.num.."/30"
            self:setFriendcout()
            local btnQuest = self.view:GetChild("n51")   --EVE 今天
            btnQuest.onClick:Add(self.onClickRuleBtn, self)
        else
            if data.page ~= self.data.page then 
                self.data.page =  data.page
                cur = #self.data.friendList
                for k ,v in pairs(data.friendList) do 
                    table.insert(self.data.friendList,clone(v))
                end
            end
        end 
        if #self.data.friendList == 0 then
            self.controllerC1.selectedIndex = 5

        else
            self.controllerC1.selectedIndex = 0
            if not self.ListMyFriend then 
                self.ListMyFriend = ListMyFriend.new(self.view:GetChild("n42"))
            end
            self.ListMyFriend:setData(self.data,cur)    
        end

        local openday = cache.PlayerCache:getRedPointById(attConst.A10325)
        local _confdata = conf.FriendConf:getDayFriendNum(openday)
        --print(openday,_confdata)
        --printt(data)
        if _confdata and _confdata.limit~=999 then
            self.dayFrienddec.text = language.friend53
            self.dayFriendNum.text = data.todayFriendNum .. "/".._confdata.limit
        else
            self.dayFrienddec.text = ""
            self.dayFriendNum.text = ""
        end
        
        self.dec1.text = string.format(language.friend28, data.leftPresentCnt, self.loveNum) 
    elseif 5070102 == data.msgId then --添加好友列表
        --当前页面不是 添加好友列表
        if 1 ~= self.selectedIndex  then
            return
        end
        --plog("有几个数据",#data.list)
        --[[for k ,v in pairs(data.list) do 
            plog(k,v )
        end]]--

        self.controllerC1.selectedIndex = 1
        self.data = {}
        --self.data = data
        self.data.list = data.list
        self.data.todayFriendNum = data.todayFriendNum
        --print("data.todayFriendNum",data.todayFriendNum)
        if not self.ListAddFriend then
            self.ListAddFriend = ListAddFriend.new(self.view:GetChild("n43"))
        end
        self.ListAddFriend:setData(self.data)
    elseif 5070103 == data.msgId then --添加 删除好友
        if 0 == self.selectedIndex and self.ListMyFriend then
            self.ListMyFriend:add5070103(data)
        elseif 1 == self.selectedIndex and self.ListAddFriend then 
            self.ListAddFriend:add5070103(data)
        end
    elseif 5070104 == data.msgId then --申请好友列表
        --当前页面不是 添加好友列表
        if 2 ~= self.selectedIndex  then
            return
        end
        self.controllerC1.selectedIndex = 2
        self.data = data
        if not self.ListFrindShenQing then
            self.ListFrindShenQing = ListFrindShenQing.new(self.view:GetChild("n44"))
        end
        self.ListFrindShenQing:setData(data)
    elseif 5070105 == data.msgId then --同意 或者 忽略
        if 2 == self.selectedIndex and self.ListFrindShenQing then 
            self.ListFrindShenQing:add5070105(data)

            if data.errStatu == 1  then
                GComAlter(language.friend29)
            elseif data.errStatu == 2 then
                GComAlter(language.friend39)
            elseif data.errStatu == 3 then
                GComAlter(language.friend40)
            elseif data.errStatu == 4 then
                --别人已达上限
                GComAlter(language.friend52)
            else
                --mgr.GuiMgr:redpointByID(10227)
            end
        end
    elseif 5070201 == data.msgId then --黑名单列表
         --当前页面不是 添加好友列表
        if 3 ~= self.selectedIndex  then
            return
        end
        self.controllerC1.selectedIndex = 3
        if data.page == 0 then
            --plog("黑名单列表 .."..data.page)
            return
        end
        local cur 
        if data.page == 1 then 
            self.data = {} 
            self.data.page = data.page
            self.data.totalSum = data.totalSum
            self.data.friendList = data.blackNameList
        else
            if data.page ~= self.data.page then 
                cur = #self.data.blackNameList
                for k ,v in pairs(data.blackNameList) do 
                    table.insert(self.data.blackNameList,v)
                end  
            end
        end 
        if not self.ListHeiMingDan then
            self.ListHeiMingDan = ListHeiMingDan.new(self.view:GetChild("n45")) 
        end
        self.ListHeiMingDan:setData(data,cur)
    elseif 5070202 == data.msgId then --请求黑名单添加删除
        if 0 == self.selectedIndex and self.ListMyFriend then
            self.ListMyFriend:add5070202(data)
        elseif self.ListHeiMingDan and  3 == self.selectedIndex then
            self.ListHeiMingDan:add5070202(data)
        end
    elseif 5070203 == data.msgId then --仇人
         --当前页面不是 添加好友列表
        if 4 ~= self.selectedIndex  then
            return
        end
        self.controllerC1.selectedIndex = 4
        if data.page == 0 then
            --plog("5070203 page="..data.page)
            return
        end
        local cur 
        if data.page == 1 then 
            self.data = {} 
            self.data.page = data.page
            self.data.totalSum = data.totalSum
            self.data.friendList = data.enemyList
        else
            if data.page ~= self.data.page then 
                cur = #self.data.enemyList
                for k ,v in pairs(data.enemyList) do 
                    table.insert(self.data.enemyList,v)
                end  
            end
        end 
        if not self.ListChouRen then
            self.ListChouRen = ListChouRen.new(self.view:GetChild("n46")) 
        end
        self.ListChouRen:setData(data,cur)
    elseif 5070204 == data.msgId then
        if 4 == self.selectedIndex and self.ListChouRen then
            --plog("5070204")
            self.ListChouRen:add5070204(data)
        end
    elseif 5070302 == data.msgId  then--请求类型 1:提醒赠送爱心 2:领取爱心 3:一键提醒 4:一键领取
        if 0 ~= self.selectedIndex  then
            return
        end
        if param.type == 1 or param.type == 2 then
            for k ,v in pairs(self.data.friendList) do
                if v.roleId == param.roleId then
                    v.recvHeartStatus = data.recvStatus
                    break
                end
            end
        elseif param.type == 3 or param.type == 4 then
            for k ,v in pairs(self.data.friendList) do
                if param.type == 3 then
                    if v.recvHeartStatus == 0 then
                        v.recvHeartStatus = data.recvStatus
                    end
                else
                    if v.recvHeartStatus  == 1 then
                        v.recvHeartStatus = data.recvStatus
                    end
                end
            end
        end
        -- plog("~~~~~~~~~~~~~~~~~~~~~~3333333" ,self.leftRecvCnt)
        -- self.dec2.text = string.format(language.friend41, self.leftRecvCnt)
        self.ListMyFriend:setData(self.data)
    elseif 5070301 == data.msgId  then--请求类型 1:单个赠送 2:一键赠送
        if 0 ~= self.selectedIndex  then
            return
        end

        if param.type == 1 then
            for k ,v in pairs(self.data.friendList) do
                if v.roleId == param.roleId then
                    v.presentStatus = data.presentStatus
                    break
                end
            end
        else
            for k ,v in pairs(self.data.friendList) do
                v.presentStatus = data.presentStatus
            end
        end

        self.dec1.text = string.format(language.friend28, data.leftPresentCnt, self.loveNum)
        self.ListMyFriend:setData(self.data)
    end 
end
function FriendPanel:onClickRuleBtn()
    local view = mgr.ViewMgr:get(ViewName.TipsView)
    if not view then 
        mgr.ViewMgr:openView2(ViewName.TipsView, {})
    end 
end
--跳转到添加好友列表
function FriendPanel:onBtnToAdd()
    -- body
    self.selectedIndex = 1
    self.leftList:AddSelection(1,false)
    --self.controllerC1.selectedIndex = 1 
    self:send()
end
--一件提醒
function FriendPanel:onOneKeyTips(context)
    -- body
    --plog("一件提醒")
    if self.data and self.data.friendList and #self.data.friendList>0 then
        local data = context.sender.data
        proxy.FriendProxy:sendMsg(1070302,{roleId = 0,type = 3})
    else
        GComAlter(language.friend27)
    end
end
--一件领取
function FriendPanel:onOneKeyGet( context)
    -- body
    --plog("一件领取")
    if self.data and self.data.friendList and #self.data.friendList>0 then
        proxy.FriendProxy:sendMsg(1070302,{roleId = 0,type = 4})
    else
        GComAlter(language.friend27)
    end
end
--一件赠送
function FriendPanel:onOneKeySend( context )
    -- body
    --plog("一件赠送")
    if self.data and self.data.friendList and #self.data.friendList>0 then
        proxy.FriendProxy:sendMsg(1070301,{roleId = 0,type = 2})
    else
        GComAlter(language.friend27)
    end
end
--搜索
function FriendPanel:onSearch()
    -- body
    --plog("搜索")
    if self.inputText.text == "" then
        GComAlter(language.friend25)
        return
    end

    proxy.FriendProxy:sendMsg(1070102,{roleName = self.inputText.text})
end
--换一批
function FriendPanel:onSearchNext()
    -- body
    --plog("换一批")
    proxy.FriendProxy:sendMsg(1070102,{roleName = ""})
end
--一键添加
function FriendPanel:onOneKeyAdd()
    -- body
    --plog("一键添加")
    if self.data and self.data.list and #self.data.list>0 then
        local param = {roleIds={},reqType=1}
        for k  ,v in pairs(self.data.list) do 
            if v.applyStatu == 0 then
                table.insert(param.roleIds,v.roleId)
            end
        end
        if #param.roleIds>0 then
            proxy.FriendProxy:sendMsg(1070103,param)
        end
    else
        GComAlter(language.friend25)
    end
end
--全部忽略
function FriendPanel:onIngoreAll()
    -- body
    if self.data and self.data.applyList and #self.data.applyList>0 then
        local param = {roleIds={},reqType=2}
        for k  ,v in pairs(self.data.applyList) do 
            if v.applyStatu == 0 then
                table.insert(param.roleIds,v.roleId)
            end
        end
        if #param.roleIds then
            proxy.FriendProxy:sendMsg(1070105,param)
        end
    else
        GComAlter(language.friend26)
    end
end
--全部统一
function FriendPanel:onArgeeAll()
    -- body
    if self.data and self.data.applyList and #self.data.applyList>0 then
        local param = {roleIds={},reqType=1}
        for k  ,v in pairs(self.data.applyList) do 
            if v.applyStatu == 0 then
                table.insert(param.roleIds,v.roleId)
            end
        end
        if #param.roleIds>0 then
            proxy.FriendProxy:sendMsg(1070105,param)
        end
    else
        GComAlter(language.friend26)
    end
end

return FriendPanel