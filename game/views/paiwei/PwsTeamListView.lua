--
-- Author: Your Name
-- Date: 2018-01-13 11:58:33
--

local PwsTeamListView = class("PwsTeamListView", base.BaseView)

function PwsTeamListView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function PwsTeamListView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.checkBtn = self.view:GetChild("n9")
    self.checkBtn.selected = false
    self.checkBtn.onChanged:Add(self.onClickCheck,self)
    self.listView = self.view:GetChild("n6")
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
    local createBtn = self.view:GetChild("n8")
    createBtn.onClick:Add(self.onClickCreate,self)
end

function PwsTeamListView:onClickCheck()
    if self.checkBtn.selected then
        self.reqType = 1
    else
        self.reqType = 0
    end
    self.teamList = {}
    self.page = 0
    proxy.QualifierProxy:sendMsg(1480202,{page = 1,reqType = self.reqType})
end

function PwsTeamListView:cellData(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.teamList then
            return 
        end 
        if self.maxPage == self.page then 
            -- return
        elseif self.page and self.page < self.maxPage then
            local param = {page=self.page+1,reqType = self.reqType}
            proxy.QualifierProxy:sendMsg(1480202,param)
        end
    end
    local data = self.teamList[index+1]
    if data then
        local numTxt = obj:GetChild("n3")
        local teamName = obj:GetChild("n4")
        local captainName = obj:GetChild("n5")
        local pwLev = obj:GetChild("n6")
        local c1 = obj:GetController("c1")
        local applyBtn = obj:GetChild("n2")
        local memberNum = obj:GetChild("n7")
        numTxt.text = index + 1
        teamName.text = data.teamName
        captainName.text = data.captainName
        local pwData = conf.QualifierConf:getPwTeamDataByLv(data.pwLev)
        pwLev.text = pwData.name .. pwData.stars .. language.gonggong118
        memberNum.text = data.memberCount .. "/" .. 3
        c1.selectedIndex = data.apply
        applyBtn.data = data
        applyBtn.onClick:Add(self.onClickApply,self)
    end
end

function PwsTeamListView:onClickApply(context)
    local data = context.sender.data
    local param = {roleId = 0,reqType = 7,teamId = data.teamId}
    print("申请战队",data.teamId)
    local canjoin = cache.PwsCache:getCanJoin()
    if canjoin == 1 then
        proxy.QualifierProxy:sendMsg(1480204,param)
    else
        GComAlter(language.qualifier27_2)
    --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
    --     GComAlter(string.format(language.qualifier27,promote))
    end
end

function PwsTeamListView:initData(data)
    self.teamList = {}
    self.page = 0
    self.checkBtn.selected = false
end

-- 变量名：page    说明：页数 从1开始
-- 变量名：pageSum 说明：总页数
-- 变量名：teams   说明：战队列表
function PwsTeamListView:setData(data)
    printt("战队列表",data)
    self.data = data
    self.maxPage = data.pageSum
    if data.page > self.page then
        self.page = data.page
        for k,v in pairs(data.teams) do
            table.insert(self.teamList,v)
        end
    end
    self.listView.numItems = #self.teamList
end

--申请后刷新列表
function PwsTeamListView:refreshList()
    self.listView.numItems = 0
    self.teamList = {}
    self.page = 0
    proxy.QualifierProxy:sendMsg(1480202,{page = 1,reqType = self.reqType})
end

--创建战队
function PwsTeamListView:onClickCreate()
    local canJoin = cache.PwsCache:getCanJoin()
    if canJoin == 1 then
        mgr.ViewMgr:openView2(ViewName.SetUpTeam,{})
    else
        GComAlter(language.qualifier27_2)
    --     local promote = conf.QualifierConf:getValue("one_promote_zd_count")
    --     GComAlter(string.format(language.qualifier27,promote))
    end
end

function PwsTeamListView:doClearView(clear)
    self.teamList = {}
    self.page = 0
    self.reqType = 0
end

return PwsTeamListView