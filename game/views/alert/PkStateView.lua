--
-- Author: 
-- Date: 2017-06-22 19:12:41
--

local PkStateView = class("PkStateView", base.BaseView)

function PkStateView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function PkStateView:initData()
    local sId = cache.PlayerCache:getSId()
    local sConf = conf.SceneConf:getSceneById(sId)
    local pkOptions = sConf and sConf.pk_options or {0}
    for k,item in pairs(self.moshiList) do
        local btn = item:GetChild("n1")
        local pkState = pkOptions[k]
        if pkState then
            item.visible = true
            if g_ios_test then
                btn.icon = UIPackage.GetItemURL(UICommonResIos , tostring(UIItemRes.main01[pkState]))
            else
                btn.icon = UIPackage.GetItemURL("main" , tostring(UIItemRes.main01[pkState]))
            end
            local desc = item:GetChild("n2")
            desc.text = language.main06[pkState]
            item.data = pkState
        else
            item.visible = false
        end
    end
end

function PkStateView:initView()
    self.moshiList = {}
    for i=0,4 do
        local item = self.view:GetChild("n"..i)
        item.visible = false
        item.onClick:Add(self.onBtnRoleMoShi,self)
        table.insert(self.moshiList, item)
    end
    self:setCloseBtn(self.view)
end

--当前战模式--0-和平,1-杀戮,2-仙盟,3-跨服,4-阵营模式
function PkStateView:onBtnRoleMoShi(context)
    local btn = context.sender
    local pkState = btn.data
    local pklv = conf.SysConf:getValue("pk_lev")
    if cache.PlayerCache:getRoleLevel() >= pklv then
        print("切换pk>>>>>>>>>>>>>>>",pkState)
        proxy.PlayerProxy:send(1020106,{pkState = pkState})
    else
        GComAlter(string.format(language.gonggong07, pklv))
    end
    self:closeView()
end

return PkStateView