--
-- Author: 
-- Date: 2017-02-07 15:28:30
--
local FriendConf = class("FriendConf",base.BaseConf)

function FriendConf:init()
    self:addConf("charm_jinjie")--M-魅力配置

    self:addConf("friend_limit")--
end

function FriendConf:getDataById(id)
    -- body
    --plog("id",id)
    return self.charm_jinjie[id..""]
end

function FriendConf:getDayFriendNum(id)
    -- body
    local maxId = id or 1

    if self.friend_limit[maxId..""] then
        return self.friend_limit[maxId..""]
    else
        maxId = 1
        for k ,v in pairs(self.friend_limit) do
            if not maxId then
                maxId = v.id 
            else
                maxId = math.max(v.id ,maxId )
            end
        end
    end
    -- print("maxId",maxId)
    return self.friend_limit[maxId..""]
end


return FriendConf