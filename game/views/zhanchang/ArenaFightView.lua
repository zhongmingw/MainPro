--
-- Author: 
-- Date: 2017-04-10 17:47:52
--

local ArenaFightView = class("ArenaFightView", base.BaseView)

function ArenaFightView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3

    self.data = {}
end

function ArenaFightView:initData()
    -- body
    local confdata = conf.SceneConf:getSceneById(ArenaScene)
    self.count = confdata.over_time/1000
    self:addTimer(1,self.count,handler(self,self.onTimer))
    
    self:setData()
end

function ArenaFightView:initView()
    local btn = self.view:GetChild("n0")
    btn.onClick:Add(self.onTiaoGuo,self)

    self.bar1 = self.view:GetChild("n21")
    self.icon1 = self.view:GetChild("n6"):GetChild("n3")
    self.power1 = self.view:GetChild("n18")
    self.name1 = self.view:GetChild("n23")

    self.bar2 = self.view:GetChild("n22")
    self.icon2 = self.view:GetChild("n10"):GetChild("n3")
    self.power2 = self.view:GetChild("n20")
    self.name2 = self.view:GetChild("n24")

    self.labtime = self.view:GetChild("n13")

    if g_is_banshu then
        self.view:GetChild("n11"):SetScale(0,0)
    end
end

function ArenaFightView:onTimer()
    -- body
    if self.count < 0 then
        return    
    end

    self.labtime.text = GTotimeString(self.count)
    self.count = self.count - 1
end

function ArenaFightView:updateHp(roleId,hp)
    -- body
    --plog("roleId",roleId)
    if tostring(roleId) == "1" then
        self.bar1.value = hp
        --plog(hp,self.bar1.max)
    else
        self.bar2.value = hp
        --plog(hp,self.bar2.max)
    end
end

function ArenaFightView:setData(data_)
    -- print("debug.traceback>>>>>>>>>>>",debug.traceback())
    -- print("data_.roleId",data_.roleId)
    if data_ then
        self.data[data_.roleId] = data_ 
    end
    if not self.isOpen then
        return 
    end

    if self.data["1"]  then
        self.bar1.value = self.data["1"].attris[104] 
        self.bar1.max = self.data["1"].attris[105] 
        self.power1.text = self.data["1"].attris[501]
        self.name1.text = self.data["1"].roleName

        self.icon1.url = GGetMsgByRoleIcon(self.data["1"].roleIcon,cache.PlayerCache:getRoleId(),function(t)
            if self.icon1 then
                self.icon1.url = t.headUrl
            end
        end).headUrl
    end
    if self.data["2"] then
        self.bar2.value = self.data["2"].attris[104] 
        self.bar2.max = self.data["2"].attris[105] 
        self.power2.text = self.data["2"].attris[501]
        self.name2.text = self.data["2"].roleName

        self.icon2.url = GGetMsgByRoleIcon(self.data["2"].roleIcon,cache.ArenaCache:getOtherRoleId(),function(t)
            if self.icon2 then
                self.icon2.url = t.headUrl
            end
        end).headUrl
    end
end

function ArenaFightView:onTiaoGuo()
    -- body
    local isArenaFight = cache.ArenaCache:getIsAreanFight()
    if isArenaFight then
        proxy.ArenaProxy:send(1310107)
    else
        local sId = cache.PlayerCache:getSId()
        if mgr.FubenMgr:isDiWangScene(sId) then
            proxy.DiWangProxy:sendMsg(1550103)
        elseif mgr.FubenMgr:isYiJiScene(sId) then
            proxy.YiJiTanSuoProxy:sendMsg(1640109)
        else
            proxy.ActivityProxy:sendMsg(1030135,{reqType = 0})
        end
    end
end

function ArenaFightView:onCloseView()
    -- body
    
    mgr.FubenMgr:quitFuben()
    self:closeView()
end

function ArenaFightView:add8100102(data)
    -- body
    mgr.ViewMgr:openView(ViewName.ArenaSaoDown,function(view)
        -- body
        view:add8100102()
    end,data)
end

return ArenaFightView