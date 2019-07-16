--
-- Author: wx 我的好友列表
-- Date: 2017-01-13 14:36:37
--好友列表

local ListMyFriend = class("ListMyFriend", import("game.base.Ref"))
--param 组件
function ListMyFriend:ctor(param)
    self.view = param
    self:initView()
end

function ListMyFriend:initView()
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0
    --self.view.onClickItem:Add(self.onItemCallBack,self)
end

function ListMyFriend:celldata( index,obj )
    -- body
    if index + 1 >= self.view.numItems then
        if not self.data then
            return 
        end 
        if self.data.totalSum == self.data.page then 
            --没有下一页了
            --return
        else
            proxy.FriendProxy:sendMsg(1070101,{page = self.data.page + 1})
        end
    end
    --头像
    local data = self.data.friendList[index+1]
    local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }
    local seeBtn = obj:GetChild("n12")
    seeBtn.data = index
    GBtnGongGongSuCai_050(seeBtn,t)
    seeBtn.onClick:Add(self.onManagerFriend, self)
    --在线否
    local textonline = obj:GetChild("n11")
    if data.offLineTime<=0 then
        textonline.text = mgr.TextMgr:getTextColorStr(language.friend07,7) 
    else
        if data.offLineTime<3600 then
            --print(data.name,"math.max(data.offLineTime/60)",math.max(data.offLineTime/60))
            local dd = math.max(data.offLineTime/60)
            if dd < 1 then
                dd = 1
            end
            textonline.text = string.format(language.friend08[1],dd)
        elseif data.offLineTime<3600*24 then
            textonline.text = string.format(language.friend08[2],math.floor(data.offLineTime/3600))
        elseif data.offLineTime<3600*24*3 then
            textonline.text = string.format(language.friend08[3],math.floor(data.offLineTime/(3600*24)))
        else
            textonline.text = language.friend08[4]
        end

        textonline.text = mgr.TextMgr:getTextColorStr(textonline.text,9)  
    end
    --名字
    local name = obj:GetChild("n10")
    name.text = data.name
    --EVE 亲密度
    local qm = obj:GetChild("n20")
    qm.scaleX = 0
    -- qm.text = data.qm
    --魅力
    local meili = obj:GetChild("n9") 
    meili.text = GTransFormNum1(data.power)
    -- local confData = conf.FriendConf:getDataById(data.charmStepId) --EVE 注释原因：魅力的地方改为显示战斗力
    -- meili.text = confData and confData.name or ""

    local btnGet = obj:GetChild("n13")
    btnGet.data = data
    btnGet:GetChild("title").visible = false
    btnGet.onClick:Add(self.onBtnGet,self)
    local dec = obj:GetChild("n5")
    dec.text = language.friend22

    local btnSong = obj:GetChild("n16")
    btnSong.data = data
    btnSong:GetChild("title").text = language.friend23
    btnSong.onClick:Add(self.onBtnSong,self)

    local btnTixing = obj:GetChild("n19")
    btnTixing.data = data
    
    btnTixing.onClick:Add(self.onbtnTiXing,self)

    local btnCaozuo = obj:GetChild("n18")
    btnCaozuo.data = data
    btnCaozuo:GetChild("title").text = language.friend20
    btnCaozuo.onClick:Add(self.onBtnCaoZuo,self)


    local controllerC1 = obj:GetController("c1")
    local controllerC2 = obj:GetController("c2")

    if data.recvHeartStatus == 0 then --提醒松红点
        controllerC1.selectedIndex = 2
        btnTixing.touchable = true
        btnTixing:GetChild("title").text = language.friend21
    elseif data.recvHeartStatus == 3 then
        controllerC1.selectedIndex = 3
        btnTixing.touchable = false
        btnTixing:GetChild("title").text = language.friend24
    elseif data.recvHeartStatus == 1 then--1:可领取
        controllerC1.selectedIndex = 0
    else
        controllerC1.selectedIndex = 1 --已经领取了
    end

    if data.presentStatus == 0 then  --0:未赠送
        controllerC2.selectedIndex = 0
    else
        controllerC2.selectedIndex = 1
    end

    textonline.sortingOrder = 2
    name.sortingOrder = 2
    meili.sortingOrder = 2
    dec.sortingOrder = 2
end

function ListMyFriend:onManagerFriend(context)
    local index = context.sender.data
    local data = self.data.friendList[index+1]
    local param = {}
    param.level = data.level
    param.roleIcon = data.roleIcon
    param.roleName = data.name
    param.roleId = data.roleId
    param.trade = true
    --plog("param.roleId="..param.roleId)
    --param.pos = {x=0,y=0}--位置偏移
    mgr.ViewMgr:openView(ViewName.FriendTips, function( view )
        -- body
        view:setData(param)
    end)
end

function ListMyFriend:setData(data,cur)
    -- body
    self.data = data
    self.view.numItems = #self.data.friendList
    self.view:RefreshVirtualList()
    --self.view.scrollPane:ScrollTop()
end

function ListMyFriend:onBtnGet(context)
    -- body
    local data = context.sender.data
    proxy.FriendProxy:sendMsg(1070302,{roleId = data.roleId,type = 2})
end

function ListMyFriend:onBtnSong(context)
    -- body
    local data = context.sender.data
    proxy.FriendProxy:sendMsg(1070301,{roleId = data.roleId,type = 1})
end

function ListMyFriend:onbtnTiXing(context)
    -- body
    local data = context.sender.data
    proxy.FriendProxy:sendMsg(1070302,{roleId = data.roleId,type = 1})

end

function ListMyFriend:onBtnCaoZuo(context)
    -- body
    local data = context.sender.data
    local param = {}
    param.level = data.level
    param.roleIcon = data.roleIcon
    param.roleName = data.name
    param.roleId = data.roleId
    --param.pos = {x=0,y=0}--位置偏移
    param.trade = true
    mgr.ViewMgr:openView(ViewName.FriendTips, function( view )
        -- body
        view:setData(param)
    end)
end
--请求删除好友
function ListMyFriend:add5070103(data)
    -- body
    if data.reqType == 1 then
        return
    end

    local delete = {}
    for k ,v in pairs(data.roleIds) do 
        for i , j in pairs(self.data.friendList) do
            if v == j.roleId then
                table.insert(delete,i)
                break
            end
        end
    end

    table.sort( delete, function( a,b )
        -- body
        return a>b
    end )

    for k ,v in pairs(delete) do 
        table.remove(self.data.friendList,v)
    end

    self.view.numItems = #self.data.friendList
    --self.view:RefreshVirtualList()
end
--请求黑名单添加
function ListMyFriend:add5070202(data)
    -- body
    if data.reqType == 2 then
        return
    end
    local remove  
    for i , j in pairs(self.data.friendList) do
        if data.roleId == j.roleId then
            remove = i
            break
        end
    end
    if remove then
        table.remove(self.data.friendList,remove)
        self.view.numItems = #self.data.friendList
        --self.view:RefreshVirtualList()
    end
end


return ListMyFriend