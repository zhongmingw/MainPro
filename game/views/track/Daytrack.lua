--
-- Author: wx
-- Date: 2017-12-20 16:38:07
-- 日常任务副本追踪

local Daytrack = class("Daytrack",import("game.base.Ref"))

function Daytrack:ctor(mParent,listView)
    self.mParent = mParent
    self.listView = listView
    self:initPanel()
end

function Daytrack:initPanel()
    -- body
    self.nameText = self.mParent.nameText
    self.listView.numItems = 0
end

function Daytrack:setdayFubenTrack()
    -- body
    self.listView.numItems = 0

    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    self.nameText.text = sConf.name
    --print("设置名字",sId,sConf.name)

    local key = cache.FubenCache:getDayKey(sId)
    self.confdata = conf.FubenConf:getdailyFubenRed(key)
    if not self.confdata then
        plog("缺少配置daily_task_fuben_ref",key)
        return
    end

    
    if self.confdata.kind == 2 then --守塔任务
        local var = UIPackage.GetItemURL("track" , "TimeTrack")
        self._compent1 = self.listView:AddItemFromPool(var)
    else
        local var = UIPackage.GetItemURL("track" , "TrackItem2")
        self._compent1 = self.listView:AddItemFromPool(var)
    end

    self:setFubenData()

    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent1 = self.listView:AddItemFromPool(var)
    _compent1:GetChild("n2").text = mgr.TextMgr:getTextColorStr(language.task19, 3)

    
    local var = UIPackage.GetItemURL("track" , "TimeTrack")
    local _compent1 = self.listView:AddItemFromPool(var)
    _compent1:GetChild("n2").text = sConf.decs or ""

    
end

function Daytrack:setFubenData()
    -- body
    if self.confdata.kind ~= 2 then
        local monsters = self.confdata and self.confdata.pass_con or {}
        self:setFuebenCondition(monsters)
    else
        local sId = cache.PlayerCache:getSId()
        local ss = clone(language.task18)
        ss[2].text = string.format(ss[2].text,cache.FubenCache:getCurBo(sId),#self.confdata.order_monster)
        self._compent1:GetChild("n2").text = mgr.TextMgr:getTextByTable(ss)
    end
end

--通关条件
function Daytrack:setFuebenCondition(monsters)
    local len = #monsters
    if len <= 2 then
        self._compent1.height = 70
    else
        self._compent1.height = 90
    end
    for i=1,3 do
        local monsterText = self._compent1:GetChild("n"..i)
        local monster = monsters and monsters[i]
        if monster then
            monsterText.visible = true
            local id = monster[1]
            local name = conf.MonsterConf:getInfoById(id).name
            local monsterNum = cache.FubenCache:getExpMonsters(id)
            monsterText.text = language.fuben09..mgr.TextMgr:getTextColorStr(name, 10).."("..monsterNum.."/"..monster[2]..")"
        else
            monsterText.visible = false
        end
    end
end


return Daytrack