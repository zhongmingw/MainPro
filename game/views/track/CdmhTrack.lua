--
-- Author: 
-- Date: 2018-01-31 14:57:34
--
--元宵答题
local CdmhTrack = class("CdmhTrack",import("game.base.Ref"))

function CdmhTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

--是否是科举答题
function CdmhTrack:isKeJu()
    local sId = cache.PlayerCache:getSId()
    return mgr.FubenMgr:isKeju(sId)
end

function CdmhTrack:initPanel()
    self.questionSum = conf.ActivityWarConf:getActGlobal("lantern_question_number")[1]--答题总数
    if self:isKeJu() then
        self.questionSum = conf.ActivityConf:getKeJuGlobal("kj_question_number")[1]
    end
end

function CdmhTrack:setCdmhTrack()
    self.sId = cache.PlayerCache:getSId()
    local sceneData = conf.SceneConf:getSceneById(self.sId)
    self.mParent.nameText.text = sceneData and sceneData.name or ""
    self:setItemUrl(self.sId)
end

function CdmhTrack:setItemUrl(sId)
    self.listView.numItems = 0
    local url = UIPackage.GetItemURL("track" , "CdmhTrack")
    self.fubenObj = self.listView:AddItemFromPool(url)
    self.fubenObj:GetChild("n11").text = language.gq17
    self.fubenObj:GetChild("n14").text = language.gq18
    self.fubenObj:GetChild("n15").text = language.gq19
    if self:isKeJu() then
        self.fubenObj:GetChild("n15").text = language.gq19_1
    end
    self.dtjdText = self.fubenObj:GetChild("n17")--答题进度
    self.scoreText = self.fubenObj:GetChild("n16")--我的得分
    self.awardsBtn = self.fubenObj:GetChild("n18")--我的得分
    self.awardsBtn.onClick:Add(self.onClickAward,self)
    -- self.rankText = self.fubenObj:GetChild("n8")--我的排名
    self.rankList = self.fubenObj:GetChild("n13")--排名列表
    self.rankList.numItems = 0
    self.rankList.itemRenderer = function(index,obj)
        self:rankCellData(index, obj)
    end
    self.rankList:SetVirtual()

    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end
    self.initRolePos = clone(gRole:getPosition())
    self:setCdmhData()
end

function CdmhTrack:rankCellData(index,obj)
    local data = self.scoreRankings and self.scoreRankings[index+1] or nil
    local nameTxt = obj:GetChild("n1")
    local scoreTxt = obj:GetChild("n2")
    if data then
        nameTxt.text = data.roleName
        scoreTxt.text = data.score
    else
        nameTxt.text = language.rank03
        scoreTxt.text = ""
    end
end

--答题进度
function CdmhTrack:setCdmhData(isNotCz)
    local data = cache.ActivityWarCache:getCdmhData()
    if self:isKeJu() then
        data = cache.ActivityCache:getCdmhData()
    end
    self.scoreRankings = data.scoreRankings
    table.sort(self.scoreRankings,function(a,b)
        if a.score ~= b.score then
            return a.score > b.score
        end
    end)
    self.rankList.numItems = 10
    if data then
        if self:isKeJu() then
            self.dtjdText.text = mgr.TextMgr:getTextColorStr(data.exp or 0, 4)
        else
            self.dtjdText.text = mgr.TextMgr:getTextColorStr(data.curQuestionNum.."/"..self.questionSum, 4)
        end
        self.scoreText.text = mgr.TextMgr:getTextColorStr(data.myScore, 4)
        local rank = data.ranking or 0
        if rank <= 0 then
            rank = language.rank04
        end
        -- self.rankText.text = language.lantern12..mgr.TextMgr:getTextColorStr(rank, 4)
    end
    if not isNotCz then
        gRole:setPosition(self.initRolePos.x,self.initRolePos.z)
        self.isRef = true
    end
end

function CdmhTrack:onTimer()
    self:checkDt()
    local sec = conf.ActivityWarConf:getActGlobal("lantern_act_time_length")
    local data = cache.ActivityWarCache:getCdmhData()
    if self:isKeJu() then
        sec = conf.ActivityConf:getKeJuGlobal("kj_act_time_length")
        data = cache.ActivityCache:getCdmhData()
    end
    if data then
        local time = data.actOpenTime + sec - mgr.NetMgr:getServerTime()
        local t = GGetTimeData(time)
        self.mParent.acttimeTxt1.text = string.format("%02d", t.min)
        self.mParent.acttimeTxt2.text = string.format("%02d", t.sec)
        if time <= 0 then
            if self.timer then
                self.mParent:removeTimer(self.timer)
                self.timer = nil
            end
            mgr.GuiMgr:redpointByVar(attConst.A20166,0)
            mgr.FubenMgr:quitFuben()
        end
    end
end

function CdmhTrack:checkDt()
    local data = cache.ActivityWarCache:getCdmhData()
    if self:isKeJu() then
        data = cache.ActivityCache:getCdmhData()
    end
    if not data then return end
    --准备时间
    local waitTime = conf.ActivityConf:getHolidayGlobal("lantern_pre_time")
    local regions = conf.ActivityWarConf:getActGlobal("lantern_regions")
    local distance = conf.ActivityWarConf:getActGlobal("lantern_region_radius")
    if self:isKeJu() then
        waitTime = conf.ActivityConf:getKeJuGlobal("kj_pre_time")
        regions = conf.ActivityConf:getKeJuGlobal("kj_regions")
        distance = conf.ActivityConf:getKeJuGlobal("kj_region_radius")
    end
    local netTime = mgr.NetMgr:getServerTime()
    local waitT = data.actOpenTime + waitTime - netTime
    if waitT > 0 then return end
    if not self.isRef then return end
    for k,v in pairs(regions) do
        local pos = Vector3.New(v[1],gRolePoz,v[2])
        local dis = GMath.distance(gRole:getPosition(), pos)
        if dis <= distance then
            gRole:stopAI()
            if self:isKeJu() then
                proxy.ActivityProxy:send(1030658,{reqType = 2,answer = k})
            else
                proxy.ActivityWarProxy:send(1030182,{reqType = 2,answer = k})
            end
            self.isRef = false
            break
        end
    end
    
end

function CdmhTrack:onClickAward()
    if self:isKeJu() then
        mgr.ViewMgr:openView2(ViewName.LanternAwardsView)
    else
        mgr.ViewMgr:openView2(ViewName.GuoQingRankAwards)
    end
end

function CdmhTrack:endCdmh()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

return CdmhTrack