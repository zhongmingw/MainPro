--
-- Author: Your Name
-- Date: 2018-12-17 11:54:19
--

local YiJiTanSuoCity = class("YiJiTanSuoCity", base.BaseView)

function YiJiTanSuoCity:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function YiJiTanSuoCity:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)

    self.listView = self.view:GetChild("n1")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.listView.onClickItem:Add(self.onClickListItem,self)

    --探索日志
    local recordBtn = self.view:GetChild("n4")
    recordBtn.onClick:Add(self.onClickRecord,self)
    --规则按钮
    local guizeBtn = self.view:GetChild("n6")
    guizeBtn.onClick:Add(self.onClickGuiZe,self)
    --进入城池按钮
    local initBtn = self.view:GetChild("n5")
    initBtn.onClick:Add(self.onClickInIt,self)
    --城池探索次数
    self.exploreTxt = self.view:GetChild("n3")
end

function YiJiTanSuoCity:initData(data)
    self.cityId = nil
    self.cityData = data
    self.listView.numItems = #self.cityData
    for i=1,#self.cityData do
        self.listView:RemoveSelection(i-1)
    end
    proxy.YiJiTanSuoProxy:sendMsg(1640101)
end

function YiJiTanSuoCity:setData(data)
    local find_times = conf.YiJiTanSuoConf:getYiJiGlobal("find_times")
    local exploreCount = data.buyCount + find_times - data.exploreCount
    self.exploreTxt.text = string.format(language.yjts01,exploreCount,(data.buyCount+find_times))
end

function YiJiTanSuoCity:celldata(index,obj)
    local data = self.cityData[index+1]
    if data then
        obj.data = data
        local nameTxt = obj:GetChild("n1")
        nameTxt.text = data.name
        local cityImg = obj:GetChild("n2")
        cityImg.url = UIPackage.GetItemURL("yiji" , data.city_img)
        local crossImg = obj:GetChild("n6")
        if data.cross_type and data.cross_type == 2 then
            crossImg.visible = true
        else
            crossImg.visible = false
        end
        local awardsList = obj:GetChild("n4")
        awardsList.numItems = 0
        awardsList.itemRenderer = function(i,cell)
            local info = data.city_awards_show[i+1]
            if info then
                local mid = info[1]
                local amount = info[2]
                local bind = info[3]
                GSetItemData(cell,{mid = mid,amount = amount,bind = bind},true)
            end
        end
        awardsList.numItems = #data.city_awards_show
    end
end

function YiJiTanSuoCity:onClickListItem(context)
    local btn = context.data
    local data = btn.data
    if not data then
        return
    end
    self.cityId = data.id
end

--请求探索日志
function YiJiTanSuoCity:onClickRecord()
    local logs = cache.YiJiTanSuoCache:getTanSuoLogs()
    printt("探索日志>>>>>>>>>>",logs)
    mgr.ViewMgr:openView2(ViewName.YiJiTanSuoLogView, {})
end

--规则
function YiJiTanSuoCity:onClickGuiZe()
    GOpenRuleView(1166)
end

--进入城池按钮
function YiJiTanSuoCity:onClickInIt()
    if self.cityId then
        cache.YiJiTanSuoCache:setCityId(self.cityId)
        mgr.ViewMgr:openView2(ViewName.YiJiCityInfoView, {cityId = self.cityId})
    else
        GComAlter(language.yjts02)
    end
end

return YiJiTanSuoCity