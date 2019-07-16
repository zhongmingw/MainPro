--
-- Author: 
-- Date: 2017-01-14 10:31:22
--

local ListHeiMingDan = class("ListHeiMingDan", import("game.base.Ref"))

function ListHeiMingDan:ctor(param)
    self.view = param
    self:initView()
end

function ListHeiMingDan:initView()
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0

    --self.view.onClickItem:Add(self.onItemCallBack,self)
end

function ListHeiMingDan:celldata( index,obj )
    -- body
    if index >= self.view.numItems then
        if self.data.totalSum == self.data.page then 
        else
            proxy.FriendProxy:send(1070201,{page = self.data.page + 1})
        end
    end
    --头像
    local data = self.data.blackNameList[index+1]
    local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }
    GBtnGongGongSuCai_050(obj:GetChild("n15"),t)
    obj:GetChild("n15").data = t
    obj:GetChild("n15").onClick:Add(self.onHeadCall, self)
   
    --名字
    local name = obj:GetChild("n10")
    name.text = data.roleName
    --魅力
    local meili = obj:GetChild("n9") 
    meili.text = GTransFormNum1(data.power)
    -- local confData = conf.FriendConf:getDataById(data.charmStepId) 
    -- meili.text =confData and confData.name or ""
    --
    local label = obj:GetChild("n13")
    label.text = ""

    local btnDelete = obj:GetChild("n17")
    btnDelete.data = data.roleId
    btnDelete:GetChild("title").text = language.friend12
    btnDelete.onClick:Add(self.onBtnDelete,self)

    local btnCaozuo = obj:GetChild("n18")
    btnCaozuo.data = data
    btnCaozuo:GetChild("title").text = language.friend20
    btnCaozuo.onClick:Add(self.onBtnCaoZuo,self)
end

function ListHeiMingDan:onHeadCall(context)
    local data = context.sender.data
    self:HeadCall(data)
end

function ListHeiMingDan:setData(data,cur)
    -- body
    self.data = data
    --self.view.numItems = 0
    self.view.numItems = #self.data.blackNameList
    self.view:RefreshVirtualList()
    self.view.scrollPane:ScrollTop()
end

function ListHeiMingDan:add5070202(data)
    -- body
    for i , j in pairs(self.data.blackNameList) do 
        if data.roleId == j.roleId then 
            table.remove(self.data.blackNameList,i)

            self.view.numItems = #self.data.blackNameList
            break
        end
    end

end

function ListHeiMingDan:onBtnDelete(context)
    -- body
    local roleId = context.sender.data

    proxy.FriendProxy:send(1070202,{roleId = roleId,reqType = 2})
end


function ListHeiMingDan:onBtnCaoZuo(context)
    -- body
    local data = context.sender.data
    self:HeadCall(data)
end

function ListHeiMingDan:HeadCall( data )
    -- body
    local param = {}
    param.level = data.level
    param.roleIcon = data.roleIcon
    param.roleName = data.roleName
    param.roleId = data.roleId
    param.heiming = true
    param.trade = true
    --param.pos = {x=0,y=0}--位置偏移
    mgr.ViewMgr:openView(ViewName.FriendTips, function( view )
        -- body
        view:setData(param)
    end)
end

return ListHeiMingDan