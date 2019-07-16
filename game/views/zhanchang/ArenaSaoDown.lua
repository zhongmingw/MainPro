--
-- Author: 
-- Date: 2017-04-06 20:26:31
--

local ArenaSaoDown = class("ArenaSaoDown", base.BaseView)

function ArenaSaoDown:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function ArenaSaoDown:initData(data)
    -- body
    self.time.visible = true
    self.overTime = 10
    self:addTimer(1, -1, handler(self,handler(self,self.onTimer)))
    self.tuichu = false --是否退出异场景
    self.data = data

    self.width = 0

    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effect = self:addEffect(4020104, self.view:GetChild("n15"))
    --plog(cache.ArenaCache:getGuide(),cache.TaskCache:CheckTaskID(1110))
    if cache.ArenaCache:getGuide() and cache.TaskCache:CheckTaskID(1111) then
        --cache.ArenaCache:setGuide(false)
        self:startGuide(conf.XinShouConf:getOpenModule(1070))
    end
    if not cache.ArenaCache:getIsAreanFight() then
        self.view:GetChild("n8").visible = false
        self.dec1.visible = false
    else
        self.dec1.visible = true
        self.view:GetChild("n8").visible = true
    end
    mgr.SoundMgr:playSound(Audios[1])
end

function ArenaSaoDown:initView()
    local btnClose = self.view:GetChild("n7")
    btnClose.onClick:Add(self.onCloseView,self)

    local btnShop = self.view:GetChild("n8")
    btnShop.onClick:Add(self.onShop,self)

    self.listView = self.view:GetChild("n12")
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self.dec1 = self.view:GetChild("n10")
    self.dec1.text = ""

    self.time = self.view:GetChild("n11")
    self.time.text = ""

    self.c1 = self.view:GetController("c1")

    if g_is_banshu then
        btnShop:SetScale(0,0)
    end
end

function ArenaSaoDown:onTimer()
    -- body
    if self.overTime <= 0 then
        self:onCloseView()
        return
    end
    self.overTime = self.overTime - 1
    self.time.text = string.format(language.kaifu38,self.overTime)
    
end

function ArenaSaoDown:setHookTiaoguo()
    self.time.visible = false
    self.overTime = 9999
end

function ArenaSaoDown:celldata( index, obj )
    -- body
    local data = self.data.items[index+1]
    local t = {mid = data.mid,amount = data.amount}
    GSetItemData(obj,t)

    self.width = obj.actualWidth + self.width
    if 8 >= self.listView.numItems then
        if index + 1 == self.listView.numItems then
            self.listView.viewWidth = self.width
        else
            self.width = self.width + self.listView.columnGap
        end
    else
        self.listView.viewWidth = 658
    end
end

function ArenaSaoDown:setData(data_)

end

function ArenaSaoDown:add8100102()
    -- body
    if self.data.type == 0 then
        if self.data.win == 1 then
            local data = cache.ArenaCache:getData()
            if not data or data.rank > self.data.rank then
                local t = clone(language.arena24)
                t[2].text  = string.format(t[2].text,self.data.rank)
                self.dec1.text = mgr.TextMgr:getTextByTable(t)
            else
                self.dec1.text = language.arena30
            end

            self.c1.selectedIndex = 1
        else
            local t = clone(language.arena25)
            self.dec1.text = mgr.TextMgr:getTextByTable(t)

            self.c1.selectedIndex = 0
        end
    else
        if self.data.win == 1 then
            self.c1.selectedIndex = 1
        else
            self.c1.selectedIndex = 0
        end
    end

    
    self.listView.numItems = #self.data.items
end

function ArenaSaoDown:add5310106()
    -- body
    self.c1.selectedIndex = 1
    local t = clone(language.arena26)
    self.dec1.text = mgr.TextMgr:getTextByTable(t)

    self.listView.numItems = #self.data.items
end

--跨服排位结算
function ArenaSaoDown:add8230101(data)
    self.tuichu = true
    self.dec1.visible = true
    local pwLev = data.pwLev
    local oldPwsLev = data.oldPwLev
    if not pwLev then
        if data.clacInfos then--组队排位结算
            local roleId = cache.PlayerCache:getRoleId()
            for k,v in pairs(data.clacInfos) do
                if roleId == v.roleId then
                    pwLev = v.pwLev
                    oldPwsLev = v.oldPwsLev
                    break
                end
            end
        end
    end
    if data.win == 1 then
        self.dec1.text = language.qualifier14
    else
        if pwLev < oldPwsLev then
            self.dec1.text = language.qualifier15
        else
            self.dec1.text = language.qualifier15_1
        end
    end

    self.view:GetChild("n8").visible = false
    if self.data.win == 1 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
    print("经验",data.gotExp)
    if data.gotExp > 0 then
        local item = {mid = 221061001,amount = data.gotExp}
        table.insert(self.data.items,item)
    end
    self.listView.numItems = #self.data.items
end

function ArenaSaoDown:onShop()
    -- body
    
    mgr.ModuleMgr:setoldData({param ={id = 1046} ,tarindex = 1045}) --竞技场
    local view = mgr.ViewMgr:get(ViewName.ArenaFightView) 
    if view then
        cache.FubenCache:setFubenModular(1045)
        self:onCloseView()
    else
        GOpenView({id = 1045})
    end
end

function ArenaSaoDown:onCloseView()
    -- body
    --plog("aaaa")
    self.overTime = 10
    if self.tuichu then
        mgr.FubenMgr:quitFuben()
    end
    self:closeView()
    local view = mgr.ViewMgr:get(ViewName.ArenaFightView) 
    if view then
        view:onCloseView()
    end  
end

return ArenaSaoDown