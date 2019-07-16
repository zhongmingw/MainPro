--
-- Author: wx
-- Date: 2018-09-17 15:03:10
--

local ShenshouPanel = class("ShenshouPanel",import("game.base.Ref"))
local moudleid = 1353
local ruleId = 1142
function ShenshouPanel:ctor(panelObj,mPanent)
    self.view = panelObj
    self.mPanent = mPanent
    self:initView()
end

function ShenshouPanel:onTimer()
    -- body
end

function ShenshouPanel:setData()
    -- body
end

function ShenshouPanel:clear()
    -- body
end

function ShenshouPanel:initView()
    -- body
    local dec1 = self.view:GetChild("n1")
    dec1.text = language.bangpai203

    local dec2 = self.view:GetChild("n9")
    dec2.text = language.bangpai31

    local dec3 = self.view:GetChild("n10")
    dec3.text = conf.SysConf:getModuleById(moudleid).open_lev

    local dec4 = self.view:GetChild("n12")
    dec4.text = language.gangwar23

    local dec5 = self.view:GetChild("n13")
    local ssjt_act_sec = conf.FubenConf:getBossValue("ssjt_act_sec")
    local temp = GGetTimeData(ssjt_act_sec[1])
    local temp1 = GGetTimeData(ssjt_act_sec[2])
    local dayy = conf.FubenConf:getBossValue("ssjt_week_day")
    local _daystr = ""
    local number = #dayy
    for k,v in pairs(dayy) do
        _daystr = _daystr..language.gonggong21[v]
        if k ~= number then
            _daystr = _daystr .. ","
        end
    end

    local var = string.format("%02d:%02d-%02d:%02d",temp.hour,temp.min,temp1.hour,temp1.min)
    local ss =  string.format(language.bangpai204,var)
    dec5.text = string.format(language.bangpai154,_daystr.." " ..ss )

    local confRule = conf.RuleConf:getRuleById(ruleId)
    local dec6 = self.view:GetChild("n14")
    dec6.text = language.xunXian01 .. "\n" .. language.xunXian04

    self.bossaward = conf.BangPaiConf:getValue("gang_sssy_reward_see")
    self.rewardlist = self.view:GetChild("n2")
    self.rewardlist.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rewardlist.numItems = #self.bossaward

    local btn = self.view:GetChild("n8")
    btn.onClick:Add(self.onBtnCallBack,self)

    local btn1 = self.view:GetChild("n15")
    btn1.onClick:Add(self.onBtnCallBack,self)

    self.lab1 = self.view:GetChild("n22")
    self.lab2 = self.view:GetChild("n24")
    self.lab3 = self.view:GetChild("n26")
    self.lab4 = self.view:GetChild("n28")
    self.lab5 = self.view:GetChild("n30")
end

function ShenshouPanel:cellData(index, obj)
    -- body
    local data = self.bossaward[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3] or 1
    GSetItemData(obj, t, true) 
end

function ShenshouPanel:onBtnCallBack(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    if "n8" == btn.name then
        local data = { id = moudleid , falg = true }
        if not GCheckView(data) then
            return
        end
        GOpenView({id = moudleid})
    elseif "n15" == btn.name then
        GOpenRuleView(ruleId)
    end
end

function ShenshouPanel:addMsgCallBack(data)
    -- body

end


return ShenshouPanel