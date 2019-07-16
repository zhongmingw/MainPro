--
-- Author: 
-- Date: 2018-08-13 11:27:35
--

local ScratchRecordView = class("ScratchRecordView", base.BaseView)

local CardIcon = {
    [0] = "guaguale_012",--卡背
    [1] = "guaguale_001",--天
    [2] = "guaguale_002",--地
    [3] = "guaguale_003",--地
}
function ScratchRecordView:ctor()
    ScratchRecordView.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function ScratchRecordView:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n3")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:cellData(index, obj)
    end
end

function ScratchRecordView:initData(data)
    self.data = data
    local size = conf.ScratchConf:getValue("personal_record_size")
    self.listView.numItems = #self.data
end

function ScratchRecordView:cellData(index,obj)
    local data = self.data[index+1]
    local icon1 = obj:GetChild("n5")
    local icon2 = obj:GetChild("n6")
    local icon3 = obj:GetChild("n7")
    local title = obj:GetChild("n1")
    if data then
        local strTab = string.split(data,"|")
        
        local strTab2 = string.split(strTab[1],",")

        icon1.url = UIPackage.GetItemURL("scratch",CardIcon[tonumber(strTab2[1])])
        icon2.url = UIPackage.GetItemURL("scratch",CardIcon[tonumber(strTab2[2])])
        icon3.url = UIPackage.GetItemURL("scratch",CardIcon[tonumber(strTab2[3])])
        local strTab2 = string.split(strTab[2],",")
        local mid = strTab2[1]
        local amount = strTab2[2]
        local color = conf.ItemConf:getQuality(mid)
        local proName = conf.ItemConf:getName(mid)
        local awardsStr = mgr.TextMgr:getQualityStr1(proName, color)
        title.text = awardsStr.."X"..amount
    end
end

function ScratchRecordView:setData(data)

end

return ScratchRecordView