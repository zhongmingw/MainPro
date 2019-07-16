--
-- Author: ohf
-- Date: 2017-02-15 10:20:06
--
--装备tips 装备对比
local EquipTipsView = class("EquipTipsView", base.BaseView)

local heightList = {{50,70},{91,113},{132,152}}--frame1和frame对应高度情况{{白底,蓝底}}

function EquipTipsView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
    self.isBlack = true
end

function EquipTipsView:initView()
    self.dianImg = mgr.TextMgr:getImg(UIItemRes.dian01)--属性点
    self.panelObj1 = self.view:GetChild("n0")
    self.panelObj1.visible = false
    self.panelObj2 = self.view:GetChild("n1")
    self.panelObj2.visible = false
    self:initPanel1()
    self:initPanel2()
    self.moneyText1 = self.panelObj1:GetChild("n55")--仙盟仓库令
    self.moneyIcon1 = self.panelObj1:GetChild("n56")--仙盟仓库令icon
    self.moneyText2 = self.panelObj2:GetChild("n63")--仙盟仓库令
    self.moneyIcon2 = self.panelObj2:GetChild("n64")--仙盟仓库令icon
    local c1 = self.panelObj1:GetController("c1")
    c1.selectedIndex = 1
    local c1 = self.panelObj2:GetController("c1")
    c1.selectedIndex = 1
    self.blackView.onClick:Add(self.onClickClose,self)

    self.leftpanel = self.view:GetChild("n0")
    self.oldxy = self.leftpanel.xy
    self.rightpanel = self.view:GetChild("n1")
     self.leftxy = {
        self.leftpanel:GetChild("n44").xy,
        self.leftpanel:GetChild("n48").xy,
        self.leftpanel:GetChild("n45").xy,
    }
    self.rightxy = {
        self.rightpanel:GetChild("n50").xy,
        self.rightpanel:GetChild("n56").xy,
        self.rightpanel:GetChild("n51").xy,
    }
end

function EquipTipsView:initData()
    -- body
    self.leftpanel:GetChild("n44").xy = self.leftxy[1]
    self.leftpanel:GetChild("n48").xy = self.leftxy[2]
    self.leftpanel:GetChild("n45").xy = self.leftxy[3]

    self.rightpanel:GetChild("n50").xy = self.rightxy[1]
    self.rightpanel:GetChild("n56").xy = self.rightxy[2]
    self.rightpanel:GetChild("n51").xy = self.rightxy[3]
end

function EquipTipsView:setData(data,isSelect,isNotDz)
    self:clear()
    self.mForgData2 = nil
    self.isSelect = isSelect
    self.mData = data
    local realMid = conf.ItemConf:getRealMid(data.mid) or 0
    local starCount = conf.ItemConf:getEquipStar(data.mid) or 0
    if starCount > 0 and realMid > 0 then--如果是假显示的道具
         self.mData.mid = realMid
    end
    local svrId = data.svrId or 0
    self.roleId = data.roleId or 0
    local part = conf.ItemConf:getPart(data.mid)
    --是否显示锻造信息
    self.isNotDz = isNotDz
    if isNotDz then--不显示锻造信息就简单设置一下属性
        self:setForgData()
    else
        if self.isSelect and (tostring(cache.PlayerCache:getRoleId()) ~= tostring(data.roleId) or svrId ~= cache.PlayerCache:getServerId()) then
            -- plog(1100101,part,svrId)
            proxy.ForgingProxy:send(1100101, {part = part,roleId = data.roleId,svrId = svrId})--别人的鍛造部位信息
            return
        end
        local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
        if view and view.controllerC1.selectedIndex == 0 then
            if view.data then
                proxy.ForgingProxy:send(1100101, {part = part,roleId = view.data.roleId,svrId = view.data.svrId})--别人的鍛造部位信息
            end
        else
            proxy.ForgingProxy:send(1100101, {part = part,roleId = 0,svrId = 0})--鍛造部位信息
        end
    end
end

function EquipTipsView:setForgPlayer(data)
    self.mForgData2 = data and data[1]
end

function EquipTipsView:setForgData()
    local part = conf.ItemConf:getPart(self.mData.mid)
    self.mForgData = cache.PackCache:getForgData(part)
    self:setDismantle()
    self:setBtnVisible()
    local callback = function()
        local equipData = cache.PackCache:getEquipDataByPart(part)
        if equipData and equipData.amount > 0 then--同部位有穿戴打开对比
            self.equipData = equipData
            self.panelObj2.visible = true
            self:addItem2()
            self:setPanel2Data()
            self.panelObj1.x = self.panelObj2.x - 408
            self.frame3.visible = false
            self.frame4.visible = false
            self.useBtn2.visible = false
            self.devourBtn2.visible = false
            self.discardBtn2.visible = false
        else--否则只打开tip
            self.equipData = self.mData
            self.useBtn.data = 2
            self.panelObj1:Center()
            self.panelObj1.y = self.panelObj2.y
            self.discardBtn.visible = false
        end
        self.panelObj1.visible = true
        self:addItem1()

        self:setPanel1Data()
    end
    local index = self.mData.index
    if not index or index == 0 then--非缓存装备
        callback()
        return
    end
    local packIndex = mgr.ItemMgr:getPackIndex()
    if self:getPlayerEq() then
        if tostring(cache.PlayerCache:getRoleId()) == tostring(self.roleId) and mgr.ItemMgr:isEquipItem(index) then--点击是自己的装备
            self.equipData = self.mData
            self.useBtn.data = 2
            self.panelObj1:Center()
            self.panelObj1.y = self.panelObj2.y
            self.discardBtn.visible = false
            self.panelObj1.visible = true
            self:addItem1()
            self:setPanel1Data()
        else
            callback()
        end
        return
    else
        self.frame3.visible = true
        self.frame4.visible = true
        self.useBtn2.visible = true
        if packIndex ~= Pack.wareIndex and packIndex ~= Pack.gangWareIndex then--不是仓库的时候
            self.devourBtn2.visible = true
            self.discardBtn2.visible = true
        end
    end
    if mgr.ItemMgr:isEquipItem(index) then--已穿戴的装备
        self.panelObj1.visible = true
        self.equipData = self.mData
        self:addItem1()
        self.useBtn.data = 2
        self.panelObj1:Center()
        self.panelObj1.y = self.panelObj2.y
        self:setPanel1Data()
        self.discardBtn.visible = false
    elseif mgr.ItemMgr:isPackItem(index) or mgr.ItemMgr:isWareItem(index) or mgr.ItemMgr:isGangWareItem(index) then--背包的装备
        if packIndex == Pack.splitIndex then--个人分解
            self.useBtn.data = 3
            self.useBtn2.data = 3
        elseif packIndex == Pack.gangWareIndex then--仙盟仓库
            self.useBtn.visible = false
            self.useBtn2.visible = false
        else
            self.useBtn.data = 1
            self.useBtn2.data = 1
        end
        local equipData = cache.PackCache:getEquipDataByPart(part)
        if equipData and equipData.amount > 0 then--同部位有穿戴打开对比
            self.equipData = equipData
            self.panelObj2.visible = true
            self:addItem2()
            self:setPanel2Data()
            self.panelObj1.x = self.panelObj2.x - 408
            if packIndex ~= Pack.gangWareIndex then
                local isNotDiscard = conf.ItemConf:getIsNotDiscard(self.mData.mid)
                if isNotDiscard == 1 then--是否要丢弃按钮
                    self.discardBtn2.visible = false
                    --self.frame3.height = heightList[2][1]
                    self.frame4.height = heightList[2][2]
                else
                    --self.frame3.height = heightList[3][1]
                    self.frame4.height = heightList[3][2]
                    self.discardBtn2.visible = true
                end
            end
        else--否则只打开tip
            self.equipData = self.mData
            self.panelObj1:Center()
            self.panelObj1.y = self.panelObj2.y
            if packIndex ~= Pack.gangWareIndex then
                local isNotDiscard = conf.ItemConf:getIsNotDiscard(self.equipData.mid)
                if isNotDiscard == 1 then--是否要丢弃按钮
                    --self.frame1.height = heightList[2][1]
                    self.frame2.height = heightList[2][2]
                    self.discardBtn.visible = false
                else
                    --self.frame1.height = heightList[3][1]
                    self.frame2.height = heightList[3][2]
                    self.discardBtn.visible = true
                end
            end
        end
        self.panelObj1.visible = true
        self:addItem1()
        self:setPanel1Data()
    end
end
--拆解
function EquipTipsView:setDismantle()
    local mid = self.mData.mid
    local color = conf.ItemConf:getQuality(mid)
    if color == 7 then
        self.devourBtn.title = language.pack45
        self.devourBtn2.title = language.pack45
    else
        self.devourBtn.title = language.pack30
        self.devourBtn2.title = language.pack30
    end
end

function EquipTipsView:addItem1()
    -- self.equipStarItem1 = self.attListView1:AddItemFromPool(UIPackage.GetItemURL("alert" , "equipStarItem"))
    local mid = self.equipData.mid
    local skillId = conf.ItemConf:getSkillAffectId(mid)
    if skillId then
        local url = UIPackage.GetItemURL("alert" , "skillAttiItem")
        self.skillAttiItem1 = self.attListView1:AddItemFromPool(url)
    end
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    self.baseAttiItem1 = self.attListView1:AddItemFromPool(url)
    local birthBaseAtt = conf.ItemConf:getBaseBirthAtt(mid)
    local birthAtt = conf.ItemConf:getBirthAtt(mid)
    local colorAttris = self.equipData.colorAttris
    if colorAttris and #colorAttris > 0 or birthAtt or birthBaseAtt then
        self.birthAttiItem1 = self.attListView1:AddItemFromPool(url)
    end
    if not self.isNotDz then
        self.strengAttiItem1 = self.attListView1:AddItemFromPool(url)
        self.starAttiItem1 = self.attListView1:AddItemFromPool(url)
        self.gemItem1 = self.attListView1:AddItemFromPool(url)
    end
    self.attListView1:ScrollToView(0)
end

function EquipTipsView:addItem2()
    -- self.equipStarItem2 = self.attListView2:AddItemFromPool(UIPackage.GetItemURL("alert" , "equipStarItem"))
    local mid = self.mData.mid
    local skillId = conf.ItemConf:getSkillAffectId(mid)
    if skillId then
        local url = UIPackage.GetItemURL("alert" , "skillAttiItem")
        self.skillAttiItem2 = self.attListView2:AddItemFromPool(url)
    end
    local url = UIPackage.GetItemURL("alert" , "baseAttiItem")
    self.baseAttiItem2 = self.attListView2:AddItemFromPool(url)
    local birthBaseAtt = conf.ItemConf:getBaseBirthAtt(mid)
    local birthAtt = conf.ItemConf:getBirthAtt(mid)
    local colorAttris = self.mData.colorAttris
    if colorAttris and #colorAttris > 0 or birthAtt or birthBaseAtt then
        self.birthAttiItem2 = self.attListView2:AddItemFromPool(url)
    end
    if not self.isNotDz then
        self.strengAttiItem2 = self.attListView2:AddItemFromPool(url)
        self.starAttiItem2 = self.attListView2:AddItemFromPool(url)
        self.gemItem2 = self.attListView2:AddItemFromPool(url)
    end
    self.attListView2:ScrollToView(0)
end
--装备tips
function EquipTipsView:initPanel1()
    self.itemObj1 = self.panelObj1:GetChild("n19")
    self.itemObj1.visible = false
    self.itemName1 = self.panelObj1:GetChild("n24")
    self.itemName1.text = ""
    self.itemDesc1 = self.panelObj1:GetChild("n25")--item备述
    self.itemDesc1.text = ""
    self.bind1 = self.panelObj1:GetChild("n26")
    self.equipDesc1 = self.panelObj1:GetChild("n27")--几阶装备
    self.equipDesc1.text = string.format(language.equip01,0)
    self.xqLev1 = self.panelObj1:GetChild("n28")--需求几级
    self.xqLev1.text = string.format(language.gonggong12,0)
    self.power1 = self.panelObj1:GetChild("n18")--战斗力
    self.power1.text = 0
    self.synScoreText1 = self.panelObj1:GetChild("n54")--综合战斗力
    self.synScoreText1.text = 0
    self.alreayEq1 = self.panelObj1:GetChild("n4")--是否已装备
    self.attListView1 = self.panelObj1:GetChild("n41")
    self.useBtn = self.panelObj1:GetChild("n44")
    self.useBtn.onClick:Add(self.onClickUse,self)
    self.useText = self.useBtn:GetChild("title")
    self.devourBtn = self.panelObj1:GetChild("n48")--吞噬
    -- self.devourBtn.title = language.pack30
    self.devourBtn.onClick:Add(self.onClickDevour,self)
    self.discardBtn = self.panelObj1:GetChild("n45")
    self.discardBtn.onClick:Add(self.onClickDiscard,self)
    self.listView1 = self.panelObj1:GetChild("n47")
    if g_ios_test then   --EVE 屏蔽物品获得途径
        self.listView1.visible = false
    end
    self.listView1.itemRenderer = function(index,obj)
        self:cellData1(index, obj)
    end
    self.colorText1 = self.panelObj1:GetChild("n49")
    self.eqLvText1 = self.panelObj1:GetChild("n50")
    self.frame1 = self.panelObj1:GetChild("n43")--左白小面板
    self.frame2 = self.panelObj1:GetChild("n42")--左蓝小面板
end
--左面板操作按钮隐藏
function EquipTipsView:setFrameVisible1()
    self.frame1.visible = false
    self.frame2.visible = false
    self.useBtn.visible = false
    self.devourBtn.visible = false
    self.discardBtn.visible = false
end
--根据条件隐藏按钮
function EquipTipsView:setBtnVisible()
    self:setFrameVisible1()
    self.useBtn2.title = language.pack05
    self.discardBtn2.visible = false
    self.devourBtn.y = self.useBtn.y + 41
    self.discardBtn.y = self.useBtn.y + 82
    local lintongEnabled = mgr.ModuleMgr:CheckView(1088)
    self.devourBtn.enabled = lintongEnabled
    self.devourBtn2.enabled = lintongEnabled
    -- self.devourBtn.title = language.pack30
    -- self.devourBtn2.title = language.pack30
    self.moneyText1.visible = false
    self.moneyIcon1.visible = false
    self.moneyText2.visible = false
    self.moneyIcon2.visible = false
    local index = self.mData.index
    if not index then
        return
    end
    local isPack = false
    if mgr.ItemMgr:isPackItem(index) then
        isPack = true
    end
    local packIndex = mgr.ItemMgr:getPackIndex()
    if packIndex == Pack.wareIndex then--仓库
        self:setWareBtn(isPack)
    elseif packIndex == Pack.shopIndex then--随身商店时候
        self:setShopBtn(isPack)
    elseif packIndex == Pack.equipIndex then--装备穿戴时候
        self:setWearEquipBtn(isPack)
    elseif packIndex == Pack.splitIndex then--分解区域时候
        self:setSplitBtn(isPack)
    elseif packIndex == Pack.gangWareIndex then--仙盟仓库的时候
        self:setGangWareBtn(isPack)
    elseif packIndex == Pack.shengXiao then -- 生肖

    end
end
--个人仓库
function EquipTipsView:setWareBtn(isPack)
    self.frame1.visible = true
    self.frame2.visible = true
    self.useBtn.visible = true
    if isPack then
        --self.frame1.height = heightList[3][1]--改变frame大小
        self.frame2.height = heightList[3][2]
        --self.frame3.height = heightList[3][1]--改变frame大小
        self.frame4.height = heightList[3][2]
        self.devourBtn.visible = true
        self.devourBtn2.visible = true
        self.discardBtn.visible = true
        self.discardBtn2.visible = true
        self.useText.text = language.pack06
        self.useBtn2.title = language.pack06
    else
        --self.frame1.height = heightList[1][1]--改变frame大小
        self.frame2.height = heightList[1][2]
        --self.frame3.height = heightList[1][1]--改变frame大小
        self.frame4.height = heightList[1][2]
        self.useText.text = language.pack07
        self.useBtn2.title = language.pack07
        self.devourBtn2.visible = false
    end
end
--随时商店的时候
function EquipTipsView:setShopBtn(isPack)
    self.frame1.visible = true
    self.frame2.visible = true
    self.discardBtn.visible = true
    if isPack then
        self.devourBtn.visible = true
        self.devourBtn.y = self.useBtn.y
        self.discardBtn.y = self.useBtn.y + 41
        --self.frame1.height = heightList[2][1]
        self.frame2.height = heightList[2][2]
    else
        self.devourBtn.visible = false
        self.discardBtn.y = self.useBtn.y
        --self.frame1.height = heightList[1][1]--改变frame大小
        self.frame2.height = heightList[1][2]
    end
end
--装备穿戴时候
function EquipTipsView:setWearEquipBtn(isPack)
    self.frame1.visible = true
    self.frame2.visible = true
    self.useBtn.visible = true
    if isPack then
        self.useText.text = language.pack01
        self.devourBtn.visible = true
        self.discardBtn.visible = true
        --self.frame1.height = heightList[3][1]--改变frame大小
        self.frame2.height = heightList[3][2]
    else
        self:setFrameVisible1()--屏蔽装备的脱下功能：只可替换
        -- self.useText.text = language.pack02
        -- self.frame1.height = heightList[1][1]--改变frame大小
        -- self.frame2.height = heightList[1][2]
    end
end
--分解区域的时候
function EquipTipsView:setSplitBtn(isPack)
    self.frame1.visible = true
    self.frame2.visible = true
    self.useBtn.visible = true
    self.useText.text = language.pack06
    self.useBtn2.title = language.pack06
    self.devourBtn.visible = true
    self.discardBtn.visible = true
    --self.frame1.height = heightList[3][1]--改变frame大小
    self.frame2.height = heightList[3][2]
end
--仙盟仓库的时候
function EquipTipsView:setGangWareBtn(isPack)
    if mgr.ViewMgr:get(ViewName.PlChooseView) then
        return
    end
    --显示钱
    self.moneyText1.visible = true
    self.moneyIcon1.visible = true
    self.moneyText2.visible = true
    self.moneyIcon2.visible = true
    --显示面板
    self.frame1.visible = true
    self.frame2.visible = true
    self.useBtn.visible = false
    self.useBtn2.visible = false
    self.devourBtn.visible = true
    self.devourBtn2.visible = true

    self.devourBtn.enabled = true
    self.devourBtn2.enabled = true
    if isPack then
        --self.frame1.height = heightList[2][1]--改变frame大小
        self.frame2.height = heightList[2][2]
        --self.frame3.height = heightList[2][1]--改变frame大小
        self.frame4.height = heightList[2][2]
        self.discardBtn.visible = false
        self.discardBtn2.visible = false
        self.devourBtn.title = language.pack06
        self.devourBtn2.title = language.pack06
    else
        local gangJob = cache.PlayerCache:getGangJob()
        self.devourBtn.title = language.pack07
        self.devourBtn2.title = language.pack07
        if gangJob == 4 or gangJob == 3 or gangJob == 2 then--盟主和副盟主的时候
            --self.frame1.height = heightList[3][1]--改变frame大小
            self.frame2.height = heightList[3][2]
            --self.frame3.height = heightList[3][1]--改变frame大小
            self.frame4.height = heightList[3][2]
            self.discardBtn.visible = true
            self.discardBtn2.visible = true
            self.discardBtn.title = language.pack40
            self.discardBtn2.title = language.pack40
        else
            self.discardBtn.visible = false
            self.discardBtn2.visible = false
            --self.frame1.height = heightList[2][1]--改变frame大小
            self.frame2.height = heightList[2][2]
            --self.frame3.height = heightList[2][1]--改变frame大小
            self.frame4.height = heightList[2][2]
        end
    end
end
--装备对比
function EquipTipsView:initPanel2()
    self.itemObj2 = self.panelObj2:GetChild("n19")
    self.itemObj2.visible = false
    self.itemName2 = self.panelObj2:GetChild("n24")
    self.itemName2.text = ""
    self.itemDesc2 = self.panelObj2:GetChild("n25")--item备述
    self.itemDesc2.text = ""
    self.bind2 = self.panelObj2:GetChild("n26")
    self.equipDesc2 = self.panelObj2:GetChild("n27")--几阶装备
    self.equipDesc2.text = string.format(language.equip01,0)
    self.xqLev2 = self.panelObj2:GetChild("n28")--需求几级
    self.xqLev2.text = string.format(language.gonggong12,0)
    self.power2 = self.panelObj2:GetChild("n18")--战斗力
    self.power2.text = 0
    self.synScoreText2 = self.panelObj2:GetChild("n62")--综合战斗力
    self.synScoreText2.text = 0
    self.alreayEq2 = self.panelObj2:GetChild("n4")--是否已装备
    self.alreayEq2.visible = false
    self.attListView2 = self.panelObj2:GetChild("n47")
    self.useBtn2 = self.panelObj2:GetChild("n50")--更换
    self.useBtn2.onClick:Add(self.onClickUse2,self)
    self.devourBtn2 = self.panelObj2:GetChild("n56")--吞噬按钮
    -- self.devourBtn2.title = language.pack30
    self.devourBtn2.onClick:Add(self.onClickDevour2,self)
    self.discardBtn2 = self.panelObj2:GetChild("n51")
    self.discardBtn2.onClick:Add(self.onClickDiscard2,self)
    self.listView2 = self.panelObj2:GetChild("n55")
    if g_ios_test then     --EVE 屏蔽物品获得途径
        self.listView2.visible = false
    end
    self.listView2.itemRenderer = function(index,obj)
        self:cellData2(index, obj)
    end
    self.colorText2 = self.panelObj2:GetChild("n58")
    self.eqLvText2 = self.panelObj2:GetChild("n57")
    self.frame3 = self.panelObj2:GetChild("n49")--右白小面板
    self.frame4 = self.panelObj2:GetChild("n48")--右蓝小面板
end
--路径描述
function EquipTipsView:cellData1(index,obj)
    self:setCellData(self.formview1[index + 1],obj)
end

function EquipTipsView:cellData2(index,obj)
    self:setCellData(self.formview2[index + 1],obj)
end

function EquipTipsView:setCellData(moduleData,obj)
    local id = moduleData and moduleData[1]
    local childIndex = moduleData and moduleData[2]
    local data = conf.SysConf:getModuleById(id)
    local lab = obj:GetChild("n1")
    lab.text = data.desc
    local btn = obj:GetChild("n0")
    if g_ios_test then
        btn.visible = false
    else
        btn.visible = true
    end
    btn.data = {id = id,childIndex = childIndex}
    btn.onClick:Add(self.onBtnGo,self)
end
--路径跳转
function EquipTipsView:onBtnGo(context)
    -- body
    local data = context.sender.data
    local param = {id = data.id,childIndex = data.childIndex}
    GOpenView(param)
end
--激活技能
function EquipTipsView:setSkillData(cell,type)
    local mid = self.equipData.mid
    if type == 2 then
        mid = self.mData.mid
    end
    local skillAffectId = conf.ItemConf:getSkillAffectId(mid)
    local skillId = math.floor(skillAffectId / 1000)
    local icon = conf.SkillConf:getSkillIcon(skillId)
    cell:GetChild("n10").url = ResPath.iconRes(icon)
    local confData = conf.SkillConf:getSkillByIndex(skillAffectId)
    cell:GetChild("n8").text = confData and confData.name or ""
    cell:GetChild("n1").text = confData and confData.dec or ""
    cell:GetChild("n0").text = language.equip02[7]
end
--装备星级
function EquipTipsView:setStarData(cell,type)
    local forgData = self:getForgData(type)
    local starlv1 = GGetStarLev(forgData.starLev)[1]--阶数
    local starlv2 = GGetStarLev(forgData.starLev)[2]--星数
    for i=1,10 do
        local num = 80 + i
        local star = cell:GetChild("n"..num)
        local starImg = star:GetChild("n0")
        starImg.url = UIItemRes.star01[starlv1]
        if starlv2 >= i then
            starImg.grayed = false
        else
            starImg.grayed = true
        end
    end
    cell:GetChild("n11").text = language.equip02[1]
end
--基础属性--只显示3个
function EquipTipsView:setAttiData(cell,type)
    local mid = self.equipData.mid
    if type == 2 then
        mid = self.mData.mid
    end
    local dian = self.dianImg--点
    local attiData = conf.ItemArriConf:getItemAtt(mid)
    local num = 0
    local t = GConfDataSort(attiData)
    local str = ""
    local text = ""
    local score = 0--基础评分
    for k,v in pairs(t) do
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..v[2]
        if k ~= #t then
            str1 = str1.."\n"
            text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])--计算综合战斗力
    end
    if type == 1 then--小面板
        self.baseScore1 = score
    else
        self.baseScore2 = score
    end
    cell:GetChild("n8").text = str
    local attiText = cell:GetChild("n1")
    attiText.visible = false--右边的属性不用显示
    attiText.text = str
    cell:GetChild("n0").text = language.equip02[3]
end
--极品属性
function EquipTipsView:setBirthAttiData(cell,type,quality)
    local data = {}
    if type == 1 then
        data = self.equipData
    else
        data = self.mData
    end
    local synScore = 0--综合战斗力
    local attiCallback = function(id,value,isTuijian)--属性解析
        local attiData = conf.ItemConf:getEquipColorAttri(id)
        local color = attiData and attiData.color or 1
        local attType = attiData and attiData.att_type or 0
        local name = conf.RedPointConf:getProName(attType)
        local maxColor = conf.ItemConf:getEquipColorGlobal("max_color")
        local attiValue = "+"..GProPrecnt(attType,value)
        if color >= maxColor then--是否是最高品质
            local attiRange = attiData.att_range or {}
            local maxValue = attiRange[#attiRange] and attiRange[#attiRange][2]
            if maxValue and value >= maxValue then
                local str = quality == 7 and "" or language.pack41
                attiValue = attiValue..str--获得了最佳的极品属性
            end
        end
        local str = ""
        local atti = 0
        if isTuijian then
            str = language.equip08.." "..name..attiValue
        else
            str = name..attiValue
        end
        local dian = self.dianImg

        return dian.." "..mgr.TextMgr:getQualityAtti(str,color)
    end

    local title = cell:GetChild("n0")--标题
    local str = ""
    local text = ""
    local colorAttris = data.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        title.text = language.equip02[2]
        --极品属性颜色排序
        local attData = clone(colorAttris)
        for k,v in pairs(attData) do
            local attiData = conf.ItemConf:getEquipColorAttri(v.type)
            local color = attiData and attiData.color or 1
            v.color = color
        end
        table.sort( attData,function (a,b)
            if a.color ~= b.color then
                return a.color > b.color
            end
        end )
        for k,v in pairs(attData) do
            local str1 = attiCallback(v.type,v.value)
            local text1 = ""
            if k~= #data.colorAttris then
                str1 = str1.."\n"
                text1 = text1.." ".."\n"
            end
            str = str..str1
            text = text..text1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(data.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(data.mid) or {}
            title.text = language.equip02[2]
        else
            title.text = language.equip02[2]..string.format(language.equip07, #birthAtt / 2)
        end
        local birthCloneAtt = clone(birthAtt)
        local _t = {}
        --将原来的一维数组改成{{type,value}}格式
        for i=1,#birthCloneAtt/2 do
            local tab = {}
            tab.type = birthCloneAtt[2*i-1]
            tab.value = birthCloneAtt[2*i]
            table.insert(_t, tab)
        end
        --添加颜色，并排序
        for k,v in pairs(_t) do
            local attiData = conf.ItemConf:getEquipColorAttri(v.type)
            local color = attiData and attiData.color or 1
            v.color = color
        end
        table.sort( _t,function (a,b)
            if a.color ~= b.color then
                return a.color > b.color
            end
        end )
        --排好序的极品属性 还原为一维数组
        local birtyAttSort = {}
        for k,v in pairs(_t) do
            table.insert(birtyAttSort,v.type)
            table.insert(birtyAttSort,v.value)
        end
        for k,v in pairs(birtyAttSort) do
            if k % 2 == 0 then--值
                local type,value = birtyAttSort[k - 1],birtyAttSort[k]
                local str1 = attiCallback(type,value,isTuijian)
                local text1 = ""
                if k ~= #birtyAttSort then
                    str1 = str1.."\n"
                    text1 = text1.." ".."\n"
                end
                str = str..str1
                text = text..text1
                if not isTuijian then--如果是固定生成的
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    if type == 1 then--计算综合战斗力
        self.synScore1 = synScore--左面板
    else
        self.synScore2 = synScore--右面板
    end
    local attiText = cell:GetChild("n1")
    attiText.text = str
    attiText.visible = false
    cell:GetChild("n8").text = str
end
--强化属性--只显示1个
function EquipTipsView:setStrenData(cell,type)
    local forgData = self:getForgData(type)
    local data = conf.ForgingConf:getStrenAttData(forgData.strenLev,forgData.part)
    local str = ""
    if data then
        local t = GConfDataSort(data)
        for k,v in pairs(t) do
            local str1 = ""
            if v[2] > 0 then
                str1 = conf.RedPointConf:getProName(v[1]).."+"..v[2]
            end
            local text = conf.RedPointConf:getProName(v[1]).."+"..v[2]
            if k ~= #t then
                str1 = str1.."\n"
            end
            str = str..str1
        end
    end
    local attiText = cell:GetChild("n1")
    if string.trim(str) == "" then
        str = language.equip03
        attiText.visible = false
    else
        attiText.visible = true
    end
    attiText.text = str
    local dian = self.dianImg--点
    cell:GetChild("n8").text = dian.." "..string.format(language.equip03, forgData.strenLev)
    cell:GetChild("n0").text = language.equip02[4]
end
--升星属性
function EquipTipsView:setStarLevData(cell,type)
    local forgData = self:getForgData(type)
    local data = conf.ForgingConf:getStarData(forgData.part,forgData.starLev)
    local num = 0
    local str = ""
    local title = self.dianImg.." "..string.format(language.equip04, forgData.starLev)
    if data then
        local t = GConfDataSort(data)
        for k,v in pairs(t) do
            local str1 = ""
            if v[2] > 0 then
                str1 = conf.RedPointConf:getProName(v[1]).."+"..v[2]
            end
            local text = conf.RedPointConf:getProName(v[1]).."+"..v[2]
            if k ~= #t then
                str1 = str1.."\n"
            end
            str = str..str1
            if k ~= 1 then
                title = title.." \n"
            end
        end
    end
    local attiText = cell:GetChild("n1")
    if string.trim(str) == "" then
        str = language.equip03
        attiText.visible = false
    else
        attiText.visible = true
    end
    attiText.text = str
    cell:GetChild("n8").text = title
    cell:GetChild("n0").text = language.equip02[5]
end
--宝石镶嵌
function EquipTipsView:setCameoData(cell,type)
    local forgData = self:getForgData(type)
    local gemName = ""
    local str = ""
    local dian = self.dianImg--点
    for i,mid in pairs(forgData.gemMap) do
        if mid > 0 then
            local attiData = conf.ItemArriConf:getItemAtt(mid)
            for k,v in pairs(attiData) do
                if string.find(k,"att_") then
                    local strList = string.split(k,'_')
                    local name = dian.." "..conf.ItemConf:getName(mid)
                    local str2 = conf.RedPointConf:getProName(strList[1]).."+"..v
                    local text = mgr.TextMgr:getTextColorStr(str2, 7)
                    if i ~= #forgData.gemMap then
                        text = text.."\n"
                        name = name.."\n"
                    end
                    str = str..text
                    gemName = gemName..name
                end
            end
        else
            local text = "  "
            local name = dian.." "..language.equip05
            if i ~= #forgData.gemMap then
                text = text.."\n"
                name = name.."\n"
            end
            str = str..text
            gemName = gemName..name
        end
    end
    cell:GetChild("n8").text = gemName
    cell:GetChild("n1").text = str
    cell:GetChild("n0").text = language.equip02[6]
end
--装备panel
function EquipTipsView:setPanel1Data()
    local mid = self.equipData.mid
    self.itemObj1.visible = true
    local data = clone(self.equipData)
    data.isquan = true
    GSetItemData(self.itemObj1, data)
    local color = conf.ItemConf:getQuality(mid)
    local name = conf.ItemConf:getName(mid)
    self.itemName1.text = mgr.TextMgr:getQualityStr1(name,color)
    local part = conf.ItemConf:getPart(mid)
    self.itemDesc1.text = language.equip06[part]
    local bind = self.equipData and self.equipData.bind or 0
    if bind > 0 then
        self.bind1.visible = true
    else
        self.bind1.visible = false
    end
    local forgData = self.mForgData2 or self.mForgData
    local stageLvl = conf.ItemConf:getStagelvl(mid)
    self.equipDesc1.text = string.format(language.equip01,stageLvl)
    self.xqLev1.text = string.format(language.gonggong12,forgData.starLev)
    if self:getPlayerEq() then--查看是别人装备没有对比的时候
        local part = conf.ItemConf:getPart(self.mData.mid)
        local equipData = cache.PackCache:getEquipDataByPart(part)
        if not equipData then
            self.alreayEq1.visible = false
        elseif self.equipData.index and mgr.ItemMgr:isEquipItem(self.equipData.index) then
            self.alreayEq1.visible = true
        end
    else
        if self.equipData.index and mgr.ItemMgr:isEquipItem(self.equipData.index) then
            self.alreayEq1.visible = true
        else
            self.alreayEq1.visible = false
        end
    end

    self.formview1 = conf.ItemConf:getFormview(mid)--跳转路径
    self.listView1.numItems = 0
    if self.formview1 then
        local len = #self.formview1
        self.listView1.numItems = len
        if len > 0 then
            self.listView1:ScrollToView(0)
        end
    end
    self.colorText1.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[color],color)
    local lvl = conf.ItemConf:getLvl(mid)
    self.eqLvText1.text = string.format(language.pack34, lvl)
    -- self:setStarData(self.equipStarItem1,1)--装备星级
    self.baseScore1 = 0--基础评分
    self.synScore1 = 0--综合评分
    self:setAttiData(self.baseAttiItem1,1)--基础属性
    self.power1.text = math.ceil(self.baseScore1)
    if self.skillAttiItem1 then
        self:setSkillData(self.skillAttiItem1,1)--极品属性
    end
    if self.birthAttiItem1 then
        self:setBirthAttiData(self.birthAttiItem1,1,color)--极品属性
    end
    self.synScoreText1.text = math.ceil(self.baseScore1 + self.synScore1)
    if not self.isNotDz then--没有屏蔽锻造属性的情况
        self:setStrenData(self.strengAttiItem1,1)--强化属性
        self:setStarLevData(self.starAttiItem1,1)--升星属性
        self:setCameoData(self.gemItem1,1)--宝石属性
    end
    local confData = conf.BangPaiConf:getStoreItem(mid)
    local ckl = confData and confData.store_gx or 0
    local moneyStr = ""
    if self.equipData.index then
        if mgr.ItemMgr:isGangWareItem(self.equipData.index) then
            local cklMoney = cache.PlayerCache:getTypeMoney(MoneyType.ckl)
            if cklMoney >= ckl then
                moneyStr = mgr.TextMgr:getTextColorStr(ckl, 7)
            else
                moneyStr = mgr.TextMgr:getTextColorStr(ckl, 14)
            end
        else
            moneyStr = mgr.TextMgr:getTextColorStr(ckl, 7)
        end
    end
    self.moneyText1.text = moneyStr
end
--对比panel
function EquipTipsView:setPanel2Data()
    local mid = self.mData.mid
    self.itemObj2.visible = true
    local data = clone(self.mData)
    data.isquan = true
    GSetItemData(self.itemObj2, data)
    local color = conf.ItemConf:getQuality(mid)
    local name = conf.ItemConf:getName(mid)
    self.itemName2.text = mgr.TextMgr:getQualityStr1(name,color)
    local part = conf.ItemConf:getPart(mid)
    self.itemDesc2.text = language.equip06[part]
    local bind = self.mData and self.mData.bind or 0
    if bind > 0 then
        self.bind2.visible = true
    else
        self.bind2.visible = false
    end
    local stageLvl = conf.ItemConf:getStagelvl(mid)
    self.equipDesc2.text = string.format(language.equip01,stageLvl)
    self.xqLev2.text = string.format(language.gonggong12,self.mForgData.starLev)
    self:setEquipContrast()
    self.formview2 = conf.ItemConf:getFormview(mid)--跳转路径
    self.listView2.numItems = 0
    if self.formview2 then
        local len = #self.formview2
        self.listView2.numItems = len
        if len > 0 then
            self.listView2:ScrollToView(0)
        end
    end
    if not self:getPlayerEq() and self.mData.index and mgr.ItemMgr:isEquipItem(self.mData.index) then
        self.alreayEq2.visible = true
    else
        self.alreayEq2.visible = false
    end
    self.colorText2.text = language.pack33..mgr.TextMgr:getQualityStr1(language.pack35[color],color)
    local lvl = conf.ItemConf:getLvl(mid)
    self.eqLvText2.text = string.format(language.pack34, lvl)
    -- self:setStarData(self.equipStarItem2,2)--装备星级
    self.baseScore2 = 0--基础评分
    self.synScore2 = 0--综合评分
    self:setAttiData(self.baseAttiItem2,2)--基础属性
    self.power2.text = math.ceil(self.baseScore2)--显示基础评分
    if self.skillAttiItem2 then
        self:setSkillData(self.skillAttiItem2,2)--激活技能
    end
    if self.birthAttiItem2 then
        self:setBirthAttiData(self.birthAttiItem2,2,color)--极品属性
    end
    self.synScoreText2.text = math.ceil(self.baseScore2 + self.synScore2)
    if not self.isNotDz then--没有屏蔽锻造属性的情况
        self:setStrenData(self.strengAttiItem2,2)--强化属性
        self:setStarLevData(self.starAttiItem2,2)--升星属性
        self:setCameoData(self.gemItem2,2)--宝石属性
    end
    local confData = conf.BangPaiConf:getStoreItem(mid)
    local ckl = confData and confData.store_gx or 0
    local moneyStr = ""
    if self.mData.index then
        if mgr.ItemMgr:isGangWareItem(self.mData.index) then
            local cklMoney = cache.PlayerCache:getTypeMoney(MoneyType.ckl)
            if cklMoney >= ckl then
                moneyStr = mgr.TextMgr:getTextColorStr(ckl, 7)
            else
                moneyStr = mgr.TextMgr:getTextColorStr(ckl, 14)
            end
        else
            moneyStr = mgr.TextMgr:getTextColorStr(ckl, 7)
        end
    end
    self.moneyText2.text = moneyStr
end
--装备对比基础属性
function EquipTipsView:setEquipContrast()
    local text1 = self.panelObj2:GetChild("n41")
    local text2 = self.panelObj2:GetChild("n42")
    local text3 = self.panelObj2:GetChild("n53")

    local text4 = self.panelObj2:GetChild("n43")
    local text5 = self.panelObj2:GetChild("n44")
    local text6 = self.panelObj2:GetChild("n54")

    local attiData1 = conf.ItemArriConf:getItemAtt(self.mData.mid)
    local attiData2 = conf.ItemArriConf:getItemAtt(self.equipData.mid)
    local num = 0
    local function getText(num)
        if num < 0 then
            return mgr.TextMgr:getTextColorStr(num, 14)
        elseif num > 0 then
            return mgr.TextMgr:getTextColorStr("+"..num, 7)
        else
            return ""
        end
    end
    local t = GConfDataSort(attiData1)
    for k,v in pairs(t) do
        num = num + 1
        local att2 = attiData2 and attiData2["att_"..v[1]] or 0
        if num == 1 then
            text1.text = conf.RedPointConf:getProName(v[1])
            text4.text = getText(v[2] - att2)
        elseif num == 2 then
            text2.text = conf.RedPointConf:getProName(v[1])
            text5.text = getText(v[2] - att2)
        elseif num == 3 then
            text3.text = conf.RedPointConf:getProName(v[1])
            text6.text = getText(v[2] - att2)
        end
    end
end
--穿脱
function EquipTipsView:onClickUse(context)
    local cell = context.sender
    local tag = cell.data
    local mId = self.equipData.mid
    local index = self.equipData.index
    local opType = 1
    if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then
        -- if conf.ItemConf:getQuality(mId) == 7 and conf.ItemConf:getType(mId) == Pack.equipType then--粉装不能放仓库
        --     GComAlter(language.pack46)
        -- else
            proxy.PackProxy:sendWareTake(self.equipData)
        -- end
    else
        if tag == 3 then--放入分解区域
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then
                view:setSplitItem(self.equipData)
            end
        else
            local toIndex = Pack.equip + conf.ItemConf:getPart(mId)
            local toIndexs = {}
            if tag == 1 then--穿戴
                opType = 0
                toIndexs = {toIndex}
            elseif tag == 2 then--脱落
                opType = 1
                toIndexs = {}
            end
            local params = {
                opType = opType,--脱
                indexs = {index},--装备的位置
                toIndexs = toIndexs,--目标位置
            }
            proxy.PackProxy:sendWearEquip(params)
        end
    end
    self:onClickClose()
end
--更换
function EquipTipsView:onClickUse2(context)
    local mId = self.mData.mid
    if mgr.ItemMgr:getPackIndex() == Pack.wareIndex then
        -- if conf.ItemConf:getQuality(mId) == 7 and conf.ItemConf:getType(mId) == Pack.equipType then--粉装不能放仓库
        --     GComAlter(language.pack46)
        -- else
            proxy.PackProxy:sendWareTake(self.mData)
        -- end
        self:onClickClose()
    else
        local cell = context.sender
        local tag = cell.data
        if tag == 3 then--放入分解区域
            local view = mgr.ViewMgr:get(ViewName.ForgingView)
            if view then
                view:setSplitItem(self.mData)
            end
        else
            local part = conf.ItemConf:getPart(mId)
            local callback = function( ... )
                local index = self.mData.index
                local toIndex = Pack.equip + part
                local params = {
                    opType = 0,--穿
                    indexs = {index},--背包的位置
                    toIndexs = {toIndex},--目标位置
                }
                self.wearPart = part
                proxy.PackProxy:sendWearEquip(params)
            end
            local awakenData = cache.PackCache:getSuitAwakenData(part)
            if awakenData and (awakenData.effectZxLev > 0 or awakenData.effectZsLev > 0) then--若该部位锻造了套装
                local color1 = 0
                local star1 = 0
                if awakenData.zxLev > 0 then--诛仙
                    color1 = conf.ForgingConf:getValue("equip_suit_zx_min_color")
                    star1 = conf.ForgingConf:getValue("equip_suit_zx_min_star")
                end
                if awakenData.zsLev > 0 then--诸神
                    color1 = conf.ForgingConf:getValue("equip_suit_zs_min_color")
                    star1 = conf.ForgingConf:getValue("equip_suit_zs_min_star")
                end
                local stage1 = conf.ItemConf:getStagelvl(self.equipData.mid)
                local color2 = conf.ItemConf:getQuality(self.mData.mid)
                local star2 = mgr.ItemMgr:getColorBNum(self.mData)
                local stage2 = conf.ItemConf:getStagelvl(self.mData.mid)
                local isCx = false--是否需要拆卸套装石
                local part = conf.ItemConf:getPart(self.equipData.mid)
                if part > 8 then--饰品
                    if color1 > color2 or star1 > star2 then
                        isCx = true
                    end
                else
                    if stage1 == stage2 then
                        if color1 > color2 or star1 > star2 then
                            isCx = true
                        end
                    else
                        isCx = true
                    end
                end
                if isCx then
                    local param = {type = 14,richtext = mgr.TextMgr:getTextByTable(language.forging67),sure = function()
                        callback()
                    end}
                    GComAlter(param)
                else
                    callback()
                end
            else
                callback()
            end
        end
    end
end
--要穿的位置
function EquipTipsView:getWearPart()
    return self.wearPart or 0
end
--已穿戴的装备丢弃--没用到
function EquipTipsView:onClickDiscard()
    if mgr.ItemMgr:isGangWareItem(self.equipData.index) then
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.bangpai150, 6),sure = function()
            proxy.BangPaiProxy:send1250305({index = self.equipData.index,amount = 1,reqType = 3},self.equipData)--销毁
            self:onClickClose()
        end}
        GComAlter(param)
        return
    end
    local cameo = self.equipData.cameo
    if cameo then--宝石
        proxy.ForgingProxy:send(1100104,{reqType = 2,part = self.mData.part,hole = self.mData.hole,itemId = 0})
        self:onClickClose()
    else
        --print("print onClickDiscard")
        mgr.ItemMgr:delete(self.mData.index,function()
            self:onClickClose()
        end)
    end
end
--背包装备丢弃
function EquipTipsView:onClickDiscard2()
    if mgr.ItemMgr:isGangWareItem(self.mData.index) then
        local param = {type = 2,richtext = mgr.TextMgr:getTextColorStr(language.bangpai150, 6),sure = function()
            proxy.BangPaiProxy:send1250305({index = self.mData.index,amount = 1,reqType = 3},self.mData)--销毁
            self:onClickClose()
        end}
        GComAlter(param)
        return
    end
    local cameo = self.mData.cameo
    if cameo then--宝石
        proxy.ForgingProxy:send(1100104,{reqType = 2,part = self.mData.part,hole = self.mData.hole,itemId = 0})
        self:onClickClose()
    else
        --print("print onClickDiscard2")
        mgr.ItemMgr:delete(self.mData.index,function()
            self:onClickClose()
        end)
    end
end
--
function EquipTipsView:onClickDevour()
    if mgr.ItemMgr:getPackIndex() == Pack.gangWareIndex then
        local index = self.equipData.index or 0
        if mgr.ItemMgr:isGangWareItem(index) then
            proxy.BangPaiProxy:send1250305({index = index,amount = 1,reqType = 2},self.equipData)--取出仙盟仓库
        else
            if mgr.ItemMgr:getColorBNum(self.equipData) < 1 then
                GComAlter(language.bangpai159)
                return
            end

            proxy.BangPaiProxy:send1250305({index = index,amount = 1,reqType = 1},self.equipData)--放入仙盟仓库
        end
        self:onClickClose()
        return
    end
    local mid = self.mData.mid
    local color = conf.ItemConf:getQuality(mid)
    if color == 7 then
        local index = self.equipData.index or 0
        local param = {}
        param.index = index
        param.reqType = 1
        proxy.ForgingProxy:send(1100402,param)
        self:onClickClose()
        return
    end
    GOpenView({id = 1088})--吞噬
end

--吞噬
function EquipTipsView:onClickDevour2()
    if mgr.ItemMgr:getPackIndex() == Pack.gangWareIndex then
        local index = self.mData.index or 0
        if mgr.ItemMgr:isGangWareItem(index) then
            proxy.BangPaiProxy:send1250305({index = index,amount = 1,reqType = 2},self.mData)--取出仙盟仓库
        else
            proxy.BangPaiProxy:send1250305({index = index,amount = 1,reqType = 1},self.mData)--放入仙盟仓库
        end
        self:onClickClose()
        return
    end
    local mid = self.mData.mid
    local color = conf.ItemConf:getQuality(mid)
    if color == 7 then
        local index = self.mData.index or 0
        local param = {}
        param.index = index
        param.reqType = 1

        proxy.ForgingProxy:send(1100402,param)
        self:onClickClose()
        return
    end
    GOpenView({id = 1088})
end
--清理
function EquipTipsView:clear()
    self.isSelect = nil
    self.mForgData2 = nil
    self.attListView1.numItems = 0
    self.attListView2.numItems = 0
    self.skillAttiItem1 = nil
    self.equipStarItem1 = nil
    self.baseAttiItem1 = nil
    self.birthAttiItem1 = nil
    self.strengAttiItem1 = nil
    self.starAttiItem1 = nil
    self.gemItem1 = nil
    self.skillAttiItem2 = nil
    self.equipStarItem2 = nil
    self.baseAttiItem2 = nil
    self.birthAttiItem2 = nil
    self.strengAttiItem2 = nil
    self.starAttiItem2 = nil
    self.gemItem2 = nil
    self.panelObj1.visible = false
    self.panelObj2.visible = false
    self.isNotDz = nil
end

function EquipTipsView:dispose(clear)
    self:clear()
    self.super.dispose(self,clear)
end
function EquipTipsView:onClickClose()
    self:closeView()
end
--查看别人的装备
function EquipTipsView:getPlayerEq()
    if self.isSelect then
        return true
    end
    local view = mgr.ViewMgr:get(ViewName.SeeOtherMsg)
    local playerEq = false--是不是点击了别人的装备
    if view and view.controllerC1.selectedIndex == 0 then
        playerEq = true
    end
    return playerEq
end
--返回对应的锻造信息
function EquipTipsView:getForgData(type)
    local forgData = self.mForgData
    if type == 2 then
        forgData = self.mForgData2 or self.mForgData
    end
    return forgData
end

return EquipTipsView