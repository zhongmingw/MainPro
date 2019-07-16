--
-- Author: EVE 
-- Date: 2018-01-24 16:27:32
-- 小年饺子

local ActiveJZ = class("ActiveJZ",import("game.base.Ref"))

function ActiveJZ:ctor(mparent)
    self.mparent = mparent
    self:initPanel()
end

function ActiveJZ:initPanel()
    local panelObj = self.mparent:getPanelObj(1068)
    
    --饺子的材料配置
    self.confData = conf.ActivityConf:getHolidayGlobal("dumplings_material")

    --活动时间
    local timeText = panelObj:GetChild("n3") 
    local actDuration = conf.ActivityWarConf:getSnowGlobal("act_duration")
    timeText.text = self:getTime(actDuration[1]).."—"..self:getTime(actDuration[2])

    --活动描述
    local decTxt = panelObj:GetChild("n4")
    decTxt.text = language.lunaryear03

    --做饺子
    local goZhuZhouBtn = panelObj:GetChild("n13")
    goZhuZhouBtn.onClick:Add(self.goDumplingsView,self)
   
    --材料列表
    self.listView = panelObj:GetChild("n23")
end
-- function ActiveJZ:initPro()
--     for i=1,#self.confData do
--         local awardData = self.confData[i]
--         self.proNameList[i].text = conf.ItemConf:getName(awardData[1])
--         self.proAmountList[i].text = cache.PackCache:getPackDataById(awardData[1]).amount
--     end
-- end
function ActiveJZ:initData()
    self:initList()
end

function ActiveJZ:getTime(time)
    local timeTab = os.date("*t",time)
    return string.format(language.ydact013, timeTab.year,timeTab.month,timeTab.day,tonumber(timeTab.hour),tonumber(timeTab.min))
end

function ActiveJZ:initList()
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.numItems = #self.confData
end

function ActiveJZ:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        --名称
        local materialName = obj:GetChild("n0")
        materialName.text = conf.ItemConf:getName(data[1])
        --数量
        local amount = obj:GetChild("n1")
        amount.text = cache.PackCache:getPackDataById(data[1]).amount
    end
end

--做饺子
function ActiveJZ:goDumplingsView()
    local isEnough = false
    for k,v in pairs(self.confData) do
        local amount = cache.PackCache:getPackDataById(v[1]).amount
        if amount < v[2] then 
            GComAlter(language.lunaryear01)
            return
        else
            isEnough = true
        end
    end

    if isEnough then 
        local sId = cache.PlayerCache:getSId()
        if sId ~= 201001 then  --神都
            if not mgr.FubenMgr:checkScene() then --检测是否战斗场景
                local point = GGetMajorPoint()
                cache.ActivityCache:setLunarYearFly(true)
                proxy.ThingProxy:send(1020101, {sceneId=201001, pox=point[1], poy=point[2], type=5})
            else
                GComAlter(language.gonggong41)
            end
        else
            mgr.ViewMgr:openView2(ViewName.DumplingsView)
            local view = mgr.ViewMgr:get(ViewName.LunarYearMainView)
            if view then 
                view:onBtnClose()
            end
        end
        -- mgr.ViewMgr:openView2(ViewName.DumplingsView)
    end
end

return ActiveJZ