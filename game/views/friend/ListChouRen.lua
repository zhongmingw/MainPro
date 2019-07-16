--
-- Author: wx
-- Date: 2017-01-16 11:40:34
-- dec : 仇人列表

local ListChouRen = class("ListChouRen", import("game.base.Ref"))

function ListChouRen:ctor(param)
    self.view = param
    self:initView()
end

function ListChouRen:initView( ... )
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0
end

function ListChouRen:celldata( index,obj )
    -- body
    if index >= self.view.numItems then
        if self.data.totalSum == self.data.page then 
        else
            proxy.FriendProxy:send(1070203,{page = self.data.page + 1})
        end
    end
    --头像
    local data = self.data.enemyList[index+1]
    local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId}
    GBtnGongGongSuCai_050(obj:GetChild("n15"),t)
    obj:GetChild("n15").onClick:Add(self.onHeadCall, self)
   
    --名字
    local name = obj:GetChild("n10")
    name.text = data.roleName
    --战力
    local meili = obj:GetChild("n9") 
    meili.text = GTransFormNum1(data.power)
    --击杀次数
    local label = obj:GetChild("n13")
    label.text = data.killCount

    local btnDelete = obj:GetChild("n17")
    btnDelete.data = data.roleId
    btnDelete:GetChild("title").text = language.friend12
    btnDelete.onClick:Add(self.onBtnDelete,self)

    local btnCaozuo = obj:GetChild("n18")
    btnCaozuo.data = data
    btnCaozuo:GetChild("title").text = language.friend20
    btnCaozuo.onClick:Add(self.onBtnCaoZuo,self)
end

function ListChouRen:onHeadCall()
    self:HeadCall(data)
end

function ListChouRen:setData(data,cur)
    -- body
    self.data = data
    --self.view.numItems = 0
    self.view.numItems = #self.data.enemyList
    --self.view:RefreshVirtualList()
    self.view.scrollPane:ScrollTop()
end

function ListChouRen:add5070204(data)
    -- body
    for i , j in pairs(self.data.enemyList) do 
        if data.roleId == j.roleId then 
            --plog("移除成功")
            table.remove(self.data.enemyList,i)
            self.view.numItems = #self.data.enemyList
            break
        end
    end

end

function ListChouRen:onBtnDelete(context)
    -- body
    local roleId = context.sender.data

    proxy.FriendProxy:send(1070204,{roleId = roleId,reqType = 2})
end


function ListChouRen:onBtnCaoZuo(context)
    -- body
    local data = context.sender.data
    self:HeadCall(data)
    
end

function ListChouRen:HeadCall(data)
    -- body
    local param = {}
    param.level = data.level
    param.roleIcon = data.roleIcon
    param.roleName = data.roleName
    param.roleId = data.roleId
    param.trade = true
    param.chouren = true
    --param.pos = {x=0,y=0}--位置偏移
    mgr.ViewMgr:openView(ViewName.FriendTips, function( view )
        -- body
        view:setData(param)
    end)
end
return ListChouRen