--
-- Author: 
-- Date: 2017-07-24 10:35:05
--

local MarryXinDong = class("MarryXinDong",import("game.base.Ref"))

function MarryXinDong:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n3")
    self:initView()
end

function MarryXinDong:initView()
    -- body
    --6个形象组件
    self.itemlist = {}
    for i = 2 , 7 do
        local item = self.view:GetChild("n"..i)
        table.insert(self.itemlist,item)
    end

    local btnReset = self.view:GetChild("n10")
    btnReset.onClick:Add(self.onReflesh,self)

    self.c1 = self.view:GetController("c1")
end

function MarryXinDong:setData(index)
    -- body
    self.index = index or 0
    local sex = cache.PlayerCache:getSex()
    if sex == 1 then
        self.othersex = 2 
    else
        self.othersex = 1
    end
    self.c1.selectedIndex = self.index
    if self.index == 1 then --请求
        proxy.MarryProxy:sendMsg(1390107, {reqType = 1,gotLevel = 0})
    else
        --创建虚拟列表
        self.data = {}
        self.data.oppoSexInfos = {}
        self:randomList(1)
        --默认点亮的灯
        self.data.oppoSexInfos[2].isBd = true
        self.data.oppoSexInfos[4].isBd = true
        self:initList()
    end
end

function MarryXinDong:randomList(index)
    -- body
    
    for i = index or 1 , 6 do
        local t = {
            roleId = 0,
            name = conf.RoleConf:getRandName(self.othersex),
            qm = 0,
            isFriend = 0,
            isBd = 0
        }
        table.insert(self.data.oppoSexInfos,t)
    end

    local number = 0
    for k ,v in pairs(self.data.oppoSexInfos) do
        if v.isBd == 1 then
            number = number + 1
            if number >= 2 then
                break
            end
        end
    end
    if number < 2 then
        for i =  6 - (2-number) + 1,6 do
            self.data.oppoSexInfos[i].isBd = 1
        end
    end

    --printt(self.data.oppoSexInfos)
end

function MarryXinDong:initModel(item,v)
    -- body
    local panel = item:GetChild("n1")
    local panellight = item:GetChild("n7")
    local id = RoleSexModel[self.othersex].id
    local x = RoleSexModel[self.othersex].angle
    local obj 
    local c1 = item:GetController("c1")
    local c2 = item:GetController("c2")
    local name = item:GetChild("n3")

    local str = string.split(v.name,".")
    if #str == 2 then
        name.text = str[2]
    else
        name.text = v.name
    end
    
    c1.selectedIndex = self.index
    if v.roleId == 0 then
        obj = self.parent:addModel(id,panel)
    else
        obj = self.parent:addModel(id,panel)
    end
    
    obj:setScale(80)
    obj:setRotationXYZ(0,x,0)
    obj:setPosition(panel.actualWidth/2,-panel.actualHeight-180,500)
    --是否好友
    if v.isFriend == 1 then
        c2.selectedIndex = 1
    else
        c2.selectedIndex = 0 
    end
    --是否亮灯
    if v.isBd == 1 then
        --plog("aaaaaaa")
        panellight.visible = true
        local effect = self.parent:addEffect(4020126, panellight)
        effect.LocalPosition = Vector3(panellight.actualWidth/2,-panellight.actualHeight/2+40,0)
    else
        panellight.visible = false
    end 

    local btn = item:GetChild("n4")
    btn.data = v
    btn.onClick:Add(self.onRequset,self)

    item.data = v 
    item.onClick:Add(self.onSeeCall,self)
end

function MarryXinDong:onRequset(context)
    -- body
    context:StopPropagation()

    local data = context.sender.data
    if data.roleId == 0 then
        GComAlter(language.kuafu108)
        return 
    end

    if data.isFriend == 0 then
        GComAlter(language.kuafu108)
        proxy.FriendProxy:sendMsg(1070103,{reqType = 1,roleIds = {data.roleId}})
    else
        local level = conf.MarryConf:getValue("marry_level")
        if cache.PlayerCache:getRoleLevel()< level then
            GComAlter(string.format(language.kuafu34,level))
            return
        end
        mgr.ViewMgr:openView2(ViewName.MarryApplyView,data)
        self.parent:onBtnClose()
    end
end

function MarryXinDong:onSeeCall(context)
    -- body
    local data = context.sender.data
    if data.roleId ~= 0 then
        local param = {
            roleId = data.roleId,
            svrId = 0
        }    
        GSeePlayerInfo(param)
    else
        GComAlter(language.kuafu107)
    end
end

function MarryXinDong:initList()
    -- body
    for k ,v in pairs(self.data.oppoSexInfos) do
        local item = self.itemlist[k]
        if item then
            self:initModel(item,v)
        end
    end
end


function MarryXinDong:onReflesh()
    -- body
    --换一批
    proxy.MarryProxy:sendMsg(1390107, {reqType = 1,gotLevel = 0})
end

function MarryXinDong:addMsgCallBack(data)
    -- body
    if self.index ~= 1 then
        return
    end
    if data.msgId == 5390107 and data.reqType == 1 then
        self.data = data
        local index = #self.data.oppoSexInfos
        if index < 6 then
            self:randomList(index+1)
        end
        self:initList()
    elseif data.msgId == 5070103 then
        --待用,申请添加好友返回
        -- for k ,v in pairs(data.roleIds) do
        -- end
    end
end


return MarryXinDong