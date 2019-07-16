--
-- Author: 
-- Date: 2018-11-26 19:36:17
--
local table = table
local VALUE = {0,0,8,18,36,66,80,91,100}--拱形进度条value不固定
local DiHunPanel = class("DiHunPanel", import("game.base.Ref"))

local HunShiEffect = {
    [3] = 4020181,--蓝色
    [4] = 4020180,--紫
    [5] = 4020179,--橙
    [6] = 4020182,--红
}


function DiHunPanel:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n20")
    self:initView()
end

function DiHunPanel:initView()
    self.c1 = self.view:GetController("c1")

    self.listView = self.view:GetChild("n1")
    self.listView.itemRenderer = function(index,obj)
        self:cellData(index,obj)
    end
    self.listView:SetVirtual()
    self.listView.onClickItem:Add(self.onClickDiHun,self)

    --帝魂属性加成
    self.dhAttList = self.view:GetChild("n33")
    self.dhAttList.itemRenderer = function(index,obj)
        self:cellDhAttData(index, obj)
    end
    self.dhAttList:SetVirtual()
     --魂饰属性加成
    self.hsAttList = self.view:GetChild("n49")
    self.hsAttList.itemRenderer = function(index,obj)
        self:cellHsAttData(index, obj)
    end
    self.hsAttList:SetVirtual()
    --战力 
    self.powerTab = self.view:GetChild("n26")
    --帝魂技能
    self.diHunSkill = self.view:GetChild("n37")
    self.diHunSkill.onClick:Add(self.onClickSkillBtn,self)
    self.diHunSkillDec = self.view:GetChild("n38")

    self.futiBtn = self.view:GetChild("n18")
    local btn2 = self.view:GetChild("n20")
    self.futiBtn.onClick:Add(self.onClickCallBack,self)
    btn2.onClick:Add(self.onClickCallBack,self)


    self.bar = self.view:GetChild("n17"):GetChild("n8")
    self.bar.max = 100
    self.diHun = {}
    for i=1,8 do
        local btn = self.view:GetChild("n17"):GetChild("n"..(i+8))
        btn.data = i
        table.insert(self.diHun,btn)
        btn.onClick:Add(self.onBtnCallBack,self)
    end
    self.hintIcon = self.view:GetChild("n22")
    --碎片
    self.suiPianTxt = self.view:GetChild("n23")
    --魂饰
    self.hunShiList = {}
    for i=1,4 do
        local btn = self.view:GetChild("n41"):GetChild("n4"..(i+1))
        table.insert(self.hunShiList,btn)
        btn.onClick:Add(self.onClickHunShi,self)
    end
    --魂饰技能列表
    self.hunShiSkillList = self.view:GetChild("n39")
    self.hunShiSkillList.itemRenderer = function(index,obj)
        self:cellHunShiSkillData(index, obj)
    end
    self.hunShiSkillList.onClickItem:Add(self.onClickHunShiSkill,self)


    self.actBtn = self.view:GetChild("n47")
    self.actBtn.onClick:Add(self.onClickActBtn,self)

    self.modelPanel = self.view:GetChild("n40")
    self.diHunAttData = {}--帝魂属性
    self.hunShiAttData = {}--魂饰属性

    self.hintGroup = self.view:GetChild("n50")
    self.hunShiBtnRedImg = self.view:GetChild("n19"):GetChild("red")
end

function DiHunPanel:addMsgCallBack(data)
    if data then
        self.data = data
        -- printt("帝魂",data)
        self.infos = data.infos
        self:refreshRed()

        self.listView.numItems = #self.infos
        if not self.selectType then
            self.selectType = 0
        end
        local isFind = false
        for k = 1,self.listView.numItems do
            local cell = self.listView:GetChildAt(k - 1)
            if cell then
                if cell.data == self.selectType then
                    cell.onClick:Call()
                    isFind =true
                    break
                end
            end
        end
        if not isFind then
            if self.listView.numItems > 0 then
                local cell = self.listView:GetChildAt(0)
                if cell then
                    cell.onClick:Call()
                end
            end
        end
    end
end
--在dihuncache里算总的红点
function DiHunPanel:refreshRed()
    -- print("执行前",os.clock())
    self.redList = {}
    self.strengRed = {}
    self.hunShiRed = {}--魂饰按钮红点
    for i=1,#self.infos do
        self.redList[i] = 0
        self.hunShiRed[i] = 0
        self.strengRed[i] = {}--只有激活过的帝魂才有数据
    end
    local function GetMaxLvByMid(mid)
        local color = conf.ItemConf:getQuality(mid)
        local maxLvByColor = conf.DiHunConf:getValue("dh_stren_max_color")
        for k,v in pairs(maxLvByColor) do
            if v[1] == color then
                return v[2]
            end
        end
        return 0
    end
    for k,v in pairs(self.redList) do
        local redNum = 0
        local hsRedNum = 0
        local dhInfo = self.infos[k]
        if dhInfo.point < 8 then--小于8个点的时候才考虑解锁红点
            local confData = conf.DiHunConf:getDhAttById(dhInfo.type,dhInfo.star,dhInfo.point)
            local needMid = confData.items[1]
            local packData = cache.PackCache:getPackDataById(needMid)
            redNum = redNum + math.floor(packData.amount/confData.items[2])--可解锁圆点
        end
        if dhInfo.star > -1 then--已激活的
            for _,j in pairs(dhInfo.partInfo) do
                self.strengRed[k][j.part] = 0
                local diHunPack = cache.PackCache:getDiHunPackDataBySubTypeAndPart(dhInfo.type,j.part)
                if j.item.mid == 0 then--有空位置
                    self.strengRed[k][j.part] = 0
                    if table.nums(diHunPack) > 0 then--有可装备的魂饰
                        redNum = redNum + 1
                        hsRedNum = hsRedNum + 1
                        -- break
                    end
                else
                    --可强化红点
                    local strengData = conf.DiHunConf:getDhStengById(dhInfo.type,j.part,j.strenLevel)
                    if strengData and  strengData.need_cost then
                        local maxLv = GetMaxLvByMid(j.item.mid)
                        --强化材料的品质
                        local quality = conf.ItemConf:getQuality(strengData.need_cost[1][1])
                        local haveScore = cache.DiHunCache:getScoreByColor(quality)
                        if tonumber(haveScore) >= tonumber(strengData.need_cost[1][2]) and j.strenLevel < maxLv  then
                            redNum = redNum + 1
                            hsRedNum = hsRedNum + 1
                            self.strengRed[k][j.part] = 1
                        end
                    end
                end
            end
        end
        self.redList[k] = redNum
        self.hunShiRed[k] = hsRedNum
    end
    -- printt("魂饰按钮红点",self.hunShiRed)
    -- printt("强化红点",self.strengRed)
    -- for k,v in pairs(self.redList) do
    --     print("红点",k,v)
    -- end
    -- print("执行后",os.clock())
end
function DiHunPanel:getRedList()
    return self.redList
end
--[[备注：备注：
1   int32   变量名: type   说明: 帝魂类型
2   array<DHPartInfo>   变量名: partInfo   说明: 部位信息
3   int32   变量名: star   说明: 星数 （-1 表示没有激活）
4   int32   变量名: point  说明: 圆点数（0-8）
5   int8    变量名: possession 说明: 是否附体 0：不附体 1：附体
6   int32   变量名: power  说明: 战力]]
function DiHunPanel:cellData(index,obj)
    local data = self.infos[index+1]
    local redNum = self.redList[index+1]
    if data then
        local c1 = obj:GetController("c1")
        local xingC1 = obj:GetChild("n7"):GetController("c1")
        if data.star == -1 then--未激活
            c1.selectedIndex = 2
        else
            xingC1.selectedIndex = data.star
            if data.possession == 1 then--已附体
                c1.selectedIndex = 0
            else
                c1.selectedIndex = 1
            end
        end
        local confData = conf.DiHunConf:getDiHunInfoByType(data.type)
        local nameTxt = obj:GetChild("n3")
        nameTxt.text = confData.name 
        obj.data = data.type
        local redImg = obj:GetChild("n9")
        if data.point == 8 and data.star ~= 5 then--可激活或升星
            redImg.visible = true
        else
            redImg.visible = redNum > 0
        end
    end
end
--选择帝魂
function DiHunPanel:onClickDiHun(context)
    local cell = context.data
    self.selectType = cell.data
    self.hunShiBtnRedImg.visible = self.hunShiRed[self.selectType] > 0
    self:setSelectData()
end

function DiHunPanel:setSelectData()
    --设置圆点信息
    local dhInfo = self.infos[self.selectType]
    self.powerTab.text = dhInfo.power

    for k,v in pairs(self.diHun) do
        local c1 = v:GetController("c1")
        local icon = v:GetChild("n2")
        local str = "dihun_0"..(v.data+17)
        icon.url = UIPackage.GetItemURL("shenqi",str)
        local effectPanel = v:GetChild("n3")
        if v.data <= dhInfo.point then
            c1.selectedIndex = 0
            effectPanel.visible = true
            local effectObj = self.parent:addEffect(4020183,effectPanel)
            -- effectObj.Scale = Vector3.New(50,50,50)
            effectObj.LocalPosition = Vector3.New(effectPanel.width/2,-effectPanel.height/2,-50)
        else
            c1.selectedIndex = 1
            effectPanel.visible = false
        end
    end
    --设置进度条
    self.bar.value = VALUE[dhInfo.point+1]
    --设置模型
    local confData = conf.DiHunConf:getDiHunInfoByType(self.selectType)
    local  modelObj = self.parent:addModel(confData.modle_id,self.modelPanel)
    modelObj:setScale(confData.scale)
    modelObj:setRotationXYZ(confData.rot[1],confData.rot[2],confData.rot[3])
    modelObj:setPosition(confData.pos[1],confData.pos[2],confData.pos[3])
    --设置激活信息
    local actConfData = conf.DiHunConf:getDhACtByTypeAndStar(self.selectType,dhInfo.star)
    local allMatrialNum = 0 --所有材料数量
    local needNum = 0--需要材料数量
    local material = {}
    for k,v in pairs(actConfData) do
        if v.items then
            table.insert(material,v.items)
        end
    end
    for k,v in pairs(material) do
        if k <= dhInfo.point then
            needNum = needNum + v[2]
        end
    end
    for k,v in pairs(actConfData) do
        allMatrialNum = allMatrialNum + (v.items and v.items[2] or 0)
    end
    self.suiPianTxt.text = needNum.."/"..allMatrialNum
    self.hintGroup.visible = true
    --设置激活按钮
    if dhInfo.point == 8 then
        self.actBtn.visible = true
        if dhInfo.star == -1 then
            self.actBtn.icon = "ui://shenqi/dihun_045"--激活
            self.actBtn.data = 0
        else
            if dhInfo.star == 5 then
                self.actBtn.visible = false
                self.hintGroup.visible = false
            else
                self.actBtn.visible = true
            end
            self.actBtn.icon = "ui://shenqi/dihun_047"--升星
            self.actBtn.data = 1
        end
    else
        self.actBtn.visible = false
    end
    if dhInfo.star == -1 then
        self.actBtn.icon = "ui://shenqi/dihun_045"--激活
        self.hintIcon.icon = "ui://shenqi/dihun_046"
    else
        self.actBtn.icon = "ui://shenqi/dihun_047"--升星
        self.hintIcon.icon = "ui://shenqi/dihun_033"
    end
    --设置帝魂技能
    local star = dhInfo.star == -1  and 0 or dhInfo.star +1
    local id = tonumber(dhInfo.type)*1000 + star
    local skillConf = conf.DiHunConf:getDhSkillById(id)
    local nextSkillConf = conf.DiHunConf:getDhSkillById(id+1)
    self.diHunSkill.icon = ResPath.iconRes(skillConf.skill_icon)
    local str = skillConf.level == 0 and "" or  "Lv."..mgr.TextMgr:getTextColorStr(skillConf.level ,7)
    self.diHunSkill.title = str
    self.diHunSkill.data = {id = id}

    if dhInfo.star == -1 then--未激活
        self.diHunSkillDec.text = language.dihun04 
        self.diHunSkill.grayed = true
    else
        self.diHunSkillDec.text = language.dihun05
        self.diHunSkill.grayed = false
    end
    --设置附体按钮可见性
    if dhInfo.possession == 1 then--已附体
        self.futiBtn.visible = false
    else
        if dhInfo.star == -1 then--未激活
            self.futiBtn.visible = false
        else
            if skillConf.type == 1 then--永久增益的不用附体
                self.futiBtn.visible = false
            else
                self.futiBtn.visible = true
            end
        end
    end
    if dhInfo.star == -1 then
        skillConf = nil--激活之后才能加入技能属性
        nextSkillConf = nil
    end
    if dhInfo.point < 8 then
        nextSkillConf = nil--圆点未满
    end
    --设置魂饰技能
    self.hsSkill = conf.DiHunConf:getHsSkillByType(dhInfo.type)
    self.hsSkillStrengLv = 0
    for k,v in pairs(dhInfo.partInfo) do
        self.hsSkillStrengLv = self.hsSkillStrengLv + v.strenLevel
    end

    self.hunShiSkillList.numItems = #self.hsSkill
    --设置帝魂属性
    self:setAttData(dhInfo,skillConf,nextSkillConf)
    --魂饰
    self:setHunShiInfo(dhInfo)
    --设置魂饰属性
    self:setHunShiAttData(dhInfo)
end
--设置魂饰信息
function DiHunPanel:setHunShiInfo(dhInfo)
    
    local partInfo = dhInfo.partInfo
    local redInfo = self.strengRed[dhInfo.type]
    -- printt("redInfo",redInfo)
    for k,v in pairs(partInfo) do
        local hunShiItem = self.hunShiList[v.part]
        local icon = hunShiItem:GetChild("n1")
        local jia = hunShiItem:GetChild("n2")
        local effectPanel = hunShiItem:GetChild("n3")
        local redImg = hunShiItem:GetChild("red")
        if redInfo and #redInfo > 0 then
            redImg.visible = redInfo[v.part] > 0 
        else
            redImg.visible = false
        end
        if v.item.mid == 0 then
            icon.url = ""
            jia.visible = true
            effectPanel.visible = false
        else
            effectPanel.visible = true
            local confData = conf.ItemConf:getItem(v.item.mid)
            icon.url = confData.src and ResPath.iconRes(confData.src) or nil
            jia.visible = false
            local effectObj = self.parent:addEffect(HunShiEffect[confData.color],effectPanel)
            effectObj.LocalPosition = Vector3.New(0,0,-50)
        end
        hunShiItem.data = v
    end
end
--点击魂饰
function DiHunPanel:onClickHunShi(context)
    local btn = context.sender
    local data = btn.data
    if data.item.mid == 0 then
        mgr.ViewMgr:openView(ViewName.DiHunPack)
    else
        local info = clone(data.item)
        info.strenLevel = data.strenLevel
        info.isquan = true
        GSeeLocalItem(info)
    end
end
--设置属性
function DiHunPanel:setAttData(dhInfo,skillConf,nextSkillConf)
    local _type = dhInfo.type
    local curStar = dhInfo.star
    local curPoint = dhInfo.point

    local nextStar = curPoint == 8 and curStar + 1 or curStar
    local nextPoint = (curPoint+1)%9
    --当前属性
    local curConfData = conf.DiHunConf:getDhAttById(_type,curStar,curPoint)
    self.curDhAttData = GConfDataSort(curConfData)
    --加入技能属性
    local skillAttData = GConfDataSort(skillConf)
    self:setHashData(skillAttData,self.curDhAttData)

    --下一级属性
    local nextConfData = conf.DiHunConf:getDhAttById(_type,nextStar,nextPoint)
    self.nextDhAttData = nextConfData and GConfDataSort(nextConfData) or {}
    --下一级技能属性
    if nextSkillConf then
        local nextSkillAttData = GConfDataSort(nextSkillConf)
        self:setHashData(nextSkillAttData,self.nextDhAttData)
    end
    -- printt("当前",self.curDhAttData)
    -- printt("下一级",self.nextDhAttData)
    -- printt("差",self.cha)
    --差
    self.cha = self:removeSameType(self.nextDhAttData,self.curDhAttData)
    if self.curDhAttData and #self.curDhAttData > 0 then
        self.dhAttList.numItems = #self.curDhAttData
    end
end
--帝魂属性
function DiHunPanel:cellDhAttData(index,obj)
    local curData = self.curDhAttData[index+1]
    local name = obj:GetChild("n0")
    local curValue = obj:GetChild("n1")
    local nextValue = obj:GetChild("n2")
    name.text = conf.RedPointConf:getProName(curData[1])
    curValue.text = GProPrecnt(curData[1],math.floor(curData[2]))
    local cha = self.cha[index+1]
    if cha and cha[2] ~= 0 then
        nextValue.text = "+"..GProPrecnt(cha[1],math.floor(cha[2]))
    else
        nextValue.text = ""
    end
end

--tar:被减函数
--temp:减函数
function DiHunPanel:removeSameType(tar,temp)
    local data = tar
    for k,v in pairs(data) do
        local flag = false
        for i,j in pairs(temp) do
            if j[1] == v[1] then
                data[k][2] = v[2]- j[2]
            end
        end
    end
    return data
end
--只显示装备本身的加成属性和魂饰技能加成属性
function DiHunPanel:setHunShiAttData(dhInfo)
    self.hsAttAllData = {}
    --装备属性
    for k,v in pairs(dhInfo.partInfo) do
        if v.item.mid and v.item.mid ~= 0 then
            local attiData = conf.ItemArriConf:getItemAtt(v.item.mid)
            local t = GConfDataSort(attiData)
            self:setHashData(t,self.hsAttAllData)
        end
    end
    --技能属性
    for k,v in pairs(self.hsSkill) do
        if self.hsSkillStrengLv >= v.level then
            local t = GConfDataSort(v)
            self:setHashData(t,self.hsAttAllData)
        end
    end
    local maxLvByColor = conf.DiHunConf:getValue("dh_stren_max_color")
    --强化属性
    for k,v in pairs(dhInfo.partInfo) do
        if v.item.mid ~= 0 then
            local maxstrenLev = 0
            for i,j in pairs(maxLvByColor) do
                local color = conf.ItemConf:getQuality(v.item.mid)
                if j[1] == color then
                    maxstrenLev = j[2]
                    break
                end
            end
            local strengAttData = conf.DiHunConf:getDhStengById(self.selectType,v.part, math.min(v.strenLevel,maxstrenLev))
            local t = GConfDataSort(strengAttData)
            self:setHashData(t,self.hsAttAllData)
        end
    end

    table.sort(self.hsAttAllData,function (a,b)
        return a[1] < b[1]
    end)
    self.hsAttList.numItems = #self.hsAttAllData
end
--魂饰属性
function DiHunPanel:cellHsAttData(index,obj)
    local name = obj:GetChild("n0")
    local curValue = obj:GetChild("n1")
    local nextValue = obj:GetChild("n2")
    nextValue.text = ""
    local data = self.hsAttAllData[index+1]
    if data then
        name.text = conf.RedPointConf:getProName(data[1])
        curValue.text = GProPrecnt(data[1],math.floor(data[2]))
    end
end

--魂饰技能
function DiHunPanel:cellHunShiSkillData(index,obj)
    local data = self.hsSkill[index+1]
    if data then
        obj.data = data
        obj.icon = ResPath.iconRes(data.skill_icon)
        if self.hsSkillStrengLv >= data.level then
            obj.grayed = false
        else
            obj.grayed = true
        end
    end
end
--点击魂饰技能
function DiHunPanel:onClickHunShiSkill(context)
    local cell = context.data
    local data = cell.data
  
    mgr.ViewMgr:openView2(ViewName.HunShiSkillView,data)

end

--点击帝魂技能
function DiHunPanel:onClickSkillBtn(context)
    local btn = context.sender
    local data = btn.data
    mgr.ViewMgr:openView2(ViewName.DiHunSkillView,data)
end

--升星||激活
function DiHunPanel:onClickActBtn(context)
    local btn = context.sender
    local data = btn.data
    proxy.DiHunProxy:sendMsg(1620107,{reqType = data, DhType = self.selectType})

end

function DiHunPanel:onClickCallBack(context)
    local btn = context.sender
    if btn.name == "n18" then--附体
        proxy.DiHunProxy:sendMsg(1620103,{reqType = self.selectType})
    elseif btn.name == "n20" then--背包
        mgr.ViewMgr:openView(ViewName.DiHunPack)
    end
end

function DiHunPanel:onBtnCallBack(context)
    local btn = context.sender 
    local data = btn.data 
    if self.infos then
        local dhInfo = self.infos[self.selectType]
        mgr.ViewMgr:openView2(ViewName.DiHunTips,{point = data,dhInfo = dhInfo})
    end
end

function DiHunPanel:setHashData(data,tar)
    for k,v in pairs(data) do
        local flag = false
        for i,j in pairs(tar) do
            if j[1] == v[1] then
                tar[i][2] = j[2] + v[2]
                flag = true
            end
        end
        if not flag then
            table.insert(tar,v)
        end
    end
end
return DiHunPanel