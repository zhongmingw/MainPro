--
-- Author: 
-- Date: 2018-11-01 19:26:45
--

local ElemetStepUpView = class("ElemetStepUpView", base.BaseView)
local table = table
local pairs = pairs
local dian = mgr.TextMgr:getImg(UIItemRes.dian01)
function ElemetStepUpView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level3 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ElemetStepUpView:initView()
    self:setCloseBtn(self.view:GetChild("n0"):GetChild("n2"))
    self.leftpanel = self.view:GetChild("n1")
    self.rightpanel = self.view:GetChild("n2")
    self.oldY = self.leftpanel.y
    self.oldX = self.leftpanel.x

    self.materialList = self.view:GetChild("n24")
    self.materialList.itemRenderer = function (index,obj)
        self:cellData(index,obj)
    end

    --升阶
    local stepUpBtn = self.view:GetChild("n25")
    stepUpBtn.onClick:Add(self.onStepUpCallBack,self)

    --提升
    local btn = self.view:GetChild("n26")
    btn.onClick:Add(self.onLevelUp,self)
    self.c1 = self.view:GetController("c1")
end

function ElemetStepUpView:initData(data)
    -- printt("initData",data)
    self.choseEleData = data.choseEleData
    self.site = data.choseEleData.mData.site
    --本事是否有极品属性
    self.isColorAtts = #data.choseEleData.mData.eleInfo.colorAttris > 0
    --显示极品属性（用于显示下一阶的极品属性）
    self.showColorAttris = data.choseEleData.mData.eleInfo.colorAttris

    self.leftmid = data.choseEleData.mData.eleInfo.mid
    local nextConf = conf.EightGatesConf:getNextStageId(self.leftmid)
    self.rightmid = nextConf.next_id--self.leftmid + 1

    self:setPanelInfo( self.leftmid,self.rightmid,data)
end

function ElemetStepUpView:setPanelInfo(leftmid,rightmid,data,isMsgCallBack)
    self.leftmid = leftmid
    self.rightmid = rightmid
    --print("左边mid",leftmid)
    --print("右边边mid",rightmid)
    local _t = data and data.choseEleData and  data.choseEleData.mData
    if not conf.ItemConf:getItem(rightmid) then--当前道具阶已经升满
        self.leftpanel:Center()
        self.leftpanel.y = self.oldY
        -- self:initPanel(1,self.leftpanel,_t)
        self:initLeft(self.leftpanel,_t)

        self.c1.selectedIndex = 1
        self.leftpanel.visible = true
        self.rightpanel.visible = false
    else
        self.leftpanel.x = self.oldX
        self.leftpanel.y = self.oldY

        -- self:initPanel(1,self.leftpanel,_t)
        self:initLeft(self.leftpanel,_t)

        self:initRight(self.rightpanel)

        self.c1.selectedIndex = 0
        self.leftpanel.visible = true
        self.rightpanel.visible = true
    end
    if isMsgCallBack then
        self.c1.selectedIndex = 1
    end
    self.costConfData = conf.EightGatesConf:getStepCost(conf.ItemConf:getStagelvl(leftmid))
    if self.costConfData and  self.costConfData.items then
        self.materialList.numItems = #self.costConfData.items
    else
        self.materialList.numItems = 0
    end
end


function ElemetStepUpView:cellData(index,obj)
    local data = self.costConfData.items[index+1]
    if data then
        local itemData = {mid = data[1],amount = 1,bind = data[3],isquan = 0}
        GSetItemData(obj:GetChild("n7"), itemData, true)
        
        local packdata = cache.PackCache:getElementById(data[1])
        local color = packdata.amount < data[2] and 14 or 10
        local textData = {
                {text = tostring(packdata.amount),color = color},
                {text = "/",color = 10},
                {text = tostring(data[2]),color = 10},
            }
        obj:GetChild("n13").text = mgr.TextMgr:getTextByTable(textData)
    end
end

function ElemetStepUpView:initLeft(panel,data)
    --道具icon
    local itemObj = panel:GetChild("n6")
    local t = {}
    t.mid = self.leftmid
    t.amount = 1
    t.bind = 0
    t.isquan = true
    GSetItemData(itemObj,t)
    self.mid = self.leftmid
    local confData = conf.ItemConf:getItem(self.mid)
    --元素名字
    local partName = panel:GetChild("n8") 
    partName.text = mgr.TextMgr:getQualityStr1(confData.name, confData.color) 
    --阶
    panel:GetChild("n19").text = string.format(language.eightgates14,language.gonggong21[confData.stage_lvl])
        --品阶
    local step = panel:GetChild("n4")
    step.text = "当前品阶"
    local score = 0

     --基础属性
    local attiData = conf.ItemArriConf:getItemAtt(self.mid)
    local t = GConfDataSort(attiData)
    local str = ""
    local text = ""
    for k,v in pairs(t) do
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #t then
            str1 = str1.."\n"
            text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end
     --基础评分
    local power = panel:GetChild("n7")
    power.text = math.floor(score)
    panel:GetChild("n14"):GetChild("n14").text = str
    --极品属性
    local str = ""
    local synScore = 0--综合战斗力
    -- printt("data",data)
    local colorAttris = data and  data.eleInfo.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        for k,v in pairs(colorAttris) do
            local str1 = dian.." "..self:attiCallback(v.type,v.value)
            local text1 = ""
            if k~= #data.eleInfo.colorAttris then
                str1 = str1.."\n"
            end
            str = str..str1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        local birthAtt = conf.ItemConf:getBaseBirthAtt(self.mid)--推荐属性
        local isTuijian = true
        if not birthAtt then--固定生成的属性不走推荐
            isTuijian = false
            birthAtt = conf.ItemConf:getBirthAtt(self.mid) or {}
        else

        end
        for k,v in pairs(birthAtt) do
            if k % 2 == 0 then--值
                local type,value = birthAtt[k - 1],birthAtt[k]
                local str1 =  dian.." "..self:attiCallback(type,value,isTuijian)
                local text1 = ""
                if k ~= #birthAtt then
                    str1 = str1.."\n"
                end
                str = str..str1
                if not isTuijian then--如果是固定生成的
                    synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                end
            end
        end
    end
    if str == "" then
        str = dian.." "..language.zuoqi26
    end
    --综合评分
    local power1 = panel:GetChild("n12")
    power1.text =  math.floor(score + synScore)
    panel:GetChild("n17"):GetChild("n14").text = str
end


--way = 1:左，way = 2 :右
function ElemetStepUpView:initRight(panel,data)
    --道具icon
    local itemObj = panel:GetChild("n6")
    local t = {}
    t.mid = self.rightmid
    t.amount = 1
    t.bind = 0
    t.isquan = true
    GSetItemData(itemObj,t)
    self.mid = self.rightmid
    local confData = conf.ItemConf:getItem(self.mid)
    --元素名字
    local partName = panel:GetChild("n8") 
    partName.text = mgr.TextMgr:getQualityStr1(confData.name, confData.color) 
    --阶
    panel:GetChild("n19").text = string.format(language.eightgates14,language.gonggong21[confData.stage_lvl])

    --品阶
    local step = panel:GetChild("n4")
    step.text = "下一品阶"
    local score = 0
    --基础属性
    local attiData = conf.ItemArriConf:getItemAtt(self.mid)
    local t = GConfDataSort(attiData)
    local str = ""
    local text = ""
    for k,v in pairs(t) do
        local str1 = dian.." "..conf.RedPointConf:getProName(v[1]).." "..GProPrecnt(v[1],math.floor(v[2]))
        if k ~= #t then
            str1 = str1.."\n"
            text = text.." ".."\n"
        end
        str = str..str1
        score = score + mgr.ItemMgr:baseAttScore(v[1],v[2])
    end
     --基础评分
    local power = panel:GetChild("n7")
    power.text =  math.floor(score)

    panel:GetChild("n14"):GetChild("n14").text = str
       --极品属性
    local str = ""
    local synScore = 0--综合战斗力
    -- printt("data",data)
    local colorAttris = data and  data.eleInfo.colorAttris
    if colorAttris and #colorAttris > 0 then--系统生成属性
        for k,v in pairs(colorAttris) do
            local str1 = dian.." "..self:attiCallback(v.type,v.value)
            local text1 = ""
            if k~= #data.eleInfo.colorAttris then
                str1 = str1.."\n"
            end
            str = str..str1
            synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
        end
    else
        if not self.isColorAtts then--本身就没有极品属性   走推荐
            local birthAtt = conf.ItemConf:getBaseBirthAtt(self.mid)--推荐属性
            local isTuijian = true
            if not birthAtt then--固定生成的属性不走推荐
                isTuijian = false
                birthAtt = conf.ItemConf:getBirthAtt(self.mid) or {}
            else

            end
            for k,v in pairs(birthAtt) do
                if k % 2 == 0 then--值
                    local type,value = birthAtt[k - 1],birthAtt[k]
                    local str1 =  dian.." "..self:attiCallback(type,value,isTuijian)
                    local text1 = ""
                    if k ~= #birthAtt then
                        str1 = str1.."\n"
                    end
                    str = str..str1
                    if not isTuijian then--如果是固定生成的
                        synScore = synScore + mgr.ItemMgr:birthAttScore(type,value)--计算综合评分
                    end
                end
            end
        else
            self.tempColorAttris = {}
            for k,v in pairs(self.showColorAttris) do
                local data = {}
                local _t = conf.ItemConf:getEquipColorAttri(v.type +1)
                if _t then
                    data.type = v.type +1
                    data.value = _t.att_range[1][1]
                else
                    data.type = v.type
                    data.value = v.value
                    print("装备极品属性表没有>>",v.type+1)
                end
                table.insert(self.tempColorAttris,data)
            end
            for k,v in pairs(self.tempColorAttris) do
                local str1 = dian.." "..self:attiCallback(v.type,v.value)
                local text1 = ""
                if k~= #self.tempColorAttris then
                    str1 = str1.."\n"
                end
                str = str..str1
                synScore = synScore + mgr.ItemMgr:birthAttScore(v.type,v.value)--计算综合评分
            end
        end
    end
    if str == "" then
        str = dian.." "..language.zuoqi26
    end
    --综合评分
    local power1 = panel:GetChild("n12")
    power1.text = math.floor(score + synScore)
    panel:GetChild("n17"):GetChild("n14").text = str
end

--极品属性
function ElemetStepUpView:attiCallback(id,value,isTuijian)
    -- body
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
            attiValue = attiValue--..language.pack41--获得了最佳的极品属性
        end
    end
    local str = ""
    local atti = 0

    if isTuijian then
        str = name..attiValue--language.equip08.." "..name..attiValue
    else
        str = name..attiValue
    end
    -- str = name..attiValue
    return mgr.TextMgr:getQualityAtti(str,color)
end

--升阶
function ElemetStepUpView:onStepUpCallBack(context)
    local listnumber = {}
    for k,v in pairs(self.costConfData.items) do
        local packdata = cache.PackCache:getElementById(v[1])
        table.insert(listnumber,math.floor(packdata.amount/v[2]))
    end
    local num = math.min(unpack(listnumber))
    if num > 0 then
        proxy.AwakenProxy:send(1610106,{site = self.site})
    else
        GComAlter(language.eightgates15)
    end
end

function ElemetStepUpView:addMsgCallBack()
    -- self.c1.selectedIndex = 1
    --升阶成功后
    local data = {}
    data.choseEleData = {}
    data.choseEleData.mData = {}
    data.choseEleData.mData.eleInfo = {}
    data.choseEleData.mData.eleInfo.colorAttris = self.tempColorAttris
    self.showColorAttris = self.tempColorAttris
    local nextConf = conf.EightGatesConf:getNextStageId(self.rightmid)
    if not nextConf then
        self:setPanelInfo(self.rightmid,0,data,true)
    else
        self:setPanelInfo(self.rightmid,nextConf.next_id,data,true)
    end
end
--强化
function ElemetStepUpView:onLevelUp()
    mgr.ViewMgr:openView2(ViewName.ElementStrengView,{mid = 0})
    self:closeView()
end

return ElemetStepUpView