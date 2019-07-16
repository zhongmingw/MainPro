--
-- Author: yr
-- Date: 2017-04-10 17:43:11
--

local BuffView = class("BuffView", base.BaseView)

function BuffView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1 
    self.uiClear = UICacheType.cacheForever
end

function BuffView:initView()
    self.buffList = self.view:GetChild("n11")
    --self.buffList:SetVirtual()
    self.buffList.itemRenderer = function(index,obj)
        self:buffItemRenderer(index, obj)
    end
    self.buffList.numItems = 0

    local btnclose = self.view:GetChild("n10")
    btnclose.onClick:Add(self.onCloseView,self)
end

function BuffView:initData(data)
    self.roleId = data and data.roleId or cache.PlayerCache:getRoleId()
    if data and data.roleId and data.roleId ~= cache.PlayerCache:getRoleId() then
        self.attris = data.attris
    end
    self:addTimer(1,-1,handler(self,self.onTimer))
end

function BuffView:setData(data_)
    self.keys = {}
    self.buffs = mgr.BuffMgr:getBuffByid(self.roleId)
    for k ,v in pairs(self.buffs) do
        local config = conf.BuffConf:getBuffConf(v.modelId)
        if config.icon then
            table.insert(self.keys,k)
        end
    end
    --self.keys = table.keys(self.buffs)

    self.bufftext = {}
    self.buffList.numItems = #self.keys
end

function BuffView:getStringBy(key)
    -- body
    local str = ""
    local buffinfo = self.buffs[key]
    local config = conf.BuffConf:getBuffConf(buffinfo.modelId)
    if config.affect_type == 1015 or config.affect_type == 1016 then --经验符buff
        local var = string.format(language.buff01,config.arg_1/100)
        str = config.name..":"..mgr.TextMgr:getTextColorStr(var, 10).."\n"
        str = str..language.buff02
    elseif config.affect_type == 1030 then --回血buff
        str = config.name..":"..mgr.TextMgr:getTextColorStr(config.desc or "", 10).."\n"
        str = str..language.buff03
    elseif config.affect_type == 1046 then --世界等级buff
        local worldLv = cache.PlayerCache:getAttribute(20138)
        local myLv = cache.PlayerCache:getRoleLevel()
        if worldLv - myLv > 0 then
            local addition = conf.WorldLevConf:getAdditionById(worldLv-myLv)
            str = config.name ..":".."\n" .. string.format(config.desc,addition)
        else
            local addition = conf.WorldLevConf:getBaseExpPer()
            str = config.name ..":".."\n" .. string.format(config.desc,addition)
        end
    elseif config.affect_type == 1081 then--红名buff
        local var = cache.PlayerCache:getAttribute(613)
        local roleId = cache.PlayerCache:getRoleId()
        if roleId ~= self.roleId and self.attris and self.attris[613] then
            var = self.attris[613]
        end
        local confData = conf.SysConf:getRedDataByValue(var)
        if confData and confData.red_lev then
            str = config.name ..":".. "\n" .. language.gonggong126 .. var .. "\n" .. confData.red_lev .. ":" .. (config.desc or "") .. "\n" .. language.gonggong127
        end
    end
    if str == "" then
        str = config.name ..":".."\n" .. (config.desc or "")
    end
    return str
end

function BuffView:onTimer()
    -- body
    for k , v in pairs(self.bufftext) do
        if v and self.buffs[k] then
            local buffinfo = self.buffs[k]
            local config = conf.BuffConf:getBuffConf(buffinfo.modelId)
            if config.affect_type == 1015 or config.affect_type == 1016 
                or config.affect_type == 1048 or config.affect_type == 1074 
                or config.affect_type == 1079 then
                local nowtime = buffinfo.endTime - mgr.NetMgr:getServerTime()
                if nowtime < 0 then
                    nowtime = 0
                end
                v.txt.text = v.str..mgr.TextMgr:getTextColorStr(GTotimeString(nowtime), 10)
            elseif config.affect_type == 1030 then
                v.txt.text = v.str..mgr.TextMgr:getTextColorStr(buffinfo.reserves, 10)
            end
        end
    end
end
--设置buff-item
function BuffView:buffItemRenderer(index, cell)
    local key = self.keys[index + 1] 
    cell.data = key
    local buffinfo = self.buffs[key]
    local bId = buffinfo.modelId
    local config = conf.BuffConf:getBuffConf(bId)
    local icon = cell:GetChild("n0") 
    icon.url = ResPath.buffRes(config.icon)
    local txt =  cell:GetChild("n1") 
    txt.text = self:getStringBy(key)--config.name or ""
    if config.affect_type == 1015 
        or config.affect_type == 1016 or config.affect_type == 1079
        or 1030 == config.affect_type or config.affect_type == 1048 or config.affect_type == 1074 then
        self.bufftext[key] = {txt = txt , str = txt.text}
    end
    -- --动态改变item 大小
    -- if txt.height > 24 then
    --     cell.height = txt.height + 2
    -- else
    --     cell.height = 24
    -- end

end

function BuffView:addBuff(data)
    -- body
    if data.roleId~=self.roleId then
        return
    end
    --没有这个buff
    local flag = false
    for k ,v in pairs(self.keys) do
        if v == data.buffInfo.buffId then
            flag = true
        end
    end

    if not flag then
        self:setData()
    else
        for k ,v in pairs(self.keys) do
            if v == data.buffInfo.buffId then
                local cell = self.buffList:GetChildAt(k-1)
                if cell then
                    --找到了对应的条目需要改点东西
                    --plog("找到了对应的条目需要改点东西")
                end
                break
            end
        end
    end
end

function BuffView:removeBuff(data)
    -- body
    if data.roleId~=self.roleId then
        return
    end

    for k ,v in pairs(self.keys) do
        if v == data.buffId then
            --plog("找到了buff")
            self.bufftext[v] = nil 
            self.buffs[v] = nil
            table.remove(self.keys,k)
            self.buffList:RemoveChildAt(k-1)
            break
        end
    end
end

function BuffView:onCloseView()
    -- body
    self:closeView()
end

return BuffView