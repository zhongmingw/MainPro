--问鼎之战panel
local WenDingPanel = class("WenDingPanel", import("game.base.Ref"))

function WenDingPanel:ctor(parent)
    -- body
    self.parent = parent
    self.imgPath = nil
    self.view = parent.view:GetChild("n52")
    self:initPanel()
end

function WenDingPanel:initPanel()
    self.confData = conf.SceneConf:getWenDings()
    --规则按钮
    local guizeBtn = self.view:GetChild("n6")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    --战场日志
    local logBtn = self.view:GetChild("n11")
    logBtn.onClick:Add(self.onClickLog,self)
    --进入战斗按钮
    self.goFightBtn = self.view:GetChild("n8")
    self.goFightBtn.onClick:Add(self.onClickGoFight,self)
    local wendingLv = conf.SysConf:getModuleById(1079).open_lev
    local pwsLv = conf.SysConf:getModuleById(1169).open_lev
    local roleLv = cache.PlayerCache:getRoleLevel()
    local data = cache.ActivityCache:get5030111() or {}
    local openDay = data.openDay or 1
    local open_forbid_day = conf.QualifierConf:getValue("open_forbid_day")
    -- print("九重天限制",pwsLv,roleLv,cache.PlayerCache:getRedPointById(50128))
    if cache.PlayerCache:getRedPointById(50128)>0 and roleLv >= pwsLv and openDay > open_forbid_day then
        self.goFightBtn.grayed = true
        self.goFightBtn.touchable = false
    else
        self.goFightBtn.grayed = false
        self.goFightBtn.touchable = true
    end
    local shopBtn = self.view:GetChild("n12")
    shopBtn.onClick:Add(self.onClickShop,self)
    --奖励列表
    self.listView = self.view:GetChild("n13")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:cellAwardsData(index, obj)
    end

    local lvText = self.view:GetChild("n19")--等级要求
    lvText.text = conf.WenDingConf:getValue("open_level")..language.gonggong43
    self.timeText = self.view:GetChild("n20")--开启时间
    self.ruleText = self.view:GetChild("n18")--战场规则
    self.moneyText = self.view:GetChild("n23")--爬塔积分

    self.bg = self.view:GetChild("n26") 
    --self:updateBgImg()
end

function WenDingPanel:updateBgImg()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bg.url = nil
    -- end
    self.imgPath = UIItemRes.zhanchang.."wendingzhizhan_001"
    --self.bg.url = self.imgPath
    self.parent:setLoaderUrl(self.bg,self.imgPath)
end

function WenDingPanel:setData(data)
    self:updateBgImg()
    self.mData = data
    local confRule = conf.RuleConf:getRuleById(1033)
    local ruleDesc = confRule.desc
    self.moneyText.text = cache.PlayerCache:getTypeMoney(MoneyType.pt)--爬塔积分
          
    self.ruleText.text = mgr.TextMgr:getTextColorStr(language.zhangchang04,10,"") --EVE --ruleDesc[2][1][3]
    self.ruleText.onClickLink:Add(self.onClickGuize,self)

    self.awards = {}
    for _,v in pairs(self.confData) do
        if v.normal_drop then
            for k,drop in pairs(v.normal_drop) do
                table.insert(self.awards, drop)
            end
        end
    end
    self.listView.numItems = #self.awards
    
    local actData = cache.ActivityCache:get5030111() or {}
    local openDay = actData.openDay or 1
    local normal_open_day = conf.WenDingConf:getValue("normal_open_day")
    if openDay > normal_open_day then
        self.timeText.text = mgr.TextMgr:getTextByTable(language.wending02_1)
    else
        self.timeText.text = mgr.TextMgr:getTextByTable(language.wending02)
    end
end

function WenDingPanel:cellAwardsData(index, itemObj)
    local data = self.awards[index + 1]
    local itemData = {mid = data[1],amount = data[2],bind = data[3]}
    GSetItemData(itemObj, itemData, true)
end

--规则
function WenDingPanel:onClickGuize()
    GOpenRuleView(1033)
end

--战场日志
function WenDingPanel:onClickLog()
    mgr.ViewMgr:openView(ViewName.ZhanChangLog,function(view)
        proxy.WenDingProxy:send(1350102,{page = 1})
    end)
end

--进入战斗
function WenDingPanel:onClickGoFight()
    local sceneId = self.mData and self.mData.lastSceneId or WenDingScene
    if sceneId == 0 then
        sceneId = WenDingScene
    end
    mgr.FubenMgr:gotoFubenWar(sceneId)
end
--跳转到功勋商城
function WenDingPanel:onClickShop()
    GOpenView({id = 1081})
end

function WenDingPanel:clear()
    self.bg.url = nil
end

return WenDingPanel
