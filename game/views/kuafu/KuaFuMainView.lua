--
-- Author: wx
-- Date: 2017-06-27 15:07:51
-- 跨服主界面
local TeamFuben = import(".TeamFuben")--组队副本
local BossPanel = import(".BossPanel")--精英boss
local PanelWar = import(".PanelWar")--三界争霸
local KuaFuMainView = class("KuaFuMainView", base.BaseView)
function KuaFuMainView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.drawcall = false
end

function KuaFuMainView:initData(data)
    -- body
    --货币管理注册
    GSetMoneyPanel(self.window2,self:viewName())

    self:sortList()
    --默认选择
    local index
    if not data or not data.index then
        index = 0
    else
        index = data.index
    end
    self.childIndex = data.sceneId
    self.controllerC1.selectedIndex = index
    self:onbtnController()

    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil  
    end
    --self:onTimer()
    self.timer = self:addTimer(1, -1, handler(self, self.onTimer))
end

function KuaFuMainView:sortList()
    -- body
    local t = {
        1093, --组队副本
        1094, --三界争霸
        1095, --精英boss 
    }
    local index = 1
    for k , v in pairs(t) do
        if k == 1 then
            self.btnlist[k].visible = false
        else
            self.btnlist[k].visible = GCheckView(v) 
        end
        if self.btnlist[k].visible then
            self.btnlist[k].y = self.btnPos[index]
            index = index + 1
        end
    end
end

function KuaFuMainView:onTimer()
    -- body
    if self.controllerC1.selectedIndex == 2 then
        if self.BossPanel then
            self.BossPanel:onTimer()
        end
    elseif self.controllerC1.selectedIndex == 0 then
        if self.TeamFuben then
            self.TeamFuben:onTimer()
        end
    elseif self.controllerC1.selectedIndex == 1 then
        if self.PanelWar then
            self.PanelWar:onTimer()
        end
    end    
end

function KuaFuMainView:initView()
    self.window2 = self.view:GetChild("n0")
    local closeBtn = self.window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    --选择控制器
    self.controllerC1 =  self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onbtnController,self)
    --按钮及其文本
    self.btnlist = {}
    self.btnPos = {}
    for i = 1 , 3 do
        local btn = self.view:GetChild("n"..i)
        btn:GetChild("title").text = language.kuafu01[i]
        table.insert(self.btnlist,btn)
        table.insert(self.btnPos, btn.y)
    end
end

function KuaFuMainView:setData(data_)

end

function KuaFuMainView:onbtnController()
    -- body
    if  0 == self.controllerC1.selectedIndex then --组队副本
        --开组队副本
        if not self.TeamFuben then
            self.TeamFuben = TeamFuben.new(self.view:GetChild("n7"))
        end
        if cache.KuaFuCache:isWillOpenByid(2) then
            --列表
            self.TeamFuben:setWillOpen()
        else
            --请求消息
            proxy.KuaFuProxy:sendMsg(1380101,{teamId=0})
        end
    elseif 1 == self.controllerC1.selectedIndex then
        if not self.PanelWar then
            self.PanelWar = PanelWar.new(self.view:GetChild("n10"))
        end
        --设置背景图
        self.PanelWar:setBg()
        proxy.KuaFuProxy:sendMsg(1410101)
        -- if cache.KuaFuCache:isWillOpenByid(3) then
        --     --列表
        --     self.PanelWar:setWillOpen()
        -- else
        --     --请求消息
            
        -- end
    elseif 2 == self.controllerC1.selectedIndex then
        if not self.BossPanel then
            self.BossPanel = BossPanel.new(self)
        end
        self.BossPanel.reset = false
        self.BossPanel.listView.numItems = 0
        if cache.KuaFuCache:isWillOpenByid(1) then
            --列表
            self.BossPanel:setWillOpen()
        else
            --请求跨服精英boss信息
            proxy.KuaFuProxy:send(1330301)
        end  
    end
end

function KuaFuMainView:addMsgCallBack(data)
    -- body
    if  0 == self.controllerC1.selectedIndex then --组队副本
        if not self.TeamFuben then
            return
        end
        self.TeamFuben:addMsgCallBack(data)
    elseif 1 == self.controllerC1.selectedIndex then
        if not self.PanelWar then
            return
        end
        self.PanelWar:addMsgCallBack(data)
    elseif 2 == self.controllerC1.selectedIndex then
        if not self.BossPanel then
            return
        end
        if 5330301 == data.msgId then
            self.BossPanel:add5330301(data,self.childIndex)
            self.childIndex = nil 
        end
    end
end

function KuaFuMainView:onClickClose()
    -- body
    self:closeView()
end

return KuaFuMainView