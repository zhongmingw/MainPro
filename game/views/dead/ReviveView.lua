--
-- Author: 
-- Date: 2017-10-18 16:12:26
--

local ReviveView = class("ReviveView", base.BaseView)

function ReviveView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function ReviveView:initView()
    self.progress = self.view:GetChild("n0")
    self.timeTxt = self.progress:GetChild("n2")
end

function ReviveView:initData(data)
    self.time = 0
    self.data = data
    if self.data.reviveType == 5 then
        self.reviveSec = conf.FubenConf:getTaFangValue("st_revive_sec")
    else
        self.reviveSec = conf.SysConf:getValue("boss_home_screen_revive_sec")
    end
    self:onTimer()
    self:addTimer(0.2, -1, handler(self, self.onTimer))
end

function ReviveView:onTimer()
    if self.data.reviveType == 4 then
        if self.time >= self.reviveSec then
            local sId = cache.PlayerCache:getSId()
            --BOSS之如果是符合对应层仙尊的玩家，死亡后倒计时5秒，在复活点复活不符合对应曾仙尊的玩家，死亡后倒计时5秒，传送出副本
            if mgr.FubenMgr:isBossHome(sId) then--
                local confData = conf.FubenConf:getBossHomeLayer(sId)
                local cons = confData and confData.con or {}
                local notXianzun = true
                for k,v in pairs(cons) do
                    if cache.PlayerCache:VipIsActivate(tonumber(v)) then--拥有了其中一个仙尊
                        notXianzun = false
                        break
                    end
                end
                if notXianzun then
                    mgr.FubenMgr:quitFuben()
                else
                    proxy.ThingProxy:sRevive(3)
                end
            elseif mgr.FubenMgr:isXianyuJinDi(sId) or mgr.FubenMgr:isKuafuXianyu(sId) 
                or mgr.FubenMgr:isShangGuShenJi(sId) or mgr.FubenMgr:isWuXingShenDian(sId) then
                proxy.ThingProxy:sRevive(3)
            end
            self:closeView()
            return
        end
    elseif self.data.reviveType == 5 then
        if self.time >= self.reviveSec then
            proxy.ThingProxy:sRevive(3)
            self:closeView()
            return
        end
    elseif self.data.reviveType == 0 then--特殊情况，飞升神殿买票进的只能打一次， 死亡直接退出副本bxp
        if self.time >= self.reviveSec then
            local sId = cache.PlayerCache:getSId()
            if mgr.FubenMgr:isFsFuben(sId) then
                mgr.FubenMgr:quitFuben()
                self:closeView()
                return
            end
        end
    end
    self.time = self.time + 0.2
    self.progress.value = self.time * 10
    self.progress.max = self.reviveSec * 10
    self.timeTxt.text = math.ceil(self.reviveSec - self.time)
end

return ReviveView