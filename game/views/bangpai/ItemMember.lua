--
-- Author: 
-- Date: 2017-03-07 11:52:11
--

local ItemMember = class("ItemMember",import("game.base.Ref"))

local language_pos = {
    language.bangpai47,
    language.bangpai04,
    language.bangpai03,
    language.bangpai02,
    language.bangpai01,
}
local BG_HIGHT = {
    [1] = 271,
    [2] = 230,
    [3] = 187,
}
function ItemMember:ctor(param)
    self.view = param
    self:initView()
end

function ItemMember:initView()
    -- body
    self.view.onClick:Add(self.onView,self)

    self.listView = self.view:GetChild("n2")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    local dec1 = self.view:GetChild("n3")
    dec1.text = language.bangpai35

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.bangpai36

    local dec1 = self.view:GetChild("n5")
    dec1.text = language.bangpai44

    local dec1 = self.view:GetChild("n6")
    dec1.text = language.bangpai37

    local dec1 = self.view:GetChild("n7")
    dec1.text = language.bangpai46
    

    self.guoobject = self.view:GetChild("n8")
    self.list = {}
    self.list[1] = self.guoobject:GetChild("n1").y
    self.list[2] = self.guoobject:GetChild("n2").y
    self.list[3] = self.guoobject:GetChild("n3").y
    self.list[4] = self.guoobject:GetChild("n4").y
    self.list[5] = self.guoobject:GetChild("n5").y
    self.list[6] = self.guoobject:GetChild("n6").y
    self.list[7] = self.guoobject:GetChild("n7").y
    self.guoobject.visible = false
    --Stage.inst.onTouchBegin:Add(self.onTouchBegin,self)
end

function ItemMember:celldata(index,obj)
    -- body
    local data = self.data[index+1]
    --名字
    local lab1 = obj:GetChild("n1")
    lab1.text = mgr.TextMgr:getTextColorStr(data.roleName, 6)
    -- local str = string.split(data.roleName,".")
    -- if #str == 2 then
    --     local param = {
    --         {text = str[1]..".",color = 7},
    --         {text = str[2],color = 6}
    --     }
    --     lab1.text = mgr.TextMgr:getTextByTable(param)
    -- else
    --     lab1.text = mgr.TextMgr:getTextColorStr(data.roleName, 6)
    -- end
    -- printt("帮派成员信息",data)
    local imgv = obj:GetChild("n9")
    local labvip = obj:GetChild("n10")

    labvip.text = data.vipLevel 
    if data.vipLevel <= 1 then
        imgv.visible = false
        labvip.visible = false
    else
        imgv.visible = true
        labvip.visible = true
    end

    --等级
    local lab2 = obj:GetChild("n2")
    lab2.text = data.roleLev

    --职位
    local lab3 = obj:GetChild("n3")
    lab3.text = language_pos[data.job+1]
    --贡献
    local lab4 = obj:GetChild("n4")
    lab4.text = data.power
    --在线时间
    local lab5 = obj:GetChild("n5")
    local str = GChangeToHMS(data.offLineTime)
    if data.offLineTime <= 0 then
        lab5.text = mgr.TextMgr:getTextColorStr(str,7)
    else
        lab5.text = mgr.TextMgr:getTextColorStr(str,8)
    end
    
    local btn =  obj:GetChild("n8")
    btn.onClick:Add(self.onCallBack,self)
    btn:GetChild("title").text = language.bangpai48
    local roleId = cache.PlayerCache:getRoleId()
    if roleId == data.roleId then
        btn.visible = false
    else
        btn.visible = true
    end
    -- local job = cache.BangPaiCache:getgangJob()
    -- if job ~= data.job then
    --     if data.job == 4 then
    --         btn:GetChild("title").text = language.bangpai58
    --     else
    --         btn:GetChild("title").text = language.bangpai48
    --         if  job >= 3 then
    --             btn.visible = true
    --         else
    --             btn.visible = false
    --         end
    --     end
    -- else
    --     btn.visible = false
    -- end

    btn.data = data 
end 

function ItemMember:setData(data)
    -- body
    self.data = cache.BangPaiCache:getMember()

    --排个序
    table.sort(self.data,function(a,b)
        -- body
        if a.job ~= b.job then
            return a.job > b.job
        else
            if a.offLineTime == b.offLineTime then
                return a.power > b.power
            else
                return a.offLineTime < b.offLineTime
            end
            --return a.power > b.power
        end
    end)


    self.listView.numItems = #self.data
end

function ItemMember:initguoObject(data)
    -- body

    self.guoobject.visible = true
    local job = cache.BangPaiCache:getgangJob()
    if job == 4 then
        self.guoobject:GetChild("n0").height = BG_HIGHT[1]
    elseif job == 3 then
        self.guoobject:GetChild("n0").height = BG_HIGHT[2]
    else
        self.guoobject:GetChild("n0").height = BG_HIGHT[3]
    end
    --让帮主
    local btn = self.guoobject:GetChild("n1")
    btn:GetChild("title").text = language.bangpai49
    btn.onClick:Add(self.onChange,self)
    --plog(job,job)
    if  job == 4 then
        btn.visible = true
    else
        btn.visible = false
    end
    
    --设置位置
    local btnSet = self.guoobject:GetChild("n2")
    --btnSet.onTouchBegin:Add(self.onTouchBegin,self)
    btnSet:GetChild("title").text = language.bangpai51
    btnSet.onClick:Add(self.onBtnset,self)
    if tonumber(job) >= 3 then
        btnSet.visible = true
        if job <= data.job then
            btnSet.grayed = true
            btnSet.touchable = false
        else
            btnSet.grayed = false
            btnSet.touchable = true
        end
    else
        btnSet.visible = false
    end
    
    --T人
    local btnOut = self.guoobject:GetChild("n3")
    btnOut:GetChild("title").text = language.bangpai57
    btnOut.onClick:Add(self.onOutGang,self)
    if tonumber(job) >= 3 then
        btnOut.visible = true
        if job <= data.job then
            btnOut.grayed = true
            btnOut.touchable = false
        else
            btnOut.grayed = false
            btnOut.touchable = true
        end
    else
        btnOut.visible = false
    end

    --查看信息
    local btnCheck = self.guoobject:GetChild("n4")
    btnCheck:GetChild("title").text = language.friend13
    btnCheck.onClick:Add(self.onCheckInfo,self)
    btnCheck.visible = true
    --私聊
    local btnChat = self.guoobject:GetChild("n5")
    btnChat:GetChild("title").text = language.friend14
    btnChat.onClick:Add(self.onChat,self)
    btnChat.visible = true
    if data.relation == 0 then
        btnChat.grayed = true
        btnChat.touchable = false
    else
        btnChat.grayed = false
        btnChat.touchable = true
    end
    --添加好友
    local btnAdd = self.guoobject:GetChild("n6")
    btnAdd:GetChild("title").text = language.friend16
    if data.relation == 0 then
        btnAdd:GetChild("title").text = language.friend30
    end
    btnAdd.onClick:Add(self.onAdd,self)
    btnAdd.visible = true
    --弹劾
    local btnAccuse = self.guoobject:GetChild("n7")
    btnAccuse:GetChild("title").text = language.bangpai58
    btnAccuse.onClick:Add(self.onAccuse,self)
    if data.job == 4 then
        btnAccuse.visible = true
    else
        btnAccuse.visible = false
    end
    --
    --动态计算位置
    local index = 1
    if btn.visible then
        btn.y = self.list[index]
        -- print("禅让位置>>>>>>>",btn.y)
        index = index+ 1
    end
    if btnSet.visible then
        btnSet.y = self.list[index]
        -- print("设置位置>>>>>>>",btnSet.y)
        index = index+ 1
    end
    if btnOut.visible then
        btnOut.y = self.list[index]
        -- print("踢出位置>>>>>>>",btnOut.y)
        index = index+ 1
    end
    if btnCheck.visible then
        btnCheck.y = self.list[index]
        -- print("查看位置>>>>>>>",btnCheck.y)
        index = index+ 1
    end
    if btnChat.visible then
        btnChat.y = self.list[index]
        -- print("私聊位置>>>>>>>",btnChat.y)
        index = index+ 1
    end
    if btnAdd.visible then
        btnAdd.y = self.list[index]
        -- print("添加位置>>>>>>>",btnAdd.y)
        index = index+ 1
    end
    if btnAccuse.visible then
        btnAccuse.y = self.list[index]
        -- print("弹劾位置>>>>>>>",btnAccuse.y)
        index = index+ 1
    end

    self.selectdata = data  
end

function ItemMember:onTouchBegin(context)
    -- body
    self.pos = {x = context.data.x,y = context.data.y}
    --print(context.data.x, context.data.y)
end

function ItemMember:onCallBack(context)
    -- body

    context:StopPropagation()

    local btn = context.sender
    local data = btn.data
    -- if data.job == 4 then--弹劾
    --     proxy.BangPaiProxy:sendMsg(1250210)
    --     return
    -- end

    local pos = btn:LocalToGlobal(btn.xy)
    local pos1 = self.view:GlobalToLocal(pos)
    if pos1.y  + btn.height  + self.guoobject.height > self.listView.viewHeight then
        self.guoobject.y = pos1.y - self.guoobject.height
    else
        self.guoobject.y = pos1.y + btn.height
    end

    
    self:initguoObject(data)
end

function ItemMember:onView()
    -- body
    self.guoobject.visible = false
end

--让帮主
function ItemMember:onChange()
    -- body
    local param = {}
    param.type = 2
    param.sure = function()
        -- body
        self.guoobject.visible = false
        proxy.BangPaiProxy:sendMsg(1250205,{roleId = self.selectdata.roleId})
    end
    local t = clone(language.bangpai50) 
    t[2].text = string.format(t[2].text,self.selectdata.roleName)
    param.richtext = mgr.TextMgr:getTextByTable(t)
    GComAlter(param)
end
--设定职位
function ItemMember:onBtnset()
    -- body
    self.guoobject.visible = false
    mgr.ViewMgr:openView(ViewName.BangPaiSetJob,function(view)
        -- body
        view:setData()
    end, self.selectdata)
end
--
function ItemMember:onOutGang()
    -- body
    local param = {}
    param.type = 2
    param.sure = function()
        -- body
        self.guoobject.visible = false
        proxy.BangPaiProxy:sendMsg(1250203,{roleId = self.selectdata.roleId})
    end
    local t = clone(language.bangpai52) 
    t[2].text = string.format(t[2].text,self.selectdata.roleName)
    param.richtext = mgr.TextMgr:getTextByTable(t)
    GComAlter(param)
end

function ItemMember:onCheckInfo()
    local param = {}
    param.roleId = self.selectdata.roleId
    param.svrId = self.selectdata.mainSvrId or 0
    --printt(param)
    GSeePlayerInfo(param)
end

function ItemMember:onChat()
    local confData = conf.ChatConf:getChatData(7)
    local openlv = confData and confData.open_lv or 1
    local level = self.selectdata and self.selectdata.roleLev or 1
    local chatName = confData and confData.name or ""
    local chatVipLv = conf.SysConf:getValue("vip_not_limit_chat")
    -- if G_AgentChatLimit() then
    --     local LimitData = conf.ChatConf:getAgentChatById(g_var.channelId)
    --     local limitLv = 0
    --     for k,v in pairs(LimitData.open_lev) do
    --         if confData.type == v[1] then
    --             limitLv = v[2]
    --             break
    --         end
    --     end
    --     if cache.PlayerCache:getRoleLevel() < limitLv and cache.PlayerCache:getVipLv() < chatVipLv then
    --         GComAlter(string.format(language.chatSend16, chatName,limitLv))
    --         return
    --     end
    -- elseif (cache.PlayerCache:getRoleLevel() < openlv) and cache.PlayerCache:getVipLv() < chatVipLv then
    --     GComAlter(string.format(language.chatSend16, chatName,openlv))
    --     return
    -- end
    local data  = {roleIcon = self.selectdata.roleIcon,roleId = self.selectdata.roleId,roleName = self.selectdata.roleName,level = self.selectdata.roleLev,relation = self.selectdata.relation}
    local param = {id = 1011,roleData = data}
    GOpenView(param)
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view then
        view:closeView()
    end
end

function ItemMember:onAdd()
    if self.selectdata.relation == 0 then
        t = clone(language.friend32)
    else
        t = clone(language.friend18)
    end
    t[2].text = string.format(t[2].text,self.selectdata.roleName or "")

    local data = {}
    data.type = 2 
    data.richtext = mgr.TextMgr:getTextByTable(t)
    data.sure = function()
        -- body
        local param = {}
        param.reqType = (self.selectdata.relation == 0) and 1 or 2 
        param.roleIds = {}
        table.insert(param.roleIds,self.selectdata.roleId)

        proxy.FriendProxy:sendMsg(1070103,param)
    end

    data.cancel = function ()
        -- body
    end
    GComAlter(data) 
end

function ItemMember:onAccuse()
    if self.selectdata.job == 4 then--弹劾
        proxy.BangPaiProxy:sendMsg(1250210)
        return
    end
end


return ItemMember