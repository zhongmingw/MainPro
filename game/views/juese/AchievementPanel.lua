--成就
local AchievementPanel = class("AchievementPanel", import("game.base.Ref"))

function AchievementPanel:ctor(parent)
    self.parent = parent
    self.achieveInfos = {} --成就信息
    self.page = 1          --当前页数
    self.sumPage = 1       --总页数
    self.achieveType = 0   --当前成就信息类型
    self.lastIn = true     --最后一次进入

    self:initPanel()
end

function AchievementPanel:initPanel()
    -- body
    self.panel = self.parent.view:GetChild("n19")
    self.listView = self.panel:GetChild("n125")
    self.attList = {} --属性列表
    for i=68,75 do
        local text = self.panel:GetChild("n"..i)
        text.text = ""
        table.insert(self.attList,text)
    end
    self.controllerC1 = self.panel:GetController("c1") --
    self.xingxing = self.panel:GetChild("n108")

    self.controllerC1.onChanged:Add(self.onController1,self)

    self.icon = self.panel:GetChild("n77") 

    self.btnAdvance = self.panel:GetChild("n66")
    self.btnAdvance.onClick:Add(self.onClickAdvance,self) --进阶按钮
    self.achieveName = self.panel:GetChild("n81") --成就名字
    self.power = self.panel:GetChild("n76") --属性加成战力
    self.advance = self.panel:GetChild("n100") --成就阶数
    self.panel:GetChild("n111").visible = false
    self.power.text = ""
    self:initListView()
    --标签列表
    self.titleListView = self.panel:GetChild("n119")
    self.titleListView.numItems = 0
    self.titleListView.itemRenderer = function(index,obj)
        self:titleData(index, obj)
    end
    self.titleListView:SetVirtual()

    self.titleListView.onClickItem:Add(self.onCallBack,self)
    self.titleListView:AddSelection(0,false)
    --成就分类列表
    self.typeList = self.panel:GetChild("n120")
    self.typeList.numItems = 0
    self.typeList.itemRenderer = function(index,obj)
        self:typeData(index, obj)
    end
    self.typeList:SetVirtual()
    self.typeList.onClickItem:Add(self.onCallBack,self)
    self.achieveTypeData = conf.AchieveConf:getAchieveTypeData()
end

function AchievementPanel:typeData( index,obj )
    local data = self.achieveTypeData[index+1]
    if data then
        obj.data = index+1
        local icon = obj:GetChild("n1")
        local redImg = obj:GetChild("n4")
        redImg.visible = false
        if self.hasAchieveGotMap[index+1] and self.hasAchieveGotMap[index+1] > 0 then
            redImg.visible = true
        end
        icon.url = UIPackage.GetItemURL("juese" , data.img)
        local processBar = obj:GetChild("n2")
        processBar.max = data.finish
        processBar.value = self.data.achieveCountMap[index+1] or 0
    end
end

function AchievementPanel:titleData( index,obj )
    local titleTxt = language.achieve07[index]
    if titleTxt then
        local redImg = obj:GetChild("n4")
        redImg.visible = false
        if self.hasAchieveGotMap[index] and self.hasAchieveGotMap[index] > 0 then
            redImg.visible = true
        end
        local nextData = conf.AchieveConf:getAttData(self.data.achieveLevel+1)
        if nextData then
            if index == 0 then
                -- print("第一个",self.data.achieveValue,nextData.achieve_value)
                if self.data.achieveValue >= nextData.achieve_value then
                    redImg.visible = true
                else
                    redImg.visible = false
                end
            end
        end
        obj.data = index
        obj:GetChild("title").text = titleTxt
    end
end

function AchievementPanel:onCallBack( context )
    local obj = context.data
    local data = obj.data
    self.achieveType = data
    -- print("当前大类",self.achieveType)
    self.controllerC1.selectedIndex = data >= 1 and 1 or 0
    if data > 7 then 
        self.titleListView:ScrollToView(7,false)
    end
    self.titleListView:AddSelection(data,false)
    self:onController1()
end

function AchievementPanel:onController1()
    self.achieveInfos = {}

    self.lastIn = true
    self.page = 1
    local param = {achieveType = self.achieveType,page = 1}
    proxy.PlayerProxy:send(1270201,param)
end

function AchievementPanel:setData(data)
    -- body
    self.data = data
    self.page = data.page
    self.sumPage = data.sumPage
    self.hasAchieveGotMap = data.hasAchieveGotMap --
    self.titleListView.numItems = 10
    -- print("当前页数",self.sumPage,self.page)
    for k,v in pairs(data.achieveInfos) do
        table.insert(self.achieveInfos,v)
    end
    -- printt("11111111111",self.data.achieveCountMap)
    self.listView.numItems = #self.achieveInfos
    if self.achieveType == 0 then
        self.typeList.numItems = #self.achieveTypeData
    end
    if 0 == self.controllerC1.selectedIndex then  --成就总信息 
        self.is10 = true
        self:initAchieveAtt()
    elseif 1 == self.controllerC1.selectedIndex then --玩法信息
        local processBar = self.panel:GetChild("n128")
        local titleIcon = self.panel:GetChild("n130")
        local confData = self.achieveTypeData[self.achieveType]
        if confData then
            processBar.max = confData.finish
            processBar.value = data.achieveCountMap[self.achieveType] or 0
            local titleConf = conf.RoleConf:getTitleData(confData.title_id)
            -- print("称号图标",titleConf.scr)
            titleIcon.url = UIPackage.GetItemURL("head" , tostring(titleConf.scr))
        end
    end
end

--加载成就属性
function AchievementPanel:initAchieveAtt()
    for k,v in pairs(self.attList) do
        v.text = ""
    end
    local attrData = conf.AchieveConf:getAttData(self.data.achieveLevel)
    local ExpBar = self.panel:GetChild("n111")
    ExpBar.visible = true
    if attrData then
        local data = GConfDataSort(attrData)
        for k,v in pairs(data) do
            local key = v[1]
            local value = v[2]
            local decTxt = self.attList[k]
            local attName = conf.RedPointConf:getProName(key)
            decTxt.text = attName.." "..value
        end
        if attrData.star and self.is10 and attrData.star ~= 0 then
            self.xingxing:GetController("c1").selectedIndex = attrData.star + 10 
        else
            self.xingxing:GetController("c1").selectedIndex = attrData.star
        end
        
        if attrData.star == 10 then
            self.btnAdvance:GetChild("icon").url = UIPackage.GetItemURL("juese" , "zuoqi_008")
        else
            self.btnAdvance:GetChild("icon").url = UIPackage.GetItemURL("juese" , "chengjiu_031")
        end
        ExpBar.value = self.data.achieveValue
        local nextData = conf.AchieveConf:getAttData(self.data.achieveLevel+1)
        if nextData then
            ExpBar.max = nextData.achieve_value
            local textData = {
                {text=self.data.achieveValue.."",color = 14},
                {text="/",color = 7},
                {text=nextData.achieve_value.."",color = 7},
            }
            if self.data.achieveValue >= nextData.achieve_value then
                textData = {
                    {text=self.data.achieveValue.."",color = 7},
                    {text="/",color = 7},
                    {text=nextData.achieve_value.."",color = 7},
                }
            end
            self.panel:GetChild("n104").text = mgr.TextMgr:getTextByTable(textData)

            if self.data.achieveValue >= nextData.achieve_value then
                self.btnAdvance:GetChild("red").visible = true
            else
                self.btnAdvance:GetChild("red").visible = false
            end
        else
            local textData = {
                {text=self.data.achieveValue.."",color = 7},
                {text="/",color = 7},
                {text=attrData.achieve_value.."",color = 7},
            }
            ExpBar.max = attrData.achieve_value
            self.panel:GetChild("n104").text = mgr.TextMgr:getTextByTable(textData)
            self.btnAdvance.visible = false
        end
        self.achieveName.text = attrData.name
        self.power.text = attrData.power
        self.advance.url = UIPackage.GetItemURL("juese" , "chengjiu_0"..(13+attrData.step))
        self.icon.url = UIPackage.GetItemURL("juese" , "chengjiu_0"..(33+attrData.step))
    else
        self.xingxing:GetController("c1").selectedIndex = 0
    end
end

--初始化list列表
function AchievementPanel:initListView()
    -- body
    self.listView.numItems = 0
    self.listView.itemRenderer = function(index,obj)
        self:itemData(index, obj)
    end
    self.listView:SetVirtual()
end

function AchievementPanel:itemData(index, obj)
    -- body
    if index + 1 >= self.listView.numItems then
        if not self.achieveInfos then
            return 
        end 
        -- print("9999999",self.page,self.maxPage,self.listView.numItems,index)
        if self.sumPage == self.page then 
            --没有下一页了
            --return
        elseif self.lastIn == true then
            local param = {achieveType = self.achieveType,page = self.page+1}
            proxy.PlayerProxy:send(1270201,param)
        end
    end
    local data = self.achieveInfos[index+1]
    if data then
        local achieveId = data.achieveId  --成就id
        local process = data.process      --成就进度
        local status = data.status        --成就状态
        local achieveData = conf.AchieveConf:getAchieveInfoById(achieveId)
        local ctrl = obj:GetController("c1")
        local dec = obj:GetChild("n7")
        -- local processTxt = obj:GetChild("n6")
        local point = obj:GetChild("n4")
        local processBar = obj:GetChild("n3")
        local awardsItem = obj:GetChild("n11")
        if achieveData then
            dec.text = achieveData.desc
            -- processTxt.text = process.."/"..achieveData.finish_cond
            point.text = "+"..achieveData.point
            processBar.value = process
            processBar.max = achieveData.finish_cond
            local info = {mid=achieveData.awards[1][1],amount = achieveData.awards[1][2]}
            awardsItem.visible = true
            GSetItemData(awardsItem,info,true)
            -- if achieveData.finish_cond == process then
            --     ctrl.selectedIndex = 1
            -- end
        else
            print("没有奖励!!!!!!!!!!!!!!",achieveId)
        end
        if status == 3 then--已领取
            ctrl.selectedIndex = 2
        elseif status == 2 then--可领取
            ctrl.selectedIndex = 1
        elseif status == 1 then--不可领取
            ctrl.selectedIndex = 0
        end
        local getBtn = obj:GetChild("n19")
        getBtn.data = data
        getBtn.onClick:Add(self.onClickGet,self)
    end
end

--领取成就按钮
function AchievementPanel:onClickGet( context )
    local cell = context.sender
    local data = cell.data
    if data.status == 2 then
        local param = {achieveId = data.achieveId,achieveType = self.achieveType}
        proxy.PlayerProxy:send(1270202,param)
    elseif data.status == 1 then
        local achieveData = conf.AchieveConf:getAchieveInfoById(data.achieveId)
        local id = achieveData.formview[1]
        local childIndex = achieveData.formview[2]
        GOpenView({id = id,childIndex = childIndex})
        -- GComAlter(language.achieve05)
    else
        GComAlter(language.achieve06)
    end
end

--领取成就后刷新
function AchievementPanel:updataAchieveAtt( data )
    self.data.achieveValue = data.achieveValue
    self.is10 = true
    self:initAchieveAtt()

    self.achieveInfos = {}

    self.lastIn = true
    self.page = 1
    local param = {achieveType = self.achieveType,page = 1}
    proxy.PlayerProxy:send(1270201,param)
end

--成就进阶按钮
function AchievementPanel:onClickAdvance( context )
    -- body
    local attrData = conf.AchieveConf:getAttData(self.data.achieveLevel+1)
    if attrData then
        if self.data.achieveValue >= attrData.achieve_value then
            proxy.PlayerProxy:send(1270203)
        else
            if self.xingxing:GetController("c1").selectedIndex == 10 then
                GComAlter(language.achieve02)
            else
                GComAlter(language.achieve04)
            end
        end
    else
        GComAlter(language.achieve03)
    end
end

--进阶刷新
function AchievementPanel:advanceRefresh( data )
    -- body
    self.data.achieveLevel = data.achieveLevel
    self.is10 = false
    self:initAchieveAtt()
    self.titleListView.numItems = 10
end

return AchievementPanel