--
-- Author: Your Name
-- Date: 2017-06-27 11:33:54
--

local LevelTip = class("LevelTip", base.BaseView)

function LevelTip:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
end

function LevelTip:initView()
    local closeBtn = self.view:GetChild("n4")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.closeText = self.view:GetChild("n5")
    self.itemIcon = self.view:GetChild("n8")
    self.itemNameTxt = self.view:GetChild("n9")
    self.itemNumsTxt = self.view:GetChild("n10")
    self.goBtn = self.view:GetChild("n3")
    self.goBtn.onClick:Add(self.onClickGo,self)
end

function LevelTip:initData()
    self.timesNum = 10
    self.closeText.text = self.timesNum .. language.tips07
    
    local proData = {}
    -- if GIsCharged() then
        proData = cache.PackCache:getPackDataById(221011017)--1.5经验符道具、
    -- else
    --     proData = cache.PackCache:getPackDataById(221041717)--1.2经验符道具、
    -- end
    local info = {mid = proData.mid,amount = proData.amount}
    GSetItemData(self.itemIcon,info,true)
     
    local textData = {
                {text = language.redbag09 ,color = 6},
                {text = proData.amount,color = 7},
            }
    if proData.amount == 0 then
        textData = {
                {text = language.redbag09 ,color = 6},
                {text = proData.amount,color = 14},
            }
    end
    self.itemNumsTxt.text = mgr.TextMgr:getTextByTable(textData)
    self.itemNameTxt.text = conf.ItemConf:getName(proData.mid)
    self.index = proData.index
    self.amount = proData.amount
    if proData.amount > 0 then
        self.type = 1
        self.goBtn:GetChild("title").text = language.gonggong66
    else
        self.type = 2
        self.goBtn:GetChild("title").text = language.gonggong67
    end

    self.timer = self:addTimer(1, -1, handler(self,self.timerClick))
end

function LevelTip:timerClick()
    if self.timesNum > 0 then
        self.timesNum = self.timesNum - 1
        self.closeText.text = self.timesNum .. language.tips07
    else
        self:onCloseView()
    end
end

function LevelTip:onClickGo()
    if self.type == 1 then
        local params = {
            index = self.index,--背包的位置
            amount = 1,--使用数量
            ext_arg = 0,
        }
        proxy.PackProxy:sendUsePro(params)
        self:onCloseView()
    else
        -- if GIsCharged() then
            GOpenView({id = 1056})
        -- else
            -- GOpenView({id = 1057})
        -- end
    end
end

function LevelTip:onCloseView()
    mgr.TimerMgr:removeTimer(self.timer)
    self:closeView()
end

return LevelTip