--
-- Author: 
-- Date: 2017-10-24 12:04:27
--
--利刃
local LirenTipView = class("LirenTipView", base.BaseView)

function LirenTipView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
end

function LirenTipView:initView()
    self.index = 0
    local closeBtn = self.view:GetChild("n0"):GetChild("n2")
    self:setCloseBtn(closeBtn)
    self.view:GetChild("n1").text = language.fuben162
    self.view:GetChild("n7").text = language.fuben181
    local buyBtn = self.view:GetChild("n4")
    buyBtn.onClick:Add(self.onClickBuy,self)
    local cancelBtn = self.view:GetChild("n5")
    self:setCloseBtn(cancelBtn)
    self.listView = self.view:GetChild("n6")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    local title = self.view:GetChild("n9")
    title.text = "("..language.fuben209..")"

    self.doubleAward = self.view:GetChild("n8")
    self.doubleAward.text = ""--language.fuben211
end

function LirenTipView:initData()
    self.items = conf.FubenConf:getValue("fam_atk_buy_cost")
    self.listView.numItems = #self.items
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isMjxlScene(sId) and cache.FubenCache:getMjxlDouble() then--单人秘境&双倍
        self.doubleAward.text = language.fuben211
    else
        self.doubleAward.text = ""
    end
end
--{1,5,9006101,1000}
function LirenTipView:cellData(index,obj)
    local data = self.items[index + 1]
    obj:GetChild("n1").text = language.money[BuyMoneyType[data[1]][1]]
    obj:GetChild("n2").text = data[2].."/次"
    local btn = obj:GetChild("n0")
    btn.data = index
    btn.onClick:Add(self.onChooseSelect,self)
end

function LirenTipView:setSelect(data)
    self.buyTimesMap = data.buyTimesMap
    local costData = conf.FubenConf:getValue("fam_atk_buy_cost")
    local tqCount = costData[1][5]
    local ybCount = costData[2][5]
    local obj1 = self.listView:GetChildAt(0)
    local btn1 = obj1:GetChild("n0")
    local obj2 = self.listView:GetChildAt(1)
    local btn2 = obj2:GetChild("n0")
    
    if data.buyType == 0 then--显示返回
        if self.buyTimesMap[1] then
            if self.buyTimesMap[1] < tqCount then
                self.listView:AddSelection(0,false)
                btn1.selected = true
                btn2.selected = false
                self.index = 1
            else
                self.listView:AddSelection(1,false)
                btn1.selected = false
                btn2.selected = true
                self.index = 2
            end
        else
            self.listView:AddSelection(0,false)
            btn1.selected = true
            btn2.selected = false
            self.index = 1
        end
    else--购买返回
        if data.buyLevel == 1 then
            if self.buyTimesMap[1] then
                if self.buyTimesMap[1] < tqCount then
                    btn1.selected = true
                    btn2.selected = false
                    self.index = 1
                else
                    btn1.selected = false
                    btn2.selected = true
                    self.index = 2
                end
            end
        else
            if self.buyTimesMap[2] then
                if self.buyTimesMap[2] < ybCount then
                    btn1.selected = false
                    btn2.selected = true
                    self.index = 2
                else
                    btn1.selected = true
                    btn2.selected = false
                    self.index = 1
                end
            end
        end
        local add = 0
        for k,v in pairs(self.buyTimesMap) do
            add = add + v*(costData[1][4])/100
        end
        GComAlter(string.format(language.fuben177,add))
    end
end

function LirenTipView:onChooseSelect(context)
    local radio = context.sender
    if radio.selected then
        for i=1,self.listView.numItems do
            local obj = self.listView:GetChildAt(i - 1)
            local btn = obj:GetChild("n0")
            if btn.data ~= radio.data then
                btn.selected = false
            end
        end
        self.index = radio.data + 1
    end
end

function LirenTipView:onClickBuy()
    local sId = cache.PlayerCache:getSId()
    if mgr.FubenMgr:isMjxlScene(sId) then--秘境修炼
        proxy.FubenProxy:send(1027304,{buyType = 1,buyLevel = self.index})
    elseif mgr.FubenMgr:isHjzyScene(sId) then
        proxy.FubenProxy:send(1027307,{buyType = 1,buyLevel = self.index})
    end
    -- self:closeView()
end

return LirenTipView