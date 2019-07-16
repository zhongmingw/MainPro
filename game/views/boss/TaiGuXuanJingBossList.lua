--
-- Author: 
-- Date: 2018-10-30 11:03:21
--

local TaiGuXuanJingBossList = class("TaiGuXuanJingBossList", base.BaseView)
local chooseBoss = false 
function TaiGuXuanJingBossList:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
end

function TaiGuXuanJingBossList:initView()
    local  closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onClose,self)
    local btn = self.view:GetChild("n2")
    btn.onClick:Add(self.onClick,self)
    self.listView = self.view:GetChild("n4")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index,obj)
    end
end

function TaiGuXuanJingBossList:initData(data)
    self.data =  data
    chooseBoss = false
    self.listView.numItems = #self.data

     if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(0.03, -1, handler(self, self.onTimer))
end

function TaiGuXuanJingBossList:cellData(index,obj)
    local data = self.data[index + 1]
    local timeText = obj:GetChild("n8")--刷新时间
    local mConf = conf.MonsterConf:getInfoById(data.monsterId)
    local bossStatu = data.bossStatu

    --名字
    local name = mConf and mConf.name or ""
    local bossText = obj:GetChild("n9")
    bossText.text = name.."LV."
    --等级
    local lvText = obj:GetChild("n7")
    local lvl = mConf and mConf.level or 1
    local str = ""..lvl
    if cache.PlayerCache:getRoleLevel() >= lvl then
        lvText.text = mgr.TextMgr:getTextColorStr(str, 7)
    else
        lvText.text = mgr.TextMgr:getTextColorStr(str, 14)
    end

end

function TaiGuXuanJingBossList:onClick(context)
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    local view = mgr.ViewMgr:get(ViewName.BossView)
    if view.TaiGuXuanJingPanel and  view.TaiGuXuanJingPanel.leftTired > 0 then
        --缓存服务器id
        local severId = self.data[1].agentServerId == 1 and 0 or self.data[1].agentServerId
        cache.TaiGuXuanJingCache:setagentServerId(severId)
        for k = 1,#self.data do
            local cell = self.listView:GetChildAt(k - 1)
            if self.data[k].bossStatu ~= 1 then
                local time = self.data[k].nextRefreshTime - mgr.NetMgr:getServerTime()
                if time < 0 and not  chooseBoss then
                     cache.TaiGuXuanJingCache:setChooseBossId(self.data[k].monsterId)
                     chooseBoss = true
                end
            end
        end
        mgr.FubenMgr:gotoFubenWar2(self.data[1].sceneId)
    else
        GComAlter(language.fuben84)
    end
end

function TaiGuXuanJingBossList:onTimer()
    for k = 1,#self.data do
        local cell = self.listView:GetChildAt(k - 1)
        if cell then
            local data = self.data[k]
            local timeText = cell:GetChild("n8")--刷新时间
            
            if data.bossStatu == 1 then--boss已经死了
                local time = data.nextRefreshTime - mgr.NetMgr:getServerTime()
                if time > 0 then
                    timeText.text = GTotimeString(time)
                else
                    timeText.text = mgr.TextMgr:getTextColorStr(language.marryiage40[2], 7)
                end
            else
                timeText.text = mgr.TextMgr:getTextColorStr(language.marryiage40[2], 7)
            end
        end
    end
end

function  TaiGuXuanJingBossList:onClose( )
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self:closeView()
end

return TaiGuXuanJingBossList