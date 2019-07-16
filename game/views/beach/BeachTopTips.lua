--
-- Author: 
-- Date: 2018-01-04 11:07:41
--

local BeachTopTips = class("BeachTopTips", base.BaseView)

function BeachTopTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BeachTopTips:initView()

end

function BeachTopTips:initData(data)
    -- body
    --定时器
    if data then
        self:addMsgCallBack(data)
    end
end

function BeachTopTips:setData(data_)

end


function BeachTopTips:addMsgCallBack(data)
    -- body
    if data.msgId == 8190202 then
        self.data = data
        
        self:addTimer(conf.BeachConf:getValue("keeptime"), 1, function( ... )
            -- body
            self:closeView()
        end)
    end
end

return BeachTopTips