--
-- Author: wx
-- Date: 2018-09-10 16:28:35
--

local Zq1001 = class("Zq1001",import("game.base.Ref"))

function Zq1001:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end
function Zq1001:onTimer()
    -- body
    if not self.data then return end
end
function Zq1001:addMsgCallBack(data)
    -- body
    if data.msgId == 5030613 then
        self.data = data 

        self.keys = table.keys(data.idAndNum)
        table.sort(self.keys,function(a,b)
            -- body
            return a < b
        end)
        self.dec1.text = "活动时间："..GToTimeString11(self.data.actStartTime).."~"..GToTimeString11(self.data.actEndTime)
        self.bosslist.numItems = #self.keys
    end
end

function Zq1001:initView()
    -- body
    self.dec1 = self.view:GetChild("n8")
   
    local dec2 = self.view:GetChild("n9")
    dec2.text = language.zq10

    self.bosslist = self.view:GetChild("n3")
    self.bosslist.itemRenderer = function(index,obj)
        self:cellBossData(index, obj)
    end
    self.bosslist.numItems = 0

    self.bossaward = conf.ZhongQiuConf:getGlobal("boss_award")
    self.rewardlist = self.view:GetChild("n4")
    self.rewardlist.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rewardlist.numItems = #self.bossaward
end

function Zq1001:cellData( index, obj )
    -- body
    local data = self.bossaward[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3] or 1
    GSetItemData(obj, t, true)
end

function Zq1001:cellBossData( index, obj )
    -- body
    local key = self.keys[index+1]
    local value = self.data.idAndNum[key]
    --print("key",key)
    local Sconf = conf.SceneConf:getSceneById(key)
    local lab = obj:GetChild("n1")
    lab.text = Sconf.name

    local boss_min_max = conf.ZhongQiuConf:getGlobal("boss_min_max")
    local labboss = obj:GetChild("n2")
    if value == 0 then
        labboss.text = string.format(language.zq11,language.zq15)
    elseif value < boss_min_max[1] then
        labboss.text = string.format(language.zq11,value)
    elseif value < boss_min_max[2] then
        labboss.text = string.format(language.zq11,language.zq13)
    else
        labboss.text = string.format(language.zq11,language.zq12)
    end

    local btn = obj:GetChild("n3")
    btn.data = key
    btn.onClick:Add(self.onBtnCallBack,self)

    obj:GetChild("n4").text = language.zq14
end

function Zq1001:onBtnCallBack( context )
    -- body
    local btn = context.sender
    local data = btn.data 

    if not self.data or not self.data.idAndNum[data] then
        return
    elseif  self.data.idAndNum[data] == 0 then
        return GComAlter(language.zq15)
    end
    local point = {}
    local sConf = conf.SceneConf:getSceneById(data)
    local lvl = sConf and sConf.lvl or 1
    local playLv = cache.PlayerCache:getRoleLevel()
    if playLv < lvl then
        GComAlter(string.format(language.zq16,sConf.name,lvl))
        return  
    end

    point.x = sConf.born[1][1]
    point.z = sConf.born[1][2]
    mgr.TaskMgr:goTaskBy(data,point)
end
return Zq1001