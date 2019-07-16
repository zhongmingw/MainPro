--排行榜
local RankMainView = class("RankMainView", base.BaseView)
local RankRoleInfoPanel = import(".RankRoleInfoPanel") --总榜
local RankInfoPanel = import(".RankInfoPanel")         --单榜

function RankMainView:ctor()
    self.super.ctor(self)
    self.firstIn = true --首次进入排行榜
end

function RankMainView:initData(data)
    -- body
    local window2 = self.view:GetChild("n0")
    GSetMoneyPanel(window2,self:viewName())
    local closeBtn = window2:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)
    --标题列表
    self.listView = self.view:GetChild("n4")
    local btnBottom = self.view:GetChild("n15")
    btnBottom.onClick:Add(self.onClickTurnBottom,self)
    local btnTop = self.view:GetChild("n16")
    btnTop.onClick:Add(self.onClickTurnTop,self)
    --总榜panel
    self.totalPanel = self.view:GetChild("n2")
    --单榜panel
    self.singlePanel = self.view:GetChild("n3")

    self.controllerC1 = self.view:GetController("c1")
    self.controllerC1.onChanged:Add(self.onController1,self)
    self:initListView()
    self.index = 0
    self.listView.numItems = 0
    self.controllerC1.selectedIndex = 0
    self:sendTotalRankMsg()
end

-- function RankMainView:GoToPage(page)
--     self.controllerC1.selectedIndex = page or 0
-- end

--获取玩家点赞信息
function RankMainView:setDzInfo( data )
    self.myDzList = data
end

--List上下两个按钮
function RankMainView:onClickTurnBottom( context )
    -- body
    if self.index < 5 then
        self.index = self.index+1
    else
        self.index = 5
    end
    self.listView:ScrollToView(self.index,true)
end
function RankMainView:onClickTurnTop( context )
    -- body
    self.index = self.index > 5 and 5 or self.index
    if self.index > 0 then
        self.index = self.index-1
    end
    self.listView:ScrollToView(self.index,true)
end

--请求排行榜总榜
function RankMainView:sendTotalRankMsg()
    -- body
    proxy.RankProxy:sendRankMsg(1280104)
end
--刷新总榜
function RankMainView:refreshTotalRank()
    self.RankRoleInfoPanel:setData(self.tops,self.svrIds,self.myDzList)
end

function RankMainView:setData( data )
    -- body
    self.tops = data.tops
    self.svrIds = data.svrIds
    self.listView.numItems = 19
    -- print("排行榜总榜信息")
    -- printt(self.tops)
    if self.firstIn then
        self.controllerC1.selectedIndex = 0
        self.totalPanel.visible = true
        self.singlePanel.visible =false
        self.firstIn = false
        local obj = self.listView:GetChildAt(0)
        obj.selected = true
        if not self.RankRoleInfoPanel then
            self.RankRoleInfoPanel = RankRoleInfoPanel.new(self)
        end
        -- self.RankRoleInfoPanel:setData(self.tops,self.svrIds,,self.myDzList)
    end
end

function RankMainView:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function RankMainView:celldata(index, obj)
    -- body
    local titleTxt = obj:GetChild("title")
    local dataConf = conf.RankConf:getRankNameById(index)
    titleTxt.text = dataConf.name
    obj.data = dataConf.sort
    obj.onClick:Add(self.onClickSelect,self)
end

function RankMainView:onClickSelect( context )
    -- body
    if self.RankInfoPanel then      --EVE 切换页签时，清理排行榜模型的缓存
        self.RankInfoPanel:clear()
    end

    local cell = context.sender
    local index = cell.data
    self.index = index
    if index == 0 then
        self.controllerC1.selectedIndex = 0
        if not self.RankRoleInfoPanel then
            self.RankRoleInfoPanel = RankRoleInfoPanel.new(self)
        end
        self.RankRoleInfoPanel:setData(self.tops,self.svrIds,self.myDzList)
    else
        self.controllerC1.selectedIndex = 1
        if not self.RankInfoPanel then
            self.RankInfoPanel = RankInfoPanel.new(self)
        end
        self.RankInfoPanel:setData(self.svrIds,self.tops[index],index,self.myDzList)
        local param = {rankType = index,svrId = 0,page=1}
        proxy.RankProxy:sendRankMsg(1280102,param)
    end
end

--控制器
function RankMainView:onController1()
    -- body
    if 0 == self.controllerC1.selectedIndex then  --总榜信息
        self.totalPanel.visible = true
        self.singlePanel.visible =false 
    elseif 1 == self.controllerC1.selectedIndex then --单榜信息
        self.singlePanel.visible =true
        self.totalPanel.visible = false
    end
end

function RankMainView:onClickClose()
    -- body
    -- self:dispose()
    self:closeView()
end

function RankMainView:dispose(clear)
    if self.RankInfoPanel then
        self.RankInfoPanel:clear()
    end
    self.super.dispose(self,clear)
    self.firstIn = true
end

return RankMainView