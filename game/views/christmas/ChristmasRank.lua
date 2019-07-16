--
-- Author: Your Name
-- Date: 2017-12-19 17:39:02
--

local ChristmasRank = class("ChristmasRank", base.BaseView)

function ChristmasRank:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
end

function ChristmasRank:initView()
    local closeBtn = self.view:GetChild("n2"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.listView = self.view:GetChild("n7")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.titleIcon = self.view:GetChild("n16")
end

function ChristmasRank:celldata( index,obj )
    local data = self.data[index+1]
    local rankTxt = obj:GetChild("n1")
    local nameTxt = obj:GetChild("n2")
    local numTxt = obj:GetChild("n3")
    local bgIcon = obj:GetChild("n9")
    local numIcon = obj:GetChild("n10")
    numIcon.visible = true
    if index == 0 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_008")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_003")
    elseif index == 1 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_009")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_004")
    elseif index == 2 then
        bgIcon.url = UIPackage.GetItemURL("_panels" , "meili_010")
        numIcon.url = UIPackage.GetItemURL("_others" , "meili_005")
    else
        bgIcon.url = UIPackage.GetItemURL("_others" , "ditu_004")
        numIcon.visible = false
    end
    if data then
        rankTxt.text = data.ranking
        nameTxt.text = data.name
        numTxt.text = data.commitCount
    else
        rankTxt.text = index + 1
        nameTxt.text = language.rank03
        numTxt.text = 0
    end
end

function ChristmasRank:initData(data)
    self.data = data
    if data.type == 1 then
        self.titleIcon.url = UIPackage.GetItemURL("christmas" , "shengdankuanghuan_011")
    elseif data.type == 2 then
        self.titleIcon.url = UIPackage.GetItemURL("christmas" , "shengdankuanghuan_012")
    end
    self.listView.numItems = #self.data > 10 and #self.data or 10
end

return ChristmasRank