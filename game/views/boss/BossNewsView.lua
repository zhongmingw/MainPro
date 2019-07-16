--
-- Author: 
-- Date: 2018-04-02 16:15:17
--
--世界BOSS、仙域禁地等BOSS场景被击杀提示
local BossNewsView = class("BossNewsView", base.BaseView)

function BossNewsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function BossNewsView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self:setCloseBtn(self.view:GetChild("n2"))
    self.listView = self.view:GetChild("n3")
    self.listView.numItems = 0
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.view:GetChild("n4").text = language.fuben218
    self.view:GetChild("n5").text = language.fuben219
end

function BossNewsView:initData()
    proxy.FubenProxy:send(1330702,{page = 1})
end

function BossNewsView:setData(data)
    local page = data.page
    if self.mData and page and page > 1 then
        if data and self.mData.page < page and data.killList then
            self.mData.page = page
            self.mData.pageSum = data.pageSum
            for _,v in pairs(data.killList) do
                table.insert(self.mData.killList, v)
            end
        end
    else
        self.mData = {}
        self.mData.page = data.page
        self.mData.pageSum = data.pageSum
        self.mData.killList = data.killList
    end

    local numItems = #self.mData.killList
    self.listView.numItems = numItems
    if page == 1 and numItems > 0 then
        self.listView:ScrollToView(0,false,true)
    end
end
--[[
1   
int32
变量名：page    说明：页数1:开始
2   
int32
变量名：pageSum 说明：总页数
3   
array<KillRecordInfo>
变量名：killList    说明：击杀记录列表
]]
function BossNewsView:cellData(index,obj)
    if index + 1 >= self.listView.numItems then
        if not self.mData.killList then
            return
        end
        if self.mData.page < self.mData.pageSum then 
           proxy.FubenProxy:send(1330702,{page = self.mData.page + 1})
        end
    end
    local data = self.mData.killList[index + 1]
    obj:GetChild("n0").text = data.roleName
    local timeTab = os.date("*t",data.lastKillTime)
    obj:GetChild("n1").text = string.format("%02d:%02d:%02d", timeTab.hour,timeTab.min,timeTab.sec)
end

return BossNewsView