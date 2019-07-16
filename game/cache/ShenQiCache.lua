--
-- Author: Your Name
-- Date: 2018-07-04 22:17:19
--
local ShenQiCache = class("ShenQiCache",base.BaseCache)
local qhsMid ={221042661,221042662,221042663,221042664,221042665,221042666,221043903,221043904}
function ShenQiCache:init()
    self.redNum = 0
    self.fjRedNum = 0
end

function ShenQiCache:setRedNum(num)
    self.redNum = num
end

function ShenQiCache:setFenjieRedNum()
    local qhsData = {}
    for k,v in pairs(qhsMid) do
        local data = cache.PackCache:getPackDataById(v,true)
        if data.amount > 0 then
            table.insert(qhsData,data)
        end
    end
    if #qhsData > 0 then
        self.fjRedNum = 1
    else
        self.fjRedNum = 0
    end
end
--强化、升星、附灵红点
function ShenQiCache:getRedNum()
    return self.redNum
end
--分解红点
function ShenQiCache:getFenJieRed()
    self:setFenjieRedNum()
    return self.fjRedNum
end

return ShenQiCache