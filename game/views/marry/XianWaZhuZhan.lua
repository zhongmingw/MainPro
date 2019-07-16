--
-- Author: 
-- Date: 2017-07-24 15:55:59
--

local XianWaZhuZhan = class("XianWaZhuZhan",import("game.base.Ref"))

function XianWaZhuZhan:ctor(param)
    self.parent = param
    self.view = self.parent.view:GetChild("n18")
    self:initView()
end

function XianWaZhuZhan:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController,self)
    --三种阵位
    self.panel1 = self.view:GetChild("n12")
    self.panel2 = self.view:GetChild("n13")
    self.panel3 = self.view:GetChild("n14")

    --阵位属性列表
    self.attrList = self.view:GetChild("n15")
    self.attrList.itemRenderer = function(index,obj)
        self:cellprodata(index, obj)
    end
    self.attrList.numItems = 0
    --技能图标
    self.skillIcon = self.view:GetChild("n16")
    self.skillName = self.view:GetChild("n17")
    self.skillDec = self.view:GetChild("n18")
    --阵法特效
    self.battleEffect = self.view:GetChild("n19")
    --技能激活条件
    self.skillActTxt = self.view:GetChild("n20")
    --规则
    local guizeBtn = self.view:GetChild("n10")
    guizeBtn.onClick:Add(self.onClickGuize,self)
end

function XianWaZhuZhan:onController()
    if self.effect then
        self.parent:removeUIEffect(self.effect)
        self.effect = nil
    end
    local effectId = 4020173
    self.index = self.c1.selectedIndex
    if self.c1.selectedIndex == 0 then
        self:setPanelData(self.panel1)
    elseif self.c1.selectedIndex == 1 then
        self:setPanelData(self.panel2)
        effectId = 4020174
    elseif self.c1.selectedIndex == 2 then
        self:setPanelData(self.panel3)
        effectId = 4020175
    end
    self.effect = self.parent:addEffect(effectId, self.battleEffect)
    self.effect.LocalPosition = Vector3.New(312,-519,500)
end

--
function XianWaZhuZhan:setPanelData(panelObj)
    local idList = conf.MarryConf:getZhuZhanKongByZW(self.c1.selectedIndex+1)
    local panelList = {}
    for i=1,3 do
        local item = panelObj:GetChild("n"..(i+2))
        if item then
            table.insert(panelList,item)
        end
    end
    self.protable = {
        [1]={102,0},
        [2]={103,0},
        [3]={105,0},
        [4]={106,0},
        [5]={107,0},
    }
    local battleNum = 0--当前上阵数量
    for k,id in pairs(idList) do
        local itemObj = panelList[k]
        itemObj.onClick:Clear()
        local zhuzhanBtn = itemObj:GetChild("n0")
        local modelPanel = itemObj:GetChild("n1")
        local nameTxt = itemObj:GetChild("n2")
        local levelImg = itemObj:GetChild("n11")
        local levelTxt = itemObj:GetChild("n12")
        local lockItem = itemObj:GetChild("n6")

        local flag = false--当前位置是否开启
        local xiantongId = 0
        for pos,xtId in pairs(self.warXtData) do
            if pos == id then
                flag = true
                xiantongId = xtId
            end
        end
        if flag then--当前阵位开启
            if xiantongId == 0 then--当前阵位没有仙童
                local delay = 0.1
                if self.pos == id then
                    -- print("开启的位置>>>>>>>>>>>>>>>self.pos",self.pos)
                    self:playLockEff(lockItem:GetChild("n2"))
                    self.pos = nil
                    lockItem:GetChild("n1").visible = false
                    delay = 2
                end
                nameTxt.text = ""
                levelTxt.text = ""
                levelImg.visible = false
                modelPanel.visible = false
                mgr.TimerMgr:addTimer(delay, 1, function()
                    lockItem.visible = false
                    zhuzhanBtn.visible = true
                    zhuzhanBtn.data = {id = id,warXtData = self.warXtData}
                    zhuzhanBtn.onClick:Add(self.onClickAddXt,self)
                end)
            else
                battleNum = battleNum + 1
                local xiantongData = cache.MarryCache:getgetXTDataByRoleId(xiantongId)
                local cfgId = xiantongData.xtId
                local level = xiantongData.level
                local xiantongConf = conf.MarryConf:getPetItem(cfgId)
                nameTxt.text = mgr.TextMgr:getQualityStr1(xiantongData.name, xiantongConf.color)
                local levConf = conf.MarryConf:getXTlev(level)
                levelTxt.text = string.format(language.huoban24,language.gonggong21[levConf.jie] or "0")
                levelImg.visible = true
                zhuzhanBtn.visible = false
                modelPanel.visible = true
                itemObj.data = {id = id,warXtData = self.warXtData}
                itemObj.onClick:Add(self.onClickAddXt,self)
                local model = self.parent:addModel(xiantongConf.model, modelPanel)
                model:setPosition(100, -380, 500)
                model:setRotationXYZ(0, 180, 0)
                local prolist = mgr.XianTongMgr:getPetPro(xiantongData)
                G_composeData(self.protable,prolist)
            end
        else--当前阵位没有开启
            lockItem.visible = true
            nameTxt.text = ""
            levelTxt.text = ""
            levelImg.visible = false
            modelPanel.visible = false
            itemObj.data = id
            itemObj.onClick:Add(self.onClickOpen,self)
        end
    end

    self.attrList.numItems = #self.protable
    local decTxt = panelObj:GetChild("n2")
    local confData = conf.MarryConf:getXianTongZhenWeiById(self.c1.selectedIndex+1)
    local textD = clone(language.xiantong35)
    textD[1].text = string.format(textD[1].text,confData.battle_name)
    textD[2].text = string.format(textD[2].text,(confData.prop_add/100))
    decTxt.text = mgr.TextMgr:getTextByTable(textD)
    --阵位技能
    local textData = clone(language.xiantong37)
    textData[1].text = string.format(textData[1].text,confData.battle_name)
    textData[2].text = string.format(textData[2].text,confData.active_skill_num)
    self.skillActTxt.text = mgr.TextMgr:getTextByTable(textData)
    self.skillDec.text = language.xiantong38 .. confData.skill_dec
    self.skillIcon.url = UIPackage.GetItemURL("marry" , confData.skill_icon)
    --技能buff信息
    local buffData = conf.BuffConf:getBuffConf(confData.buff[1])
    self.skillName.text = buffData.name
    local isActImg = self.view:GetChild("n21")
    if battleNum == (self.c1.selectedIndex+1) then
        isActImg.visible = true
    else
        isActImg.visible = false
    end

end

--播放解锁特效
function XianWaZhuZhan:playLockEff(effectPanel)
    -- self.lockEff
    local lock = self.parent:addEffect(4020176,effectPanel)
    lock.Scale = Vector3.New(55,55,55)
    -- self.lock.LocalPosition = Vector3.New(confData.pos[1],confData.pos[2],confData.pos[3])
end

function XianWaZhuZhan:cellprodata(index,obj)
    local data = self.protable[index+1]
    local lab = obj:GetChild("n0")
    local confData = conf.MarryConf:getXianTongZhenWeiById(self.c1.selectedIndex+1)
    local prop_add = (confData.prop_add)/10000
    local dec = conf.RedPointConf:getProName(data[1])
    dec = dec .. " +".. GProPrecnt(data[1],checkint(data[2]*prop_add))
    lab.text = dec
end

--判断当前阵位是否开启
function XianWaZhuZhan:isOpen(pos)
    local flag = false
    for id,xtId in pairs(self.warXtData) do
        if id == pos then
            flag = true
        end
    end
    return flag
end

--开启阵位
function XianWaZhuZhan:onClickOpen(context)
    local id = context.sender.data
    -- print("开启阵位>>>>>>>id",id)
    local xiantongConf = conf.MarryConf:getXianTongZhuZhanById(id)
    if not xiantongConf.pre_id or (xiantongConf.pre_id and self:isOpen(xiantongConf.pre_id)) then
        mgr.ViewMgr:openView2(ViewName.XianTongOpenPos, {id = id})
    else
        GComAlter(language.xiantong39)
    end
end

--上阵按钮
function XianWaZhuZhan:onClickAddXt(context)
    local data = context.sender.data
    mgr.ViewMgr:openView2(ViewName.XianTongOnHelp, data)
end

function XianWaZhuZhan:addMsgCallBack(data)
    -- body
    if data.msgId == 5390610 then
        self.warXtData = data.warXtData--当前上阵仙童
        printt("阵位信息>>>>>>>>>>>>",data)
        local index = 0
        if data.pos ~= 0 then
            local xiantongConf = conf.MarryConf:getXianTongZhuZhanById(data.pos)
            index = xiantongConf.zw_type - 1
        else
            index = self.index or 0
        end

        if self.c1.selectedIndex ~= index then
            self.c1.selectedIndex = index
        else
            self:onController()
        end
    elseif data.msgId == 5390611 then
        self.warXtData[data.pos] = 0
        self.pos = data.pos
        local index = self.index or 0
        if self.c1.selectedIndex ~= index then
            self.c1.selectedIndex = index
        else
            self:onController()
        end
    end
end

function XianWaZhuZhan:onClickGuize()
    GOpenRuleView(1160)
end

return XianWaZhuZhan