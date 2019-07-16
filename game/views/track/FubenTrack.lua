--
-- Author: 
-- Date: 2017-07-15 11:01:19
--

local FubenTrack = class("FubenTrack",import("game.base.Ref"))

local defineNum = 1000

function FubenTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function FubenTrack:initPanel()
    self.nameText = self.mParent.nameText
    self:setNewBoss()
end

function FubenTrack:setItemUrl()
    self.listView.numItems = 0
    local url1 = UIPackage.GetItemURL("track" , "TrackItem1")
    local url2 = UIPackage.GetItemURL("track" , "TrackItem2")
    -- local url3 = UIPackage.GetItemURL("track" , "TrackItem3")

    self.fubenObj1 = self.listView:AddItemFromPool(url1)
    -- self.fubenObj1.height = 0
    -- self.fubenObj1.visible = false
    --or mgr.FubenMgr:isMainTaskFuben(cache.PlayerCache:getSId())  
    --11/22 策划要求显示时间 但是只显示分 和 秒
    if mgr.FubenMgr:isJuqingFuben(cache.PlayerCache:getSId()) then
        --特殊副本不要看第一条
        self.fubenObj1.height = 0
        self.fubenObj1.visible = false
    else
        self.fubenObj1.height = 60
        self.fubenObj1.visible = true
    end
    self.fubenObj2 = self.listView:AddItemFromPool(url2)
    local isFirst = cache.FubenCache:getIsFrist() or 0
    if mgr.FubenMgr:isGangFuben(cache.PlayerCache:getSId()) then
        --仙盟副本不要通过奖励显示
    else
        -- if isFirst == 1 then
        --     self.fubenObj3 = self.listView:AddItemFromPool(url3)
        -- else
        --     local firstData = cache.FubenCache:getFirstData(self.curId)
        --     if firstData and firstData.value == 1 or mgr.FubenMgr:isCopperFuben(self.sId) then
        --         self.fubenObj3 = self.listView:AddItemFromPool(url3)
        --     end
        -- end
    end
    self.listView:ScrollToView(0)
end

function FubenTrack:setFubenTrack()
    self.sId = cache.PlayerCache:getSId()
    self.sPex = self.sId * defineNum
    self.curId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
    local confData = conf.SceneConf:getSceneById(self.sId)
    self.nameText.text = confData and confData.name or ""
    self:setItemUrl()
    local passText = self.fubenObj1:GetChild("n1")
    self.passText = passText
    self.timeText = self.fubenObj1:GetChild("n2")
    -- self.proStarObj = self.fubenObj1:GetChild("n3")--三星进度条
    -- self.proStarObj.visible = false
    -- self.starBarLis = {}
    if mgr.FubenMgr:isJinjie(self.sId) 
    or mgr.FubenMgr:isCopperFuben(self.sId) 
    or mgr.FubenMgr:isPlotFuben(self.sId) 
    or mgr.FubenMgr:isVipFuben(self.sId) 
    or mgr.FubenMgr:isZhiXianTaskFuben(self.sId)then--没有当前X波的副本

        passText.visible = false
        self.timeText.y = 15
    else
        passText.visible = true
        self.timeText.y = 31
    end
    if mgr.FubenMgr:isJinjie(self.sId) then--进阶副本的倒计时
        -- self.proStarObj.visible = true
        passText.visible = false
        -- self.fubenObj1.height = 30
        self.timeText.y = passText.y
        -- for i=0,2 do
        --     local progress = self.proStarObj:GetChild("n"..i)
        --     progress.max = 100
        --     progress.value = 0
        --     table.insert(self.starBarLis, progress)
        -- end
    end
    if mgr.FubenMgr:isYuanDanTanSuo(self.sId)  then--没有当前X波，没有倒计时的副本
        passText.visible = false
        self.timeText.visible = false
    end

    if mgr.FubenMgr:isShengXiao(self.sId) then--如果是生肖试炼
        self.timeText = self.fubenObj1:GetChild("n1")
        self.passText = self.fubenObj1:GetChild("n2")
    end
    self:setFirstTime(cache.FubenCache:getFirstTime())--设置进入时间
    self:setFubenData()

    self:addPlotGuide()
    self:onTimer()
    if not self.timer then
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end    
end

function FubenTrack:setFirstTime(time)
    self.firstTime = time
    local pass = self.curId - self.sPex
    local strTab = {}
    if mgr.FubenMgr:isTower(self.sId) then
        strTab = clone(language.fuben73) 
        strTab[2].text = string.format(strTab[2].text,pass) 
    elseif mgr.FubenMgr:isShengXiao(self.sId) then--如果是生肖试炼
        strTab = clone(language.fuben252)
        local passData = conf.FubenConf:getPassDatabyId(self.curId)
        local monsterId = passData.pass_con[1][1]
        local monsterData = conf.MonsterConf:getInfoById(monsterId)
        if monsterData then
            strTab[2].text = string.format(strTab[2].text,monsterData.level)
        end
    else
        strTab = clone(language.fuben08)
        strTab[2].text = string.format(strTab[2].text,pass) 
    end
    self.passText.text = mgr.TextMgr:getTextByTable(strTab)
    -- if self.fubenObj3 then
    --     self:setFirstAward()
    -- end
    -- self:setNormalData()
end
--设置进度条的星级进度（仅用于进阶副本）
function FubenTrack:setStarData(time,starDiff)
    -- local star = 1
    -- if time <= starDiff[3] then
    --     star = 3
    -- elseif time > starDiff[3] and time <= starDiff[2] then
    --     star = 2
    -- else
    --     star = 1
    -- end
    -- for k,v in pairs(self.starBarLis) do
    --     v.max = 100
    --     if k <= star then
    --         v.value = 100
    --     else
    --         v.value = 0
    --     end
    -- end
end
--副本结束
function FubenTrack:endFuben()
    self:releaseTimer()
    if self.sId and mgr.FubenMgr:isJinjie(self.sId) then--如果是进阶副本
        local data = conf.SceneConf:getSceneById(self.sId) 
        local overTime = data.over_time or 0
        local passId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
        local passData = conf.FubenConf:getPassDatabyId(self.curId)
        self:setStarData(overTime / 1000 - self.time,passData.star_diff)
    end
end

function FubenTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function FubenTrack:onTimer()
    local severTime = mgr.NetMgr:getServerTime()
    local data = conf.SceneConf:getSceneById(self.sId) 
    local overTime = data.over_time or 0
    self.time = overTime / 1000 + self.firstTime - severTime
    local str = language.fuben12
    if mgr.FubenMgr:isJinjie(self.sId) then--如果是进阶副本
        str = language.fuben20
        local passId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
        local passData = conf.FubenConf:getPassDatabyId(passId)
        if passData then
            self:setStarData(overTime / 1000 - self.time,passData.star_diff)
        end
    end
    if mgr.FubenMgr:isTower(self.sId) then
        str = language.fuben74
    end
    if mgr.FubenMgr:isShengXiao(self.sId) then
        str = language.fuben20
    end
    self.timeText.text = str.." "..mgr.TextMgr:getTextColorStr(GTotimeString3(self.time), 10)
    if self.time <= 0 then
        self:releaseTimer()
    end
    self:unlockNpc()
    -- if sId >= Fuben.plot and sId < Fuben.tower then--剧情
    --     self:checkPlotBoss()--检测是否出现了boss
    -- end
end
--解锁npc
function FubenTrack:unlockNpc()
    if mgr.FubenMgr:isExpFuben(cache.PlayerCache:getSId()) then--经验副本添加特效
        if self.bindNpc then
            if not self.isUnlock then
                local bindNpcPos = self.bindNpc:getPosition()
                local distance = GMath.distance(gRole:getPosition(), bindNpcPos)
                if distance <= 400 then
                    self.isUnlock = true
                    gRole:stopAI()
                    mgr.HookMgr:cancelHook()
                    mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = self.bindNpcDialog,callback = function()
                        gRole:moveToPoint(bindNpcPos, 0, function()
                            self:npcPlot()
                        end)
                    end})
                else
                    self.isUnlock = false
                end
            end
        end
    end
end
--npc的d动画
function FubenTrack:npcPlot()
    gRole:collect(function(state)
        local param = {}
        param.func = function()--拾取完成要弹出恭喜获得
            self:addGuideNpc(self.bindNpcNpcs)
            self.isUnlock = false
            if self.bindNpc then
                self.bindNpc:dead()
                self.bindNpc = nil
            end
            local confData = conf.FubenConf:getPassDatabyId(self.curId)
            if confData and confData.guide_dialog_id then--配了剧情对话的要先对话
                mgr.ViewMgr:openView2(ViewName.GuideDialog2, {id = confData.guide_dialog_id,callback = function()
                        mgr.HookMgr:enterHook()
                    end})
            else
                mgr.HookMgr:enterHook()
            end
        end
        mgr.ViewMgr:openView2(ViewName.PickAwardsView,param)
    end)
end

--添加剧情引导npc
function FubenTrack:addPlotGuide()
    if not cache.GuideCache:getGuide() then return end
    if mgr.FubenMgr:isExpFuben(self.sId) then--经验关
        local confData = conf.FubenConf:getPassDatabyId(self.curId)
        if confData then
            if confData.bind_npc then
                plog("添加剧情引导npc",self.curId)
                local bindNpcData = confData.bind_npc
                local parent = UnitySceneMgr.pStateTransform
                local bindNpc = thing.Npc.new()
                bindNpc:setData({id = bindNpcData[1]})
                if bindNpc.character then
                    UnityObjMgr:AddThing(ThingType.npc,bindNpc.character)
                end
                self.bindNpc = bindNpc
                self.bindNpcDialog = bindNpcData[2]
                self.bindNpcNpcs = confData.guide_npc
            else
                if confData.guide_npc then
                    self:addGuideNpc(confData.guide_npc)
                end
            end
        end
    end
    if mgr.FubenMgr:isTower(self.sId) then--通天塔
        local confData = conf.FubenConf:getPassDatabyId(self.curId)
        if confData and confData.guide_npc then
            self:addGuideNpc(confData.guide_npc)
        end
    end
end

function FubenTrack:addGuideNpc(npcs)
    for k,npcId in pairs(npcs) do
        local npcData = conf.FubenConf:getGuideNpc(npcId)
        cache.FubenCache:addGuideNpc(npcData.opt)
        mgr.ThingMgr:addGuideNpc(npcId)
    end
end

function FubenTrack:setFubenData()
    --通关条件
    local data = conf.FubenConf:getPassDatabyId(self.curId)
    local monsters = data and data.pass_con or {}
    self:setFubenCondition(monsters)

end
--通关条件
function FubenTrack:setFubenCondition(monsters)
    local len = #monsters
    if len <= 2 then
        self.fubenObj2.height = 70
    else
        self.fubenObj2.height = 90
    end
    for i=1,3 do
        local monsterText = self.fubenObj2:GetChild("n"..i)
        local monster = monsters and monsters[i]
        if monster then
            monsterText.visible = true
            local id = monster[1]
            local mConf = conf.MonsterConf:getInfoById(id)
            local name = mConf and mConf.name or ""
            local monsterNum = cache.FubenCache:getExpMonsters(id)
            monsterText.text = language.fuben09..mgr.TextMgr:getTextColorStr(name, 10).."("..monsterNum.."/"..monster[2]..")"
        else
            monsterText.visible = false
        end
    end
    if mgr.FubenMgr:isYuanDanTanSuo(self.sId)  then--没有当前X波，没有倒计时的副本
        for i=1,3 do
            local monsterText = self.fubenObj2:GetChild("n"..i)
            if i == 2 then
                monsterText.text = "击杀Boss即可通关"
            else
                monsterText.text = ""
            end
        end

    end

end
--首通奖励
function FubenTrack:setFirstAward()
    local sId = self.sId
    local curId = self.curId--当前副本关卡id
    local passData = self:getPassData(sId,curId)
    local passId = passData[1]
    local awardsData = passData[2]
    local maxPass = passData[3]
    local pass = passData[4]
    local awards = awardsData.first_pass_award and awardsData.first_pass_award--首通奖励
    -- printt(awardsData.first_pass_award)
    local desc1 = self.fubenObj3:GetChild("n3")
    if mgr.FubenMgr:isCopperFuben(sId) then--铜钱追踪
        desc1.text = language.fuben35
        awards = awardsData.normal_drop
    elseif mgr.FubenMgr:isPlotFuben(sId) or mgr.FubenMgr:isVipFuben(sId) or mgr.FubenMgr:isJinjie(sId) then--剧情，vip，进阶
        desc1.text = language.fuben15
    else--经验，爬塔，帮派
        local isFirstTower = false
        local str = language.fuben10
        if sId == Fuben.tower then
            str = language.fuben65
            if pass == maxPass then
                isFirstTower = true
            end
        end
        if isFirstTower then
            desc1.text = language.fuben15
        else
            desc1.text = string.format(str, maxPass).."("..pass.."/"..maxPass..")"
        end
    end
    
    local itemlist = self.fubenObj3:GetChild("n6")
    if awards then
        itemlist.itemRenderer = function(index,obj)
            local data = awards[index + 1]
            local itemData = {mid = data[1],amount = data[2],bind = data[3]}
            GSetItemData(obj, itemData, true)
        end
        itemlist.numItems = #awards
    end
    local awardsBtn = self.fubenObj3:GetChild("n5")
    local firstData = cache.FubenCache:getFirstData(passId)
    if mgr.FubenMgr:isExpFuben(sId) then--经验副本显示按钮
        awardsBtn.visible = true
    else
        awardsBtn.visible = false
    end
    if firstData and firstData.value == 1 then
        awardsBtn.enabled = true
    else
        awardsBtn.enabled = false
    end
    awardsBtn.data = passId
    awardsBtn.onClick:Add(self.onClickAwards,self)
end
--不同副本的任务追踪数据（待优化）
function FubenTrack:getPassData(sId,curId)
    local passId = 0--关卡id
    local awardsData = {}--首通数据
    local maxPass = 1--最大关卡
    local pass = 1--当前关卡
    if mgr.FubenMgr:isCopperFuben(sId) then--铜钱追踪
        passId = curId
        awardsData = conf.FubenConf:getPassDatabyId(passId)--返回有首通的关卡数据
    elseif mgr.FubenMgr:isExpFuben(sId) then--经验追踪
        passId = cache.FubenCache:getMinFirstPass(sId,curId)
        awardsData = conf.FubenConf:getExpFirstAwards(passId)--返回有首通的关卡数据
        maxPass = awardsData.id - self.sPex
        pass = passId - self.sPex
    elseif mgr.FubenMgr:isPlotFuben(sId) then--剧情追踪
        passId = curId
        awardsData = conf.FubenConf:getPlotFirstAwards(passId)--返回有首通的关卡数据
    elseif mgr.FubenMgr:isTower(sId) then--爬塔追踪
        passId = cache.FubenCache:getMinFirstPass(sId,curId)
        awardsData = conf.FubenConf:getTowerFirstAwards(passId)--返回有首通的关卡数据
        maxPass = awardsData.id - self.sPex
        pass = passId - self.sPex
    elseif mgr.FubenMgr:isVipFuben(sId) then--vip追踪
        passId = curId
        awardsData = conf.FubenConf:getVipFirstAwards(passId)--返回有首通的关卡数据
    elseif mgr.FubenMgr:isJinjie(sId) then--进阶副本
        passId = curId
        awardsData = conf.FubenConf:getAdvancedFirstAwards(passId)--返回有首通的关卡数据
    elseif mgr.FubenMgr:isGangFuben(sId) then
        passId = curId
        awardsData = conf.FubenConf:getPassDatabyId(passId)--返回有首通的关卡数据
        maxPass = curId%1000
        pass = maxPass
    end
    return {passId,awardsData,maxPass,pass}
end

--设置普通通关奖励
function FubenTrack:setNormalData()
    if not mgr.FubenMgr:isCopperFuben(self.sId) 
    and not mgr.FubenMgr:isJuqingFuben(self.sId) 
    and not mgr.FubenMgr:isGangFuben(self.sId)  then
        local curId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
        local data = conf.FubenConf:getPassDatabyId(curId)--
        local url = UIPackage.GetItemURL("track" , "TrackItem4")
        if data.normal_drop then
            local obj = self.listView:AddItemFromPool(url)
            self:cellNormalData(data.normal_drop,obj)
        end
    end
end

function FubenTrack:cellNormalData(data,obj)
    local item = obj:GetChild("n1")
    local desc = obj:GetChild("n3")
    desc.text = language.fuben36
    local listView = obj:GetChild("n7")
    listView:SetVirtual()
    listView.itemRenderer = function(index,item)
        local award = data[index + 1]
        local itemData = {mid = award[1],amount = award[2],bind = award[3]}
        GSetItemData(item, itemData, true)
    end
    listView.numItems = #data
end
----------------------------------------------------------------
function FubenTrack:setNewBoss()
    self.isNewBoss = true
end
--检测剧情boss
function FubenTrack:checkPlotBoss()
    local allMonster = mgr.ThingMgr:objsByType(ThingType.monster)--所有的怪物
    for k,v in pairs(allMonster) do
        local mId = v:getMId()
        local confData = conf.MonsterConf:getInfoById(mId)
        if confData then
            if confData.kind == MonsterType.boss and self.isNewBoss then--如果检测到boss
                local distance = GMath.distance(gRole:getPosition(), v:getPosition())
                -- plog(distance, BossDistance)
                -- if distance <= BossDistance then
                --     local view = mgr.ViewMgr:get(ViewName.PlotDialogView)
                --     local passId = cache.PlayerCache:getSId()..string.format("%03d", 1)
                --     if view then
                --         view:setData(passId,mId)
                --     else
                --         mgr.ViewMgr:openView(ViewName.PlotDialogView,function(view)
                --            view:setData(passId,mId)
                --         end)
                --     end
                --     self.isNewBoss = false
                -- end
            end
        end
    end
end
--领取首通奖励 目前只有经验副本
function FubenTrack:onClickAwards(context)
    proxy.FubenProxy:send(1024102,{passId = context.sender.data})
end

return FubenTrack