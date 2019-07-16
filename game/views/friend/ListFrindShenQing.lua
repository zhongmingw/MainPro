--
-- Author: 王显
-- Date: 2017-01-13 17:30:08
--申请列表

local ListFrindShenQing = class("ListFrindShenQing", import("game.base.Ref"))

function ListFrindShenQing:ctor(param)
    self.view = param
    self:initView()
end

function ListFrindShenQing:initView( ... )
    -- body
    self.view:SetVirtual()
    self.view.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.view.numItems = 0
end

function ListFrindShenQing:celldata( index,obj )
    local data = self.data.applyList[index+1]
     --头像
    local t = { level = data.level , roleIcon = data.roleIcon,roleId = data.roleId }
    GBtnGongGongSuCai_050(obj:GetChild("n12"),t)

    --名字
    local name = obj:GetChild("n10")
    name.text = data.name 

    --魅力
    local meili = obj:GetChild("n9") 
    meili.text = GTransFormNum1(data.power)
    -- --plog("data.charmStepId",data.charmStepId)
    -- local confData = conf.FriendConf:getDataById(data.charmStepId)
    -- meili.text = confData and confData.name or ""

    local btnArgee = obj:GetChild("n21")
    btnArgee:GetChild("title").text = language.friend10
    btnArgee.onClick:Add(self.onbtnArgee,self)
    btnArgee.data = data.roleId

    local btnIngore = obj:GetChild("n16")
    btnIngore:GetChild("title").text = language.friend11
    btnIngore.onClick:Add(self.onbtnIngore,self)
    btnIngore.data = data.roleId

    local c1 = obj:GetController("c1")
    c1.selectedIndex = data.applyStatu

end

function ListFrindShenQing:setData(data)
    -- body
    self.data = data
    --self.view.numItems = 0
    self.view.numItems = #self.data.applyList
    self.view:RefreshVirtualList()
    self.view.scrollPane:ScrollTop()
end
--同意 或者 忽略返回
function ListFrindShenQing:add5070105(data)
    -- body
    --plog("add5070105")
    --printt(data.roleIds)

    local var ={}
    for k , v in pairs(data.roleIds) do 
        for i , j in pairs(self.data.applyList) do 
            if v == j.roleId then 
                --plog("remove",i)
                self.data.applyList[i].applyStatu = 1

                --table.insert(var,i)
                break     
            end
        end
    end

    for k ,v in pairs(self.data.applyList) do
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
        table.remove(self.data.applyList,v)
    end

    self.view.numItems = #self.data.applyList
end
--同意
function ListFrindShenQing:onbtnArgee(context)
    -- body
    --plog("self.data.errStatu",self.data.errStatu)
    

    local roleId = context.sender.data
    local param = {reqType = 1,roleIds = {}}
    table.insert(param.roleIds,roleId)
    --plog("#param",#param.roleIds,roleId)

    proxy.FriendProxy:send(1070105,param)
end
--拒绝
function ListFrindShenQing:onbtnIngore( context )
    -- body
     local roleId = context.sender.data
    local param = {reqType = 2,roleIds = {}}
    table.insert(param.roleIds,roleId)
    proxy.FriendProxy:send(1070105,param)
end

return ListFrindShenQing