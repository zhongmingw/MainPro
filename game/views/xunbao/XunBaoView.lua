--
-- Author: bxp
-- Date: 2017-12-06 16:57:53
--
local XunBaoView = class("XunBaoView", base.BaseView)

local EquipXunBao = import(".XunBaoMany")--装备寻宝

-- local JinJieXun = import(".XunBaoSingle")--进阶寻宝

local PetXunBao = import(".XunBaoSingle")--宠物寻宝

local RuneXunbao = import(".RuneXunbao")--符文寻宝

local ShenQiMany= import(".XunBaoMany")--神器寻宝

local JianLingXunBao = import(".XunBaoMany")--剑灵寻宝

local Modules = {
    [1] = {1155,1163,1343,1437},--装备,进阶,仙装,奇兵
    [2] = {1194},--宠物
    [3] = {1217},--符文
    [4] = {1239,1240,1450},--神奇洪荒
    [5] = {1267,1358,1362}--剑灵寻宝
}

function XunBaoView:ctor()
    XunBaoView.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end
function XunBaoView:initView()
    self.window = self.view:GetChild("n0")
    local btnClose = self.window:GetChild("n3")
    btnClose.onClick:Add(self.onClickClose,self)

    self.controller1 = self.view:GetController("c1")--主控制器  
    self.controller1.onChanged:Add(self.onController1,self)

    local ruleBtn = self.view:GetChild("n15")  
    ruleBtn.onClick:Add(self.onClickRule,self)

    self.btnList = {}
    self.btnPos = {}
    for i=1,5 do  
        local btn = self.view:GetChild("n20"..i)
        btn.data = {status = i }
        btn.onClick:Add(self.createObj,self)
        table.insert(self.btnList, btn)
        table.insert(self.btnPos,btn.y)
    end

end
function XunBaoView:initData(data)
    self.controller1.selectedIndex = 0
    self:checkSeeBtn()
    self:setPictureSize()
    local goIndex = data.index or 0
    self.moduleId = data.moduleId or self:getOpenModule(goIndex+1)
    self:GoToPage(goIndex)
    if self.controller1.selectedIndex == 0 and self.equipMany then
        self.equipMany:clear()
        self.equipMany:initData(self.moduleId)
    elseif self.controller1.selectedIndex == 1 and self.petXunBao then
        self.petXunBao:clear()
    elseif self.controller1.selectedIndex == 2 and self.runeXunbao then
        self.runeXunbao:clear()
    elseif self.controller1.selectedIndex == 3 and self.shenQiMany then
        self.shenQiMany:clear()
    elseif self.controller1.selectedIndex == 4 and self.jianLingXunBao then
        self.jianLingXunBao:clear()
    end
end
--跳转用
function XunBaoView:GoToPage(page)
    self.index = page or 0
    self.controller1.selectedIndex = self.index
    self:initAct(page)
end
function XunBaoView:checkSeeBtn()
    -- local btn = self.btnList[1]
    -- local redPanel = btn:GetChild("n7")
    -- local param = {panel = redPanel, ids = {attConst.A30125,attConst.A30128,attConst.A30135},notnumber = true}
    -- mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
    -- mgr.ModuleMgr:setModuleVisible(Modules,self.btnList,self.btnPos)
    local index = 1
    local open_lev = {}--按开启等级排序

    for k,v in ipairs(Modules) do
        local isOpen = false
        if type(v) == "table" then 
            local maxOpenLv = 500
            for _,j in pairs(v) do
                local openLv = conf.SysConf:getModuleById(j).open_lev or 0
                if openLv < maxOpenLv then 
                   maxOpenLv = openLv 
                end

                if mgr.ModuleMgr:CheckView(j) then 
                    -- if j == 1267 then --剑灵寻宝
                    --     local data = cache.ActivityCache:get5030111()
                    --     if data.acts[3065] and data.acts[3065] == 1 then 
                    --         isOpen = true
                    --     else
                    --         isOpen = false
                    --     end
                    -- else
                        isOpen = true
                    -- end
                    -- break
                end
            end
            table.insert(open_lev,{k = k, ["openLv"] = maxOpenLv})

        else
            -- local openLv = conf.SysConf:getModuleById(v).open_lev or 0
            -- table.insert(open_lev,{k = k ,["openLv"] = openLv})
            -- isOpen = mgr.ModuleMgr:CheckSeeView(v)
            -- if v == 1267 then --剑灵寻宝
            --     isOpen = mgr.ModuleMgr:CheckSeeView(v)
            --     if isOpen then
            --         local data = cache.ActivityCache:get5030111()
            --         if data.acts[3065] and data.acts[3065] == 1 then 
            --             isOpen = true
            --         else
            --             isOpen = false
            --         end
            --     end
            -- end
        end
        self.btnList[k].visible = isOpen
        if self.btnList[k].visible then
            self.btnList[k].y = self.btnPos[index]
            index = index + 1
        end
    end
    table.sort(open_lev ,function ( a,b )
        return a.openLv < b.openLv
    end )
    for k,v in pairs(open_lev) do
        self.btnList[v.k].y = self.btnPos[k]
    end
end
function XunBaoView:initAct(page)
    local btn = self.btnList[page+1]
    if btn then 
        btn.onClick:Call()
    end
end

function XunBaoView:createObj(context)
    local status  = context.sender.data.status
    if status == 1 and not self.equipMany then
        self.equipMany = EquipXunBao.new(self,status-1,self:getOpenModule(status))
    elseif status == 2 and not self.petXunBao then 
        self.petXunBao = PetXunBao.new(self,1194)
    elseif status == 3 and not self.runeXunbao then 
        self.runeXunbao = RuneXunbao.new(self)
    elseif status == 4 and not self.shenQiMany then 
        self.shenQiMany = ShenQiMany.new(self,status-1,self:getOpenModule(status))
    elseif status == 5 and not self.jianLingXunBao then 
        self.jianLingXunBao = JianLingXunBao.new(self,status-1,self:getOpenModule(status))
    end
end

function XunBaoView:getOpenModule(status)
    for k,v in pairs(Modules[status]) do
        local isOpen = mgr.ModuleMgr:CheckView(v)
        if isOpen then 
            return v 
        end
    end
end

function XunBaoView:getTowerMaxLevel()
    if self.runeXunbao then
        return self.runeXunbao:getTowerMaxLevel()
    end
    return 0
end
--设置界面按钮背景图片尺寸
function XunBaoView:setPictureSize()
    local trueNum = 0
    for k,v in pairs(self.btnList) do
        if v.visible then 
            trueNum = trueNum + 1
        end
    end
    if trueNum > 1 then 
        self.view:GetChild("n3").height = 190 + ((trueNum-1) * 88)
    else
        self.view:GetChild("n3").height = 190
    end
end

--寻宝切换
function XunBaoView:onController1()
    
    if self.controller1.selectedIndex ~= 0 then
        if self.equipMany then 
            self.equipMany:clear()
        end
    end
    if self.controller1.selectedIndex ~= 1 then
        if self.petXunBao then 
            self.petXunBao:clear()
        end
    end
    if self.controller1.selectedIndex ~= 2 then
        if self.runeXunbao then 
            self.runeXunbao:clear()
        end
    end
    if self.controller1.selectedIndex ~= 3 then
        if self.shenQiMany then 
            self.shenQiMany:clear()
        end
    end
    if self.controller1.selectedIndex ~= 4 then
        if self.jianLingXunBao then 
            self.jianLingXunBao:clear()
        end
    end
    if self.controller1.selectedIndex == 0 then 
        if not self.equipMany then 
            self.equipMany = EquipXunBao.new(self,0,self.moduleId)
            self.equipMany:initData(self.moduleId)
        else
            self.equipMany:initData(self.moduleId)
        end

    elseif self.controller1.selectedIndex == 1 then --请求宠物寻宝信息
        proxy.ActivityProxy:sendMsg(1030170)
    elseif self.controller1.selectedIndex == 2 then --请求符文寻宝信息
        proxy.RuneProxy:send(1500201)
    elseif self.controller1.selectedIndex == 3 then 
        if not self.shenQiMany then 
            self.shenQiMany = ShenQiMany.new(self,3,self.moduleId)
            self.shenQiMany:initData(self.moduleId)
        else
            self.shenQiMany:initData(self.moduleId)
        end
    elseif self.controller1.selectedIndex == 4 then --请求剑灵寻宝信息
        -- proxy.ActivityProxy:sendMsg(1030195)
        if not self.jianLingXunBao then 
            self.jianLingXunBao = JianLingXunBao.new(self,4,self.moduleId)
            self.jianLingXunBao:initData(self.moduleId)
        else
            self.jianLingXunBao:initData(self.moduleId)
        end
    end
end

function XunBaoView:setData(data)

    if data then --有data 是请求信息返回
        local msgId = data.msgId
        if self.controller1.selectedIndex == 0 then
            if msgId == 5030152 then --装备寻宝信息
                self:updateEquip(data)
            elseif msgId == 5030156 then --进阶寻宝信息
                self:updateJinjie(data)
            elseif msgId == 5030246 then
                --仙装寻宝
                self:updateXianzhuang(data)
            elseif msgId == 5030683 then --奇兵寻宝信息
                self:updateQiBin(data)
            end
            self.equipMany:setAwardItem()--因为涉及到人物等级所以每次需要重新设置奖励
            self.packHaveThing = self.equipMany:getPackHaveThing()
        elseif self.controller1.selectedIndex == 1 and msgId == 5030170 then--宠物寻宝信息
            self:updatePet(data)
            self.packHaveThing = self.petXunBao:getPackHaveThing()
            self.petXunBao:setAwardItem()
        elseif self.controller1.selectedIndex == 2 and msgId == 5500201 then--符文寻宝信息
            self:severXunbao(data)
        elseif self.controller1.selectedIndex == 3 then
            if msgId == 5030189 then --神器寻宝信息
                self:updateShenQi(data)
            elseif msgId == 5030192 then --洪荒寻宝信息
                self:updateHonghuang(data)
            elseif msgId == 5030693 then --鸿蒙寻宝信息
                self:updateHongMeng(data)
            end
        elseif self.controller1.selectedIndex == 4 then
            if msgId == 5030195 then--剑灵寻宝信息
                self:updateJianLing(data)
            elseif msgId == 5030622 then--圣印寻宝信息
                self:updateShengYin(data)
            elseif msgId == 5030630 then--剑神寻宝信息
                self:updateJianShen(data)
            end
            self.packHaveThing = self.jianLingXunBao:getPackHaveThing()
            self.jianLingXunBao:setAwardItem()
        end
    else
        local msgId = 0
        if self.controller1.selectedIndex == 0 then--装备寻宝
            if msgId == 5030155 then --装备寻宝
                self:updateEquip()
            elseif msgId == 5030160 then --进阶寻宝
                self:updateJinjie()
            elseif msgId == 5030248 then
                --仙装寻宝
                self:updateXianzhuang()
            elseif msgId == 5030685 then --奇兵寻宝
                self:updateQiBin()
            end
        elseif self.controller1.selectedIndex == 1 and msgId == 5030172 then--宠物寻宝
            self:updatePet()
        elseif self.controller1.selectedIndex == 3 then
            if msgId == 5030189 then --神器寻宝
                self:updateShenQi()
            elseif msgId == 5030194 then --洪荒寻宝
                self:updateHonghuang()
            elseif msgId == 5030695 then --鸿蒙寻宝
                self:updateHongMeng()
            end
        elseif self.controller1.selectedIndex == 4 then--剑灵寻宝
            if msgId == 5030195 then
                self:updateJianLing()
            elseif msgId == 5030622 then--圣印寻宝
                self:updateShengYin()
            elseif msgId == 5030630 then--剑神寻宝
                self:updateJianShen()
            end
        end
    end
    self:refreshRed()
    -- self:getPackHaveThing()
end
--装备寻宝数据
function XunBaoView:updateEquip(data)
    self.equipMany:setData(data)
end
--进阶寻宝数据
function XunBaoView:updateJinjie(data)
    self.equipMany:setData(data)
end
--进阶寻宝数据
function XunBaoView:updateXianzhuang(data)
    self.equipMany:setData(data)
end
--奇兵寻宝数据
function XunBaoView:updateQiBin(data)
    self.equipMany:setData(data)
end
--宠物寻宝数据
function XunBaoView:updatePet(data)
    self.petXunBao:setData(data)
end
--符文寻宝信息
function XunBaoView:setRuneXunbao(data)
    self.runeXunbao:setData(data)
end
--符文寻宝数据
function XunBaoView:severXunbao(data)
    self.runeXunbao:severXunbao(data)
end
--神器寻宝数据
function XunBaoView:updateShenQi(data)
    self.shenQiMany:setData(data)
end
--洪荒寻宝数据
function XunBaoView:updateHonghuang(data)
    self.shenQiMany:setData(data)
end
--鸿蒙寻宝数据
function XunBaoView:updateHongMeng(data)
    self.shenQiMany:setData(data)
end
--剑灵寻宝数据
function XunBaoView:updateJianLing(data)
    self.jianLingXunBao:setData(data)
end
--圣印寻宝数据
function XunBaoView:updateShengYin(data)
    self.jianLingXunBao:setData(data)
end
--剑神寻宝数据
function XunBaoView:updateJianShen(data)
    self.jianLingXunBao:setData(data)
end
--积分兑换完后刷新界面积分
function XunBaoView:refreshScore(data)
    if data then 
        if data.msgId == 5030153 then --装备积分兑换
            self:scoreEquip(data)
        elseif data.msgId == 5030157 then--进阶积分兑换
            self:scoreJinjie(data)
        elseif data.msgId == 5030247 then--仙装积分兑换
            self:scoreJinjie(data)
        elseif data.msgId == 5030684 then--奇兵积分兑换
            self:scoreQiBin(data)
        elseif data.msgId == 5030171 then--宠物积分兑换
            self:scorePet(data)
        elseif data.msgId == 5030190 then --神器积分兑换
            self:scoreShenQi(data)
        elseif data.msgId == 5030193 then--洪荒积分兑换
            self:scoreHongHuang(data)
        elseif data.msgId == 5030196 then --剑灵积分兑换
            self:scoreJianLing(data)
        elseif data.msgId == 5030623 then --圣印积分兑换
            self:scoreShengYin(data)
        elseif data.msgId == 5030631 then --剑神积分兑换
            self:scoreJianShen(data)
        elseif data.msgId == 5030694 then --鸿蒙积分兑换
            self:scoreHongMeng(data)
        end
    end
end
--装备积分兑换
function XunBaoView:scoreEquip(data)
    self.equipMany:refreshScoreData(data)
end
--进阶积分兑换
function XunBaoView:scoreJinjie(data)
    self.equipMany:refreshScoreData(data)
end
--奇兵寻宝积分兑换
function XunBaoView:scoreQiBin(data)
    self.equipMany:refreshScoreData(data)
end
--宠物积分兑换
function XunBaoView:scorePet(data)
    self.petXunBao:refreshScoreData(data)
end
--神器积分兑换
function XunBaoView:scoreShenQi(data)
    self.shenQiMany:refreshScoreData(data)
end
--洪荒积分兑换
function XunBaoView:scoreHongHuang(data)
    self.shenQiMany:refreshScoreData(data)
end
--剑灵积分兑换
function XunBaoView:scoreJianLing(data)
    self.jianLingXunBao:refreshScoreData(data)
end
--剑灵积分兑换
function XunBaoView:scoreShengYin(data)
    self.jianLingXunBao:refreshScoreData(data)
end
--剑神积分兑换
function XunBaoView:scoreJianShen(data)
    self.jianLingXunBao:refreshScoreData(data)
end
--鸿蒙积分兑换
function XunBaoView:scoreHongMeng(data)
    self.shenQiMany:refreshScoreData(data)
end

-- function XunBaoView:getPackHaveThing()
--     self.packHaveThing = self.xunbaoSingle:getPackHaveThing()
-- end
--标签按钮红点设置
function XunBaoView:refreshRed()
    local redPoints = {
        [1] = {attConst.A30125,attConst.A30128,attConst.A30181,attConst.A30251},--装备，进阶,仙装，奇兵
        [2] = attConst.A30135,--宠物寻宝红点
        [3] = attConst.A10259,--符文寻宝红点
        [4] = {attConst.A30149,attConst.A30150,attConst.A30256},--神器，洪荒,鸿蒙
        [5] = {attConst.A30157,attConst.A30216,attConst.A30218}--剑灵,圣印,剑神
    }
    for i=1,5 do
        local red = redPoints[i]
        local redNum = 0
        if type(red) == "table" then 
            for k,v in pairs(red) do
                local var = cache.PlayerCache:getRedPointById(v)
                redNum = redNum + var
            end
        else
            redNum = cache.PlayerCache:getRedPointById(redPoints[i])
        end
        local btn = self.view:GetChild("n20"..i)
        if i == 1 then
            btn:GetChild("n7").visible = false
            if redNum > 0 then  
                if redNum >= 1 then
                    if redNum == 1 and self.packHaveThing then
                        btn:GetChild("n7").visible = false
                    else
                        btn:GetChild("n7").visible = true
                    end
                end
            end
        else
            if redNum > 0 then
                btn:GetChild("n7").visible = true
            else
                btn:GetChild("n7").visible = false
            end
        end
    end
end
--取出物品之后
function XunBaoView:refreshLimitWare()
    if self.controller1.selectedIndex == 0 then
        self.equipMany:refreshLimitWareRed()
        self.packHaveThing = self.equipMany:getPackHaveThing()
    elseif self.controller1.selectedIndex == 1 then
        self.petXunBao:refreshLimitWareRed()
        self.packHaveThing = self.petXunBao:getPackHaveThing()
    elseif self.controller1.selectedIndex == 3 then
        self.shenQiMany:refreshLimitWareRed()
        self.packHaveThing = self.shenQiMany:getPackHaveThing()
    elseif self.controller1.selectedIndex == 4 then
        self.jianLingXunBao:refreshLimitWareRed()
        self.packHaveThing = self.jianLingXunBao:getPackHaveThing()
    end
end
function XunBaoView:onClickRule()
    local index = self.controller1.selectedIndex
    if index == 2 then
        GOpenRuleView(1084)--符文寻宝规则
    elseif index == 4 then--剑灵寻宝
        GOpenRuleView(1068)
    else 
        GOpenRuleView(1068)
    end
end

function XunBaoView:onClickClose()
    self:closeView()
end

return XunBaoView

