--
-- Author: 
-- Date: 2017-12-05 17:24:35
--
--结算排行日志
local RecordJsRankView = class("RecordJsRankView", base.BaseView)

function RecordJsRankView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
end

function RecordJsRankView:initView()
    self.title = self.view:GetChild("n1")
    self.view:GetChild("n2").text = language.xmhd34[1]
    self.view:GetChild("n3").text = language.xmhd34[2]
    self.view:GetChild("n4").text = language.xmhd34[3]
    self.view:GetChild("n5").text = language.xmhd34[4]
    self.view:GetChild("n6").text = language.xmhd34[5]
    self.view:GetChild("n7").text = language.xmhd34[6]
    self.listView = self.view:GetChild("n8")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self.myItem = self.view:GetChild("n12")
    local quitBtn = self.view:GetChild("n9")
    quitBtn.onClick:Add(self.onClickQuit,self)
    self.timeText = self.view:GetChild("n10")
end

function RecordJsRankView:initData(data)
    self.mData = data
    mgr.GuiMgr:redpointByVar(attConst.A20133,0)--清理红点
    local view = mgr.ViewMgr:get(ViewName.BangPaiMain)
    if view then
        view:refreshActivity()
    end
    local ourGangId = cache.PlayerCache:getGangId()--我的仙盟
    local url = ""
    if tostring(ourGangId) == tostring(data.winGangId) then
        url = UIItemRes.xmhd06[1]
    else
        url = UIItemRes.xmhd06[2]
    end
    self.title.url = url
    -- proxy.XmhdProxy:send(1360206,{page = 1})

    for k,v in pairs(self.mData.logs) do
        if v.playerName == cache.PlayerCache:getRoleName() then
            self.mRoleData = v
            break
        end
    end
    self:setMyItem()
    local numItems = #self.mData.logs
    self.listView.numItems = numItems
    if page == 1 and numItems > 0 then
        self.listView:ScrollToView(0,false,true)
    end
    self.time = 9
    self:onTimer()
    self:addTimer(1, -1, handler(self, self.onTimer))
end

function RecordJsRankView:setData(data)
    
end
--[[
1   
string
变量名：playerName  说明：玩家名
2   
int32
变量名：rank    说明：排名
3   
int32
变量名：occupyNum   说明：占领水晶数
4   
int32
变量名：killNum 说明：杀人数
5   
int32
变量名：beKillNum   说明：被杀数
6   
string
变量名：gangName    说明：仙盟名
]]
function RecordJsRankView:cellData(index, obj)
    -- if index + 1 >= self.listView.numItems then
    --     if not self.mData.logs then return end
    --     if self.mData.page < self.mData.totalSum then
    --        proxy.TeamProxy:send(1360206,{page = self.mData.page + 1})
    --     end
    -- end
    local data = self.mData.logs[index + 1]
    local rank = data.rank
    local frameUrl = obj:GetChild("n0")
    local rankIcon = obj:GetChild("n1")
    rankIcon.visible = false
    local rankText = obj:GetChild("n2")
    rankText.visible = false
    if rank <= 3 then
        rankIcon.visible = true
        rankIcon.url = UIItemRes.xmhd07[rank]
        frameUrl.url = UIItemRes.xmhd08[rank]
    else
        rankText.visible = true
        rankText.text = rank
        frameUrl.url = UIItemRes.xmhd08[3]
    end
    obj:GetChild("n3").text = data.playerName
    obj:GetChild("n4").text = data.score
    obj:GetChild("n5").text = data.killNum
    obj:GetChild("n6").text = data.beKillNum
    obj:GetChild("n7").text = data.occupyNum
end
--设置自己的信息
function RecordJsRankView:setMyItem()
    local data = self.mRoleData
    local rank = data.rank
    self.myItem:GetChild("n0").url = UIItemRes.xmhd08[0]
    local rankIcon = self.myItem:GetChild("n1")
    rankIcon.visible = false
    local rankText = self.myItem:GetChild("n2")
    rankText.visible = false
    if rank <= 3 then
        rankIcon.visible = true
        rankIcon.url = UIItemRes.xmhd07[rank]
    else
        rankText.visible = true
        rankText.text = rank
    end
    self.myItem:GetChild("n3").text = data.playerName
    self.myItem:GetChild("n4").text = data.score
    self.myItem:GetChild("n5").text = data.killNum
    self.myItem:GetChild("n6").text = data.beKillNum
    self.myItem:GetChild("n7").text = data.occupyNum
end

function RecordJsRankView:onTimer()
    self.timeText.text = mgr.TextMgr:getTextColorStr(string.format(language.fuben11, self.time), 4)
    if self.time <= 0 then
        self:onClickQuit()
        return
    end
    self.time = self.time - 1
end

function RecordJsRankView:onClickQuit()
    if mgr.FubenMgr:isGangWar(cache.PlayerCache:getSId()) then
        mgr.FubenMgr:quitFuben()
    end
    self:closeView()
end

return RecordJsRankView