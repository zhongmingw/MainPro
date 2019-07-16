--
-- Author: bxp
-- Date: 2017-12-07 12:45:35
--

local HintView = class("HintView", base.BaseView)

function HintView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function HintView:initView()
    local window4 = self.view:GetChild("n0")
    local closeBtn = window4:GetChild("n2")
    local cancelBtn = self.view:GetChild("n9")
    closeBtn.onClick:Add(self.onCloseView,self)
    cancelBtn.onClick:Add(self.onCloseView,self)
    local sureBtn = self.view:GetChild("n8")
    sureBtn.onClick:Add(self.onSure,self)
    self.richText = self.view:GetChild("n1")
    self.radioBtn = self.view:GetChild("n5")--不再提醒按钮
    self.radioBtn.onClick:Add(self.onChooseSelect,self)
end

function HintView:initData(data)
    if not data then return end 
    self.times = data.times
    self.msg = data.msg
    local mid = data.mid 
    local haveKeyAmount = data.haveKeyAmount  --拥有钥匙数量
    local needKeyAmount = data.needKeyAmount  --需要钥匙数量
    local subKey = needKeyAmount - haveKeyAmount --需要补充的钥匙数量
    local moduleId = data.moduleId
    local ybCost 
    if moduleId == 1155 then 
        ybCost = conf.ActivityConf:getValue("treasure_book_item_cost")
    elseif moduleId == 1163 then 
        ybCost = conf.ActivityConf:getValue("treasure_jinjie_item_cost")
    elseif moduleId == 1217 then
        ybCost = conf.RuneConf:getFuwenGlobal("fuwen_finding_item_cost")
    elseif moduleId == 1194 then 
        ybCost = conf.ActivityConf:getValue("treasure_pet_item_cost")
    elseif moduleId == 1239 then 
        ybCost = conf.ActivityConf:getValue("treasure_shenqi_item_cost")
    elseif moduleId == 1240 then 
        ybCost = conf.ActivityConf:getValue("treasure_honghuang_item_cost")  
    elseif moduleId == 1267 then 
        ybCost = conf.ActivityConf:getValue("treasure_jianling_item_cost") 
    elseif moduleId == 1343 then 
        ybCost = conf.ActivityConf:getValue("treasure_xianequip_item_cost") 
    elseif moduleId == 1358 then 
        ybCost = conf.ActivityConf:getValue("treasure_shengyin_item_cost") 
    elseif moduleId == 1362 then 
        ybCost = conf.ActivityConf:getValue("treasure_jianshen_item_cost") 
    elseif moduleId == 1437 then
        ybCost = conf.ActivityConf:getValue("treasure_qibing_item_cost")
    elseif moduleId == 1450 then
        ybCost = conf.ActivityConf:getValue("treasure_hm_item_cost")
    end
    local name = conf.ItemConf:getName(mid)
    self.needYb = subKey * ybCost
    -- print("道具名字",name,mid)
    self.richText.text = string.format(language.xunbao01,name,self.needYb,subKey) 
end

function HintView:setData(data_)

end

function HintView:onSure()
    local goldData = cache.PackCache:getPackDataById(PackMid.gold)
    local times = self.times
    if goldData.amount < self.needYb then 
        GGoVipTequan(0)
        self:closeView()
    else
        -- print(print("发送信息"..self.msg.."次数"..times))
        proxy.ActivityProxy:sendMsg(self.msg,{times = times})
    end
    self:closeView()
end
--本次登录提醒按钮
function HintView:onChooseSelect()
    if self.radioBtn.selected then
        cache.ActivityCache:setXunBaoAlert(self.radioBtn.selected)
    end
end

function HintView:onCloseView()
    self:closeView()
end

return HintView