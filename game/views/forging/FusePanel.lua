--
-- Author: ohf
-- Date: 2017-02-06 21:13:46
--
--合成区域
local FusePanel = class("FusePanel",import("game.base.Ref"))

local maxRed = 99
local pairs = pairs
local table = table

function FusePanel:ctor(mParent)
    self.mParent = mParent
    self:initPanel()
end

function FusePanel:initPanel()
   
    self.checkpart = {}
    local _cc = conf.ForgingConf:getComposeValue("compose_new_part")
    for k ,v in pairs(_cc) do
        self.checkpart[tonumber(v)] = true --需要是指定的部位
    end
    self.checkinfo =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_new_color_xin_jie")
    for k , v in pairs(_dd) do
        self.checkinfo[v[1]] = v  
    end
    --五行
    self.checkinfowuxing =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_wuxing_color_xin")
    for k , v in pairs(_dd) do
        self.checkinfowuxing[v[1]] = v  
    end
    --仙装部位指定
    self.checkxianpart = {}
    local ff = conf.ForgingConf:getComposeValue("compose_new_part_xian")
    for k,v in pairs(ff) do
        self.checkxianpart[tonumber(v)] = true
    end
    self.checkxianinfo =  {}
    local _dd = conf.ForgingConf:getComposeValue("compose_new_color_xin_jie_xian")
    for k , v in pairs(_dd) do
        self.checkxianinfo[v[1]] = v  
    end

    self.fuseNum = 1
    --
    self.mSuitData = conf.ForgingConf:getSuitFuse()

    local panelObj = self.mParent.view:GetChild("n10")
    --神装预览
    self.seeGodEquipBtn = panelObj:GetChild("n41")
    self.seeGodEquipBtn.onClick:Add(self.onClickGodBtn,self)
    self.seeGodEquipBtn.visible = false

    --控制器
    self.c1 = panelObj:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
   
    --左边列表
    self.listView = panelObj:GetChild("n1")

    self.prosObj = panelObj:GetChild("n7")--目标
    self.prosObj.visible = false
    self.prosName = panelObj:GetChild("n14")
    self.prosName.text = ""

    self.materObj = panelObj:GetChild("n9")--材料
    self.materObj.visible = false
    self.materName = panelObj:GetChild("n15")
    self.materName.text = ""
    self.materNum = panelObj:GetChild("n16")
    self.materNum.text = ""

    self.moneyNum = panelObj:GetChild("n17")
    self.moneyNum.text = 0

    self.fuseText = panelObj:GetChild("n25")
    self.fuseText.text = self.fuseNum
    local addBtn = panelObj:GetChild("n23")
    addBtn.data = 1
    addBtn.onClick:Add(self.onClickUpdateNum,self)
    local lessBtn = panelObj:GetChild("n24")
    lessBtn.data = 2
    lessBtn.onClick:Add(self.onClickUpdateNum,self)
    local maxBtn = panelObj:GetChild("n26")
    maxBtn.onClick:Add(self.onClickMaxNum,self)
    local fuseBtn = panelObj:GetChild("n4")
    fuseBtn.onClick:Add(self.onClickFuse,self)
    local fuseBtn02 = panelObj:GetChild("n35") --EVE 
    fuseBtn02.onClick:Add(self.onClickFuse,self)
    local fuseBtn02Text = panelObj:GetChild("n34")
    fuseBtn02Text.text = language.forging56
    self.fuseBtn02Text = fuseBtn02Text
    local helpBtn = panelObj:GetChild("n6")--帮助
    helpBtn.onClick:Add(self.onClickHelp, self)
    local buyProBtn = panelObj:GetChild("n10")
    buyProBtn.onClick:Add(self.onClickBuyPro,self)

    self.checkBox = panelObj:GetChild("n19")
    self.checkBox.onChanged:Add(self.onCheck,self)--给控制器获取点击事件

    local desc = panelObj:GetChild("n20")
    desc.text = language.forging31

    --合成信息
    local panel = panelObj:GetChild("n33")
    self.equiplist = {}
    for i = 33 , 37 do
        local icon = panel:GetChild("n"..i)
        icon.data = {pos = i - 32,data = nil}
        icon.onClick:Add(self.inputEquip,self)
        table.insert(self.equiplist,icon)
    end
    self.frame = {}
    for i = 50 , 54 do
        local frame = panel:GetChild("n"..i)
        frame.url = nil 
        table.insert(self.frame,frame) 
    end
    self._HcIcon = panel:GetChild("n32")
    --self._HcIcon.onClick:Add(self.hcSee,self)
    --一键放入
    local btnAuto = panel:GetChild("n40")
    btnAuto.onClick:Add(self.inPutAuto,self)
    self.btnAutoRed = btnAuto:GetChild("red")

    self.n41 = panel:GetChild("n41")
    self.moneyCost = panel:GetChild("n43")
    self.moneyicon = panel:GetChild("n42")
    self.plus = panel:GetChild("n55")
    self.plus.onClick:Add(self.onPlus,self)
    ---3星合3星
    self.equiplist3 = {}
    local panel = panelObj:GetChild("n36")
    for i = 12,13 do
        local icon = panel:GetChild("n"..i)
        icon.data = {pos = i - 11,data = nil}
        icon.onClick:Add(self.inputEquip,self)
        table.insert(self.equiplist3,icon)
    end
    self.frame3 = {}
    for i = 10 , 11 do
        local frame = panel:GetChild("n"..i)
        frame.url = nil 
        table.insert(self.frame3,frame) 
    end
    self._HcIcon_3 = panel:GetChild("n42")
    local btnAutoRed_3 = panel:GetChild("n5")
    btnAutoRed_3.onClick:Add(self.inPutAuto,self)
    self.btnAutoRed_3 = btnAutoRed_3:GetChild("red") 
    self.moneyCost_3 = panel:GetChild("n3")
    self.plus_3 = panel:GetChild("n4")
    self.plus_3.onClick:Add(self.onPlus,self)
    --仙装3合1
    self.equipxianlist = {}
    local panel = panelObj:GetChild("n37")
    for i = 201 , 203 do 
        local icon = panel:GetChild("n"..i)
        icon.data = {pos = i - 200,data = nil}
        icon.onClick:Add(self.inputEquip,self)
        table.insert(self.equipxianlist,icon)
    end
    self.xianframe3 = {}
    for i = 101 , 103 do
        local frame = panel:GetChild("n"..i)
        frame.url = nil 
        table.insert(self.xianframe3,frame) 
    end
    self._HcIcon_xian = panel:GetChild("n42")
     local btnAutoRed_3 = panel:GetChild("n5")
    btnAutoRed_3.onClick:Add(self.inPutAuto,self)
    self.btnAutoRed_xian = btnAutoRed_3:GetChild("red") 
    self.moneyCost_xian = panel:GetChild("n3")
    self.plus_xian = panel:GetChild("n4")
    self.plus_xian.onClick:Add(self.onPlus,self)
    self.moneyGroup_xian = panel:GetChild("n13")
    --圣印
    local panel = panelObj:GetChild("n38")
    self.leftinfo = panel:GetChild("n15")
    self.rightinfo = panel:GetChild("n16")
    self.middle_ss = panel:GetChild("n42")
    self.lab_number = panel:GetChild("n22")
    local btn1 = panel:GetChild("n19")
    btn1.data = -1 
    btn1.onClick:Add(self.changnumber,self)
    local btn2 = panel:GetChild("n18")
    btn2.data = 1
    btn2.onClick:Add(self.changnumber,self)
    local btnmax =  panel:GetChild("n20") 
    btnmax.data = "max"
    btnmax.onClick:Add(self.changnumber,self)

    self.labjcsb = panel:GetChild("n24") 

    self.leftinfo:GetChild("n2").onClick:Add(self.onPlus,self)
    self.rightinfo:GetChild("n2").onClick:Add(self.onPlus,self)

    --神装4合1
    local panel = panelObj:GetChild("n39")
    self.godEquipList4 = {}
    for i = 6 , 8 do 
        local icon = panel:GetChild("n"..i)
        icon.data = {pos = i - 5,data = nil}
        icon.onClick:Add(self.inputEquip,self)
        table.insert(self.godEquipList4,icon)
    end
    self.godFrame4 = {}
    for i = 1 , 3 do
        local frame = panel:GetChild("n"..i)
        frame.url = nil 
        table.insert(self.godFrame4,frame) 
    end
    self.godEquip4 = panel:GetChild("n32")
    self.proPanel = panel:GetChild("n11")
    self.proPanel:GetChild("n2").onClick:Add(self.onPlus,self)
    --神装3合1
    local panel = panelObj:GetChild("n40")
    self.godEquipList3 = {}
    local icon = panel:GetChild("n2")
    icon.data = {pos = 1,data = nil}
    icon.onClick:Add(self.inputEquip,self)
    table.insert(self.godEquipList3,icon)

    self.godFrame3 = {}
    local frame = panel:GetChild("n1")
    frame.url = nil
    table.insert(self.godFrame3,frame) 

    self.godEquip3 = panel:GetChild("n5")
    self.proLeft = panel:GetChild("n3")
    self.proRight = panel:GetChild("n4")
    self.proLeft:GetChild("n2").onClick:Add(self.onPlus,self)
    self.proRight:GetChild("n2").onClick:Add(self.onPlus,self)

end



function FusePanel:onPlus( context )
    -- body
    local data = context.sender.data
    if data then
        mgr.ViewMgr:openView2(ViewName.Alert6,data)
    end
end

function FusePanel:clearinfo()
    -- body
    local cb = function(comp)
        -- body
        GSetItemData(comp:GetChild("n1"), {isquan = 0})
        comp:GetChild("n3").text = ""
        comp:GetChild("n4").text = ""
        comp:GetChild("n2").data = nil 
    end
    cb(self.leftinfo)
    cb(self.rightinfo)
  
    GSetItemData(self.middle_ss, {isquan = 0})
    self.labjcsb.text = ""
    self.lab_number.text = 0
    -- print("清理数据")
    
    self.moneyCost_xian.text = ""
    self.moneyCost_3.text = ""
    self.moneyCost.text = ""
    --神装4合1
    for k ,v in pairs(self.godEquipList4) do
        v.url = nil 
        v.data.data = nil 
    end
    for k,v in pairs(self.godFrame4) do
        v.url = nil 
    end
    cb(self.proPanel)
    GSetItemData(self.godEquip4, {isquan = 0})
    --神装3合1 
    for k ,v in pairs(self.godEquipList3) do
        v.url = nil 
        v.data.data = nil 
    end
    for k,v in pairs(self.godFrame3) do
        v.url = nil 
    end
    cb(self.proLeft)
    cb(self.proRight)

    GSetItemData(self.godEquip3, {isquan = 0})

    --仙装
    for k ,v in pairs(self.equipxianlist) do
        v.url = nil 
        v.data.data = nil 
    end
    for k ,v in pairs(self.xianframe3) do
        v.url = nil 
    end
    for k ,v in pairs(self.equiplist3) do
        v.url = nil 
        v.data.data = nil 
    end
    for k ,v in pairs(self.frame3) do
        v.url = nil 
    end
    for k ,v in pairs(self.equiplist) do
        v.url = nil 
        v.data.data = nil 
    end
    for k ,v in pairs(self.frame) do
        v.url = nil 
    end
    self.max19 = 0
    self.number_C = 0
    self.fuseData = nil
    self.itemData = nil
    self.materData = nil
    self.fuseText.text = 1
    self:setSclelctData(nil,nil)
end

function FusePanel:changnumber( context )
    -- body
    local btn = context.sender
    local data = btn.data 
    if not self.selectedIndex == 4 or  not self.max19 then--or self.max19 == 0 then
        return
    end
    if self.max19 == 0 then
        if data == "max" or data == 1 then
            GComAlter(language.forging32)
        elseif data == -1 then
            GComAlter(language.forging34)
        end
        return
    end
    if data == "max" then
        if self.number_C == self.max19 then
            GComAlter(language.forging32)
        else
            self.number_C = self.max19
        end
    else
        self.number_C = self.number_C+data
        -- print("self.number_C",self.number_C)
        -- self.number_C = math.min( math.max(1, self.number_C+data),self.max19)
        if self.number_C < 1 then
            self.number_C = 1
            GComAlter(language.forging34)
        elseif self.number_C > self.max19 then
            self.number_C = self.max19
            GComAlter(language.forging32)
        end
    end
    self.lab_number.text = self.number_C
end

function FusePanel:onController1()
    -- body
    self.btnAutoRed.visible = false
    self.btnAutoRed_3.visible = false
    self.btnAutoRed_xian.visible = false
    self.composedata = nil 
    self:clearinfo()
end

function FusePanel:cellSuitData1(data,cell)
    local controller = cell:GetController("c1")--主控制器
    controller.selectedIndex = data.open
    if data.open == 1 then
        if data.type <= 1 
            or data.type == 6 
            or data.type == 7  
            or data.type == 10
            or data.type == 11 
            or data.type == 14 
            or data.type == 15 then
            self.c1.selectedIndex = 1
        elseif data.type == 16 then
            self.c1.selectedIndex = 2
        elseif data.type == 18 then
            self.c1.selectedIndex = 3
            self.moneyGroup_xian.visible = true
        elseif data.type == 19 then
            self.c1.selectedIndex = 4
        elseif data.type == 21 or data.type == 25 then
            self.c1.selectedIndex = 5
            self.seeGodEquipBtn.visible = true
        elseif data.type == 22 then
            self.c1.selectedIndex = 5
            self.seeGodEquipBtn.visible = false
        elseif data.type == 23 or data.type == 24 then
            self.c1.selectedIndex = 3
            self.moneyGroup_xian.visible = false
        else
            self.c1.selectedIndex = 0
        end
    end

    local img = cell:GetChild("n0")
    img.url = UIItemRes.fuseIcon[data.type]

    local redImg = cell:GetChild("n8")
    redImg.visible = false

    local redText = cell:GetChild("n9")
    redText.text = ""
    if data.redNum > 0 then
        redImg.visible = true
    end

    cell.data = data
    cell.onClick:Clear()
    cell.onClick:Add(self.onClickFuseSuit,self)
end

function FusePanel:cellSuitData2(data,cell,k,type)
    local itemObj = cell:GetChild("n1")
    local nameText = cell:GetChild("n6")
    local nameTextOldX = nameText.x
    local numImg = cell:GetChild("n2")
    local numText = cell:GetChild("n3")
    numText.visible = false
    if type == 19 then
       nameText.x = 86
    else
       nameText.x = 98
    end
    cell.onClick:Add(self.onClickFuseItem,self)
    if type <= 1 or type == 6 or type == 7 
    or type == 10 or type == 11 or type == 14 or type == 15
    or type == 16 or type == 18 or type == 19 or type == 21 
    or type == 22 or type == 23 or type == 24 or type == 25 then

        --道具icon
        cell.data = {type = type,data = data}
        --第几阶的装备
        nameText.text = data.name
        numImg.visible = data.redNum>0
        for i = 0 , itemObj.numChildren-1 do 
            local var = itemObj:GetChildAt(i)
            if var then
                var.visible = false
            end
        end
        itemObj.touchable = false
        local itemFrame = itemObj:GetChild("n1")
        itemFrame.visible = true
        if type == 0 then
            itemFrame.url = ResPath.iconRes("beibaokuang_005")
        elseif type == 14 or type == 18 or type == 19 or type == 21 
            or type == 22 or type == 23 or type == 25 then
            if data.color == 5 then
                itemFrame.url = ResPath.iconRes("beibaokuang_005")
            elseif data.color == 7 then
                itemFrame.url = ResPath.iconRes("beibaokuang_007")
            else
                itemFrame.url = ResPath.iconRes("beibaokuang_006")
            end
        elseif type == 6 or type == 7 then
            itemFrame.url = ResPath.iconRes("beibaokuang_00"..data.color)
        else
            itemFrame.url = ResPath.iconRes("beibaokuang_006")
        end
        if data.color == 3 then
            itemFrame.url = ResPath.iconRes("beibaokuang_004")
        end
        

        local iconObj = itemObj:GetChild("icon")
        iconObj.visible = true
        iconObj.url = ResPath.iconRes(data.icon)
        if type == 19 then
            local shengYinLoader = itemObj:GetChild("n20")
            shengYinLoader.visible = true
            if data.id then
                local shengYinMovie = conf.ItemConf:getShengYinMovie(data.id)
                if shengYinMovie ~= 0 then
                    shengYinLoader.url = UIPackage.GetItemURL("_movie" , "MovieShengYin"..shengYinMovie)
                else
                    shengYinLoader.url = nil
                end
            end    
        end
    elseif type == 20 then
        cell.data = {type = type,data = data}
        --剑神装备
        itemObj.touchable = true
        local param = {}
        param.mid = data.id 
        param.isquan = true
        --print("param.mid",param.mid)
        GSetItemData(itemObj, param, true)

        nameText.text =  data.name--conf.ItemConf:getName(param.mid)

        numImg.visible = data.redNum>0
    else
        itemObj.touchable = true
        local mid = data.id
        local itemData = cache.PackCache:getPackDataById(mid)
        itemData["mIndex"] = k
        itemData.isquan = true
        cell.data = {data,itemData,type = type}
        GSetItemData(itemObj, itemData, true)
        nameText.text = conf.ItemConf:getName(mid)
        local amount = itemData.amount
        if data.type == 8 or data.type == 9 then
            numImg.visible = false
        else
            numImg.visible = GIsHcData(data,self.buildReds)--红点
        end
        
    end
    
    local key = self.mIndex or 1
    if k == key then
        cell.selected = true
        local context = {sender = cell}
        self:onClickFuseItem(context)
    end
end

function FusePanel:onClickGodBtn(context)
    local part = self.part or 0
    if not self.composedata or not self.composedata.type then
        return 
    end
    mgr.ViewMgr:openView2(ViewName.SeeGodEquipView,{part = part,_type = self.composedata.type})
end
--复选框
function FusePanel:setChoose()
    self.checkBox.selected = false
    self.isSelect = false

    
end
--选取一次背包数据
function FusePanel:getPackData()
    -- body
    --放入之后清理之前的
    local _t = {}
    GSetItemData(self._HcIcon,_t,false)
    GSetItemData(self._HcIcon_3,_t,false)
    GSetItemData(self._HcIcon_xian,_t,false)
    GSetItemData(self.godEquip4,_t,false)
    GSetItemData(self.godEquip3,_t,false)
    local data = cache.PackCache:getPackDataByType(Pack.equipType)
    self.info = {}
    --能够合成神装的装备(也是装备)
    self.godInfo = {}
    local _aa = conf.ForgingConf:getComposeValue("compose_god_color_xin_jie")

    for k ,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if self.checkpart[condata.part] then
            if self.checkinfo[condata.color] 
            and condata.stage_lvl >= self.checkinfo[condata.color][3]
            and mgr.ItemMgr:getColorBNum(v) == self.checkinfo[condata.color][2] then
                if not self.info[condata.part] then
                    self.info[condata.part] = {}
                end
                if not self.info[condata.part][condata.color] then
                    self.info[condata.part][condata.color] = {}
                end
                if not self.info[condata.part][condata.color][condata.stage_lvl] then
                    self.info[condata.part][condata.color][condata.stage_lvl] = {}
                end
                table.insert(self.info[condata.part][condata.color][condata.stage_lvl],v)
            end
            --神装8~12部位
            if condata.color == _aa[1] and mgr.ItemMgr:getColorBNum(v) == _aa[2] and condata.stage_lvl >= _aa[3] then
                if not self.godInfo[condata.part] then
                    self.godInfo[condata.part] = {}
                end
                if not self.godInfo[condata.part][condata.color] then
                    self.godInfo[condata.part][condata.color] = {}
                end
                if not self.godInfo[condata.part][condata.color][condata.stage_lvl] then
                    self.godInfo[condata.part][condata.color][condata.stage_lvl] = {}
                end
                table.insert(self.godInfo[condata.part][condata.color][condata.stage_lvl],v)

            end
        else
            if condata.color >= conf.ForgingConf:getComposeValue("equip_compose_min_color") 
            and mgr.ItemMgr:getColorBNum(v) == conf.ForgingConf:getComposeValue("equip_compose_min_star") 
            and condata.stage_lvl >= conf.ForgingConf:getComposeValue("equip_compose_min_jie") then
                --橙色基本条件
                if not self.info[condata.color] then
                    self.info[condata.color] = {}
                end
                if not self.info[condata.color][condata.stage_lvl] then
                    self.info[condata.color][condata.stage_lvl] = {}
                end

                table.insert(self.info[condata.color][condata.stage_lvl],v)
            end
            --神装1~8部位
            if condata.color >= _aa[1] and mgr.ItemMgr:getColorBNum(v) == _aa[2] and condata.stage_lvl >= _aa[3] then
                if not self.godInfo[condata.color] then
                    self.godInfo[condata.color] = {}
                end
                if not self.godInfo[condata.color][condata.stage_lvl] then
                    self.godInfo[condata.color][condata.stage_lvl] = {}
                end
                table.insert(self.godInfo[condata.color][condata.stage_lvl],v)
            end
        end

    end
    local petdata = cache.PackCache:getPackDataByType(Pack.equippetType)
    self.petinfo = {}
    local gg = conf.ForgingConf:getComposeValue("compose_pet_color_xin")
    for k ,v in pairs(petdata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color >= gg[1]
        and mgr.ItemMgr:getColorBNum(v) == gg[2] then
            --橙色基本条件
            if not self.petinfo[condata.color] then
                self.petinfo[condata.color] = {}
            end
            table.insert(self.petinfo[condata.color],v)
        end
    end

    local wuxingdata = cache.PackCache:getPackDataByType(Pack.wuxing)
    self.wuxingdata = {}
    self.wuxingdata_3 = {}
    for k ,v in pairs(wuxingdata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if self.checkinfowuxing[condata.color] 
        and condata.color >= self.checkinfowuxing[condata.color][1]
        and mgr.ItemMgr:getColorBNum(v) == self.checkinfowuxing[condata.color][2] then
            if not self.wuxingdata[condata.part] then
                self.wuxingdata[condata.part] = {}
            end
            if not self.wuxingdata[condata.part][condata.color] then
                self.wuxingdata[condata.part][condata.color] = {}
            end
            table.insert(self.wuxingdata[condata.part][condata.color],v)
        end

        if condata.color == 6 and mgr.ItemMgr:getColorBNum(v) == 3 then
            if not self.wuxingdata_3[condata.part] then
                self.wuxingdata_3[condata.part] = {}
            end

            table.insert(self.wuxingdata_3[condata.part],v)
            --print("condata.part",condata.part,#self.wuxingdata_3[condata.part])
        end
    end

  
    local xiandata = cache.PackCache:getPackDataByType(Pack.xianzhuang)
    self.xiandata = {}
    for k ,v in pairs(xiandata) do
        local condata = conf.ItemConf:getItem(v.mid)
        if self.checkxianpart[condata.part] then
            --print("指定部位",condata.part,self.checkxianinfo[condata.color] )
            if self.checkxianinfo[condata.color] 
            and condata.stage_lvl >= self.checkxianinfo[condata.color][3]
            and mgr.ItemMgr:getColorBNum(v) == self.checkxianinfo[condata.color][2] then
                if not self.xiandata[condata.part] then
                    self.xiandata[condata.part] = {}
                end
                if not self.xiandata[condata.part][condata.color] then
                    self.xiandata[condata.part][condata.color] = {}
                end
                if not self.xiandata[condata.part][condata.color][condata.stage_lvl] then
                    self.xiandata[condata.part][condata.color][condata.stage_lvl] = {}
                end
                table.insert(self.xiandata[condata.part][condata.color][condata.stage_lvl],v)
            end
        else
            if condata.color >= conf.ForgingConf:getComposeValue("equip_compose_min_color_xian") 
            and mgr.ItemMgr:getColorBNum(v) == conf.ForgingConf:getComposeValue("equip_compose_min_star_xian") 
            and condata.stage_lvl >= conf.ForgingConf:getComposeValue("equip_compose_min_jie_xian") then
                --橙色基本条件
                if not self.xiandata[condata.color] then
                    self.xiandata[condata.color] = {}
                end
                if not self.xiandata[condata.color][condata.stage_lvl] then
                    self.xiandata[condata.color][condata.stage_lvl] = {}
                end
                table.insert(self.xiandata[condata.color][condata.stage_lvl],v)
            end
        end

    end

    self.xianGodNeedpart = conf.ForgingConf:getXianGodNeedPart()
    --仙装神装
    self.xianGod = cache.ComposeCache:getXianGodData()
    --神兽神装
    self.shenShouGod = {}
    --3星神兽装备
    self.shenShou_3 = {}
    local _bb = conf.ForgingConf:getComposeValue("shenshou_god_equip_color_xin_jie")
    local _ee = conf.ForgingConf:getComposeValue("shenshou_equip_color_xin_jie")
    local shenshouData = cache.PackCache:getPackDataByType(Pack.shenshouEquipType)
    for k,v in pairs(shenshouData) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color >= _bb[1] and mgr.ItemMgr:getColorBNum(v) == _bb[2] and condata.stage_lvl >= _bb[3] then--神装
            if not self.shenShouGod[condata.color] then
                self.shenShouGod[condata.color] = {}
            end
            if not self.shenShouGod[condata.color][condata.stage_lvl] then
                self.shenShouGod[condata.color][condata.stage_lvl] = {}
            end
            table.insert(self.shenShouGod[condata.color][condata.stage_lvl],v)
        elseif condata.color >= _ee[1] and mgr.ItemMgr:getColorBNum(v) == _ee[2]and condata.stage_lvl >= _ee[3] then--3星红
            if not self.shenShou_3[condata.color] then
                self.shenShou_3[condata.color] = {}
            end
            -- if not self.shenShou_3[condata.color][condata.stage_lvl] then
            --     self.shenShou_3[condata.color][condata.stage_lvl] = {}
            -- end
            --神兽3星红不需要阶字段
            table.insert(self.shenShou_3[condata.color],v)
        end
    end
    --八门元素
    self.element_3 = {}
    local _ff = conf.ForgingConf:getComposeValue("compose_eight_gates_color_xin_jie")
    local data = cache.PackCache:getElementPackData()
    for k,v in pairs(data) do
        local condata = conf.ItemConf:getItem(v.mid)
        if condata.color >= _ff[1] and mgr.ItemMgr:getColorBNum(v) == _ff[2] and condata.stage_lvl >= _ff[3] then--元素
            if not self.element_3[condata.color] then
                self.element_3[condata.color] = {}
            end
            table.insert(self.element_3[condata.color],v)
        end
    end
end

function FusePanel:isCanCompose(v)
    -- body
    if v.type == 19 then
        return GGetCompseSYByMid(v.id)>0
    elseif v.type == 20 then
        return GGetCompseJSByMid(v.id)>0
    elseif v.type == 21 or (v.type == 6 and v.color == 7) then--神装
        return self:getGodCompose(v)
    elseif v.type == 7 and v.color == 7 then--神装
        return self:getGodCompose(v)
    elseif v.type == 22 then--神兽神装
        return self:getShenShouGodCompose(v)
    elseif v.type == 23 then--神兽3星红
        if not self.shenShou_3 then
            return false
        end
        if not self.shenShou_3[v.color] then
            return false
        end
        return #self.shenShou_3[v.color] >= 3
    elseif v.type == 24 then--元素3星红
        if not self.element_3 then
            return false
        end
        if not self.element_3[v.color] then
            return false
        end
        return #self.element_3[v.color] >= 3
    elseif v.type == 25 then--仙装神装
        return self:getXianZhuangGodCompose(v)
    elseif v.type == 10 or v.type == 11 then
        --宠物装备
        if not self.petinfo then
            return false
        end
        if not self.petinfo[v.color] then
            return false
        end
        return #self.petinfo[v.color] >= 5
    elseif v.type == 14 or v.type == 15 then
        --五行装备是否能够合成
         if not self.wuxingdata[v.part] then
            return false
        end
        if not self.wuxingdata[v.part][v.color] then
            return false
        end
        local _compose = conf.WuxingConf:getEquipCompose(1,v.color,2)
        local need = cache.PackCache:getPackDataById(_compose.cost_item[1])
        return #self.wuxingdata[v.part][v.color] >= 5 and _compose.cost_item[2] <= need.amount
    elseif v.type == 16 then
         if not self.wuxingdata_3[v.part] then
            return false
        end
        local _compose = conf.WuxingConf:getEquipCompose(2,6,3)
        return #self.wuxingdata_3[v.part] >= 2 and _compose.cost_money[2] <= cache.PlayerCache:getTypeMoney(_compose.cost_money[1]) 
    elseif v.type == 18 then
        if not self.xiandata then
            return false
        end
        if self.checkxianpart[v.part] then
            if not self.xiandata[v.part] or not self.xiandata[v.part][v.color] then
                return false
            end
            for k ,var in pairs(self.xiandata[v.part][v.color]) do
                if #var >= 3 then
                    return true
                end
            end
        else
            if not self.xiandata[v.color] then
                return false
            end
            for k ,var in pairs(self.xiandata[v.color]) do
                if #var >= 3 then
                    return true
                end
            end
        end
        return false
    end
    if not self.info then
        return false
    end  
    if self.checkpart[v.part] then
        --特别的部位
        if not self.info[v.part] then
            return false
        end
        if not self.info[v.part][v.color] then
            return false
        end
        for k ,var in pairs(self.info[v.part][v.color]) do
            if #var >= 5 then
                return true
            end
        end
    else
        if not self.info[v.color] then
            return false
        end
        for k ,var in pairs(self.info[v.color]) do
            if #var >= 5 then
                return true
            end
        end
    end
    return false
end
--仙装神装
function FusePanel:getXianZhuangGodCompose(v)
    if not self.xianGod then
        return false
    end
    if not self.xianGod[v.part] then
        return false
    end
    if not self.xianGod[v.part][v.color-1] then--v是配置,配置中的color是7，self.xianGod是获取背包内的红装
        return false
    end
    --部位同阶的个数
    local partJieNum = {}
    if not partJieNum[v.part] then
        partJieNum[v.part] = {}
    end
    for k,needpart in pairs(self.xianGodNeedpart[v.part]) do
        if self.xianGod[needpart] and self.xianGod[needpart][v.color-1] then
            for i,j in pairs(self.xianGod[needpart][v.color-1]) do
                if not partJieNum[v.part][i] then
                    partJieNum[v.part][i] = #j
                else
                    partJieNum[v.part][i] = partJieNum[v.part][i]+ #j
                end
            end
        end
    end
    -- printt("@@@",partJieNum)
    for jie,sameJieNum in pairs(partJieNum[v.part]) do
        if sameJieNum >= 3 then
            local id = ((((100+Pack.xianzhuang)*100+v.color)*100+jie)*100+v.part)
            local godEquipCost = conf.ForgingConf:getXianEquipCompose(id)
            if not godEquipCost then
                return
            end
            local listnumber = {}
            if godEquipCost.cost_item then
                for _,j in pairs(godEquipCost.cost_item) do
                    local _packdata = cache.PackCache:getPackDataById(j[1])
                    table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                end
                local canComposeNum = math.min(unpack(listnumber))
                if canComposeNum > 0 then
                    return true
                end
            end
        end
    end
end

--神兽神兽神装
function FusePanel:getShenShouGodCompose(v)
    if not self.shenShouGod then
        return false
    end
    if not self.shenShouGod[v.color-1] then--v是配置,配置中的color是7，self.shenShouGod是获取背包内的红装
        return false
    end
    for k ,var in pairs(self.shenShouGod[v.color-1]) do
        if #var >= 3 then
            local id = ((100+v.color)*100+k)*100+v.part
            local godEquipCost = conf.ShenShouConf:getShenShouGodEquipCompose(id)
            if not godEquipCost then
                print("@策划  神兽配置合成表没有",id)
                return
            end
            local listnumber = {}
            for _,j in pairs(godEquipCost.cost_item) do
                local _packdata = cache.PackCache:getPackDataById(j[1])
                table.insert(listnumber,math.floor(_packdata.amount/j[2]))
            end
            local canComposeNum = math.min(unpack(listnumber))
            if canComposeNum > 0 then
                return true
            end
        end
    end
end
--神(粉)装
function FusePanel:getGodCompose(v)
    if self.checkpart[v.part] then
        --特别的部位
        if not self.godInfo[v.part] then
            return false
        end
        if not self.godInfo[v.part][v.color-1] then
            return false
        end
        local num = 1
        if v.part == 11 or v.part == 12 then
            num = 1
        elseif v.part == 9 or v.part == 10 then
            num = 3
        end
        for k ,var in pairs(self.godInfo[v.part][v.color-1]) do
            if #var >= num then
                local id = ((100+v.color)*100+k)*100+v.part
                local godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
                local listnumber = {}
                if not godEquipCost then
                    print("@策划  合成配置神装表没有",id)
                    return false
                end
                for _,j in pairs(godEquipCost.cost_item) do
                    local _packdata = cache.PackCache:getPackDataById(j[1])
                    table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                end
                local canComposeNum = math.min(unpack(listnumber))
                if canComposeNum > 0 then--只有找到符合条件的合成选项才能renturn
                    return true
                end
                -- return math.min(unpack(listnumber)) > 0
            end
        end
    else
        if not self.godInfo[v.color-1] then--v是配置,配置中的color是7，self.godInfo是获取背包内的红装
            return false
        end
        for k ,var in pairs(self.godInfo[v.color-1]) do
            if #var >= 3 then
                local id = ((100+v.color)*100+k)*100+v.part
                local godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
                if not godEquipCost then
                    print("@策划  合成配置神装表没有",id)
                    return
                end
                local listnumber = {}
                for _,j in pairs(godEquipCost.cost_item) do
                    local _packdata = cache.PackCache:getPackDataById(j[1])
                    table.insert(listnumber,math.floor(_packdata.amount/j[2]))
                end
                local canComposeNum = math.min(unpack(listnumber))
                if canComposeNum > 0 then--只有找到符合条件的合成选项才能renturn
                    return true
                end
                -- return math.min(unpack(listnumber)) > 0
            end
        end
    end
    return false
end

function FusePanel:setFuseList(buildReds)
    self.buildReds = buildReds
end

function FusePanel:setData()
    --print(debug.traceback())
    --设置左边列表
    -- self.mSuitData = conf.ForgingConf:getSuitFuse()
    -- self:clear()
    self:setListViewData()
    --默认选择
    -- self.fuseData = nil
    -- self.itemData = nil
    -- self.materData = nil
    -- self.fuseText.text = 1
    self:setSclelctData(self.fuseData,self.itemData)
end

function FusePanel:getCanCompose(suits,flag)
    -- body
    local compose = {}
    for k,v in pairs(suits) do
        local _t = clone(v)
        if flag then
            --只要有红点的
            if self:isCanCompose(v) then
                _t.redNum = 1
                table.insert(compose,_t)
            end
        else
            if self:isCanCompose(v) then
                _t.redNum = 1
            else
                _t.redNum = 0
            end
            table.insert(compose,_t)
        end
    end

    return compose
end

function FusePanel:setListViewData()
    local num = 0
    self.listView.numItems = 0
    -- plog("1",#self.mSuitData)
    for k,data in pairs(self.mSuitData) do
        num = num + 1
        local url = UIPackage.GetItemURL("forging" , "FuseItem")
        local obj = self.listView:AddItemFromPool(url)
        --红点计算
        local redNum = 0 
        if data.type == 1 then
            --3星神装 2星红装
            redNum = GGetCompseNum(6)
        elseif data.type == 0 then 
            --2星红妆 2星橙装 
            redNum = GGetCompseNum(5)
        elseif data.type == 6 or data.type == 7 then
            --2017/12-3 
            --新增合成功能
            --红点按部位和颜色
            local param = {}
            for i , j in pairs(data.suitData) do
                param[j.part] = true
            end
            for i , j in pairs(param) do
                redNum = redNum + GGetCompseNum1(i)
            end
        elseif data.type == 10 then
            redNum = GGetCompsePetNum(5)
        elseif data.type == 11 then
            redNum = GGetCompsePetNum(6)
        elseif data.type == 14 then
            --五行装备合成
            for i = 1 , 5 do
                redNum = redNum + GGetCompseWuxingNum(i,5)
            end
            for i = 1 , 5 do
                redNum = redNum + GGetCompseWuxingNum(i,6)
            end
        elseif data.type == 15 then
            --五行装备合成
            for i = 1 , 5 do
                redNum = redNum + GGetCompseWuxingNum(i,6)
            end
        elseif data.type == 16 then
            for i = 1 , 5 do
                redNum = redNum + GGetCompseWuxingNum_1(i)
            end
        elseif data.type == 18 then
            --仙装
            redNum = redNum + GGetCompseXianNum(5) + GGetCompseXianNum(6) 
            for k , v in pairs(self.checkxianpart) do
                redNum = redNum + GGetCompseNum2(k)
            end
        elseif data.type == 19 then
            redNum = redNum + GGetCompseSY(19)
        elseif data.type == 20 then
            redNum = redNum + GGetCompseJS()
        elseif data.type == 21 then
            redNum = redNum +GGetCompseGod1()
        elseif data.type == 22 then
            redNum = redNum + GGetCompseShenShouGod()
            -- print("redNum",redNum,GGetCompseShenShouGod())
        elseif data.type == 23 then
            --3星神兽装备
            redNum = redNum + GGetCompseShenShouNum(6)
        elseif data.type == 24 then--3星红八门元素
            redNum = redNum + GGetElementCompse()
        elseif data.type == 25 then--仙装神装
            local param = {}
            for i , j in pairs(data.suitData) do
                param[j.part] = true
            end

            for i , j in pairs(param) do
                redNum = redNum + GGetCompseXianGodNum(i)
            end
        else
            if data.type == 9 or  data.type == 8 then
                redNum = 0
            else
                redNum = GGetSuitProNum(data.suitData,self.buildReds)
            end
        end
        data.redNum = redNum
        self:cellSuitData1(data,obj)

        if data.open == 1 then
            --当前选中项 的 小项目
            self.num = num
            local suits = data.suitData
            if self.isSelect then
                if data.type <= 1 then
                    suits = self:getCanCompose(suits,true) --计算那几阶的装备够合成
                elseif data.type == 6 or data.type == 7 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 10 or data.type == 11 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 14 or data.type == 15 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 16 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 18 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 19 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 20 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 21 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 22 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 23 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 24 then
                    suits = self:getCanCompose(suits,true)
                elseif data.type == 25 then
                    suits = self:getCanCompose(suits,true)
                else
                    suits = GGetProId(suits,self.buildReds)
                end
            else
                if data.type <= 1 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 6 or data.type == 7 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 10 or data.type == 11 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 14 or data.type == 15 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 16 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 18 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 19 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 20 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 21 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 22 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 23 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 24 then
                    suits = self:getCanCompose(suits)
                elseif data.type == 25 then
                    suits = self:getCanCompose(suits)
                end
            end
            for k,suitData in pairs(suits) do
                local url = UIPackage.GetItemURL("forging" , "FuseProItem")
                local obj = self.listView:AddItemFromPool(url)
                local _t = clone(suitData)
                _t.isquan = true
                self:cellSuitData2(_t, obj, k,data.type)
                num = num + 1
            end  
        end
    end
    if self.num then
        self.listView:ScrollToView(self.num - 1)
        self.num = nil
    end
end
--套装预览
function FusePanel:onClickFuseSuit(context)
     local data = context.sender.data
    -- if data.type == 1 or data.type == 0 or data.type == 6 or data.type == 7 then
    --     self.c1.selectedIndex = 1
    -- else
    --     self.c1.selectedIndex = 0
    -- end
    --
    self.moneyicon.url = UIItemRes.moneyIcons[MoneyType.bindCopper]
    self.plus.visible = false
    self.n41.visible = true
    self.ruleId = 1007
    if tonumber(data.type) == 1 or tonumber(data.type) == 11 then--bxp10改11
        self.c1.selectedIndex = 1
        self.fuseBtn02Text.text = language.forging60
    elseif tonumber(data.type) == 0 or tonumber(data.type) == 10 then
        self.c1.selectedIndex = 1
        self.fuseBtn02Text.text = language.forging56
    elseif tonumber(data.type) == 6 then
        self.c1.selectedIndex = 1
        self.ruleId = 1070
        self.fuseBtn02Text.text = ""
    elseif tonumber(data.type) == 7 then
        self.c1.selectedIndex = 1
        self.fuseBtn02Text.text = ""
        self.ruleId = 1071
    elseif tonumber(data.type) == 14 or tonumber(data.type) == 15 then
        self.c1.selectedIndex = 1
        self.fuseBtn02Text.text = ""
        local _compose = conf.WuxingConf:getEquipCompose(1,5,2)
        if _compose.cost_item then
            self.moneyicon.url = ResPath.iconRes("jianling_016")
            self.plus.data = {mid = _compose.cost_item[1]} 
            self.plus.visible = true 
        end
    elseif tonumber(data.type) == 16 then    
        self.c1.selectedIndex = 2
    elseif tonumber(data.type) == 18 then 
        self.c1.selectedIndex = 3
        self.fuseBtn02Text.text = ""
    elseif tonumber(data.type) == 19 then
        self.c1.selectedIndex = 4
        self.fuseBtn02Text.text = ""
    elseif tonumber(data.type) == 20 then
        self.ruleId = 1148
        self.c1.selectedIndex = 0
    elseif tonumber(data.type) == 21 then
        self.c1.selectedIndex = 5
        -- self.seeGodEquipBtn.visible = false
        self.ruleId = 1151
    elseif tonumber(data.type) == 22 then
        self.c1.selectedIndex = 5
        self.ruleId = 1152
        -- self.seeGodEquipBtn.visible = false
    elseif tonumber(data.type) == 23 then
        self.c1.selectedIndex = 3
    elseif tonumber(data.type) == 24 then
        self.c1.selectedIndex = 3
        self.moneyGroup_xian.visible = false
        -- self.n41.visible = false
        -- self.moneyicon.url = ""
        -- self.moneyCost.text = ""
    elseif tonumber(data.type) == 25 then
        self.c1.selectedIndex = 5
        self.ruleId = 1162
        -- self.seeGodEquipBtn.visible = false
    else
        self.c1.selectedIndex = 0
    end
    self:onController1()

    self.mIndex = nil
    for k,v in pairs(self.mSuitData) do
        if data.type == v.type then
            if v.open == 0 then--关
                self.mSuitData[k].open = 1
            else
                self.mSuitData[k].open = 0
            end
        else
            self.mSuitData[k].open = 0
        end
    end
    self:setListViewData()
end

function FusePanel:onClickFuseItem(context)
    local cell = context.sender
    local data = cell.data
    if data.type == 21 or data.type == 6 or data.type == 7 or data.type == 25 then
        self.part = data.data.part or 0
    end
    if data.type <= 1  or data.type == 6 or data.type == 7 
    or data.type == 10 or data.type == 11 
    or data.type == 14 or data.type == 15
    or data.type == 16 or data.type == 18 
    or data.type == 19 or data.type == 20 
    or data.type == 21 or data.type == 22 
    or data.type == 23 or data.type == 24 
    or data.type == 25 then
        --装备
        if data.type == 14 then
            local _compose = conf.WuxingConf:getEquipCompose(1,data.data.color,2)
            if _compose.cost_item then
                if data.data.color == 5 then
                    self.moneyicon.url = ResPath.iconRes("jianling_016")
                else
                    self.moneyicon.url = ResPath.iconRes("jianling_017")
                end
                self.plus.data = {mid = _compose.cost_item[1]} 
                self.plus.visible = true 
            end
        end
        if data.type == 6 then
            if data.data.color == 7 then
                self.c1.selectedIndex = 5
                self.seeGodEquipBtn.visible = true
            else
                self.c1.selectedIndex = 1
                self.seeGodEquipBtn.visible = false
            end
        end
        if data.type == 7 then
            if data.data.color == 7 then
                self.seeGodEquipBtn.visible = true
                self.c1.selectedIndex = 6
            else
                self.seeGodEquipBtn.visible = false
                self.c1.selectedIndex = 1
            end
        end
        self:setCompose(data.data) 
    else
        self.fuseNum = 1
        self.fuseText.text = self.fuseNum
        self:setSclelctData(data[1],data[2])
    end
end
--合成信息设置
function FusePanel:setCompose(data)
    -- body
    --放入之后清理之前的
    local _t = {}
    GSetItemData(self._HcIcon,_t,false)
    GSetItemData(self._HcIcon_3,_t,false)
    GSetItemData(self._HcIcon_xian,_t,false)
    GSetItemData(self.godEquip4,_t,false)
    GSetItemData(self.godEquip3,_t,false)

    self.composedata = data
    self:clearinfo()
    --检测放

    self:checkInput()
    if self.composedata.desc then
        self.fuseBtn02Text.text = self.composedata.desc
    end
end

function FusePanel:checkInput()
    -- body
    if not self.composedata then
        return
    end
    if self.composedata.type == 20 then
        local condata = conf.AwakenConf:getJScomposeInfo(self.composedata.id)

        local data = {mid = self.composedata.id}
        data.isquan = true
        data.eStar = condata.tar_star
        GSetItemData(self.prosObj, data, true)--显示要合成的道具

        self.prosName.text =self.composedata.name-- conf.ItemConf:getName(data.mid)
        local need = condata.need_item[2]
        local packdata = cache.PackCache:getShenZhuangDebrisNum( condata.need_item[1])

        local data = {mid = condata.need_item[1]}
        data.eStar = math.max(0,condata.tar_star-1)
        data.isquan = true
        GSetItemData(self.materObj, data, true)

        self.materName.text = conf.ItemConf:getName(data.mid)

        local param = {}
        param.mid = condata.need_item[1]
        self.materData = param

        self.fuseNum = 1
        self.maxFuseNum = math.floor(packdata.amount / need) 
        local str = ""
        if need > packdata.amount then
            str = mgr.TextMgr:getTextColorStr( tostring(packdata.amount), 14)
        else
            str = mgr.TextMgr:getTextColorStr( tostring(packdata.amount), 7)
        end
        self.materNum.text = str .. mgr.TextMgr:getTextColorStr("/"..tostring(need), 7)
        return
    elseif self.composedata.type == 16 then
        if self.wuxingdata_3[self.composedata.part] then
            for k ,v in pairs(self.equiplist3) do
                if not v.data.data  then 
                    self.frame3[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        end
        self.btnAutoRed_3.visible = self:isCanCompose(self.composedata)
        return
    elseif self.composedata.type == 22 then--神兽神装
        if self.shenShouGod[self.composedata.color-1] then
            for k,v in pairs(self.godEquipList4) do
                if not v.data.data then
                    self.godFrame4[k].url = nil
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        end
        return
    elseif self.composedata.type == 21 then--神装1~8
        if self.godInfo[self.composedata.color-1] then--1~8部位
            for k,v in pairs(self.godEquipList4) do
                if not v.data.data then
                    self.godFrame4[k].url = nil
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        end
        return
    elseif self.composedata.type == 25 then--仙-神
        local needPartList = self.xianGodNeedpart[self.composedata.part]
        for k,v in pairs(needPartList) do
            if self.xianGod[v] and self.xianGod[v][self.composedata.color-1] then
                for k,v in pairs(self.godEquipList4) do
                    if not v.data.data then
                        self.godFrame4[k].url = nil
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        end
        return
    elseif self.composedata.type == 6 and self.composedata.color == 7  then--神装9~10
        if self.godInfo[self.composedata.part] and self.godInfo[self.composedata.part][self.composedata.color-1] then
            for k,v in pairs(self.godEquipList4) do
                if not v.data.data then
                    self.godFrame4[k].url = nil
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        end
        return
    elseif self.composedata.type == 7 and self.composedata.color == 7  then--神装11~12
        if self.godInfo[self.composedata.part] and self.godInfo[self.composedata.part][self.composedata.color-1] then
            for k,v in pairs(self.godEquipList3) do
                if not v.data.data then
                    self.godFrame3[k].url = nil
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        end
        return
    elseif self.composedata.type == 19 then
        self.max19 = GGetCompseSYByMid(self.composedata.id)
        local condata = conf.ShengYinConf:getSycompose(self.composedata.id)
        local cb = function(comp,mid,flag)
            -- body
            local t = {}
            t.mid = mid 
            t.isquan = 0
            GSetItemData(comp:GetChild("n1"), t,true)
            comp:GetChild("n3").text = conf.ItemConf:getName(t.mid)
            
            if flag then
                local packData = cache.PackCache:getPackDataById(mid)
                local color = tonumber(packData.amount) >= tonumber(condata.cost_item[1][2]) and 10 or 14
                local textData = {
                    {text = packData.amount,color = color},
                    {text = "/"..condata.cost_item[1][2],color = 10},
                }
                comp:GetChild("n4").text = mgr.TextMgr:getTextByTable(textData)
            else
                local packData = cache.PackCache:getShengYinById(mid)
                local color = tonumber(packData.amount) >= tonumber(condata.need_num) and 10 or 14
                local textData = {
                    {text = packData.amount,color = color},
                    {text = "/"..condata.need_num,color = 10},
                }
                comp:GetChild("n4").text = mgr.TextMgr:getTextByTable(textData)
            end
            comp:GetChild("n2").data = {mid = mid}  
        end
        --print("self.composedata.id",self.composedata.id)
        cb(self.leftinfo,self.composedata.id )
        cb(self.rightinfo,condata.cost_item[1][1],true)

        GSetItemData(self.middle_ss, {mid = condata.tar_item[1][1],isquan = 0},true)
        self.labjcsb.text = mgr.TextMgr:getColorNameByMid(condata.tar_item[1][1]) 

        self.number_C = self.max19
        self.lab_number.text = self.max19
        return
    end


    local number = 0 --已经放入了几个
    local color 
    local stage_lvl 
    for k ,v in pairs(self.equiplist) do
        if v.data.data then
            number = number + 1
            local condata = conf.ItemConf:getItem(v.data.data.mid)
            color = condata.color
            stage_lvl = condata.stage_lvl
        end
    end


    --检测是否有装备可添加
    if not color then
        if self.composedata.type == 10 or self.composedata.type == 11 then
            for k ,v in pairs(self.equiplist) do
                self.frame[k].url = nil
                if not v.data.data then
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        elseif self.composedata.type == 14 or self.composedata.type == 15 then
            if self.wuxingdata[self.composedata.part] 
            and self.wuxingdata[self.composedata.part][self.composedata.color] then
                for k ,v in pairs(self.equiplist) do
                    self.frame[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        elseif self.composedata.type == 18 then
            if self.checkxianpart[self.composedata.part] then
                --特别的部位
                if self.xiandata[self.composedata.part] 
                and self.xiandata[self.composedata.part][self.composedata.color] then
                    for k ,v in pairs(self.equipxianlist) do
                        self.frame[k].url = nil
                        if not v.data.data then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号 
                        end
                    end
                end
            elseif self.xiandata[self.composedata.color] then
                for k ,v in pairs(self.equipxianlist) do
                    self.frame[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        elseif self.composedata.type == 23 then --神兽3星
            if self.shenShou_3[self.composedata.color] then
                for k ,v in pairs(self.equipxianlist) do
                    self.frame[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        elseif self.composedata.type == 24 then --元素3星
            if self.element_3[self.composedata.color] then
                for k ,v in pairs(self.equipxianlist) do
                    self.frame[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        elseif self.checkpart[self.composedata.part] then
            --特别的部位
            if self.info[self.composedata.part] 
            and self.info[self.composedata.part][self.composedata.color] then
                for k ,v in pairs(self.equiplist) do
                    self.frame[k].url = nil
                    if not v.data.data then
                        v.url = ResPath.iconload("baoshi_028","forging")--加号 
                    end
                end
            end
        elseif self.info[self.composedata.color] then
            for k ,v in pairs(self.equiplist) do
                self.frame[k].url = nil
                if not v.data.data then
                    v.url = ResPath.iconload("baoshi_028","forging")--加号 
                end
            end
        end
        self.btnAutoRed.visible = self:isCanCompose(self.composedata)
    else
        if self.composedata.type == 10 or self.composedata.type == 11 then
            if self.petinfo[color] then
                local flag = table.nums(self.petinfo[color]) > number
                for k ,v in pairs(self.equiplist) do
                    if not v.data.data  then
                        self.frame[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end
                
                if number == 5 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
        elseif self.composedata.type == 14 or self.composedata.type == 15 then
            if self.wuxingdata[self.composedata.part] 
            and self.wuxingdata[self.composedata.part][self.composedata.color] then
                local flag = table.nums(self.wuxingdata[self.composedata.part][color]) > (5-number)
                for k ,v in pairs(self.equiplist) do
                    if not v.data.data  then
                        self.frame[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end

                if number == 5 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
       
        elseif self.composedata.type == 18 then 
            if self.checkxianpart[self.composedata.part] then
                if self.xiandata[self.composedata.part]
                and self.xiandata[self.composedata.part][color] 
                and self.xiandata[self.composedata.part][color][stage_lvl] then
                    local flag = table.nums(self.xiandata[self.composedata.part][color][stage_lvl]) > number
                    for k ,v in pairs(self.equipxianlist) do
                        if not v.data.data  then
                            self.xianframe3[k].url = nil 
                            if flag then
                                v.url = ResPath.iconload("baoshi_028","forging")--加号
                            else
                                v.url = nil 
                            end
                        end
                    end

                    if number == 3 then
                        self.btnAutoRed.visible = false
                    else
                        self.btnAutoRed.visible = flag
                    end
                else
                    self.btnAutoRed.visible = self:isCanCompose(self.composedata)
                end
            else
                if self.xiandata[color] and self.xiandata[color][stage_lvl] then
                    local flag = table.nums(self.xiandata[color][stage_lvl]) > number
                    for k ,v in pairs(self.equipxianlist) do
                        if not v.data.data  then
                            self.xianframe3[k].url = nil 
                            if flag then
                                v.url = ResPath.iconload("baoshi_028","forging")--加号
                            else
                                v.url = nil 
                            end
                        end
                    end
                    
                    if number == 3 then
                        self.btnAutoRed.visible = false
                    else
                        self.btnAutoRed.visible = flag
                    end
                else
                    self.btnAutoRed.visible = self:isCanCompose(self.composedata)
                end
            end
        elseif self.composedata.type == 23 then 
            if self.shenShou_3[color] and self.shenShou_3[color][stage_lvl] then
                local flag = table.nums(self.shenShou_3[color][stage_lvl]) > number
                for k ,v in pairs(self.equipxianlist) do
                    if not v.data.data  then
                        self.xianframe3[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end
                if number == 3 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
        elseif self.composedata.type == 24 then--元素3星
            if self.element_3[color] then
                local flag = table.nums(self.element_3[color]) > number
                for k ,v in pairs(self.equipxianlist) do
                    if not v.data.data  then
                        self.xianframe3[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end
                if number == 5 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
        elseif self.checkpart[self.composedata.part] then
            if self.info[self.composedata.part]
            and self.info[self.composedata.part][color] 
            and self.info[self.composedata.part][color][stage_lvl] then
                local flag = table.nums(self.info[self.composedata.part][color][stage_lvl]) > number
                for k ,v in pairs(self.equiplist) do
                    if not v.data.data  then
                        self.frame[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end

                if number == 5 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
        else
            if self.info[color] and self.info[color][stage_lvl] then
                local flag = table.nums(self.info[color][stage_lvl]) > number
                for k ,v in pairs(self.equiplist) do
                    if not v.data.data  then
                        self.frame[k].url = nil 
                        if flag then
                            v.url = ResPath.iconload("baoshi_028","forging")--加号
                        else
                            v.url = nil 
                        end
                    end
                end
                
                if number == 5 then
                    self.btnAutoRed.visible = false
                else
                    self.btnAutoRed.visible = flag
                end
            else
                self.btnAutoRed.visible = self:isCanCompose(self.composedata)
            end
        end
    end
    
end

function FusePanel:ChooseBack( data )
    -- body
    if self.composedata.type == 21 or (self.composedata.type == 6 and self.composedata.color == 7) 
        or self.composedata.type == 22 
        or self.composedata.type == 25 then
        for k ,v in pairs(self.godEquipList4) do
            --v.data.data = nil 
            if v.data.data then
                if not data[v.data.data.index] then
                    --取消了选择
                   self:setInfo(v,nil)
                else
                    data[v.data.data.index] = nil 
                end
            end
        end

        local key = table.keys(data) 
        if key[1] then
            self:setInfo(self.godEquipList4[self.pos],data[key[1]])
            data[key[1]] = nil 
        end

        --找空位置
        if data then
            for k,v in pairs(data) do
                for i , j in pairs(self.godEquipList4) do
                    if not j.data.data then
                        self:setInfo(j,v)
                        break
                    end
                end
            end
        end
        self:checkInput()
        return
    elseif self.composedata.type == 7 and self.composedata.color == 7 then
        for k ,v in pairs(self.godEquipList3) do
            --v.data.data = nil 
            if v.data.data then
                if not data[v.data.data.index] then
                    --取消了选择
                   self:setInfo(v,nil)
                else
                    data[v.data.data.index] = nil 
                end
            end
        end

        local key = table.keys(data) 
        if key[1] then
            self:setInfo(self.godEquipList3[self.pos],data[key[1]])
            data[key[1]] = nil 
        end
        --找空位置
        if data then
            for k,v in pairs(data) do
                for i , j in pairs(self.godEquipList3) do
                    if not j.data.data then
                        self:setInfo(j,v)
                        break
                    end
                end
            end
        end
        self:checkInput()
        return
    elseif self.composedata.type == 16 then
        for k ,v in pairs(self.equiplist3) do
            --v.data.data = nil 
            if v.data.data then
                if not data[v.data.data.index] then
                    --取消了选择
                   self:setInfo(v,nil)
                else
                    data[v.data.data.index] = nil 
                end
            end
        end

        local key = table.keys(data) 
        if key[1] then
            self:setInfo(self.equiplist3[self.pos],data[key[1]])
            data[key[1]] = nil 
        end

        --找空位置
        if data then
            for k,v in pairs(data) do
                for i , j in pairs(self.equiplist3) do
                    if not j.data.data then
                        self:setInfo(j,v)
                        break
                    end
                end
            end
        end
        self:checkInput()
        return
    elseif self.composedata.type == 18 or self.composedata.type == 23 or self.composedata.type == 24 then
        for k ,v in pairs(self.equipxianlist ) do
            --v.data.data = nil 
            if v.data.data then
                if not data[v.data.data.index] then
                    --取消了选择
                   self:setInfo(v,nil)
                else
                    data[v.data.data.index] = nil 
                end
            end
        end
        --优先选择
        local key = table.keys(data) 
        if key[1] then
            self:setInfo(self.equipxianlist[self.pos],data[key[1]])
            data[key[1]] = nil 
        end
        --找空位置
        if data then
            for k,v in pairs(data) do
                for i , j in pairs(self.equipxianlist) do
                    if not j.data.data then
                        self:setInfo(j,v)
                        break
                    end
                end
            end
        end
        self:checkInput()
        return
    end
    for k ,v in pairs(self.equiplist) do
        --v.data.data = nil 
        if v.data.data then
            if not data[v.data.data.index] then
                --取消了选择
               self:setInfo(v,nil)
            else
                data[v.data.data.index] = nil 
            end
        end
    end
    --优先选择
    local key = table.keys(data) 
    if key[1] then
        self:setInfo(self.equiplist[self.pos],data[key[1]])
        data[key[1]] = nil 
    end
    --找空位置
    if data then
        for k,v in pairs(data) do
            for i , j in pairs(self.equiplist) do
                if not j.data.data then
                    self:setInfo(j,v)
                    break
                end
            end
        end
    end

    self:checkInput()
end

function FusePanel:inputEquip(context)
    -- body
    context:StopPropagation()
    if not self.composedata then
        return GComAlter(language.forging51)
    end
    local listdata = {}
    local param = {}
    param.btnlist = self.equiplist --控件
    if self.composedata.type == 10 or self.composedata.type == 11 then
        table.insert(listdata,self.petinfo[self.composedata.color])
        if not listdata then
            GComAlter(language.forging51)
            return 
        end
    elseif self.composedata.type == 14 or self.composedata.type == 15 then
        if not self.wuxingdata[self.composedata.part]
        or not self.wuxingdata[self.composedata.part][self.composedata.color] then
            GComAlter(language.forging51)
            return
        end
        table.insert(listdata,self.wuxingdata[self.composedata.part][self.composedata.color]) 
    elseif self.composedata.type == 16 then
        param.btnlist = self.equiplist3 --控件
        table.insert(listdata,self.wuxingdata_3[self.composedata.part]) 
    elseif self.composedata.type == 18 then
        param.btnlist = self.equipxianlist --控件
        if self.checkxianpart[self.composedata.part] then 
            if not self.xiandata[self.composedata.part]
            or not self.xiandata[self.composedata.part][self.composedata.color] then
                GComAlter(language.forging51)
                return
            end
            listdata = self.xiandata[self.composedata.part][self.composedata.color]
        else
            listdata = self.xiandata[self.composedata.color]
            if not listdata then
                GComAlter(language.forging51)
                return 
            end
        end
    elseif self.composedata.type == 25 then--仙-神
        param.btnlist = self.godEquipList4 --控件
        local needPartList = self.xianGodNeedpart[self.composedata.part]
        for k,v in pairs(needPartList) do
            if self.xianGod[v] and self.xianGod[v][self.composedata.color-1] then 
                for _,var in pairs(self.xianGod[v][self.composedata.color-1]) do
                    table.insert(listdata,var)
                end 
            end
        end
        if not listdata then
            GComAlter(language.forging51)
            return
        end
    elseif self.composedata.type == 24 then--3星元素
        param.btnlist = self.equipxianlist --控件
        table.insert(listdata,self.element_3[self.composedata.color])
        if not listdata then
            GComAlter(language.forging51)
            return
        end
    elseif self.composedata.type == 23 then--神兽3星红
        param.btnlist = self.equipxianlist --控件
        table.insert(listdata,self.shenShou_3[self.composedata.color])
        if not listdata then
            GComAlter(language.forging51)
            return 
        end
    elseif self.composedata.type == 22 then--神兽神装
        param.btnlist = self.godEquipList4
        listdata = self.shenShouGod[self.composedata.color-1]
        if not listdata then
            GComAlter(language.forging51)
            return 
        end
    elseif self.composedata.type == 21 then--神装
        param.btnlist = self.godEquipList4

        if self.checkpart[self.composedata.part] then 
            if not self.godInfo[self.composedata.part] or not self.godInfo[self.composedata.part][self.composedata.color-1] then
                GComAlter(language.forging51)
                return
            end
            listdata = self.godInfo[self.composedata.part][self.composedata.color-1]
        else
            listdata = self.godInfo[self.composedata.color-1]
            if not listdata then
                GComAlter(language.forging51)
                return 
            end
        end
    elseif self.checkpart[self.composedata.part] then 
        if (self.composedata.type == 6 or self.composedata.type == 7) and self.composedata.color == 7 then--9~12部位的神装
            if self.composedata.type == 6 then
                param.btnlist = self.godEquipList4
            elseif self.composedata.type == 7 then
                param.btnlist = self.godEquipList3
            end
            if not self.godInfo[self.composedata.part] or not self.godInfo[self.composedata.part][self.composedata.color-1] then
                GComAlter(language.forging51)
                return
            end
            listdata = self.godInfo[self.composedata.part][self.composedata.color-1]
        else
            if not self.info[self.composedata.part]
            or not self.info[self.composedata.part][self.composedata.color] then
                GComAlter(language.forging51)
                return
            end
            listdata = self.info[self.composedata.part][self.composedata.color]
        end
    else
        listdata = self.info[self.composedata.color]
        if not listdata then
            GComAlter(language.forging51)
            return 
        end
    end
    local data = context.sender.data
    self.pos = data.pos --点击位置 
    param.listdata = listdata --选择列表
    param.composedata =self.composedata
    param.callback = function(data)
        -- body
        self:ChooseBack(data)
    end
    mgr.ViewMgr:openView2(ViewName.ComposeChooseView,param)
end
--一键放入
function FusePanel:inPutAuto()
    -- body
    if not self.composedata then
        return GComAlter(language.forging51)
    end
    local var = 0
    local _clist = {}
    if self.composedata.type == 16 then
        for k ,v in pairs(self.equiplist3) do
            if v.data.data then
                var = var + 1
                _clist[v.data.data.index] = 1
            end
        end
        if var>= 2 then
            GComAlter(language.forging50)
            return 
        end
    elseif self.composedata.type == 18 or self.composedata.type == 23 or self.composedata.type == 24 then
        for k ,v in pairs(self.equipxianlist) do
            if v.data.data then
                var = var + 1
                _clist[v.data.data.index] = 1
            end
        end
        if var>= 3 then
            GComAlter(language.forging50)
            return 
        end
    else
        for k ,v in pairs(self.equiplist) do
            if v.data.data then
                var = var + 1
                _clist[v.data.data.index] = 1
            end
        end
    end
    if var >= 5 then
        GComAlter(language.forging50)
        return 
    end
    --没有可添加的
    if self.composedata.type == 16 then
        if not self.wuxingdata_3[self.composedata.part] or #self.wuxingdata_3[self.composedata.part]<2 then
            GComAlter(language.forging51)
            return
        end
        --开始放东西
        for k , v in pairs(self.equiplist3) do
            if not v.data.data then 
                for i , j in pairs(self.wuxingdata_3[self.composedata.part]) do
                    if not _clist[j.index] then
                        self:setInfo(v,j)
                        _clist[j.index]  = 1
                        break
                    end
                end
            end
        end
        return
    elseif self.composedata.type == 10 or self.composedata.type == 11 then
        if not self.petinfo[self.composedata.color] then
            GComAlter(language.forging51)
            return 
        end
        listdata = self.petinfo[self.composedata.color]
    elseif self.composedata.type == 14 or self.composedata.type == 15 then
        if not self.wuxingdata[self.composedata.part]
        or not self.wuxingdata[self.composedata.part][self.composedata.color]  then
            GComAlter(language.forging51)
            return
        end
        listdata = self.wuxingdata[self.composedata.part][self.composedata.color]
    elseif self.composedata.type == 18 then
        if self.checkxianpart[self.composedata.part] then 
            if not self.xiandata[self.composedata.part]
            or not self.xiandata[self.composedata.part][self.composedata.color]  then
                GComAlter(language.forging51)
                return
            end
            listdata = self.xiandata[self.composedata.part][self.composedata.color]
        else
            if not self.xiandata[self.composedata.color] then
                GComAlter(language.forging51)
                return 
            end
            listdata = self.xiandata[self.composedata.color]
        end 
    elseif self.composedata.type == 23 then
        if not self.shenShou_3[self.composedata.color] then
            GComAlter(language.forging51)
            return 
        end
        listdata = self.shenShou_3[self.composedata.color]

    elseif self.composedata.type == 24 then
        if not self.element_3[self.composedata.color] then
            GComAlter(language.forging51)
            return 
        end
        listdata = self.element_3[self.composedata.color]
    elseif self.checkpart[self.composedata.part] then 
        if not self.info[self.composedata.part]
        or not self.info[self.composedata.part][self.composedata.color]  then
            GComAlter(language.forging51)
            return
        end
        listdata = self.info[self.composedata.part][self.composedata.color]
    else
        if not self.info[self.composedata.color] then
            GComAlter(language.forging51)
            return 
        end
        listdata = self.info[self.composedata.color]
    end
    
    
    --先检测当前放入品质
    local color 
    local stage_lvl 
    if var > 0 then
        if self.composedata.type == 18 or self.composedata.type == 23 or self.composedata.type == 24 then
            for k ,v in pairs(self.equipxianlist ) do
                if v.data.data then
                    local condata = conf.ItemConf:getItem(v.data.data.mid)
                    color = condata.color
                    stage_lvl = condata.stage_lvl
                    break
                end
            end
        else
            for k ,v in pairs(self.equiplist) do
                if v.data.data then
                    local condata = conf.ItemConf:getItem(v.data.data.mid)
                    color = condata.color
                    stage_lvl = condata.stage_lvl
                    break
                end
            end
        end
    end
    if color then
        --已经有放入
        local flag = false
        if not listdata then
            --print("listdata",listdata)
            return--容错 
        end

        if self.composedata.type == 18 then
            if not listdata[stage_lvl] then
                return --容错 
            end
            for k , v in pairs(self.equipxianlist) do
                if not v.data.data  then
                    for i , j in pairs(listdata[stage_lvl]) do
                        if not _clist[j.index] then
                            --printt("j",j )
                            self:setInfo(v,j)
                            _clist[j.index]  = 1
                            flag = true
                            --print("添加一个",k)
                            break
                        end
                    end
                end
            end
        elseif self.composedata.type == 23 or self.composedata.type == 24 then
            for k , v in pairs(self.equipxianlist) do
                if not v.data.data  then
                    for i , j in pairs(listdata) do
                        if not _clist[j.index] then
                            self:setInfo(v,j)
                            _clist[j.index]  = 1
                            flag = true
                            break
                        end
                    end
                end
            end
        -- elseif self.composedata.type == 24 then 
        --     for k , v in pairs(self.equipxianlist) do
        --         if not v.data.data  then
        --             for i , j in pairs(listdata) do
        --                 if not _clist[j.index] then
        --                     self:setInfo(v,j)
        --                     _clist[j.index]  = 1
        --                     flag = true
        --                     break
        --                 end
        --             end
        --         end
        --     end
        elseif self.composedata.type == 10 or self.composedata.type == 11 then
            for k , v in pairs(self.equiplist) do
                if not v.data.data  then
                    for i , j in pairs(listdata) do

                        if not _clist[j.index] then
                            self:setInfo(v,j)
                            _clist[j.index]  = 1
                            flag = true
                            --print("添加一个",k)
                            break
                        end
                    end
                end
            end
        elseif self.composedata.type == 14 or self.composedata.type == 15 then 
            for k , v in pairs(self.equiplist) do
                if not v.data.data  then
                    for i , j in pairs(listdata) do
                        if not _clist[j.index] then
                            self:setInfo(v,j)
                            _clist[j.index]  = 1
                            flag = true
                            --print("添加一个",k)
                            break
                        end
                    end
                end
            end
       
        else
            if not listdata[stage_lvl] then
                return --容错 
            end
            for k , v in pairs(self.equiplist) do
                if not v.data.data then 
                    --这个位置没有东西
                    for i , j in pairs(listdata[stage_lvl]) do
                        if not _clist[j.index] then
                            self:setInfo(v,j)
                            _clist[j.index]  = 1
                            flag = true
                            break
                        end
                    end
                end
            end
        end
        if not flag then
            return GComAlter(language.forging51)
        end
    else
        --检测当前能合成的放入
        if not self:isCanCompose(self.composedata) then
            GComAlter(language.forging54)
            return
        end
        local flag = false
        if self.composedata.type == 10 or self.composedata.type == 11 then
            for k ,v in pairs(listdata) do
                
                if k > 5 then
                    flag = true
                    break
                end
                self:setInfo(self.equiplist[k],v)
            end
        elseif self.composedata.type == 14 or self.composedata.type == 15 then
            for k ,v in pairs(listdata) do
                if k > 5 then
                    flag = true
                    break
                end
                self:setInfo(self.equiplist[k],v)
            end
        elseif self.composedata.type == 23 or self.composedata.type == 24 then
            for k ,v in pairs(listdata) do
                
                if k > 3 then
                    break
                end
                flag = true
                self:setInfo(self.equipxianlist[k],v)
            end
        elseif self.composedata.type == 18 then
            for k ,v in pairs(listdata) do
                if table.nums(v) >= 3 then
                    for i , j in pairs(v) do
                        if i > 3 then
                            break
                        end
                        self:setInfo(self.equipxianlist[i],j)
                    end
                    flag = true
                    break
                end
            end
        else
            for k ,v in pairs(listdata) do
                if table.nums(v) >= 5 then
                    for i , j in pairs(v) do
                        if i > 5 then
                            break
                        end
                        self:setInfo(self.equiplist[i],j)
                    end
                    flag = true
                    break
                end
            end
        end
        if not flag then
            return GComAlter(language.forging51)
        end
    end

    self:checkInput()
end

function FusePanel:setInfo( icon,data )
    -- body
    icon.data.data = data
    -- printt("设置setInfo",data)
    if data then
        local condata = conf.ItemConf:getItem(data.mid)
        icon.url = ResPath.iconRes(condata.src)
        self.frame[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
        local SetProInfo = function (com,mid,godEquipCost,flag)
            local mid = mid
            local t = {}
            t.mid = mid 
            t.isquan = 0
            GSetItemData(com:GetChild("n1"), t,true)
            com:GetChild("n3").text = conf.ItemConf:getName(t.mid)
            if not flag then
                local packData = cache.PackCache:getPackDataById(mid)
                local color = tonumber(packData.amount) >= tonumber(godEquipCost.cost_item[1][2]) and 10 or 14
                local textData = {
                    {text = packData.amount,color = color},
                    {text = "/"..godEquipCost.cost_item[1][2],color = 10},
                }
                com:GetChild("n4").text = mgr.TextMgr:getTextByTable(textData)
            else
                local packData = cache.PackCache:getPackDataById(mid)
                local color = tonumber(packData.amount) >= tonumber(godEquipCost.cost_item[2][2]) and 10 or 14
                local textData = {
                    {text = packData.amount,color = color},
                    {text = "/"..godEquipCost.cost_item[2][2],color = 10},
                }
                com:GetChild("n4").text = mgr.TextMgr:getTextByTable(textData)
            end
            com:GetChild("n2").data = {mid = mid}  
        end
        if self.composedata.type == 21 
            or (self.composedata.type == 6 and self.composedata.color == 7)  then
            self.godFrame4[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
            local id = ((100+self.composedata.color)*100+condata.stage_lvl)*100+self.composedata.part
            -- print(self.composedata.color,condata.stage_lvl,self.composedata.part,id)
            local godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
            if not godEquipCost then
                print("@策划  合成配置神装表没有",id)
                return
            end
            if godEquipCost.cost_item and #godEquipCost.cost_item == 1 then
                SetProInfo(self.proPanel,godEquipCost.cost_item[1][1],godEquipCost)
                self.godComposeCost = godEquipCost.cost_item
            end
        elseif self.composedata.type == 7 and self.composedata.color == 7 then--神装11~12部位
            self.godFrame3[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)

            local id = ((100+self.composedata.color)*100+condata.stage_lvl)*100+self.composedata.part
            local godEquipCost = conf.ForgingConf:getGodEquipCompose(id)
            if not godEquipCost then
                print("@策划  合成配置神装表没有",id)
                return
            end
            if godEquipCost.cost_item then
                SetProInfo(self.proLeft,godEquipCost.cost_item[1][1],godEquipCost)
                SetProInfo(self.proRight,godEquipCost.cost_item[2][1],godEquipCost,true)
                self.godComposeCost = godEquipCost.cost_item
            end
        elseif self.composedata.type == 22 then--神兽神装
            self.godFrame4[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
            local id = ((100+self.composedata.color)*100+condata.stage_lvl)*100+self.composedata.part
            local godEquipCost = conf.ShenShouConf:getShenShouGodEquipCompose(id)
            if not godEquipCost then
                print("@策划  神兽配置合成表没有",id)
                return
            end
            if godEquipCost.cost_item and #godEquipCost.cost_item == 1 then
                SetProInfo(self.proPanel,godEquipCost.cost_item[1][1],godEquipCost)
                self.godComposeCost = godEquipCost.cost_item
            end
        elseif self.composedata.type == 23 then--神兽3星红
            self.moneyCost_xian.text = ""
            self.xianframe3[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)

        elseif self.composedata.type == 24 then--元素3星红
            -- self.n41.visible = false
            -- self.moneyicon.url = ""
            -- self.moneyCost.text = ""
            -- self.plus.visible = true
            self.moneyCost_xian.text = ""
            self.xianframe3[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
        elseif self.composedata.type == 25 then--仙-神
            self.godFrame4[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
            local id = ((((100+condata.type)*100+self.composedata.color)*100+condata.stage_lvl)*100+self.composedata.part)
            local confcost = conf.ForgingConf:getXianEquipCompose(id)
            if confcost.cost_item and #confcost.cost_item == 1 then
                SetProInfo(self.proPanel,confcost.cost_item[1][1],confcost)
                self.godComposeCost = confcost.cost_item
            end

        elseif self.composedata.type == 18 then
            local id = ((((100+condata.type)*100+self.composedata.color)*100+condata.stage_lvl)*100+self.composedata.part)
            local confcost = conf.ForgingConf:getXianEquipCompose(id)
            if not confcost then
                print("id = ",id,"在表里面找不到")
            end
            self.moneyCost_xian.text = confcost.cost_money
            self.plus.data = {mid = MoneyPro2[MoneyType.bindGold]}
            self.xianframe3[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
        elseif self.composedata.type == 16 then
            self.frame3[icon.data.pos].url = ResPath.iconRes("beibaokuang_00"..condata.color)
            local _compose = conf.WuxingConf:getEquipCompose(2,6,3)
            if not _compose then
                self.moneyCost_3.text = ""
            else
                if _compose.cost_money then
                    --消耗货币
                    self.plus_3.data = {mid = MoneyPro2[_compose.cost_money[1]]}
                    self.moneyicon.url = ResPath.iconRes(_compose.cost_money[1])
                    if _compose.cost_money[2] > cache.PlayerCache:getTypeMoney(_compose.cost_money[1]) then
                        self.moneyCost_3.text = mgr.TextMgr:getTextColorStr(_compose.cost_money[2],14) 
                    else
                        self.moneyCost_3.text = _compose.cost_money[2]
                    end
                end
                self.plus.visible = true
            end
        elseif self.composedata.type == 14 or self.composedata.type == 15 then
            local color 
            local star
            if self.composedata.color == 5 then
                color = 5
                star = 2
            else
                color = 6
                star = 2
            end
            --self.moneyCost:AddRelation(self.n41,RelationType.Center_Center )
            local _compose = conf.WuxingConf:getEquipCompose(1,color,star)
            if not _compose then
                self.moneyCost.text = ""
            else
                if _compose.cost_item then
                    --消耗道具
                    if color == 5 then
                        self.moneyicon.url = ResPath.iconRes("jianling_016")
                    else
                        self.moneyicon.url = ResPath.iconRes("jianling_017")
                    end
                    

                    local need = cache.PackCache:getPackDataById(_compose.cost_item[1])
                    --print("need = "..need)
                    if _compose.cost_item[2] >  need.amount then
                       
                        self.moneyCost.text = mgr.TextMgr:getTextColorStr(need.amount,14) 
                    else
                        self.moneyCost.text = mgr.TextMgr:getTextColorStr(need.amount,7) 
                    end
                    self.moneyCost.text =self.moneyCost.text.."/"  .. mgr.TextMgr:getTextColorStr(_compose.cost_item[2],7) 
                    self.plus.data = {mid = _compose.cost_item[1]}
                end
                self.plus.visible = true
            end
        else
            --self.moneyCost:AddRelation(self.n41,RelationType.Left_Left )
            --材料颜色品质*10000+星数*1000+阶数
            local id = condata.color * 10000 + mgr.ItemMgr:getColorBNum(data)*1000 + condata.stage_lvl --self.composedata.id
            local _compose = conf.ForgingConf:getEquipCompose(id)
            if not _compose then
                self.moneyCost.text = ""
            else
                if _compose.cost_money > cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) then
                    self.moneyCost.text = mgr.TextMgr:getTextColorStr(_compose.cost_money,14) 
                else
                    self.moneyCost.text = _compose.cost_money
                end
            end 
        end
        local _t = {}
        GSetItemData(self._HcIcon,_t,false)
        GSetItemData(self._HcIcon_3,_t,false)
    else
        self:clearinfo()
        self.frame[icon.data.pos].url = nil 
        icon.url = nil 
    end
end


--对应道具的相关信息
function FusePanel:setSclelctData(fuseData,itemData)
    local bmoney = cache.PlayerCache:getTypeMoney(MoneyType.bindCopper) or 0
    local money = cache.PlayerCache:getTypeMoney(MoneyType.copper) or 0--拥有的金钱
    if fuseData and itemData then
        self.itemData = itemData
        self.mIndex = itemData.mIndex--记录是列表第几个
        GSetItemData(self.prosObj, itemData, true)--显示要合成的道具
        self.prosName.text = conf.ItemConf:getName(itemData.mid)

        self.fuseData = fuseData
        local cost_money = fuseData.cost_money or 0--所需金钱
        self.moneyNum.text = cost_money
        local materId = fuseData.cost_items[1][1]
        local materData = cache.PackCache:getPackDataById(materId)--显示要消耗的道具
        self.materData = materData
        local data = clone(materData)
        data.isquan = true
        GSetItemData(self.materObj, data, true)
        self.materName.text = conf.ItemConf:getName(materId)
        local color = 7
        local amount = materData.amount--拥有的道具数量
        local confNum = fuseData.cost_items[1][2]--所需的道具数量
        self.isPros = true
        if amount < confNum then
            self.isPros = false
            color = 14
        end
        self.materNum.text = mgr.TextMgr:getTextColorStr(amount.."/"..confNum,color)
        local num1 = math.floor(amount / confNum)
        local num2 = math.floor(bmoney / cost_money) + math.floor(money / cost_money)
        if num1 > num2 then
            self.maxFuseNum = num2
        else
            self.maxFuseNum = num1--最大可合成的数量
        end
        self.isNothc = false
        if self.maxFuseNum <= 0 then
            self.isNothc = true--没法合成
            self.maxFuseNum = 1
        end

        if money >= cost_money or bmoney >= cost_money then
            self.isMoney = true--判断钱够不够
        else
            self.isMoney = false
        end
    else
        self.prosObj.visible = false
        self.materObj.visible = false
        self.materName.text = 0
        self.materNum.text = "0/0"
        self.materName.text = ""
        self.prosName.text = ""
    end
    
end
--选择目标道具
function FusePanel:onClickUpdateNum(context)
    local cell = context.sender
    if self.materData then
        if cell.data == 1 then
            self.fuseNum =  self.fuseNum + 1
            if self.fuseNum >= self.maxFuseNum then
                self.fuseNum = self.maxFuseNum
                GComAlter(language.forging32)
            end
        else
            self.fuseNum =  self.fuseNum - 1
            if self.fuseNum <= 1 then
                self.fuseNum = 1
                GComAlter(language.forging34)
            end
        end

        self.fuseText.text = self.fuseNum
    else
        GComAlter(language.forging15)
    end
end
--最大值
function FusePanel:onClickMaxNum(context)
    context:StopPropagation()
    if self.isNothc then
        GComAlter(language.forging33)
        return
    end
    if self.materData then
        if self.fuseNum == self.maxFuseNum then
            GComAlter(language.forging32)
        end
        self.fuseNum = self.maxFuseNum
        self.fuseText.text = self.fuseNum
    else
        GComAlter(language.forging15)
    end
end
--合成
function FusePanel:onClickFuse(context)
    context:StopPropagation()
    if self.c1.selectedIndex == 0 then
        if self.composedata and  self.composedata.type == 20 then 
            if self.maxFuseNum <= 0 then
                return GComAlter(language.forging17)
            end
            if self.fuseNum <= 0 then
                GComAlter(language.forging16)
                return
            end
            local param = {}
            param.itemId = self.composedata.id
            param.num = self.fuseNum
            proxy.ForgingProxy:send(1190202,param)
            return
        end
        if not self.fuseData then return GComAlter(language.forging15) end
        local needLvl = self.fuseData.need_lvl or 0
        local playerLv = cache.PlayerCache:getRoleLevel()
        if playerLv < needLvl then
            GComAlter(string.format(language.forging41, needLvl))
            return
        end
        if not self.itemData then
            GComAlter(language.forging15)
            return
        end
        if self.fuseNum <= 0 then
            GComAlter(language.forging16)
            return
        end
        if not self.isPros then
            GComAlter(language.gonggong11)
            return
        end
        if not self.isMoney then
            GComAlter(language.gonggong29)
            return
        end
        proxy.ForgingProxy:send(1100106,{itemId = self.itemData.mid,hcNum = self.fuseNum})
    elseif self.c1.selectedIndex == 2 then
        if not self.composedata then
            return
        end
        --print("self.composedata.type == 14",self.composedata.type )
        if self.composedata.type == 16 then
            local putinfo = {}
            putinfo.reqType = 2
            putinfo.indexs = {}
            for k ,v in pairs(self.equiplist3) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                end
            end
            if #putinfo.indexs < 2 then
                GComAlter(language.forging96)
                return
            end
            proxy.AwakenProxy:send(1530105,putinfo)
            return
        end
    elseif self.c1.selectedIndex == 3 then
        if not self.composedata then
            return
        end
        if self.composedata.type == 18 then
            local putinfo = {}
            putinfo.indexs = {}
            putinfo.part = self.composedata.part
            putinfo.color = self.composedata.color
            putinfo.step = 0

            for k ,v in pairs(self.equipxianlist) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                    
                    if putinfo.step == 0 then
                        local condata = conf.ItemConf:getItem(v.data.data.mid)
                        putinfo.step = condata.stage_lvl
                    end
                 end
            end
            if #putinfo.indexs < 3 then
                GComAlter(language.forging97 )
                return
            end
            proxy.FeiShengProxy:sendMsg(1100301,putinfo)
            return
        elseif self.composedata.type == 23 then--神兽3星
            local putinfo = {}
            putinfo.indexs = {}
            putinfo.part = self.composedata.part
            putinfo.color = self.composedata.color
            for k ,v in pairs(self.equipxianlist) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                 end
            end
            if #putinfo.indexs < 3 then
                GComAlter(language.forging97 )
                return
            end
            proxy.ShenShouProxy:send(1590106,putinfo)
            return
        elseif self.composedata.type == 24 then--3星红元素
            local putinfo = {}
            putinfo.index = {}
            putinfo.element = self.composedata.part
            for k ,v in pairs(self.equipxianlist) do
                if v.data.data then
                    table.insert(putinfo.index,v.data.data.index)
                end
            end
            if #putinfo.index < 3 then
                GComAlter(language.forging54)
                return
            end
            proxy.AwakenProxy:send(1610107,putinfo)
            return
        end 
    elseif self.c1.selectedIndex == 4 then
        if not self.composedata then
            return
        end
        if self.composedata.type == 19 then
            if self.number_C == 0 then
                return GComAlter(language.gonggong11)
            end
            local putinfo = {}
            putinfo.num = self.number_C
            putinfo.syIndexs = {}
            local packinfo = cache.PackCache:getShengYinDiffById(self.composedata.id)
            local condata = conf.ShengYinConf:getSycompose(self.composedata.id)
            local var = self.number_C * condata.need_num
            for i = 1 ,var  do
                if packinfo[i].index then
                    table.insert(putinfo.syIndexs,packinfo[i].index)
                else
                    print("计算合成上限有错")
                end
            end
            print("发送  是爱思爱思 ")
            proxy.AwakenProxy:sendMsg(1600106,putinfo)
            --
        end
    elseif self.c1.selectedIndex == 5 then
        if not self.composedata then
            return
        end
        if not self.godComposeCost then
            return
        end
        if self.composedata.type == 21 or self.composedata.type == 6 or self.composedata.type == 22 then
            local putinfo = {}
            putinfo.indexs = {}
            putinfo.part = self.composedata.part
            putinfo.color = self.composedata.color
            for k ,v in pairs(self.godEquipList4) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                end
            end
            for k,v in pairs(self.godComposeCost) do
                local packData = cache.PackCache:getPackDataById(v[1])
                if packData.amount < v[2] then
                    GComAlter(language.gonggong11)
                    return
                end
            end
            -- printt("putinfo",putinfo)
            -- printt("putinfo.indexs",putinfo.indexs)
            if #putinfo.indexs < 3 then
                GComAlter(language.forging97)
                return
            end
            if self.composedata.type == 22 then
                proxy.ShenShouProxy:send(1590106,putinfo)
            else
                proxy.ForgingProxy:send(1100401,putinfo)
            end
            return
        elseif self.composedata.type == 25 then
            local putinfo = {}
            putinfo.indexs = {}
            putinfo.part = self.composedata.part
            putinfo.color = self.composedata.color
            putinfo.step = 0
            for k ,v in pairs(self.godEquipList4) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                    if putinfo.step == 0 then
                        local condata = conf.ItemConf:getItem(v.data.data.mid)
                        putinfo.step = condata.stage_lvl
                    end
                end
            end
            if #putinfo.indexs < 3 then
                GComAlter(language.forging97 )
                return
            end
            for k,v in pairs(self.godComposeCost) do
                local packData = cache.PackCache:getPackDataById(v[1])
                if packData.amount < v[2] then
                    GComAlter(language.gonggong11)
                    return
                end
            end
            proxy.FeiShengProxy:sendMsg(1100301,putinfo)
            return
        end
    elseif self.c1.selectedIndex == 6 then
        if not self.composedata then
            return
        end
        if self.composedata.type == 7 then
            local putinfo = {}
            putinfo.indexs = {}
            putinfo.part = self.composedata.part
            putinfo.color = self.composedata.color
            for k ,v in pairs(self.godEquipList3) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                end
            end
            for k,v in pairs(self.godComposeCost) do
                local packData = cache.PackCache:getPackDataById(v[1])
                if packData.amount < v[2] then
                    GComAlter(language.gonggong11)
                    return
                end
            end
            if #putinfo.indexs < 1 then
                GComAlter(language.forging97)
                return
            end
            proxy.ForgingProxy:send(1100401,putinfo)
            return
        end
    else
        if not self.composedata then
            return
        end
        if self.composedata.type == 14 or self.composedata.type == 15 then
            local putinfo = {}
            putinfo.reqType = 1
            putinfo.indexs = {}
            for k ,v in pairs(self.equiplist) do
                if v.data.data then
                    table.insert(putinfo.indexs,v.data.data.index)
                end
            end
            if #putinfo.indexs < 5 then

                GComAlter(language.forging53[self.composedata.color])
                return
            end
            proxy.AwakenProxy:send(1530105,putinfo)
            return
       
        end
        local putinfo = {}
        putinfo.reqType = 2
        putinfo.part = self.composedata.part
        putinfo.materials = {}

        local flag = false
        for k ,v in pairs(self.equiplist) do
            if v.data.data then
                table.insert(putinfo.materials,v.data.data.index)

                local condata = conf.ItemConf:getItem(v.data.data.mid)
                if condata.color > 4 and condata.lvl > cache.PlayerCache:getRoleLevel() then
                    flag = true
                end
            end
        end
        if #putinfo.materials < 5 then
            GComAlter(language.forging53[self.composedata.color])
            return
        end

        --检测放入的装备是否超过自己的等级
        --not cache.PackCache:getDayOnce()
        if flag then
            local param = {}
            param.type = 2
            param.richtext = language.forging57
            param.sure = function(selected)
                -- body
                --cache.PackCache:setDayOnce(selected)
                proxy.ForgingProxy:send(1100112,putinfo)
            end
            GComAlter(param)
            return
        end


        proxy.ForgingProxy:send(1100112,putinfo)
    end
end

--帮助
function FusePanel:onClickHelp()
    --print("self.ruleId",self.ruleId)
    GOpenRuleView(self.ruleId or 1007)
end

function FusePanel:onClickBuyPro()
    if self.materData then
        GGoBuyItem(self.materData)
    else
        GComAlter(language.forging28)
    end
end

function FusePanel:onCheck()
    for k ,v in pairs(self.equiplist) do
        v.url = nil 
        v.data.data = nil 
    end

    for k ,v in pairs(self.frame) do
        v.url = nil 
    end

    self.isSelect = self.checkBox.selected--仅显示已打造选项
    self.fuseData,self.itemData = nil,nil
    self:setData()
end

function FusePanel:clear()
    self.mSuitData = {}
    local condata = conf.ForgingConf:getSuitFuse()
    local level = cache.PlayerCache:getRoleLevel()
    local fslevel = cache.PlayerCache:getAttribute(541)
    for k ,v in pairs(condata) do
        -- print("#",k,v.type)
        if v.openlv and v.openlv <= level and v.fslv <= fslevel then
            table.insert(self.mSuitData,v)
        end
    end
    --合成项目排序按开放等级 10-30-11-4 版本计划
    table.sort(self.mSuitData,function(a,b)
        -- body 
        if a.openlv == b.openlv then
            return a.type < b.type
        else
            return a.openlv < b.openlv
        end
    end)
    -- self.checkBox.selected = false
    -- self.isSelect = false
end



function FusePanel:addMsgCallBack(data)
    -- body
    if data.msgId == 5100112 then
        self.moneyCost.text = ""
        for k ,v in pairs(self.equiplist) do
            v.url = nil 
            v.data.data = nil 
        end
        for k ,v in pairs(self.frame) do
            v.url = nil 
        end
        self:getPackData()
        if data.status ~= 0 then
            --错误号 刷新背包
            return
        end
        GOpenAlert3(data.items)
        if not self:isCanCompose(self.composedata) then
            --当前阶无可合成 刷新列表
            self.composedata = nil 
            self:setData()
        else
            self:checkInput()
        end

        if self.c1.selectedIndex == 1 then
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.equipType then
                    local _t = clone(v)
                    GSetItemData(self._HcIcon,_t,true)
                    break
                end
            end
        end
    elseif data.msgId == 5530105 then
        if data.reqType == 1 then
            self.moneyCost.text = ""
            for k ,v in pairs(self.equiplist) do
                v.url = nil 
                v.data.data = nil 
            end
            for k ,v in pairs(self.frame) do
                v.url = nil 
            end
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            GOpenAlert3(data.items)

            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else
                self:checkInput()
            end

            if self.c1.selectedIndex == 1 then
                for k,v in pairs(data.items) do
                    local condata = conf.ItemConf:getItem(v.mid)
                    if condata.type == Pack.wuxing then
                        local _t = clone(v)
                        GSetItemData(self._HcIcon,_t,true)
                        break
                    end
                end
            end
        elseif data.reqType ==  2 then
            self.moneyCost_3.text = ""
            for k ,v in pairs(self.equiplist3) do
                v.url = nil 
                v.data.data = nil 
            end
            for k ,v in pairs(self.frame3) do
                v.url = nil 
            end
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            GOpenAlert3(data.items)

            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else
                self:checkInput()
            end

            if self.c1.selectedIndex == 2 then
                for k,v in pairs(data.items) do
                    local condata = conf.ItemConf:getItem(v.mid)
                    if condata.type == Pack.wuxing then
                        local _t = clone(v)
                        GSetItemData(self._HcIcon_3,_t,true)
                        break
                    end
                end
            end
        end
    elseif data.msgId == 5100301 then
        self:clearinfo()
        self:getPackData()
        if data.status ~= 0 then
            --错误号 刷新背包
            return
        end
        GOpenAlert3(data.items)
        if not self:isCanCompose(self.composedata) then
            --当前阶无可合成 刷新列表
            self.composedata = nil 
            self:setData()
        else
            self:checkInput()
        end

        if self.c1.selectedIndex == 3 then
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.xianzhuang then
                    local _t = clone(v)
                    GSetItemData(self._HcIcon_xian
                        ,_t,true)
                    break
                end
            end
        elseif self.c1.selectedIndex == 5 then
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.xianzhuang then
                    local _t = clone(v)
                    GSetItemData(self.godEquip4,_t,true)
                    break
                end
            end
        end
    elseif 5100401 == data.msgId then--神装合成
        if self.c1.selectedIndex == 5 then--4合1
            self:clearinfo()
            -- for k ,v in pairs(self.godEquipList4) do
            --     v.url = nil 
            --     v.data.data = nil 
            -- end
            -- for k ,v in pairs(self.godFrame4) do
            --     v.url = nil 
            -- end
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            GOpenAlert3(data.items)
            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else

                self:checkInput()
            end
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.equipType then
                    local _t = clone(v)
                    GSetItemData(self.godEquip4,_t,true)
                    break
                end
            end
        elseif self.c1.selectedIndex == 6 then--3合1
            self:clearinfo()

            -- for k ,v in pairs(self.godEquipList3) do
            --     v.url = nil 
            --     v.data.data = nil 
            -- end
            -- for k ,v in pairs(self.godFrame3) do
            --     v.url = nil 
            -- end
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            GOpenAlert3(data.items)
            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else

                self:checkInput()
            end
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.equipType then
                    local _t = clone(v)
                    GSetItemData(self.godEquip3,_t,true)
                    break
                end
            end
        end
    elseif 5600106 == data.msgId then
        self:clearinfo()
        print("jisuan",self:isCanCompose(self.composedata))
        if not self:isCanCompose(self.composedata) then
            --当前阶无可合成 刷新列表
            self.composedata = nil 
            self:setData()
            print("重新")
        else
            self:checkInput()
        end
        GOpenAlert3(data.items)
    elseif 5190202 == data.msgId then 
        self:clearinfo()
        if not self:isCanCompose(self.composedata) then
            --当前阶无可合成 刷新列表
            self.composedata = nil 
            self:setData()
        else
            self:checkInput()
        end
        GOpenAlert3(data.items)
    elseif 5610107 == data.msgId then --八门元素合成
        self.moneyCost_xian.text = ""
        for k ,v in pairs(self.equipxianlist) do
            v.url = nil 
            v.data.data = nil 
        end
        for k ,v in pairs(self.xianframe3) do
            v.url = nil 
        end
        self:getPackData()
        if data.status ~= 0 then
            --错误号 刷新背包
            return
        end
        GOpenAlert3(data.items)
        if not self:isCanCompose(self.composedata) then
            --当前阶无可合成 刷新列表
            self.composedata = nil 
            self:setData()
        else
            self:checkInput()
        end

        if self.c1.selectedIndex == 3 then
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.elementType then
                    local _t = clone(v)
                    GSetItemData(self._HcIcon_xian
                        ,_t,true)
                    break
                end
            end
        end
    elseif 5590106 == data.msgId then --神兽合成
        if self.c1.selectedIndex == 5 then--4合1
            self:clearinfo()
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            printt("合成道具",data.item)
            GOpenAlert3(data.items)
            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else

                self:checkInput()
            end
            for k,v in pairs(data.items) do
                local condata = conf.ItemConf:getItem(v.mid)
                if condata.type == Pack.shenshouEquipType then
                    local _t = clone(v)
                    GSetItemData(self.godEquip4,_t,true)
                    break
                end
            end
        elseif self.c1.selectedIndex == 3 then
            self.moneyCost_xian.text = ""
            self:clearinfo()
            self:getPackData()
            if data.status ~= 0 then
                --错误号 刷新背包
                return
            end
            GOpenAlert3(data.items)
            if not self:isCanCompose(self.composedata) then
                --当前阶无可合成 刷新列表
                self.composedata = nil 
                self:setData()
            else
                self:checkInput()
            end

            if self.c1.selectedIndex == 3 then
                for k,v in pairs(data.items) do
                    local condata = conf.ItemConf:getItem(v.mid)
                    if condata.type == Pack.shenshouEquipType then
                        local _t = clone(v)
                        GSetItemData(self._HcIcon_xian,_t,true)
                        break
                    end
                end
            end
        end
    end
end

return FusePanel