--排行榜
local RankProxy = class("RankProxy",base.BaseProxy)

function RankProxy:init()
    self:add(5280101,self.add5280101) --请求排行榜总榜返回
    self:add(5280102,self.add5280102) --请求排行榜单榜返回
    self:add(5280103,self.add5280103) --请求给第一名点赞返回
    self:add(5280104,self.add5280104) --请求点赞
end

--排行榜请求
function RankProxy:sendRankMsg(sendId,param,from)
    --from 1为总榜 2为单榜
    self.from = from
    self:send(sendId,param)
end

--请求排行榜总榜返回
function RankProxy:add5280101( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankMainView)
        if view then
            view:setData(data)
            view:refreshTotalRank()
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求排行榜单榜返回
function RankProxy:add5280102( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankMainView)
        if view then
            -- print("单榜信息返回")
            -- printt(data)
            view.RankInfoPanel:setRankInfo(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

--请求给第一名点赞返回
function RankProxy:add5280103( data )
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankMainView)
        if view then
            if self.from == 1 then
                view:sendTotalRankMsg()
            elseif self.from == 2 then
                view.RankInfoPanel:refreshPraise(data)
            end
        end
    else
        -- GComAlter(language.rank02)
        GComErrorMsg(data.status)
    end
end

--请求排行榜点赞
function RankProxy:add5280104( data )
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.RankMainView)
        if view then
            view:setDzInfo(data.dzIds)
        end
        proxy.RankProxy:sendRankMsg(1280101)
    else
        GComErrorMsg(data.status)
    end
end

return RankProxy