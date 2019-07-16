--
-- Author: 
-- Date: 2017-08-30 14:33:09
--
--仙魔战
local XianMoWarPanel = class("XianMoWarPanel",import("game.base.Ref"))

function XianMoWarPanel:ctor(parent)
    self.mParent = parent
    self.imgPath = nil
    self.view = parent.view:GetChild("n57")
    self:initPanel()
end

function XianMoWarPanel:initPanel()
    --规则按钮
    local guizeBtn = self.view:GetChild("n5")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    --战场日志
    local logBtn = self.view:GetChild("n7")
    logBtn.onClick:Add(self.onClickLog,self)
    --进入战斗按钮
    self.goFightBtn = self.view:GetChild("n6")
    self.goFightBtn.onClick:Add(self.onClickGoFight,self)
    local shopBtn = self.view:GetChild("n22")
    shopBtn.onClick:Add(self.onClickShop,self)
    --奖励列表
    self.listView = self.view:GetChild("n9")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local lvText = self.view:GetChild("n14")--等级要求
    local model = conf.SysConf:getModuleById(1117)
    local lv = model and model.open_lev or 1
    lvText.text = lv.."级"
    self.view:GetChild("n17").text = language.store12.."值"
    self.timeText = self.view:GetChild("n15")--开启时间
    self.ruleText = self.view:GetChild("n13")--战场规则
    self.moneyText = self.view:GetChild("n18")--威名值
    self.view:GetChild("n2").url = UIItemRes.moneyIcons[MoneyType.wm]
    self.bg = self.view:GetChild("n3") 
end

function XianMoWarPanel:updateBgImg()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bg.url = nil
    -- end
    self.imgPath = UIItemRes.zhanchang.."xianmozhanchang_018"
    --self.bg.url = self.imgPath
    self.mParent:setLoaderUrl(self.bg,self.imgPath)
end

function XianMoWarPanel:setData()
    self:updateBgImg()
    self.moneyText.text = cache.PlayerCache:getTypeMoney(MoneyType.wm)
    local sceneData = conf.SceneConf:getSceneById(XianMoScene)
    self.awards = sceneData and sceneData.normal_drop or {}
    self.listView.numItems = #self.awards
    local confRule = conf.RuleConf:getRuleById(1043)
    local ruleDesc = confRule.desc
    self.ruleText.text = mgr.TextMgr:getTextColorStr(language.zhangchang04,10,"") --EVE --ruleDesc[2][1][3]
    self.ruleText.onClickLink:Add(self.onClickGuize,self)
    
    local actData = cache.ActivityCache:get5030111() or {}
    local openDay = actData.openDay or 1
    if openDay > 7 then
        self.timeText.text = mgr.TextMgr:getTextByTable(language.xianmoWar07_1)
    else
        self.timeText.text = mgr.TextMgr:getTextByTable(language.xianmoWar07)
    end
end

function XianMoWarPanel:cellAwardsData(index, itemObj)
    local data = self.awards[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(itemObj, itemData, true)
end

--规则
function XianMoWarPanel:onClickGuize()
    GOpenRuleView(1043)
end

--战场日志
function XianMoWarPanel:onClickLog()
    mgr.ViewMgr:openView2(ViewName.ZhanChangLog)
    proxy.XianMoProxy:send(1420102,{page = 1})
end

--进入战斗
function XianMoWarPanel:onClickGoFight()
    mgr.FubenMgr:gotoFubenWar(XianMoScene)
end
--跳转到功勋商城
function XianMoWarPanel:onClickShop()
    GOpenView({id = 1118})
end

function XianMoWarPanel:clear()
    self.bg.url = nil
end

return XianMoWarPanel