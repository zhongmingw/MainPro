--
-- Author: 
-- Date: 2018-08-08 19:30:05
--

local KuaFuChargeRank = class("KuaFuChargeRank", base.BaseView)

function KuaFuChargeRank:ctor()
    KuaFuChargeRank.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function KuaFuChargeRank:initView()
    local btnclose = self.view:GetChild("n1"):GetChild("n2")
    -- btnclose.visible = false
    self:setCloseBtn(btnclose)

    self.list2 = self.view:GetChild("n6")
    self.list2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list2:SetVirtual()
    self.list2.numItems = 0

    local var = conf.ActivityConf:getHolidayGlobal("kf_cz_min_yb")
    self.view:GetChild("n7").text = string.format(language.kuafuCharge09,var)

end

function KuaFuChargeRank:initData(data)
    self.data = data 
    table.sort(self.data,function(a,b)
        -- body
        return a.rank < b.rank
    end)

    local rankSize = conf.ActivityConf:getHolidayGlobal("cz_rank_size")
    self.list2.numItems = rankSize
end


function KuaFuChargeRank:celldata( index, obj )
    -- body
    local data = self.data[index+1]
    local c1 = obj:GetController("c1")
    if index <= 3 then
        c1.selectedIndex = index
    else
        c1.selectedIndex = 3
    end
    local rank = obj:GetChild("n1")
    local name = obj:GetChild("n2")
    local quota = obj:GetChild("n3")
    obj:GetChild("n9").visible = false
    if data then
        rank.text = data.rank
        name.text = data.name
        quota.text = data.quota
        local roleId = data.roleId --玩家id
        local uId = string.sub(roleId,1,3)
        obj:GetChild("n9").visible = false
        -- print("cache.PlayerCache:getRedPointById(10327)",cache.PlayerCache:getRedPointById(10327),roleId)
        if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
           obj:GetChild("n9").visible = true
        end
        if data.roleId == cache.PlayerCache:getRoleId() then
            obj:GetChild("n9").visible = false
        end
    else
        rank.text = index + 1
        name.text = language.rank03
        quota.text = ""
    end
    
end
function KuaFuChargeRank:setData(data_)

end

return KuaFuChargeRank