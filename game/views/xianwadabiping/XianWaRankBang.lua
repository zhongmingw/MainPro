--
-- Author: 
-- Date: 2018-07-24 19:23:52
--

local XianWaRankBang = class("XianWaRankBang", base.BaseView)

function XianWaRankBang:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function XianWaRankBang:initView()
    local btnclose = self.view:GetChild("n1"):GetChild("n2")
    self:setCloseBtn(self.view)

    self.list2 = self.view:GetChild("n6")
    self.list2.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    --self.list2:SetVirtual()
    self.list2.numItems = 10

    local var = conf.ActivityConf:getHolidayGlobal("xt_rank_min_power")
    self.view:GetChild("n7").text = string.format(language.XianWaDaBiPing05,var)
    
end

function XianWaRankBang:initData(data)
    -- body
    self.data = data 
    table.sort(self.data,function(a,b)
        -- body
        return a.rank < b.rank
    end)
    local num = conf.ActivityConf:getHolidayGlobal("xt_rank_size")
    self.list2.numItems = num
       
end

function XianWaRankBang:celldata( index, obj )
    -- body
    if self.data then
        local data = self.data[index+1]
        if data then
            local c1 = obj:GetController("c1")
            if data.rank <= 3 then
                c1.selectedIndex = data.rank - 1
            else
                c1.selectedIndex = 3
            end
            local str = string.split(data.name,".")
            local namestr = mgr.TextMgr:getTextColorStr(str[1]..".", 7)..mgr.TextMgr:getTextColorStr(str[2], 7)
            obj:GetChild("n1").text = data.rank
            obj:GetChild("n2").text = namestr
            obj:GetChild("n3").text = data.power
            local roleId = data.roleId --玩家id
            local uId = string.sub(roleId,1,3)
            obj:GetChild("n9").visible = false
            -- print("其他玩家id:"..uId.."玩家当前id:"..cache.PlayerCache:getRedPointById(10327))
            if cache.PlayerCache:getRedPointById(10327) ~= tonumber(uId) and tonumber(roleId) > 10000 then
               obj:GetChild("n9").visible = true
            end
            if roleId == cache.PlayerCache:getRoleId() then --隐藏自身标志
                obj:GetChild("n9").visible = false
            end
        else
            local c = obj:GetController("c1")
            if index == 0 then
                c.selectedIndex = 0
            elseif index == 1 then
                c.selectedIndex = 1
            elseif  index == 2 then
                c.selectedIndex = 2
            else
                c.selectedIndex = 3
            end
            obj:GetChild("n9").visible = false
            obj:GetChild("n1").text = index + 1
            obj:GetChild("n2").text = language.rank03
            obj:GetChild("n3").text = 0
        
        end
    end
end


function XianWaRankBang:setData(data_)

end

return XianWaRankBang