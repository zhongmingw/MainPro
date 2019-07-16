--皇陵探险
local HuangLingPanel = class("HuangLingPanel", import("game.base.Ref"))

function HuangLingPanel:ctor(parent)
    -- body
    self.parent = parent
    self.view = parent.view:GetChild("n53")
    self.imgPath = nil
    self:initView()
end

function HuangLingPanel:initView()
    -- body
    --规则按钮
    local guizeBtn = self.view:GetChild("n5")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    --进入战斗按钮
    
    self.goFightBtn = self.view:GetChild("n6")
    self.goFightBtn.onClick:Add(self.onClickGoFight,self)
    --奖励列表
    self.listView = self.view:GetChild("n7")
    self:initListView()
    self.dataConf = conf.HuanglingConf:getPriviewAwards()
    self.listView.numItems = #self.dataConf

    local lvLimit = self.view:GetChild("n12")
    lvLimit.text = language.huangling10

    local wanfaTxt = self.view:GetChild("n14")
    local textData = {
                            {text=language.huangling07[1],color = 2},
                            {text=language.huangling07[2],color = 10},
                            {text=language.huangling07[3],color = 2},
                        }
    wanfaTxt.text = mgr.TextMgr:getTextByTable(textData)
    local startTime = self.view:GetChild("n16")
    startTime.text = language.huangling11

    self.bg = self.view:GetChild("n18")
    --self:updateBgImg()
    local shopBtn = self.view:GetChild("n19")
    shopBtn.onClick:Add(self.onClickGoToShop,self)

    self.moneyText = self.view:GetChild("n22")--荣誉积分

    --
end

function HuangLingPanel:updateBgImg()
    if self.bg.url and self.bg.url ~= "" then
        return
    end
    -- if self.imgPath then
    --     UnityResMgr:UnloadAssetBundle(self.imgPath, true)
    --     self.bg.url = nil
    -- end
    self.imgPath = UIItemRes.zhanchang.."huanglingzhizhan_009"
    --self.bg.url = self.imgPath
    self.parent:setLoaderUrl(self.bg,self.imgPath)
end

--奖励列表
function HuangLingPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.listView:SetVirtual()
end

function HuangLingPanel:cellData(index, obj)
    -- body
    self.dataConf = conf.HuanglingConf:getPriviewAwards()
    local data = self.dataConf[index+1]
    if data then
        local mId = data[1]
        local amount = data[2]
        local bind = data[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end

function HuangLingPanel:setData(data)
    -- body
    self.open = data.open
    self:updateBgImg()
    self.moneyText.text = cache.PlayerCache:getTypeMoney(MoneyType.ry)
end

--规则
function HuangLingPanel:onClickGuize( context )
    GOpenRuleView(1038)
end

--进入战斗
function HuangLingPanel:onClickGoFight( context )
    -- body
    -- print("进入战斗",self.open)
    mgr.FubenMgr:gotoFubenWar(HuangLingScene)
end

--荣誉商店跳转
function HuangLingPanel:onClickGoToShop()
    GOpenView({id = 1045})
end

function HuangLingPanel:clear()
    self.bg.url = ""
end

return HuangLingPanel
