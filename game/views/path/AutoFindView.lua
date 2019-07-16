--
-- Author: 
-- Date: 2017-05-12 20:28:18
--

local AutoFindView = class("AutoFindView", base.BaseView)

function AutoFindView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level0 
end

function AutoFindView:initData(index)
    -- body
    local sId = cache.PlayerCache:getSId()
    if sId == 204001 then
        self.view.visible = false
        return
    end
    self.view.visible = true

    self.c1.selectedIndex = index
    local quickBtn = self.view:GetChild("n3")
    quickBtn.onClick:Add(self.onQuickClick, self)
    if cache.PlayerCache:VipIsActivate(1) then --小飞鞋显隐控制
        quickBtn.visible = true
        local curTime = cache.VipChargeCache:getXianzunTyTime() or 0
        if curTime > 0 then --体验中
            self.view:GetChild("n9").visible = false --直接屏蔽什么情况下都不显示
            self.view:GetChild("n10").visible = false
        else                --体验结束
            self.view:GetChild("n9").visible = false
            self.view:GetChild("n10").visible = false
        end
    else
        self.view:GetChild("n9").visible = false
        self.view:GetChild("n10").visible = false
        if cache.TaskCache:isfinish(1064) then
            quickBtn.visible = true
        else
            quickBtn.visible = false
        end
    end

    --副本屏蔽
    if mgr.FubenMgr:checkScene(cache.PlayerCache:getSId()) then
        if not mgr.FubenMgr:isKuaFuWar(cache.PlayerCache:getSId()) then
            --灵界夺宝，可以用小飞鞋 2018/3/13
            quickBtn.visible = false
        end 
    end

    --自动挂机获得经验预览
    self.bg = self.view:GetChild("n13")
    self.bg.visible = false
    self.txtMg = self.view:GetChild("n14")
    self.txtMg.visible = false
    self.ExpTxt = self.view:GetChild("n15")
    self.ExpTxt.visible = false

    if self.timers then
        mgr.TimerMgr:removeTimer(self.timers)
        self.timers = nil
    end
    local sId = cache.PlayerCache:getSId()
    if (GIsYeWaiScene() or 
        mgr.FubenMgr:isLevel(sId) or 
        mgr.FubenMgr:isMjxlScene(sId) or 
        mgr.FubenMgr:isHjzyScene(sId)) and index == 1 then
        self.timeCount = 0
        -- self.minCount = 0
        self.roleExp = cache.PlayerCache:getRoleExp() --玩家挂机时的经验
        self.roleAddExp = 0--记录玩家挂机15秒后增加的经验
        self.timers = self:addTimer(1,-1,handler(self,self.onTiemr))
    end

    if g_is_banshu then
        quickBtn:SetScale(0,0)
    end
end

function AutoFindView:onTiemr()
    self.timeCount = self.timeCount + 1
    if self.timeCount == 15 then
        self.roleAddExp = cache.PlayerCache:getRoleExp() - self.roleExp
        -- print("增加的总经验",self.roleAddExp)
    end
    if self.timeCount > 15 then
        if self.roleAddExp <= 0 then
            self.roleExp = cache.PlayerCache:getRoleExp()
            -- self.minCount = self.minCount + 1
            self.timeCount = 0
        else
            self.ExpTxt.text = GTransFormNum(math.floor(self.roleAddExp*4))
            self.bg.visible = true
            self.txtMg.visible = true
            self.ExpTxt.visible = true
            if self.timeCount == 60 then
                -- self.minCount = self.minCount + 1
                self.roleExp = cache.PlayerCache:getRoleExp()
                self.timeCount = 0
            end
        end
    end
end

function AutoFindView:onQuickClick()
    -- body
    -- if gRole:getStateID() ~= 5 or gRole.isChangeBody then
    --     --移动过程中才能使用小飞鞋 避免一些地图切换错误
    --     if gRole.isChangeBody then
    --         GComAlter(language.gonggong54) 
    --         return
    --     end
    --     return
    -- end
    if gRole:getStateID() ~= 5 then
        return
    end

    local toMap = mgr.TaskMgr.toMap 
    local toPos = mgr.TaskMgr.toPos 

    if not toMap or not toPos then
        plog("位置异常 @wx 然后提供账号 密码 id=",mgr.TaskMgr.mCurTaskId)
    else
        -- plog("使用小飞鞋",toPos.x, toPos.z,cache.PlayerCache:getAttribute(10310))
        if cache.PlayerCache:VipIsActivate(1) then
            proxy.ThingProxy:sXiaoFeiXie(toMap, toPos.x, toPos.z)
        else
            if cache.PlayerCache:getAttribute(10310) <= 0 then--白银体验剩余时间
                if cache.PlayerCache:getAttribute(10309) > 0 then--小飞鞋使用次数
                    proxy.ThingProxy:sXiaoFeiXie(toMap, toPos.x, toPos.z)
                elseif cache.PackCache:getPackDataById(PackMid.feixie).amount > 0 then
                    proxy.ThingProxy:sXiaoFeiXie(toMap, toPos.x, toPos.z)
                else
                    GComAlter(language.map02)
                end
            else
                proxy.ThingProxy:sXiaoFeiXie(toMap, toPos.x, toPos.z)
            end
        end
    end
    --self:closeView()
end

function AutoFindView:initView()
    self.c1 = self.view:GetController("c1")
end

function AutoFindView:setData(data_)

end

return AutoFindView