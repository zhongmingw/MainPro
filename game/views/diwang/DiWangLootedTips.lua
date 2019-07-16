--
-- Author: Your Name
-- Date: 2018-08-27 20:14:46
--

local DiWangLootedTips = class("DiWangLootedTips", base.BaseView)

function DiWangLootedTips:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
end

function DiWangLootedTips:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    
    local skipBtn = self.view:GetChild("n2")
    skipBtn.onClick:Add(self.onClickSkip,self)

    self.decTxt = self.view:GetChild("n3")

end

function DiWangLootedTips:initData(data)
    self.lostRank = cache.PlayerCache:getRedPointById(attConst.A50131)
    if self.lostRank > 0 then
        local confData = conf.DiWangConf:getXianWeiDataByRank(self.lostRank)
        if confData then
            self.decTxt.text = string.format(language.diwang11,confData.name)
        end
    end
end

function DiWangLootedTips:onClickSkip()
    if self.lostRank > 0 then
        GOpenView({id = 1278,index = self.lostRank})
    end
end

return DiWangLootedTips