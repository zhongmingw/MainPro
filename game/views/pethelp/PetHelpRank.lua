--
-- Author: 
-- Date: 2018-07-24 19:23:52
--

local PetHelpRank = class("PetHelpRank", base.BaseView)

function PetHelpRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function PetHelpRank:initView()
    local btnclose = self.view:GetChild("n1"):GetChild("n2")
    btnclose.visible = false
    self:setCloseBtn(self.view)

    self.list2 = self.view:GetChild("n6")
    self.list2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.list2:SetVirtual()
    self.list2.numItems = 0

    local var = conf.ActivityConf:getHolidayGlobal("pet_find_rank_min")
    self.view:GetChild("n7").text = string.format(language.pethelpactive05,var)
end

function PetHelpRank:initData(data)
    -- body
    self.data = data 
    table.sort(self.data,function(a,b)
        -- body
        return a.rank < b.rank
    end)

    self.list2.numItems = #self.data
end

function PetHelpRank:celldata( index, obj )
    -- body
    local data = self.data[index+1]
    local c1 = obj:GetController("c1")
    if data.rank<= 3 then
        c1.selectedIndex = data.rank - 1
    else
        c1.selectedIndex = 3
    end
    
    local str = string.split(data.roleName,".")
    local namestr = mgr.TextMgr:getTextColorStr(str[1]..".", 7)..str[2]

    obj:GetChild("n1").text = data.rank
    obj:GetChild("n2").text = namestr
    obj:GetChild("n3").text = data.times
    local roleId = data.roleId --玩家id
    local uId = string.sub(roleId,1,3)
    obj:GetChild("n9").visible = false
    if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
       obj:GetChild("n9").visible = true
    end
end


function PetHelpRank:setData(data_)

end

return PetHelpRank