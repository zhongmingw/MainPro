--
-- Author: wx
-- Date: 2017-11-23 14:55:33
--

local HomeOS = class("HomeOS", base.BaseView)

function HomeOS:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function HomeOS:initData(data)
    -- body
    
    self.zu1.visible = false
    self.zu2.visible = false
    self.data = data.data

    local mainview = mgr.ViewMgr:get(ViewName.HomeMainView)
    --print("view.c1.selectedIndex")
    if not mainview then
        -- mainview:changePageBtn()
        self:closeView()
        return
    elseif mainview.pageIndex ~= 2 then
        mainview:changePageBtn()
        self:closeView()
        return
    end
    --
    mainview:changePageBtn(true)

    self:setData()
end

function HomeOS:initView()
    self.zu1 = self.view:GetChild("n2")
    
    local btn1 = self.view:GetChild("n0")
    btn1.onClick:Add(self.onPlant,self)

    local btn2 = self.view:GetChild("n1")
    btn2.onClick:Add(self.onTianUp,self)

    self.zu2 = self.view:GetChild("n7")
    

    local btnJiaoshuo = self.view:GetChild("n4")
    btnJiaoshuo.data = 2
    btnJiaoshuo.onClick:Add(self.onBtnCall,self)

    local btnChuishu = self.view:GetChild("n5")
    btnChuishu.data = 3
    btnChuishu.onClick:Add(self.onBtnCall,self)

    local btnClear = self.view:GetChild("n6")
    btnClear.data = 6
    btnClear.onClick:Add(self.onBtnCall,self)
end

function HomeOS:onPlant()
    -- body
    if not self.data then
        return
    end
    local mainview = mgr.ViewMgr:get(ViewName.HomeMainView)
    if mainview then
        mainview:changePageBtn()
    end
    mgr.ViewMgr:openView2(ViewName.HomePlantingChoose,self.data)
    self:closeView()
end

function HomeOS:onTianUp()
    -- body
    if not self.data then
        return
    end
    local condata = conf.HomeConf:getHomeThing(self.data.ext01)
    if condata.type ~= 5 then
        return
    end
    mgr.HomeMgr:updateTian(self.data,function()
        local mainview = mgr.ViewMgr:get(ViewName.HomeMainView)
        if mainview then
            mainview:changePageBtn()
        end
        self:closeView()
    end)
end

function HomeOS:onBtnCall(context)
    -- body
    local data = context.sender.data
    if tonumber(data) == 2 then
        --浇水
        mgr.HomeMgr:doWater(self.data)
    elseif tonumber(data) == 3 then
        --催熟
        mgr.HomeMgr:doAccelerate({self.data})
    elseif tonumber(data) == 6 then
        --清理
        mgr.HomeMgr:doClear(self.data,function( ... )
            local mainview = mgr.ViewMgr:get(ViewName.HomeMainView)
            if mainview then
                mainview:changePageBtn()
            end
            self:closeView()
        end)
    end
end

function HomeOS:setData(data_)
    local condata = conf.HomeConf:getHomeThing(self.data.ext01)
    if condata.type == 5 then
        if self.data.mId == 0 then
            self.zu1.visible = true
        else
            self.zu2.visible = true
        end
    end
end

function HomeOS:addMsgCallBack(data)
    -- body
    if data.msgId == 5460111 then
        --重新获取对象信息
        --做一点延迟
        if data.reqType == 2
        or data.reqType == 3 
        or data.reqType == 6 then
            self:addTimer(0.5,1,function( ... )
                -- body
                for k ,v in pairs(data.confId) do
                    local monster = mgr.HomeMgr:getComponentById(k)
                    if monster then
                        self.data = monster.data
                    end
                end
            end)
        elseif data.reqType == 4 then
            local mainview = mgr.ViewMgr:get(ViewName.HomeMainView)
            if mainview then
                mainview:changePageBtn()
            end
            self:closeView()
        end
    end
end

return HomeOS