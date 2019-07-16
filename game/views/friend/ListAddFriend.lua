--
-- Author: 王显
-- Date: 2017-01-13 15:43:07
--添加好友

local ListAddFriend = class("ListAddFriend", import("game.base.Ref"))

function ListAddFriend:ctor(param)
    self.view = param
    self:initView()
end

function ListAddFriend:initView()
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0
    --self.view.onClickItem:Add(self.onItemCallBack,self)
end

function ListAddFriend:celldata( index,obj )
    if not self.data then
        return
    end

    local data = self.data.list[index+1]
    --头像
    local t = { level = data.level , roleIcon = data.roleIcon, roleId = data.roleId }
    GBtnGongGongSuCai_050(obj:GetChild("n15"),t)

    --名字
    local name = obj:GetChild("n10")
    name.text = data.name 

    --魅力
    local meili = obj:GetChild("n9") 
    meili.text = GTransFormNum1(data.power)
    -- local confData = conf.FriendConf:getDataById(data.charmStepId)
    -- --plog("data.charmStepId = "..data.charmStepId)
    -- meili.text = confData and confData.name or ""--data.charmValue

    --添加
    local btnAdd = obj:GetChild("n17")
    btnAdd:GetChild("title").text = language.friend09
    btnAdd.onClick:Add(self.onBtnAdd,self)
    btnAdd.data = data.roleId
    --plog(data.applyStatu,"data.applyStatu ",data.name )
    local controllerC1 = obj:GetController("c1")
    controllerC1.selectedIndex = data.applyStatu 
end

function ListAddFriend:setData(data)
    -- body
    self.data = data
    self.todayFriendNum = data.todayFriendNum
    local itemCount = #self.data.list
    self.view.numItems = itemCount
    self.view:RefreshVirtualList()
    self.view.scrollPane:ScrollTop()
    --self.view:EnsureBoundsCorrect()
end

function ListAddFriend:add5070103(data)
    -- body
    
    if data.reqType == 1 then
        local var ={} 
        for k , v in pairs(data.roleIds) do 
            for i , j in pairs(self.data.list) do 
                if v ==  j.roleId then 
                    --plog("remove",i)
                    self.data.list[i].applyStatu = 1
                    --table.insert(var,i)
                    break
                end
            end
        end

        for k ,v in pairs(self.data.list) do
            if v.applyStatu == 1 then
                table.insert(var,k)
            end
        end

        table.sort( var,function (a,b )
            -- body
            return a>b
        end )

        for k ,v in pairs(var) do
            --plog(" true ",v)
            table.remove(self.data.list,v)
        end

        self.view.numItems = #self.data.list
    end
end

function ListAddFriend:onBtnAdd(context)
    -- body
    if not self.data then
        return
    end
    local openday = cache.PlayerCache:getRedPointById(attConst.A10325)
    local _confdata = conf.FriendConf:getDayFriendNum(openday)
    if _confdata then
        if (self.todayFriendNum or 1)>= (_confdata.limit or 1) then
            return GComAlter(language.friend51)
        end
    end

    local roleId = context.sender.data
    local param = {reqType = 1,roleIds = {}}
    table.insert(param.roleIds,roleId)
    proxy.FriendProxy:sendMsg(1070103,param)
end

return ListAddFriend