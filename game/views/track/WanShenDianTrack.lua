--
-- Author: Your Name
-- Date: 2018-09-12 19:27:32
--
local WanShenDianTrack = class("WanShenDianTrack",import("game.base.Ref"))

local existsTime = conf.WanShenDianConf:getValue("tt_exists_interval")--图腾存在时间
local refreshTime = conf.WanShenDianConf:getValue("tt_refresh_interval")--图腾刷新时间

function WanShenDianTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function WanShenDianTrack:initPanel()
    self.nameTxt = self.mParent.view:GetChild("n18"):GetChild("n6")
    local buyJlBtn = self.mParent.view:GetChild("n30")
    buyJlBtn.onClick:Add(self.onClickBuyJl,self)
end

function WanShenDianTrack:setWsdTrack()

    --剩余精力
    self.jlValue = cache.WanShenDianCache:getJlValue()
    --最大精力
    self.maxJl = conf.WanShenDianConf:getValue("init_max_jl")
    --结束时间
    self.endTime = cache.WanShenDianCache:getEndTime()

    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "WanShenDianItem")
    self.listItem = self.listView:AddItemFromPool(url)
    self.lastTimeTxt = self.listItem:GetChild("n7")
    self.decTxt1 = self.listItem:GetChild("n6")
    self.bar = self.listItem:GetChild("n3")
    self.bar.value = self.jlValue
    self.bar.max = self.maxJl
    
    self.decTxt = self.listItem:GetChild("n4")
    local sId = cache.PlayerCache:getSId()
    local costJl = conf.WanShenDianConf:getCostJl(sId)
    local textData = clone(language.wanshendian09)
    textData[2].text = string.format(textData[2].text,costJl)
    self.decTxt.text = mgr.TextMgr:getTextByTable(textData)

    if self.endTime > mgr.NetMgr:getServerTime() then
        self.decTxt1.text = language.wanshendian05
        self.lastTimeTxt.text = GTotimeString(self.endTime - mgr.NetMgr:getServerTime())
    else
        self.decTxt1.text = language.wanshendian04
        local nextTime = (self.endTime + refreshTime - existsTime) - mgr.NetMgr:getServerTime()
        self.lastTimeTxt.text = GTotimeString(nextTime)
    end
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self.mParent:addTimer(1, -1, handler(self, self.onTimer))
    local chooseMonsterId = cache.FubenCache:getChooseMonsterId()
    print("进入挂机>>>",chooseMonsterId)
    if chooseMonsterId > 0 then
        mgr.TimerMgr:addTimer(2, 1, function()
            local bossConf = conf.MonsterConf:getInfoById(chooseMonsterId)
            local point = Vector3.New(bossConf.pos[1], gRolePoz, bossConf.pos[2])
            gRole:moveToPoint(point, 50, function()
                mgr.HookMgr:enterHook()
            end)
            cache.FubenCache:setChooseMonsterId(0)
        end)
    end
    self.isIn = true
end

--精力值刷新
function WanShenDianTrack:refreshJlValue()
    self.jlValue = cache.WanShenDianCache:getJlValue()
    self.bar.value = self.jlValue
end

function WanShenDianTrack:onTimer()
    if self.jlValue and self.jlValue <= 0 then
        if self.isIn then
            self.isIn = false
            local view = mgr.ViewMgr:get(ViewName.BossTiredTipView)
            if not view then
                mgr.ViewMgr:openView2(ViewName.BossTiredTipView, {})
            end
        end
        return
    end
    if self.lastTimeTxt and self.endTime then
        if self.endTime > mgr.NetMgr:getServerTime() then
            self.decTxt1.text = language.wanshendian05
            self.lastTimeTxt.text = GTotimeString(self.endTime - mgr.NetMgr:getServerTime())
        else
            self.decTxt1.text = language.wanshendian04
            local nextTime = (self.endTime + refreshTime - existsTime) - mgr.NetMgr:getServerTime()
            if nextTime <= 0 then
                self.endTime = self.endTime + refreshTime
            else
                self.lastTimeTxt.text = GTotimeString(nextTime)
            end
        end
    end
end

function WanShenDianTrack:onClickBuyJl()
    mgr.ViewMgr:openView2(ViewName.WsdBuyJingLiTip, {})
end

return WanShenDianTrack