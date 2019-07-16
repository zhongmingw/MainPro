-- 跨服城战入口界面
-- Author: Your Name
-- Date: 2018-04-17 15:13:01
--
local CityWarPanel = class("CityWarPanel", import("game.base.Ref"))

function CityWarPanel:ctor(parent,view)
    self.parent = parent
    self.view = view
    self:initView()    
end

function CityWarPanel:initView()
    self.awardsBtn = self.view:GetChild("n22")
    self.awardsBtn.onClick:Add(self.onClickAwards,self)
    local guizeBtn = self.view:GetChild("n25")
    guizeBtn.onClick:Add(self.onClickGuize,self)
    self.btnlist = {}
    for i=2,5 do
        table.insert(self.btnlist,self.view:GetChild("n"..i))
    end
    self.namelist = {}
    for i=18,21 do
        table.insert(self.namelist,self.view:GetChild("n"..i))
    end
    self.imglist = {}
    for i=10,13 do
        table.insert(self.imglist,self.view:GetChild("n"..i))
    end
    self.xuanzhanSign = {}
    for i=31,34 do
        table.insert(self.xuanzhanSign,self.view:GetChild("n"..i))
    end
    --跨平台标志
    self.crossIcon = {}
    for i=35,38 do
        table.insert(self.crossIcon,self.view:GetChild("n"..i))
    end
    self.startTxt = self.view:GetChild("n29")
    local dec1 = self.view:GetChild("n27")
    dec1.text = language.citywar14
    local dec2 = self.view:GetChild("n28")
    dec2.text = language.citywar15
    self.nextOpenTxt = self.view:GetChild("n29")
end

--初始化城池信息
function CityWarPanel:initCityInfo()
    local openRedPiont = cache.PlayerCache:getRedPointById(attConst.A20168)--城战开启红点值
    local getRedPoint = 0 --奖励红点
    local redPoints = {attConst.A20169,attConst.A20204,attConst.A20205}
    for k,v in pairs(redPoints) do
        local var = cache.PlayerCache:getRedPointById(v)
        getRedPoint = getRedPoint + var
    end
    if getRedPoint > 0 then
        self.awardsBtn:GetChild("red").visible = true
    else
        self.awardsBtn:GetChild("red").visible = false
    end
    for i=1,4 do
        local occupyInfos = self.data.occupyInfos[language.citywar01[i]]
        local btn = self.btnlist[i]
        local attImg = self.imglist[i]
        local nameTxt = self.namelist[i]
        local xuanzhanSign = self.xuanzhanSign[i]
        local crossIcon = self.crossIcon[i]
        crossIcon.visible = false
        xuanzhanSign.visible = false
        if occupyInfos then
            btn.data = occupyInfos
            btn.onClick:Add(self.onClickEnter,self)

            --宣战时间
            local netTime = mgr.NetMgr:getServerTime()
            local nowtime = GGetSecondBySeverTime(netTime)
            local signTime = conf.CityWarConf:getValue("sign_time")
            if nowtime < signTime[2] and nowtime > signTime[1] and self.data.isXz == 1 and cache.PlayerCache:getRedPointById(20170) > 0 then
                xuanzhanSign.visible = true
            else
                xuanzhanSign.visible = false
            end
            if self.data.warSceneId > 0 or occupyInfos.sceneId == language.citywar01[3] or self:hasCity() then
                xuanzhanSign.visible = false
            end
            nameTxt.text = occupyInfos.gangName 
            if not occupyInfos.gangName or occupyInfos.gangName == "" then
                nameTxt.text = language.citywar02
            end
            attImg.visible = true
            if openRedPiont == 0 then--未开始
                attImg.visible = false
            else
                local gangId = cache.PlayerCache:getGangId()
                if gangId == occupyInfos.gangId and tonumber(gangId) ~= 0 then--己方
                -- print("。。。。。。。。。。。。。。",occupyInfos.gangId,type(gangId))
                    attImg.url = UIPackage.GetItemURL("citywar" , "chengzhan_006")
                elseif occupyInfos.sceneId == self.data.warSceneId or (self:hasCity() and occupyInfos.sceneId == language.citywar01[3]) then
                    attImg.url = UIPackage.GetItemURL("citywar" , "chengzhan_005")
                else
                    attImg.visible = false
                end
            end

            if tonumber(occupyInfos.gangId) ~= 0 then
                local chanelId = tonumber(string.sub(occupyInfos.gangId,1,3))
                local myChanelId = cache.PlayerCache:getRedPointById(10327)
                if chanelId ~= myChanelId then
                    crossIcon.visible = true
                end
            end
        else
            nameTxt.text = language.citywar02
            attImg.visible = false
        end
    end
end

--己方是否已经占领了城池
function CityWarPanel:hasCity()
    local gangId = cache.PlayerCache:getGangId()
    local flag = false
    for k,v in pairs(self.data.occupyInfos) do
        if gangId == v.gangId and tonumber(gangId) ~= 0 then
            flag = true
            break
        end
    end
    return flag
end

-- 变量名：nextOpenWeekDay 说明：开启时间
-- 变量名：occupyInfos 说明：占领信息
-- 变量名：isXz    说明：是否有权限宣战 1:可宣战
-- 变量名：warSceneId  说明：已宣战城池id
    -- 变量名：sceneId 说明：场景id(城池)
    -- 变量名：gangName    说明：占领宗门
    -- 变量名：gangAdminName   说明：占领宗主名
    -- 变量名：occupyDay   说明：占领天数
    -- 变量名：warNum  说明：宣战数量
    -- 变量名：gangId  说明：占领仙盟id
function CityWarPanel:setData(data)
    printt("跨服城战信息",data)
    self.data = data
    self:initCityInfo()
    local nextOpenDay = data.nextOpenWeekDay
    local netTime = mgr.NetMgr:getServerTime()
    local weekday = GGetWeekDayByTimestamp(netTime)
    if weekday == 0 then weekday = 7 end
    if nextOpenDay >= weekday then
        self.nextOpenTxt.text = language.xmhd27[nextOpenDay] .. language.citywar16
    else
        self.nextOpenTxt.text = language.xmhd31[nextOpenDay] .. language.citywar16
    end
end
--城池宣战信息返回
function CityWarPanel:setCityDeclareInfo(data)
    for k,v in pairs(self.data.occupyInfos) do
        if v.sceneId == data.sceneId then
            self.data.occupyInfos[k].occupyType = data.occupyType
        end
    end
    self:initCityInfo()
end

-- declearGangId   说明：宣战宗门id
-- sceneId         说明：宣战城池（场景id）
-- gangAdminName   说明：宗主(服务器用)
function CityWarPanel:onClickEnter(context)
    local data = context.sender.data
    local gangId = cache.PlayerCache:getGangId()
    local openRedPiont = cache.PlayerCache:getRedPointById(attConst.A20168)--城战开启红点值
    local sId = cache.PlayerCache:getSId()
    if openRedPiont == 0 then--活动未开启
        mgr.ViewMgr:openView2(ViewName.CityWarAwards, {index = 0,sId = data.sceneId})
    elseif data.sceneId == self.data.warSceneId and openRedPiont > 0 or 
        data.gangId == gangId or (data.sceneId == language.citywar01[3] and self:hasCity()) then--进入城池战斗
        if data.sceneId == sId then 
            GComAlter(language.citywar13)
        else
            if mgr.FubenMgr:checkScene() or mgr.FubenMgr:isFlameScene(sId) then
                GComAlter(language.gonggong41)
                return
            end
            proxy.ThingProxy:send(1020101,{sceneId = data.sceneId,type = 3})
        end
    else
        if data.sceneId == language.citywar01[3] then
            GComAlter(language.citywar21)
        else
            GComAlter(language.citywar06)
        end
    end

end

function CityWarPanel:onClickAwards()
    mgr.ViewMgr:openView2(ViewName.CityWarAwards,{index = 1,sId = language.citywar01[3]})
end

function CityWarPanel:onClickGuize()
    GOpenRuleView(1086)
end

return CityWarPanel