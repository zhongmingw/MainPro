--
-- Author:ohf 
-- Date: 2017-01-19 14:40:55
--
--我要变强
local GrowthView = class("GrowthView", base.BaseView)

function GrowthView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
end

function GrowthView:initData()
    local basePanel = self.view:GetChild("n15")
    GSetMoneyPanel(basePanel,self:viewName())

    local closeBtn = basePanel:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.control=self.view:GetController("c1")
    self.control.selectedIndex=0

    local basePanel1 = self.view:GetChild("n200")
    self.listView={}

    local totalPower=cache.PlayerCache:getRolePower()
    self.myPower=basePanel1:GetChild("n11")
    self.myPower.text=totalPower

    local title=basePanel1:GetChild("n5")
    self.level=basePanel1:GetChild("n10")

    self.view:GetChild("n20"):GetChild("title").text=language.growth01
    self.view:GetChild("n21"):GetChild("title").text=language.growth02
    self.view:GetChild("n22"):GetChild("title").text=language.growth03
    self.view:GetChild("n23"):GetChild("title").text=language.growth04
    self.view:GetChild("n24"):GetChild("title").text=language.growth05

    self.Recom=basePanel1:GetChild("n12")
    

    for i=1,5 do
        local btn=self.view:GetChild("n"..(19+i))
        btn.onClick:Add(self.onPageClickBtn,self)

        local label=self.view:GetChild("n"..(24+i))
        --btn.text
        local listview=basePanel1:GetChild("n"..(12+i))
        listview.visible=false
        self.listView[i]=listview
    end
    self.listView[1].visible = true
    self.currListView=self.listView[1]
    -- self.currListView.visible=true

    self.lv=cache.PlayerCache:getRoleLevel()
    self.growthPowerConf=conf.GrowthConf:getGrowthByLevel(self.lv)


    local confdata1=conf.GrowthConf:getGrowthOtherByType(1)
    self.growthOtherConf1=self:sort(confdata1)
    --printt(self.growthOtherConf1)

    local confdata2=conf.GrowthConf:getGrowthOtherByType(2)
    self.growthOtherConf2=self:sort(confdata2)
    --printt(#self.growthOtherConf2)

    local confdata3=conf.GrowthConf:getGrowthOtherByType(3)
    self.growthOtherConf3=self:sort(confdata3)
    --printt(#self.growthOtherConf3)

    local confdata4=conf.GrowthConf:getGrowthOtherByType(4)
    self.growthOtherConf4=self:sort(confdata4)
    --printt(#self.growthOtherConf4) 

    self.listView[1].itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end

    self:onRating(totalPower/self.growthPowerConf.power)
    self.Recom.text=self.growthPowerConf.power

    title.text=self.lv..language.growth06
end

function GrowthView:initView()
    
end

function GrowthView:sort(data)
    local newdata={}
    local enddata={}
    local serverTime=mgr.NetMgr:getServerTime()
    local timetab=os.date("*t",serverTime);
    local currTime=timetab.hour*3600+timetab.min*60+timetab.sec
    for i=1,#data do
        val=data[i]
        local moduleConf = conf.SysConf:getModuleById(val.moduleId)
        local open_lev = moduleConf.open_lev or 0
        local starttime=val.time[1]*60
        local endtime=val.time[2]*60
        if self.lv>=open_lev and (currTime>=starttime and endtime>=currTime) then
            newdata[#newdata+1]=val
        else
            enddata[#enddata+1]=val
        end
    end

    for k,v in pairs(enddata) do
        newdata[#newdata+1]=v
    end
    return newdata
end

function GrowthView:cellData( index,obj )
    local title=obj:GetChild("n4")
    local head=obj:GetChild("n3")
    local btn=obj:GetChild("n11")
    local desc=obj:GetChild("n13")
    local enddesc=obj:GetChild("n15")
    enddesc.visible=false
    obj:GetChild("n5").visible=false
    local progress=obj:GetChild("n9")
    progress.visible=false
    local label=obj:GetChild("n10")
    label.visible=false

    btn.data={}
    local stars={}
    for i=1,5 do
        stars[i]=obj:GetChild("n"..(15+i))
        stars[i].visible=false
    end
    if self.control.selectedIndex==1 then
        local confData=self.growthOtherConf1[index+1]
        btn.data=confData
        self:setOtherItem(obj,confData,stars)
    elseif self.control.selectedIndex==2 then
        local confData=self.growthOtherConf2[index+1]
        self:setOtherItem(obj,confData,stars)
        btn.data=confData
    elseif self.control.selectedIndex==3 then
        local confData=self.growthOtherConf3[index+1]
        self:setOtherItem(obj,confData,stars)
        btn.data=confData
    elseif self.control.selectedIndex==4 then
        local confData=self.growthOtherConf4[index+1]
        self:setOtherItem(obj,confData,stars)
        btn.data=confData
    else
        local val=0
        local confData=conf.GrowthConf:getGrowthDescById(index+1)
        if self.data.modulePowerMap[confData.moduleId] then
            val=self.data.modulePowerMap[confData.moduleId]
        end
        title.text=confData.title
        head.url=UIPackage.GetItemURL("_icons2",confData.icon)
        progress.visible=true

        btn.data=confData
        local proValue=math.floor(val/self.growthPowerConf["attr"..(index+1)]*100)
        if proValue<60 then
            obj:GetChild("n5").visible=true
        end
        progress.value=proValue
        desc.visible=false
        label.visible=true
        label.text=""..val.."/"..self.growthPowerConf["attr"..(index+1)]
        local moduleConf = conf.SysConf:getModuleById(confData.moduleId)
        local taskData=cache.TaskCache:getData()--任务信息
        local taskFlag = false
        if taskData and #taskData > 0 then
            if moduleConf.openTask and moduleConf.openTask < taskData[1].taskId then
                taskFlag = true
            elseif not moduleConf.openTask then
                taskFlag = true
            end
        else
            taskFlag = true
        end
        -- print("任务开启",taskFlag,#taskData,moduleConf.openTask,taskData[1].taskId)
        if (moduleConf.open_lev and moduleConf.open_lev>self.lv) or not taskFlag then
            progress.value=0
            label.text="0/"..self.growthPowerConf["attr"..(index+1)]
            obj:GetChild("n2").grayed=true
            label.grayed=true
            btn.visible=false
            enddesc.visible=true
            head.grayed=true
            enddesc.text=confData.level..language.growth07
        end
    end

    btn.onClick:Add(self.onForwardClick,self)
end

function GrowthView:setStarHide(stars,num)
    for i=1,num do
        local star=stars[i]
        star.visible=false
    end
end

function GrowthView:setStar(stars,num)
    for i=1,num do
        local star=stars[i]
        star.visible=true
    end
end

function GrowthView:setStarGray(stars,num)
    for i=1,num do
        local star=stars[i]
        star.grayed=true
    end
end

function GrowthView:setOtherItem(obj,data,stars)
    local title=obj:GetChild("n4")
    local head=obj:GetChild("n3")
    local btn=obj:GetChild("n11")
    local desc=obj:GetChild("n13")
    local enddesc=obj:GetChild("n15")

    title.text=data.title
    desc.text=data.desc
    head.url=UIPackage.GetItemURL("_icons2",data.icon)
    self:setStar(stars,data.star)

    local serverTime=mgr.NetMgr:getServerTime()
    local timetab=os.date("*t",serverTime);
    if data.time then
        local starttime=data.time[1]*60
        local endtime=data.time[2]*60
        local currTime=timetab.hour*3600+timetab.min*60+timetab.sec
        if (currTime>=starttime and endtime>=currTime) then
            --obj:GetChild("n2").grayed=false
        else
            self:setStarGray(stars,data.star)
            obj:GetChild("n2").grayed=true
            head.grayed=true
            timetab.hour=math.floor(data.time[1]/60)
            timetab.min=math.floor(data.time[1]%60)
            btn.visible=false
            enddesc.visible=true
            enddesc.text=string.format(("%02d:%02d"..language.growth08), timetab.hour,timetab.min) 
        end
    end
    local moduleConf = conf.SysConf:getModuleById(data.moduleId)
    local taskData=cache.TaskCache:getData()--任务信息
    local taskFlag = false
    if taskData and #taskData > 0 then
        if moduleConf.openTask and moduleConf.openTask < taskData[1].taskId then
            taskFlag = true
        elseif not moduleConf.openTask then
            taskFlag = true
        end
    else
        taskFlag = true
    end
    -- print("任务开启",taskFlag,#taskData,moduleConf.openTask,taskData[1].taskId)
    if moduleConf.open_lev and moduleConf.open_lev>self.lv or not taskFlag then
        self:setStarGray(stars,data.star)
        obj:GetChild("n2").grayed=true
        btn.visible=false
        head.grayed=true
        enddesc.visible=true
        enddesc.text=data.level..language.growth07
    end
end

function GrowthView:add5020301(data)
    self.data=data
    local num=0
    self.powerData={}
    for k,v in pairs(self.growthPowerConf) do
        if k=="id" or k=="power" then
            
        else
            self.powerData[k]=v
            num=num+1
        end
    end
    
    self.listView[1].numItems = num
end


function GrowthView:setData(data)
    
end


function GrowthView:onPageClickBtn(context)
    local index = self.control.selectedIndex
    local listview=self.listView[index+1]
    self.currListView.visible=false
    self.currListView=listview
    self.currListView.visible=true
   
    if index==1 then
        if listview.numItems <= 0 then
            listview.itemRenderer = function(index,obj)
                self:cellData(index, obj)
            end
            listview.numItems = #self.growthOtherConf1
        end
    elseif index==2 then
        if listview.numItems <= 0 then
            listview.itemRenderer = function(index,obj)
                self:cellData(index, obj)
            end
            listview.numItems = #self.growthOtherConf2
        end
    elseif index==3 then
        if listview.numItems <= 0 then
            listview.itemRenderer = function(index,obj)
                self:cellData(index, obj)
            end
            listview.numItems = #self.growthOtherConf3
        end
    elseif index==4 then
        if listview.numItems <= 0 then
            listview.itemRenderer = function(index,obj)
                self:cellData(index, obj)
            end
            listview.numItems = #self.growthOtherConf4
        end
    else
        
    end
end

function GrowthView:onClickClose()
    -- body
    self:closeView()
end

function GrowthView:onForwardClick(context)--前往
    local btn = context.sender
    local data=btn.data
    --plog("onForwardClick=====:")
    -- print(data.id)
    if data.moduleId then
        GOpenView({id = data.moduleId})
    end
end

function GrowthView:onRating(score)--前往
    if 0.6>score then --c
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_010")
    elseif score>=0.6 and 0.9>score then --b
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_009")
    elseif score>=0.9 and 1.05>score then --a
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_006")
    elseif score>=1.05 and 1.4>score then  --s
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_005")
    elseif score>=1.4 and 1.9>score then  --ss
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_008")
    else                                  --sss
        self.level.url=UIPackage.GetItemURL("growth","woyaobianqiang_007")
    end
end

return GrowthView