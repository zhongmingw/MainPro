--
-- Author: Your Name
-- Date: 2017-05-19 14:22:26
--

local HuobanExpPop = class("HuobanExpPop", base.BaseView)

function HuobanExpPop:ctor()
    self.super.ctor(self)
    self.isBlack = true
    self.uiLevel = UILevel.level2 
    self.openTween = ViewOpenTween.scale
end

function HuobanExpPop:initView()
    local closeBtn = self.view:GetChild("n8"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView,self)
    self.listView = self.view:GetChild("n11")
    self:initListView()
    --筛选按钮
    local levelBtn = self.view:GetChild("n22")--等阶筛选按钮
    levelBtn.onClick:Add(self.onClickLevCal,self)
    local colorBtn = self.view:GetChild("n21")--等阶筛选按钮
    colorBtn.onClick:Add(self.onClickColorCal,self)
    self.jieTxt = self.view:GetChild("n20")
    self.colorTxt = self.view:GetChild("n19")
    --筛选组件
    self.Panel = self.view:GetChild("n26")--等阶筛选
    self.Panel.visible = false
    self.listPanel = self.view:GetChild("n25")
    self.listPanel:SetVirtual()
    self.listPanel.itemRenderer = function(index,obj)
        self:cellPanelData(index, obj)
    end
    self.listPanel.numItems = 0
    self.listPanel.onClickItem:Add(self.onlistPanel,self)

    self.devourBtn = self.view:GetChild("n12")
    self.devourBtn.onClick:Add(self.onClickDevour,self)
    
    --1星复选按钮
    self.checkBtn = self.view:GetChild("n13")
    self.checkBtn.onChanged:Add(self.selelctCheck,self)

    self.oldicon = self.view:GetChild("n8").icon
    self.oldbtnicon = self.devourBtn.icon
    self.oldtext = self.view:GetChild("n15").text

    self.c1 = self.view:GetController("c1")
end

function HuobanExpPop:initData(param)
    -- body
    self.param = param
    self.selectData = {}
    self.filtrateData = {}
    self.equipD = {}
    self.jie = 0
    local roleLv = cache.PlayerCache:getRoleLevel()
    if roleLv >= 80 then
        self.color = 4
    else
        self.color = 3
    end
    self.xing = 0
    self.addExp = 0

    self.c1.selectedIndex = 0
    self.way = nil 
    if self.param and self.param.way and self.param.way == "JianLing" then
        self.c1.selectedIndex = 1
        self.color = 4

        self.way = self.param.way
        --改变标题
        self.view:GetChild("n8").icon = ResPath.iconOther("jianling_001")
        self.view:GetChild("n15").text = language.awaken57
        self.devourBtn.icon = ResPath.iconOther("fenjiezhuangbei_005")

        self.jieTxt.text = language.huoban59[1][self.xing+1]
        self.colorTxt.text = language.huoban59[2][self.color-3]
        self.checkBtn.selected = false
    else
        self.view:GetChild("n8").icon = self.oldicon 
        self.devourBtn.icon = self.oldbtnicon 
        self.view:GetChild("n15").text = self.oldtext

        --记录阶选择状态bxp
        if cache.HuobanCache:getJieText() then
            self.jieTxt.text = cache.HuobanCache:getJieText()
            self.jie = cache.HuobanCache:getSelfJie()
        else
            self.jieTxt.text = language.huoban46[1][self.jie+1]
        end
        --记录颜色选择状态bxp
        if cache.HuobanCache:getcolorText() then 
            self.colorTxt.text = cache.HuobanCache:getcolorText()
            self.color = cache.HuobanCache:getSelfColor()
        else
            self.colorTxt.text = language.huoban46[2][self.color-2]
        end
        --记录一星选择状态bxp
        if cache.HuobanCache:getSelectState() then 
            self.checkBtn.selected = cache.HuobanCache:getSelectState() 
        else
            self.checkBtn.selected = false
        end
        if self.checkBtn.selected then 
            self:selelctCheck()
        end
    end

    self:refreshView()--加载列表
    self.Panel.visible = false
end

--刷新列表
function HuobanExpPop:refreshView()
    if self.way and self.way == "JianLing" then
        self.equipD = GGetWuXingEquipData()
    else
        self.equipD = GGetEquipData()
    end
    self.filtrateData = self:equipFiltrate()
    self.selectData = self:selectExpPill()--self.filtrateData --已选择的
    self:getEquipExp(self.selectData) --计算所选装备可加的经验
    self.listView.numItems = math.max((math.ceil(#self.equipD/28)*28),28) --重新加载列表
end

--选中灵通经验丹
function HuobanExpPop:selectExpPill()
    local data = {}
    if self.way and self.way == "JianLing" then
        return self.filtrateData
    end
    
    for k,v in pairs(self.filtrateData) do
        if not v.stage_lvl then
            table.insert(data,v)
        else
            if v.colorBNum <= self.xing  and self:isPart(v) then
                table.insert(data,v)
            end
        end
    end
    return data
end

function HuobanExpPop:isSelected(index)
    local flag = false
    for k,v in pairs(self.selectData) do
        if v.index == index then
            flag = true
            break
        end
    end
    return flag
end

--1星复选按钮
function HuobanExpPop:selelctCheck()
    if not self.way then cache.HuobanCache:setSelectState(self.checkBtn.selected) end--bxp设置勾选缓存
    if self.checkBtn.selected then
        self.xing = 1
        for k,v in pairs(self.filtrateData) do
            if v.colorBNum == self.xing and not self:isSelected(v.index) and self:isPart(v) then
                table.insert(self.selectData,v)
            end
        end
    else
        self.xing = 0
        local data = {}
        for k,v in pairs(self.selectData) do
            if v.colorBNum == self.xing and self:isPart(v)  then
                table.insert(data,v)
            end
        end
        self.selectData = data
    end
    self.listView.numItems = math.max((math.ceil(#self.equipD/28)*28),28)
    self:getEquipExp(self.selectData)
end

--等阶筛选
function HuobanExpPop:onClickLevCal(context)
    local btn = context.sender 
    if self.call and self.call == 1 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 1
    self:callset(btn)
end
--品质筛选
function HuobanExpPop:onClickColorCal(context)
    local btn = context.sender 
    if self.call and self.call == 2 and self.Panel.visible then 
        self.Panel.visible = false
        return
    end
    self.call = 2
    self:callset(btn)
end

function HuobanExpPop:callset(btn)
    self.Panel.x = btn.x - self.Panel.width + btn.width + 8
    self.Panel.y = btn.y - self.Panel.height
    self.Panel.visible = true

    if self.way and self.way == "JianLing" then
        self.listPanel.numItems = #language.huoban59[self.call]
        if self.call == 1 then
            self.listPanel:AddSelection(self.xing,false)
        else
            self.listPanel:AddSelection(self.color - 4,false)
        end
        return
    end

    self.listPanel.numItems = #language.huoban46[self.call]
    if self.call == 1 then
        self.listPanel:AddSelection(self.jie,false)
    else
        self.listPanel:AddSelection(self.color-3,false)
    end
end
--
function HuobanExpPop:cellPanelData(index,obj)
    obj.data = index + 1
    if self.way and self.way == "JianLing" then
        obj.title = language.huoban59[self.call][index+1]
    else
        obj.title = language.huoban46[self.call][index+1]
    end
end
--
function HuobanExpPop:onlistPanel(context)
    local data = context.data.data
    if self.call == 1 then
        if self.way and self.way == "JianLing" then
            self.xing = data - 1
        else
            self.jie = data - 1
        end
    elseif self.call == 2 then
        if self.way and self.way == "JianLing" then
            self.color = data + 3
        else
            self.color = data + 2
        end
        
    end
    if self.way and self.way == "JianLing" then
        self.jieTxt.text = language.huoban59[1][self.xing+1]
        self.colorTxt.text = language.huoban59[2][self.color-3]
    else

        self.jieTxt.text = language.huoban46[1][self.jie+1]
        self.colorTxt.text = language.huoban46[2][self.color-2]
    end
    
    
    if not self.way then
        cache.HuobanCache:setJieText(language.huoban46[1][self.jie+1])
        cache.HuobanCache:setSelfJie(self.jie)

        cache.HuobanCache:setcolorText(language.huoban46[2][self.color-2])
        cache.HuobanCache:setSelfColor(self.color)
    end

    self:refreshView()--刷新列表
    self.Panel.visible = false
end

--计算所选装备可加的经验
function HuobanExpPop:getEquipExp(equipData)
    local addExp = 0
    for k,v in pairs(equipData) do
        --printt(v)
        if self.way and self.way == "JianLing" then
            local confdata = conf.ForgingConf:getEquipSplit(v.id)
            if confdata and confdata.items then
                addExp = addExp + confdata.items[1][2]
            end
        else
            local amount = 1
            if v.amount then
                amount = v.amount
            end
            addExp = addExp + v.partner_exp*amount
        end
    end
    self.view:GetChild("n16").text = "+" .. addExp
    self.addExp = addExp
end

function HuobanExpPop:isPart(v)
    -- body
    return v.part ~= 11 and v.part ~= 12 
end

--最终吞噬获得的经验
function HuobanExpPop:getAddExp()
    return self.addExp
end

--是否是当前阶
function HuobanExpPop:isNowStageLv(stage_lvl)
    if self.jie == 0 then
        return true
    else
        return self.jie >= stage_lvl
    end
end
--是否是当前品质
function HuobanExpPop:isNowColor(color)
    if self.color == 0 then
        return true
    else
        return self.color >= color
    end
end

--装备筛选
--stage_lvl 等阶
--color     品质
--colorBNum 星级
function HuobanExpPop:equipFiltrate()
    local data = {}
    local equipD 
    if self.way and self.way == "JianLing" then
        equipD = GGetWuXingEquipData()
        for k ,v in pairs(equipD) do
            --print("self.xing",self.xing,self.color)
            if self.xing  == 0 then
                --print(v.color,self.color,v.color <= self.color)
                if v.color <= self.color then
                    table.insert(data,v)
                end
            else

                if (v.colorBNum or 0)<= self.xing then
                   if v.color <= self.color then
                        table.insert(data,v)
                    end
                end
            end
        end
    else
        equipD = GGetEquipData()
        for k,v in pairs(equipD) do
            
            local xing = v.colorBNum or 0
            if v.stage_lvl then
                if self:isNowStageLv(v.stage_lvl) and self:isNowColor(v.color) and self:isPart(v)  then
                    table.insert(data,v)
                end
            else
                table.insert(data,v)
            end
        end
    end
    
    --print(#data)
    table.sort(data,function(a,b)
        if a.type ~= b.type then
            return a.type > b.type 
        elseif a.bind ~= b.bind then
            return a.bind > b.bind
        elseif a.stage_lvl ~= b.stage_lvl then
            return a.stage_lvl > b.stage_lvl
        elseif a.color ~= b.color then
            return a.color > b.color
        elseif a.colorBNum ~= b.colorBNum then
            return a.colorBNum > b.colorBNum
        elseif a.part ~= b.part then
            return a.part < b.part
        end
    end)
    return data
end


function HuobanExpPop:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function HuobanExpPop:celldata( index,obj )
    -- body
    local data = self.equipD[index+1]
    local item = obj:GetChild("n5")
    if data then
        item.visible = true
        local mid = data.id
        local amount = 1
        if not data.stage_lvl then
            amount = data.amount
        end
        local info = {mid = mid,amount = amount,bind = data.bind,colorAttris = data.colorAttris,isArrow = data.isArrow,isquan = true}
        GSetItemData(item,info,false)
        local flag = false
        for k,v in pairs(self.selectData) do
            if v.index == data.index then
                flag = true
                break
            end
        end
        obj.selected = flag
        obj.touchable = true
        obj.data = {data = data}
        obj.onClick:Add(self.onClickSelect,self)
    else
        obj.selected = false
        obj.touchable = false
        item.visible = false
    end
end

function HuobanExpPop:onClickSelect(context)
    -- body
    local cell = context.sender
    local data = cell.data

    local flag = true
    local key = 0
    for k,v in pairs(self.selectData) do
        if v.index == data.data.index and not cell.selected then
            flag = false
            key = k
            break
        end
    end
    if not flag then
        table.remove(self.selectData,key)
    else
        if cell.selected then
            table.insert(self.selectData,data.data)
        end
    end
    -- print("选择装备",cell.selected,data.data.index,#self.selectData)

    self:getEquipExp(self.selectData)
end

--吞噬按钮
function HuobanExpPop:onClickDevour()
    if not self.selectData then
        return
    end

    local data = {}
    local flag = false
    for k,v in pairs(self.selectData) do
        if v.colorBNum and v.colorBNum >=2 then
            flag = true
        end
        table.insert(data,v.index)
    end
    if not self.way then
        local param = {}
        param.type = 2
        param.richtext = language.huoban47
        param.sure = function()
            -- body
            proxy.HuobanProxy:send(1200201,{destIndex = data,reqType = 1})
        end
        param.cancel = function()
            
        end
        if flag then
            GComAlter(param)
        else
            if #self.selectData > 0 then
                proxy.HuobanProxy:send(1200201,{destIndex = data,reqType = 1})
            else
                GComAlter(language.huoban48)
            end
        end
    else
        local param = {}
        param.type = 2
        param.richtext = language.awaken58
        param.sure = function()
            -- body
            proxy.AwakenProxy:sendMsg(1100109,{indexs = data})
        end
        param.cancel = function()
            
        end
        if flag then
            GComAlter(param)
        else
            if #self.selectData > 0 then
                proxy.AwakenProxy:sendMsg(1100109,{indexs = data})
            else
                GComAlter(language.awaken56)
            end
        end
    end
end

function HuobanExpPop:onCloseView()
    -- body
    self:closeView()

    local view = mgr.ViewMgr:get(ViewName.PackView)
    if view then
        view:refreshPackClean()
    end
end

return HuobanExpPop