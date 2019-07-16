--
-- Author: 
-- Date: 2018-01-11 10:24:44
--

local ActiveLbz = class("ActiveLbz",import("game.base.Ref"))

function ActiveLbz:ctor(mparent)
    self.mparent = mparent
    self:initPanel()
end

function ActiveLbz:initPanel()
    local panelObj = self.mparent:getPanelObj(1182)
    
    self.timeText = panelObj:GetChild("n3")
    self.zhouImg = panelObj:GetChild("n15")
    local goZhuZhouBtn = panelObj:GetChild("n13")
    goZhuZhouBtn.onClick:Add(self.goZhuZhou,self)
    local decTxt = panelObj:GetChild("n4")
    decTxt.text = language.labazhou01
    self.listView = panelObj:GetChild("n23")
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end
    self.listView.numItems = 0
    self.listView:SetVirtual()

end
function ActiveLbz:initPro()
    for i=1,#self.confData do
        local awardData = self.confData[i]
        self.proNameList[i].text = conf.ItemConf:getName(awardData[1])
        self.proAmountList[i].text = cache.PackCache:getPackDataById(awardData[1]).amount
    end
end


function ActiveLbz:cellData(index,obj)
    local data = self.confData[index+1]
    if data then 
        local materialName = obj:GetChild("n0")
        materialName.text = conf.ItemConf:getName(data[1])
        local amount = obj:GetChild("n1")
        amount.text = cache.PackCache:getPackDataById(data[1]).amount
    end
end
function ActiveLbz:goZhuZhou()
    local isEnough = false
    for k,v in pairs(self.confData) do
        local amount = cache.PackCache:getPackDataById(v[1]).amount
        if amount < v[2] then 
            GComAlter(language.labazhou05)
            return
        else
            isEnough = true
        end
    end
    if isEnough then 
        local sId = cache.PlayerCache:getSId()
        if sId ~= 201001 then  --神都
            if not mgr.FubenMgr:checkScene() then
                local point = GGetMajorPoint()
                cache.ActivityCache:setLabaFly(true)
                proxy.ThingProxy:send(1020101, {sceneId=201001, pox=point[1], poy=point[2], type=5})
            else
                GComAlter(language.gonggong41)
            end
        else
            -- GComAlter(language.labazhou03)
            mgr.ViewMgr:openView2(ViewName.LabaZhouView)
            local view = mgr.ViewMgr:get(ViewName.LabaMainView)
            if view then 
                view:onBtnClose()
            end
        end
        -- mgr.ViewMgr:openView2(ViewName.LabaZhouView)
    end
end

function ActiveLbz:setData(data)
    self.data = data

    self.timeText.text = GToTimeString8(data.actStartTime).."—"..GToTimeString8(data.actEndTime)

    self.confData = conf.ActivityConf:getHolidayGlobal("laba_porridge_material")

    self.listView.numItems = #self.confData
end

return ActiveLbz