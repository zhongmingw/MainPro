--
-- Author: 
-- Date: 2017-11-23 00:23:15
--

local DropRecordPanel = class("DropRecordPanel",import("game.base.Ref"))

function DropRecordPanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function DropRecordPanel:initPanel()
    local panelObj = self.mParent.view:GetChild("n18")
    self.listView = panelObj:GetChild("n0")
    self:initListView()
end

function DropRecordPanel:initListView()
    self.listView.numItems = 0 
    self.listView:SetVirtual()
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
end

function DropRecordPanel:setData(data)
    if data.records then
        self.data = data.records
        if #data.records <= 100 then
            self.listView.numItems = #data.records
        else
            self.listView.numItems = 100
        end
    end
end

function DropRecordPanel:cellData(index,obj)
    local controller = obj:GetController("c1")
    local timeTitle = obj:GetChild("n1") 
    local key = index+1 
    if key%2 == 0 then 
        controller.selectedIndex = 0
    else
        controller.selectedIndex = 1
    end
    timeTitle.text = self.data[key]
    timeTitle.onClickLink:Add(self.onClickLinkText,self)
 
end

function DropRecordPanel:onClickLinkText(context)
    local params = {}
    local strText = context.data  
    local strList = string.split(strText,ChatHerts.PLAYINFOHERT) --以'@@'分割
    local str = string.sub(context.data, 1,1)
    if str == ChatHerts.SYSTEMPRO then--道具查看
        local strProList = string.split(strList[1],ChatHerts.SYSTEMPRO) --以'|'分割
        local mid = strProList[3]
        if strProList[3] then 
            local isSuit = conf.ItemConf:getSuitmodel(mid) --是不是时装
            if isSuit then 
                mgr.ViewMgr:openView(ViewName.FashionTipsView,function(view)
                    local data = {mid = mid}
                    view:setData(data)end)
                return
            else
                -- mgr.ChatMgr:onLinkSystemPros(strText) --普通道具
            end
        end
        mgr.ChatMgr:onLinkSystemPros(strText) --普通道具
    elseif str == "@" then  --玩家查看@@
        params = {roleId =strList[2],roleIcon = strList[3],roleName = strList[4]}
        if params.roleId == cache.PlayerCache:getRoleId() then
            GComAlter(language.gonggong57)
            return
        else
            mgr.ViewMgr:openView(ViewName.FriendTips,function (view)
            view:setData(params)
            end)
        end
    end
end

return DropRecordPanel