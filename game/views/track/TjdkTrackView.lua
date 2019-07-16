--
-- Author: Your Name
-- Date: 2018-08-22 14:18:42
--天晶洞窟采集活动
local TjdkTrackView = class("TjdkTrackView", base.BaseView)

function TjdkTrackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function TjdkTrackView:initView()
    local panel = self.view:GetChild("n7")
    local quitBtn = panel:GetChild("n9")
    quitBtn.onClick:Add(self.onClickQuit,self)
    self.timeTxt = panel:GetChild("n1")
    self.progressText = panel:GetChild("n10")

    self.decList = {}
    for i=1,3 do
        local nameTxt = panel:GetChild("n"..(2*i))
        local valueTxt = panel:GetChild("n"..(1+2*i))
        table.insert(self.decList,{nameTxt = nameTxt,valueTxt = valueTxt})
    end
    self.nextRefreshTimeTxt = self.view:GetChild("n10")
    self.sceneName = self.view:GetChild("n1"):GetChild("n355")
end

-- 变量名：leftTime    说明：结束时间时间戳
-- 变量名：progress    说明：进度
-- 变量名：profit  说明：累计收益(id,数量)
-- 变量名：nextRefreshTime 说明：下次水晶刷新时间
function TjdkTrackView:initData(data)
    -- print("天晶洞窟活动>>>>>>>>>>>>>>>>>",data)
    self.sceneName.text = language.funben230
    for i=8,10 do
        self.view:GetChild("n"..i).visible = false
    end
    self.nextRefreshTime = data.nextRefreshTime
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    local netTime = mgr.NetMgr:getServerTime()
    self.leftTime = data.leftTime
    self.timeTxt.text = GTotimeString(self.leftTime-netTime)
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
    self:refreshInfo(data)
end

function TjdkTrackView:refreshInfo(data)
    local progress = data.progress
    local profit = data.profit
    local maxValue = conf.FubenConf:getTjdkValue("max_collect_num")
    self.progressText.text = progress.."/"..maxValue
    local i = 0
    for k,v in pairs(profit) do
        i = i + 1
        if self.decList[i] then
            local nameTxt = self.decList[i].nameTxt
            local valueTxt = self.decList[i].valueTxt
            local name = conf.ItemConf:getName(k)
            nameTxt.text = name
            valueTxt.text = v
        end
    end
end

--刷新水晶下次刷新时间
function TjdkTrackView:refreshNextRefreshTime(data)
    self.nextRefreshTime = data.nextRefreshTime
end

function TjdkTrackView:onTimer()
    local netTime = mgr.NetMgr:getServerTime()
    if self.leftTime-netTime > 0 then
        self.timeTxt.text = GTotimeString(self.leftTime-netTime)
    else
        mgr.FubenMgr:quitFuben()
    end
    --下一次刷新倒计时
    if self.nextRefreshTime - netTime <= 10 and self.nextRefreshTime - netTime > 0 then
        for i=8,10 do
            self.view:GetChild("n"..i).visible = true
        end
        self.nextRefreshTimeTxt.text = self.nextRefreshTime - netTime
    else
        for i=8,10 do
            self.view:GetChild("n"..i).visible = false
        end
    end
end

function TjdkTrackView:onClickQuit()
    mgr.FubenMgr:quitFuben()
end

return TjdkTrackView