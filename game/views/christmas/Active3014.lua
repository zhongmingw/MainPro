--
-- Author: Your Name
-- Date: 2017-12-18 21:37:00
--圣诞活动圣诞树
local Active3014 = class("Active3014",import("game.base.Ref"))

function Active3014:ctor(param)
    self.view = param
    self:initView()
end

function Active3014:initView()
    -- body
    self.actTimeTxt = self.view:GetChild("n3")
    self.countTxt = self.view:GetChild("n11")
    self.treeLv = self.view:GetChild("n12")
    self.decTxt = self.view:GetChild("n4")
    self.treeImg = self.view:GetChild("n15")
end

function Active3014:onTimer()
    -- body
end

function Active3014:setCurId(id)
    -- body
    
end


function Active3014:add5030164(data)
    -- body
    -- printt("圣诞树",data)
    self.data = data
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = startTab.month .. language.gonggong79 .. startTab.day .. language.gonggong80 .. string.format("%02d",startTab.hour) .. ":" .. string.format("%02d",startTab.min)
    local endTxt = endTab.month .. language.gonggong79 .. endTab.day .. language.gonggong80 .. string.format("%02d",endTab.hour) .. ":" .. string.format("%02d",endTab.min)
    self.actTimeTxt.text = startTxt .. "-" .. endTxt
    self.countTxt.text = data.commitCount
    local treeData = conf.ActivityConf:getChristmasTreeData(data.treeLevel+1)
    if treeData then
        self.treeLv.text = treeData.need_socks or language.skill08
    else
        self.treeLv.text = language.skill08        
    end
    
    self.decTxt.text = language.active42
    local presentData = conf.ActivityConf:getChristmasTreeData(data.treeLevel)
    if presentData and presentData.tree_img then
        self.treeImg.visible = true
        self.treeImg.url = UIPackage.GetItemURL("christmas" , presentData.tree_img)
    else
        self.treeImg.visible = false
    end
    local gotoBtn = self.view:GetChild("n13")
    gotoBtn.onClick:Add(self.onClickGoTo,self)
    local socksBtn = self.view:GetChild("n14")
    socksBtn.onClick:Add(self.onClickSkip,self)
end

function Active3014:onClickGoTo()
    local sId = cache.PlayerCache:getSId()
    if sId ~= 201001 then
        if not mgr.FubenMgr:checkScene() then
            local point = GGetMajorPoint()
            proxy.ThingProxy:send(1020101, {sceneId=201001, pox=point[1], poy=point[2], type=5})
        else
            GComAlter(language.gonggong41)
        end
    else
        GComAlter(language.active46)
    end
end

function Active3014:onClickSkip()
    local view = mgr.ViewMgr:get(ViewName.ChristmasActView)
    if view then
        view:nextStep(3015)
    end
end

return Active3014