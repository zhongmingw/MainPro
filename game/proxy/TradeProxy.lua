--
-- Author: 
-- Date: 2017-03-22 19:30:20
--

local TradeProxy = class("TradeProxy",base.BaseProxy)

function TradeProxy:init()
    -- self:add(5010101,self.resLogin)
    self:add(5260201,self.add5260201)-- 请求申请交易
    self:add(5260202,self.add5260202)-- 请求同意&拒绝交易申请
    self:add(5260203,self.add5260203)-- 请求交易添加&移除
    self:add(5260204,self.add5260204)-- 请求锁定交易
    self:add(5260205,self.add5260205)-- 请求确认&取消交易
    self:add(5260206,self.add5260206) --金钱交易

    self:add(8070101,self.add8070101)-- 交易广播
    self:add(8070102,self.add8070102)-- 交易物品变化广播
    self:add(8070103,self.add8070103)--  交易金钱变化广播

    self.param = nil
end

function TradeProxy:add5260201(data)
    -- body
    if data.status == 0 then
        GComAlter(language.trade05)
        cache.TradeCache:setrequestTrade(conf.SysConf:getValue("trade_wait_reply"))
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add5260202(data)
    -- body
    if data.status == 0 then
        if data.tradeType == 1 then
            mgr.ViewMgr:openView(ViewName.TradeMainView,function(view)
                -- body
                view:setData()
                if self.param then
                    view:setOtherData(self.param)
                end
            end)
        else
            local view = mgr.ViewMgr:get(ViewName.TradeMainView)
            if view then
                view:closeView()
            end
        end
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add5260203(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TradeMainView)
        if view then
            view:add5260203(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add5260204(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TradeMainView)
        if view then
            view:add5260204(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add5260205(data)
    -- body
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add5260206( data )
    -- body
    if data.status == 0 then
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add8070101(data)
    -- body
    if data.status == 0 then
        if data.noticeType == 1 then
            --副本不给交易
            if mgr.FubenMgr:isFuben(cache.PlayerCache:getSId()) then
                return
            end
            local t = clone(language.trade06)
            t[2].text = string.format(t[2].text,data.roleName)

            local param = {}
            param.type = 2
            param.timer = conf.SysConf:getValue("trade_wait_reply")
            param.richtext = mgr.TextMgr:getTextByTable(t)
            param.sure = function()
                -- body
                local view = mgr.ViewMgr:get(ViewName.TradeMainView)
                if view then
                    GComAlter(language.trade08)
                    return
                end

                self:send(1260202,{tradeType = 1,originRoleId = data.originRoleId })
            end
            param.cancel = function()
                -- body
                self:send(1260202,{tradeType = 2,originRoleId = data.originRoleId })
            end
            param.closefun = function()
                -- body
                self:send(1260202,{tradeType = 2,originRoleId = data.originRoleId })
            end
            self.param = data
            GComAlter(param)
        elseif data.noticeType == 2 then--2同意申请 对方同意了我的申请
            cache.TradeCache:removeTimer()
            --拒接其他交易
            local view = mgr.ViewMgr:get(ViewName.Alert2)
            if view then
                --拒绝交易
                view:onBtnLeftCallBack()
            end

            mgr.ViewMgr:openView(ViewName.TradeMainView,function(view)
                -- body
                view:setData()
                view:setOtherData(data)
            end,{})

            -- local view = mgr.ViewMgr:get(ViewName.TradeMainView)
            -- if view then
            --     view:setOtherData(data)
            -- end
            
        elseif data.noticeType == 3 then-- 对方绝交了我的申请
            local view = mgr.ViewMgr:get(ViewName.Alert2)
            if view then
                view:closeView()
            end
            GComAlter(language.trade07)
            cache.TradeCache:removeTimer()
        elseif data.noticeType == 4 then-- 4广播交易状态
            cache.TradeCache:removeTimer()
            local view = mgr.ViewMgr:get(ViewName.TradeMainView)
            if view then
                if data.tradeStatu == 1 then --:发起者锁定
                    if cache.PlayerCache:getRoleId() ~= data.originRoleId then 
                        view:otherTrade(data)
                    else
                        view:add5260204()
                    end
                elseif data.tradeStatu == 2 then--被邀请者锁定
                    if cache.PlayerCache:getRoleId() == data.originRoleId then 
                        view:otherTrade(data)
                    else
                        view:add5260204()
                    end
                elseif data.tradeStatu == 3 then--全部锁定 
                    view:twoSuo() 
                elseif data.tradeStatu == 7 then
                    if cache.PlayerCache:getRoleId() ~= data.originRoleId then
                        --对方确定
                        --view:setTimer()
                        GComAlter(language.trade14)
                    else
                        --自己确定了
                    end
                elseif data.tradeStatu == 11 then
                    if cache.PlayerCache:getRoleId() == data.originRoleId then
                        --对方确定
                        --view:setTimer()
                        GComAlter(language.trade14)
                    else
                        --自己确定了
                    end
                elseif data.tradeStatu == 15 then
                    GComAlter(language.trade09)
                    view:closeView()
                end
            end
        elseif data.noticeType == 5 then-- 交易取消
            local view = mgr.ViewMgr:get(ViewName.TradeMainView)
            if view then
                view:closeView()
            end
            local view = mgr.ViewMgr:get(ViewName.Alert2)
            if view then
                view:closeView()
            end
            GComAlter(language.trade12)
            cache.TradeCache:removeTimer()
        elseif data.noticeType == 6 then-- 取消cd
            cache.TradeCache:removeTimer()
        end
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add8070102(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TradeMainView)
        if view then
            view:add8070102(data)
        end
    else
        GComErrorMsg(data.status)
    end
end

function TradeProxy:add8070103(data)
    -- body
    if data.status == 0 then
        local view = mgr.ViewMgr:get(ViewName.TradeMainView)
        if view then
            view:add8070103(data)
        end
    else
        GComErrorMsg(data.status)
    end
end


return TradeProxy