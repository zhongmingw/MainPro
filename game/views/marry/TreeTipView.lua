--
-- Author: 
-- Date: 2017-08-14 14:15:48
--
--姻缘树
local TreeTipView = class("TreeTipView", base.BaseView)

function TreeTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function TreeTipView:initView()
    self:setCloseBtn(self.view:GetChild("n18"))
    self.view:GetChild("n3").text = language.marryiage01
    self.view:GetChild("n4").text = language.marryiage02 
    self.view:GetChild("n5").text = language.marryiage03
    self.view:GetChild("n6").text = language.marryiage04
    self.view:GetChild("n7").text = language.marryiage05
    self.view:GetChild("n8").text = language.marryiage06
    self.view:GetChild("n9").text = language.marryiage07
    self.view:GetChild("n10").text = language.marryiage08

    self.plant = self.view:GetChild("n11")--栽种者
    self.plantSpouse = self.view:GetChild("n12")--配偶
    self.watering = self.view:GetChild("n13")--浇水
    self.insecticidal = self.view:GetChild("n14")--除虫
    self.ripper = self.view:GetChild("n15")--松土
    self.stateText = self.view:GetChild("n16")--状态

    self.awardList = self.view:GetChild("n17")
    self.awardList:SetVirtual()
    self.awardList.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end
    self.awardList.numItems = 0
end
-- 1:浇水 2:除虫 3:松土 4:收货
function TreeTipView:initData(data)
    local coupleName = cache.PlayerCache:getCoupleName()
    local myName = cache.PlayerCache:getRoleName()
    if data.attachName == myName then
        self.plant.text = myName
        self.plantSpouse.text = coupleName
    else
        self.plant.text = coupleName
        self.plantSpouse.text = myName
    end
    local optTimesMap = data.optTimesMap
    if optTimesMap then
        local water = 1
        local insect = 2
        local ripper = 3
        local confData = conf.MarryConf:getValue("marry_tree_step_time")
        local str = optTimesMap[water] or 0
        self.watering.text = str.."/"..confData[water][3]
        local str = optTimesMap[insect] or 0
        self.insecticidal.text = str.."/"..confData[insect][3]
        local str = optTimesMap[ripper] or 0
        self.ripper.text = str.."/"..confData[ripper][3]
    end
    local confData = conf.MarryConf:getMarryTreeStatus(data.treeStatus)
    self.stateText.text = confData and confData.status_name or "没有状态"
    local treeObj = mgr.ThingMgr:getObj(ThingType.monster,data.treeRoleId)
    self.createTime = 0--树的创建时间
    if treeObj then
        self.createTime = treeObj.data.ext02
    end
    self.awards = confData and confData.awards or {}
    self.awardList.numItems = #self.awards
end

function TreeTipView:cellAwardsData(index,itemObj)
    local data = self.awards[index + 1]
    local openTimes = conf.MarryConf:getValue("marry_tree_double_time")
    local timeTab = os.date("*t",self.createTime)
    local s = 0
    s = s + tonumber(timeTab.hour) * 3600
    s = s + tonumber(timeTab.min) * 60
    s = s + tonumber(timeTab.sec)
    local amount = data[2] or 1
    -- if tonumber(s) <= openTimes[2] and tonumber(s) >= openTimes[1] then
    --     amount = amount * 2
    -- end
    local itemData = {mid = data[1], amount = amount, bind = data[3]}
    GSetItemData(itemObj, itemData, true)
end

return TreeTipView