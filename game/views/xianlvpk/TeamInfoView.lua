--
-- Author: 
-- Date: 2018-07-24 22:06:02
--

local TeamInfoView = class("TeamInfoView", base.BaseView)

function TeamInfoView:ctor()
    TeamInfoView.super.ctor(self)
    self.uiLevel = UILevel.level2   
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function TeamInfoView:initView()
    local closeBtn = self.view:GetChild("n24")
    self:setCloseBtn(closeBtn)
    self.teamName = self.view:GetChild("n11")
    self.winRate = self.view:GetChild("n12")
    self.teamPower = self.view:GetChild("n13")
    self.matchTime = self.view:GetChild("n14")

    self.infoList = {}
    local t = {}
    t.roleName = self.view:GetChild("n17")
    t.roleLv = self.view:GetChild("n18")
    t.rolePower = self.view:GetChild("n19")
    t.rolePanel = self.view:GetChild("n15")
    table.insert(self.infoList,t)
    local t = {}
    t.roleName = self.view:GetChild("n21")
    t.roleLv = self.view:GetChild("n22")
    t.rolePower = self.view:GetChild("n23")
    t.rolePanel = self.view:GetChild("n16")
    table.insert(self.infoList,t)

end

function TeamInfoView:initData()

end

function TeamInfoView:setData(data)
    printt("队伍详细信息",data)
    if data then
        self.data = data
        self.teamName.text = data.teamDetailInfo.teamName
        self.teamPower.text = data.teamDetailInfo.power
        if tonumber(data.teamDetailInfo.joinCount) <= 0 then
            self.winRate.text = "0%"
        else
            self.winRate.text = tostring(math.floor(tonumber(data.teamDetailInfo.winCount)/tonumber(data.teamDetailInfo.joinCount)*100)).."%"
        end
        self.matchTime.text = data.teamDetailInfo.joinCount

        for k,v in pairs(self.infoList) do
            local data = data.teamDetailInfo.memberInfo[k]
            v.roleName.text = data.roleName
            v.roleLv.text = data.level.."级"
            v.rolePower.text = language.xianlv15..data.power
            self:setModel(v.rolePanel,data.sex,data.skinMap)--伴侣的皮肤
        end
    end
end
--设置模型
function TeamInfoView:setModel(panel,sex,skins)
    local skins1 = skins and skins[1] or cache.PlayerCache:getSkins(Skins.clothes)--衣服
    local skins2 = skins and skins[2] or cache.PlayerCache:getSkins(Skins.wuqi)--武器
    local skins3 = skins and skins[3] or cache.PlayerCache:getSkins(Skins.xianyu)--仙羽
    local skins5 = skins and skins[5] or cache.PlayerCache:getSkins(Skins.shenbing) --神兵
    local modelObj
    modelObj,cansee = self:addModel(skins1,panel)
    modelObj:setSkins(nil,skins2,skins3)
    modelObj:setPosition(panel.actualWidth/2,-panel.actualHeight-40,100)
    modelObj:setRotation(RoleSexModel[sex].angle)
    modelObj:setScale(100)
    -- if skins5 > 0 and skins2>0 then
        -- modelObj:addWeaponEct(skins5.."_ui")
    -- end
end

return TeamInfoView