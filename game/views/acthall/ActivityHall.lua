--
-- Author: Your Name
-- Date: 2017-07-28 15:10:38
--

local ActivityHall = class("ActivityHall", base.BaseView)

function ActivityHall:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function ActivityHall:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n5")
    closeBtn.onClick:Add(self.onClickView,self)
    self.listView = self.view:GetChild("n4")
    -- self.decList = self.view:GetChild("n9")
    self.awardsList = self.view:GetChild("n10")
    self.gotoBtn = self.view:GetChild("n8")
    self.decTxtItem = self.view:GetChild("n11"):GetChild("n0")
    self:initListView()
    self:initAwardsList()
end

function ActivityHall:initListView()
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
end

function ActivityHall:initAwardsList()
    self.awardsList.numItems = 0
    self.awardsList.itemRenderer = function (index,obj)
        self:awardsCelldata(index, obj)
    end
    self.awardsList:SetVirtual()
end

function ActivityHall:initData(data)
    self.moduleId = data.childIndex
    self.data = conf.ActivityHallConf:getactData()
    self:sort()
    local index = 0
    for k,v in pairs(self.data) do
        if v.skip == self.moduleId then
            index = k-1
        end
    end
    self.listView.numItems = #self.data
    if self.listView.numItems >0 then
        self:setItemInfo(self.data[index+1])
        -- self.listView:ScrollToView(0,false)
        self.listView:AddSelection(index,true)
    end
end

function ActivityHall:sort()
    local curTime = mgr.NetMgr:getServerTime()
    local nowTime = GGetSecondBySeverTime(curTime)
    for k,v in pairs(self.data) do
        if not v.proceed_time and v.id ~= 11 then--全天开放的
            if v.id ~= 13 and v.id ~= 14 then
                self.data[k].sortindex = 1
            else
                local var = cache.PlayerCache:getAttribute(attConst.A10323)
                if var == 1 then
                    self.data[k].sortindex = 1
                else
                    self.data[k].sortindex = 5
                end
            end
        else
            if not v.red_open then--不是仙盟战、仙魔战、三界争霸
                if nowTime < v.proceed_time[1] then --未开启
                    self.data[k].sortindex = 3
                elseif nowTime >= v.proceed_time[1] and nowTime < v.proceed_time[2] then --进行中
                    self.data[k].sortindex = 2
                else--已结束
                    self.data[k].sortindex = 4
                end
            elseif v.red_open and v.red_open ~= 20133 then--仙魔战、三界争霸、排位赛
                local var = cache.PlayerCache:getAttribute(v.red_open)
                if v.red_open == 50128 then--排位赛
                    var = cache.PlayerCache:getRedPointById(v.red_open)
                end
                if var > 0 then
                    if nowTime < v.proceed_time[1] then --未开启
                        self.data[k].sortindex = 3
                    elseif nowTime >= v.proceed_time[1] and nowTime < v.proceed_time[2] then --进行中
                        self.data[k].sortindex = 2
                    else--已结束
                        self.data[k].sortindex = 4
                    end
                else
                    self.data[k].sortindex = 5
                end
            else--仙盟战
                local xmstartTime = cache.PlayerCache:getAttribute(50111)
                local xmTime = GGetSecondBySeverTime(xmstartTime)
                local endtime = cache.PlayerCache:getAttribute(20133)
                if xmstartTime > 0 then
                    if nowTime < xmTime then --未开启
                        self.data[k].sortindex = 3
                    elseif nowTime >= xmTime and nowTime < GGetSecondBySeverTime(endtime) then --进行中
                        -- print("999999999999",nowTime,xmTime,endtime)
                        self.data[k].sortindex = 2
                    else--已结束
                        self.data[k].sortindex = 4
                    end
                else--不开放
                    self.data[k].sortindex = 5
                end
            end
        end
    end
    table.sort(self.data,function(a,b)
        if a.sortindex ~= b.sortindex then
            return a.sortindex < b.sortindex
        else
            return a.id < b.id
        end
    end)
end

function ActivityHall:celldata( index, obj )
    local data = self.data[index+1]
    local icon = obj:GetChild("n8")
    local openTxt = obj:GetChild("n5")
    local lvTxt = obj:GetChild("n6")
    local typeImg = obj:GetChild("n11")
    local openImg = obj:GetChild("n2")
    local selectImg = obj:GetChild("n12")
    if data then
        local iconUrl = UIPackage.GetItemURL("_icons2" , data.icon)
        if not iconUrl then
            iconUrl = UIPackage.GetItemURL("_icons" , data.icon)
        end
        icon.url = iconUrl
        openTxt.text = data.open_time
        lvTxt.text = data.open_lv
        
        if data.type == 1 then
            typeImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_012")
        elseif data.type == 2 then
            typeImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_013")
        elseif data.type == 3 then
            typeImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_006")
        elseif data.type == 4 then
            typeImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_014")  
        end

        if data.sortindex == 1 then--全天开放
            openImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_002")
        elseif data.sortindex == 2 then--进行中
            openImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_005")
        elseif data.sortindex == 3 then--未开启
            openImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_004")
        elseif data.sortindex == 4 then--已结束
            openImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_003")
        elseif data.sortindex == 5 then--不开放
            openImg.url = UIPackage.GetItemURL("acthall" , "huodongdatin_001")
        end
        obj.data = data
        obj.onClick:Add(self.onClickSetInfo,self)
    end
end

function ActivityHall:awardsCelldata( index,obj )
    local data = self.awards[index+1]
    if data then
        local mId = data[1]
        local amount = data[2]
        local bind = data[3]
        local info = {mid = mId,amount = amount,bind = bind}
        GSetItemData(obj,info,true)
    end
end
function ActivityHall:setItemInfo(data)
    -- body
    self.gotoBtn.data = data
    self.gotoBtn.onClick:Add(self.onClickGoTo,self)
    -- self.decList:RemoveChildren()
    self.decTxtItem.text = ""
    local decTab = data.explain
    for k,v in pairs(decTab) do
        self.decTxtItem.text = self.decTxtItem.text .. v .."\n"
    end

    self.awards = data.awards or {}

    self.awardsList.numItems = #self.awards
end

function ActivityHall:onClickSetInfo( context )
    local data = context.sender.data
    self:setItemInfo(data)
end


function ActivityHall:onClickGoTo( context )
    local data = context.sender.data
    local id = data.skip
    local roleLv = cache.PlayerCache:getRoleLevel()
    if roleLv >= data.open_lv then
        if data.sortindex == 3 then--未开启
            GComAlter(language.acthall03)
        elseif data.sortindex == 4 then--已结束
            GComAlter(language.acthall02)            
        elseif data.sortindex == 5 then--不开放
            GComAlter(language.acthall04)
        else
            if id == 1116 then
                if not gRole:isMajor() then
                    local point = GGetMajorPoint()
                    proxy.ThingProxy:send(1020101, {sceneId=201001, pox=point[1], poy=point[2], type=5})
                end
                self:onClickView()
            elseif id == 1112 then
                GOpenView({id = id,isActHall = true})
            elseif id == 1126 then
                local roleLv = cache.PlayerCache:getRoleLevel()
                local confData = conf.ActivityHallConf:getTrebleDataByLv(roleLv)
                proxy.ThingProxy:send(1020101, {sceneId=confData.sid, pox=confData.pos[1], poy=confData.pos[2], type=5})
            else
                GOpenView({id = id})
            end
        end
    else
        GComAlter(string.format(language.acthall01,data.open_lv))
    end
end

function ActivityHall:onClickView(  )
    self:closeView()
end

return ActivityHall