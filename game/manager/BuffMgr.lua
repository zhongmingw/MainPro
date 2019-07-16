--[[--
 BUFF管理
]]

local BuffMgr = class("BuffMgr")

function BuffMgr:ctor()
    self:init()
end

function BuffMgr:init()
    self.buffs = {}
    self.buffIcons = {}
end

function BuffMgr:update()

end

function BuffMgr:getBuffByid(roleId)
    -- body
    return self.buffs[roleId] or {}
end

function BuffMgr:getBuffByModelId(modelId,roleId)
    local id = roleId or cache.PlayerCache:getRoleId()
    local buffList = self.buffs[id] or {}
    for k,v in pairs(buffList) do
        if v.modelId == modelId then
            return v
        end
    end
end

function BuffMgr:isFight()
    local buffs = self:getBuffByid(cache.PlayerCache:getRoleId())
    for k ,v in pairs(buffs) do
        if tonumber(v.modelId) == 6020201 then
            return true
        end
    end

    return false
end

--是否有红名buff
function BuffMgr:isHongMing(roleId)
    local buffs = self:getBuffByid(roleId)
    for k,v in pairs(buffs) do
        local conf = conf.BuffConf:getBuffConf(v.modelId)
        if conf.affect_type == 1081 then
            return true
        end
    end
    return false
end

--返回旺财总加成
function BuffMgr:isWangcai()
    local buffs = self:getBuffByid(cache.PlayerCache:getRoleId())
    local n = 0
    local addrate = 0
    for k ,v in pairs(buffs) do
        local conf = conf.BuffConf:getBuffConf(v.modelId)
        if conf.affect_type == 1070 then--旺财铜钱加成
            n = n + 1
            addrate = addrate + conf.arg_1
        end
    end
    return n*(addrate/10000)
end

function BuffMgr:isChangeBody()
    local buffs = self:getBuffByid(cache.PlayerCache:getRoleId())
    for k ,v in pairs(buffs) do
        if tonumber(v.modelId) >= 6010101 and tonumber(v.modelId) <= 6010110 then
            return true
        end
    end

    return false
end

--添加buff
function BuffMgr:addBuff(data)
    if not data or not data.roleId then
        print("BuffMgr =========> data.roleId=nil")
        return
    end

    if not self.buffs[data.roleId] then
        self.buffs[data.roleId] = {}
    end

    local buffInfo = data.buffInfo
    if not buffInfo or not buffInfo.buffId then
        print("BuffMgr =========> buffInfo=nil")
        return
    end
    --如果有相同buff则替换
    if self.buffs[data.roleId][buffInfo.buffId] then
        self.buffs[data.roleId][buffInfo.buffId] = buffInfo
        return
    end
    --如果是新buff
    if self.buffs[data.roleId] then
        local ok,errorInfo = pcall(function()
            self:handleBuff(data.roleId, buffInfo, true)
            self.buffs[data.roleId][buffInfo.buffId] = buffInfo
        end)
        if not ok then
            print("[Error-需要通知技术]-",(data and data.roleId),(buffInfo and buffInfo.buffId))
            print(">>>>>>>>>>",buffInfo and buffInfo.modelId)
            printt(errorInfo)
        end
    else
        print("BUFF-异常")
    end
    self:refreshBuffDisplay()
end

--添加玩家buff-玩家出现添加
function BuffMgr:addThingBuff(data)
    if not data.buffs then return end
    local len = #data.buffs
    for i=1, len do
        self:addBuff({roleId=data.roleId, buffInfo=data.buffs[i]})
    end
end

--移除buff-服务端广播
function BuffMgr:removeBuff(data)
    local roleBuffs = self.buffs[data.roleId]
    if roleBuffs then
        local buffInfo = roleBuffs[data.buffId]
        if buffInfo then
            local config = conf.BuffConf:getBuffConf(buffInfo.modelId)
            if config.id == 6010201 or config.id == 6010203 or config.id == 6010204 then
                if gRole and gRole:getHp() > 0 then--只有主角血条大于0的时候
                    mgr.ViewMgr:openView2(ViewName.BloodBuyView, {})
                else
                    GCloseBloodBuyView()
                end
            end
            self:handleBuff(data.roleId, buffInfo, false)
            roleBuffs[data.buffId] = nil
        end
    end
    self:refreshBuffDisplay()
end
--移除buff-玩家消失
function BuffMgr:removeThingBuff(data)
    if not data.roleId then return end 
    local roleBuffs = self.buffs[data.roleId]
    if roleBuffs then
        for k, v in pairs(roleBuffs) do 
            self:handleBuff(data.roleId, v, false)
            -- if v.ectName then --清理buff特效
            --     plog("移除buff-",v.ectName)
            --     mgr.EffectMgr:removeEffectByName(v.ectName)
            -- end
        end
    end
    self.buffs[data.roleId] = nil
    -- if data.roleId == cache.PlayerCache:getRoleId() then
    --     --移除玩家自己的bufficon显示
    --     self.buffIcons = {}
    --     self:refreshBuff()
    -- end
end
--TODO 刷新主界面buff显示
function BuffMgr:refreshBuff()
    -- body
    table.sort(self.buffIcons,function(a,b)
        if a.over_type ~= b.over_type then
            return a.over_type > b.over_type
        end
    end)
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        mainView:updateBuffs(self.buffIcons)
    end
end

--buff配置处理
function BuffMgr:handleBuff(roleId, buffInfo, isAdd)
    local config = conf.BuffConf:getBuffConf(buffInfo.modelId)
    local isSelf = false
    if config then
        local thing
        if roleId == gRole:getID() then
            isSelf = true
            thing = gRole
            --处理自己 buff-icon
            local icon = config["icon"]
            if icon then
                if isAdd then
                    table.insert(self.buffIcons, config)
                else
                    local len = #self.buffIcons
                    for i=len, 1,-1 do
                        if self.buffIcons[i].id == config.id then
                            table.remove(self.buffIcons, i)
                        end
                    end
                end
                --TODO 刷新主界面buff显示
                self:refreshBuff()
            end
            --效果类型
            local client = config["client_type"]
            if client then
                if client == 101 then  --眩晕冰冻无法操作
                    if isAdd then
                        thing:fixed()
                    else
                        thing:removeFixed()
                    end
                elseif client == 102 then  --定身，只能攻击不能做其他操作
                    if isAdd then
                        thing:setDingShen(true)
                    else
                        thing:setDingShen(false)
                    end
                elseif client == 103 then  --战斗状态
                    thing:setFightState(isAdd)
                    if not isAdd then  --离开战斗状态
                        --mgr.FightMgr:clear()
                    end
                end    
            end
            --print("@您获得一个buff："..buffInfo.modelId)
        else
            thing = mgr.ThingMgr:getObj(ThingType.player, roleId)
            if not thing then
                thing = mgr.ThingMgr:getObj(ThingType.monster, roleId)
            end
            if thing then
                --效果类型
                local client = config["client_type"]
                if client then
                    if client == 101 or client == 102 then  --眩晕冰冻无法操作
                        thing:stopAI()
                    end
                end
            end
            
        end
        if not thing then return end
        local client = config["client_type"]
        if client then
            if client == 613 then   -- 红名id配到buff配置
                thing:setHongMing(isAdd)
            end
        end

        --打坐
        local dazuo = config["dazuo"]
        if dazuo then
            if isAdd then
                thing:sit()
            else
                thing:cancelSit()
            end
            thing:setHeadBarPos()
        end
        --变身
        local args = config["bs_args"]
        if args then  
            if isAdd then
                thing:changeBody(args)
            else
                thing:restoreBody()
            end
            if isSelf == false then  --如果是变身别人不加特效
                return
            end
        end
        --buff 特效
        local ect = config["ect"]
        if ect then
            local effectId = ect[1]
            if isAdd then
                thing:addBuffEct(effectId)
            else
                if #ect > 1 then
                    local parent
                    local ectConf = conf.EffectConf:getEffectById(ect[2])
                    if ectConf["layer"] == 5 then
                        parent = thing:getModel()
                    elseif ectConf["layer"] == 6 then  --头顶
                        parent = thing:getTop()
                    else
                        parent = thing:getRoot()
                    end
                        if  mgr.QualityMgr:getAllSkillEffect() then
                            mgr.EffectMgr:playCommonEffect(ect[2], parent)
                        end
                        
                end
                thing:removeBuffEct(effectId)
            end
        end
    end
end
--刷新部分buffs的显示
function BuffMgr:refreshBuffDisplay()
    --改变baff的时候刷新
    local view = mgr.ViewMgr:get(ViewName.PlayerHpView)
    if view then--玩家
        local data = view:getData()
        local viewRoleId = data and data.roleId or 0
        local buffs = self.buffs[viewRoleId]
        if buffs then
            local lists = {}
            for k,v in pairs(buffs) do
                local config = conf.BuffConf:getBuffConf(v.modelId)
                if config and config.icon then
                    table.insert(lists, v)
                end
            end
            view:setBuffsData(lists)
        end
    end
    local view = mgr.ViewMgr:get(ViewName.BossHpView)
    if view then--boss
        local buffs = self.buffs[view:getBossRoleId()]
        if buffs then
            local lists = {}
            for k,v in pairs(buffs) do
                local config = conf.BuffConf:getBuffConf(v.modelId)
                if config and config.icon then
                    table.insert(lists, v)
                end
            end

            view:setBuffsData(lists)
        end
    end
end

return BuffMgr