--排行榜
local RankConf = class("RankConf",base.BaseConf)

function RankConf:init()
    self:addConf("rank_type")
end

--获取排行榜类型配置
function RankConf:getRankNameById( id )
    -- body
    local data = self.rank_type[tostring(id)]
    if data then
        return data
    end
    return nil
end

--获取排行榜总榜图片说明
function RankConf:getRankSrcById( id )
    -- body
    local data = self.rank_type[tostring(id)]
    if data then
        return data.src
    end
    return nil
end

--获取排行描述
function RankConf:getRankDescribe( id )
    -- body
    local dec = ""
    for k,v in pairs(self.rank_type) do
        if id == v.sort then
            dec = v.dec
            break
        end
    end
    return dec
end
return RankConf