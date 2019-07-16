--
--渡劫副本追踪
local DuJieTrack = class("DuJieTrack",import("game.base.Ref"))

function DuJieTrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function DuJieTrack:initPanel()
    self.nameText = self.mParent.titlePanel:GetChild("n355")
end

function DuJieTrack:setItemUrl()
    self.listView.numItems = 0
    local url1 = UIPackage.GetItemURL("track" , "BossTrack1")
    local url2 = UIPackage.GetItemURL("track" , "TrackItem2")

    local fubenObj1 = self.listView:AddItemFromPool(url1)
    -- self.passText = fubenObj1:GetChild("n1")
    self.timeText = fubenObj1:GetChild("n2")
    self.fubenObj2 = self.listView:AddItemFromPool(url2)
    self.listView:ScrollToView(0)
end

function DuJieTrack:setDuJieTrack()
    self.sId = cache.PlayerCache:getSId()
    self.curId = cache.FubenCache:getCurrPass(self.sId)--当前副本关卡id
    local sceneData = conf.SceneConf:getSceneById(self.sId)
    self.nameText.text = sceneData and sceneData.name or "渡劫副本"
    self:setItemUrl()
    self:setDuJieData()
end

function DuJieTrack:setDuJieData()
    local fubenData = conf.SceneConf:getSceneById(self.sId)
    local dTime = mgr.NetMgr:getServerTime() - cache.FubenCache:getFirstTime()

    self.time = fubenData.over_time/1000 - dTime 
    local data = conf.FubenConf:getPassDatabyId(self.curId)
    -- print("场景id，关卡id",self.sId,self.curId)
    -- self.passText.text = mgr.TextMgr:getTextByTable(data.name)

    self.fubenObj2:GetChild("n4").text = language.fuben95
    self:setFubenData()

    if not self.timer then
        self:onTimer()
        self.timer = self.mParent:addTimer(1, -1, handler(self,self.onTimer))
    end 
end

function DuJieTrack:setFubenData(flag)
    --通关条件
    local data = conf.FubenConf:getPassDatabyId(self.curId)
    local monsters = data and data.pass_con
    local len = #monsters
    if len <= 2 then
        self.fubenObj2.height = 70
    else
        self.fubenObj2.height = 90
    end
    for i=1,3 do
        local monsterText = self.fubenObj2:GetChild("n"..i)
        if len <= 2 then
            monsterText.y = 21+(i-1)*24 + 5
        end
        local monster = monsters and monsters[i]
        if monster then
            monsterText.visible = true
            local id = monster[1]
            local name = conf.MonsterConf:getInfoById(id).name
            local monsterNum = cache.FubenCache:getExpMonsters(id)
            if flag then--特殊处理一下
                monsterNum = 1
            end
            monsterText.text = i.."."..language.fuben09..mgr.TextMgr:getTextColorStr(name, 10).."（"..monsterNum.."/"..monster[2].."）"
        else
            monsterText.visible = false
        end
    end
end

--副本结束
function DuJieTrack:endFuben()
    self.listView.numItems = 0
    self:releaseTimer()
end

function DuJieTrack:releaseTimer()
    if self.timer then
        self.mParent:removeTimer(self.timer)
        self.timer = nil
    end
end

function DuJieTrack:onTimer()
    local fubenData = conf.SceneConf:getSceneById(self.sId)
    local dTime = mgr.NetMgr:getServerTime() - cache.FubenCache:getFirstTime()
    self.time = fubenData.over_time/1000 - dTime 
    self.timeText.text = language.fuben74.." "..mgr.TextMgr:getTextColorStr(GTotimeString(self.time), 10)
    if self.time <= 0 then
        self:releaseTimer()
    end
end

return DuJieTrack