--
-- Author: Your Name
-- Date: 2018-07-23 17:05:52
--
--仙位详情
local XianWeiDetails = class("XianWeiDetails", base.BaseView)

function XianWeiDetails:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
end

function XianWeiDetails:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    self:setCloseBtn(closeBtn)
    self.modelPanel = self.view:GetChild("n3")
    self.powerTxt = self.view:GetChild("n10")
    self.titleIcon = self.view:GetChild("n31")
    self.nameTxt = self.view:GetChild("n2")
    self.shouhuTims = self.view:GetChild("n7")
    self.attrsList = {}
    for i=1,6 do
        local nameTxt = self.view:GetChild("att"..i)
        local attTxt = self.view:GetChild("att"..(i+10))
        table.insert(self.attrsList,{nameTxt,attTxt})
    end
    self.buffAtt = self.view:GetChild("n44")
end

function XianWeiDetails:initData(data)
    self.roleData = data.roleData
    self.myRank = data.myRank
    self.leftColdTime = data.leftColdTime
    self.powerTxt.text = self.roleData.power
    self.shouhuTims.text = self.roleData.defCount or 0
    -- if self.model then
    --     self:removeModel(self.model)
    --     self.model = nil
    -- end
    self.model = self:addModel(self.roleData.skins[1],self.modelPanel)
    self.model:setSkins(nil, self.roleData.skins[2],self.roleData.skins[3])
    self.model:setPosition(0,-200,550)
    self.model:setRotationXYZ(0,150,0)
    self.model:setScale(180)
    local xianWeiData = conf.DiWangConf:getXianWeiDataByRank(self.roleData.rank)
    local titleId = xianWeiData.title[1]
    local titleData = conf.RoleConf:getTitleData(titleId)
    self.titleIcon.url = UIPackage.GetItemURL("head" , tostring(titleData.scr))
    self.nameTxt.text = self.roleData.roleName 

    --仙位额外属性
    local buffId = xianWeiData.buff
    if buffId then
        local buffData = conf.BuffConf:getBuffConf(buffId)
        self.buffAtt.text = buffData.desc
        for i=25,28 do
            self.view:GetChild("n"..i).visible = true
        end
    else
        self.buffAtt.text = ""
        for i=25,28 do
            self.view:GetChild("n"..i).visible = false
        end
    end


    --称号属性
    local attrData = GConfDataSort(titleData)
    for k,v in pairs(self.attrsList) do
        local nameTxt = v[1]
        local attTxt = v[2]
        local t = attrData[k]
        if t then
            nameTxt.visible = true
            attTxt.visible = true
            nameTxt.text = conf.RedPointConf:getProName(t[1])
            attTxt.text = "+" .. GProPrecnt(t[1],math.floor(t[2]))
        else
            nameTxt.visible = false
            attTxt.visible = false
        end
    end

    --挑战按钮
    local fightBtn = self.view:GetChild("n46")
    fightBtn.data = self.roleData
    fightBtn.onClick:Add(self.onClickFight,self)
    local roleId = cache.PlayerCache:getRoleId()
    if self.roleData.roleId == roleId then
        fightBtn.visible = false
    else
        fightBtn.visible = true
    end
end

function XianWeiDetails:refreshCdTime(data)
    self.leftColdTime = data.leftColdTime
end

function XianWeiDetails:onClickFight(context)
    local data = context.sender.data
    local roleId = cache.PlayerCache:getRoleId()
    local myPower = cache.PlayerCache:getRolePower()
    if data.roleId == roleId then
        GComAlter(language.diwang04)
    elseif self.myRank ~= 0 then
        local myXianWeiData = conf.DiWangConf:getXianWeiDataByRank(self.myRank)
        local otherXianWeiData = conf.DiWangConf:getXianWeiDataByRank(data.rank)
        if myXianWeiData.xw_type < otherXianWeiData.xw_type then
            GComAlter(language.diwang06)
        else
            if self.leftColdTime > 0 then
                GComAlter(language.diwang08)
            else
                if myPower < data.power*0.3 then
                    GComAlter(language.diwang07)
                else
                    mgr.ViewMgr:openView2(ViewName.DiWangFightTips, {leftColdTime = self.leftColdTime,rank = data.rank,myRank = self.myRank})
                end
            end
        end
    elseif myPower < data.power*0.3 then
        GComAlter(language.diwang07)
    else
        if self.leftColdTime > 0 then
            GComAlter(language.diwang08)
        else
            mgr.ViewMgr:openView2(ViewName.DiWangFightTips, {leftColdTime = self.leftColdTime,rank = data.rank,myRank = self.myRank})
        end
    end
end

return XianWeiDetails