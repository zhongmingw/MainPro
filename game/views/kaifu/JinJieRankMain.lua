--
-- Author: 
-- Date: 2018-11-06 16:28:05
--

local JinJieRankMain = class("JinJieRankMain", base.BaseView)
local Active1023 = import(".Active1023")--3001-3008 --坐骑进阶排行
local Active1091 = import(".Active1091")--1091 --神器战力排行bxp
local Active1041 = import(".Active1041")--1041 --等级排行
local Active1048 = import(".Active1048")--包含1075 宠物排行



local ActId = {
    [1385] = 1023,--坐骑进阶大比拼
    [1386] = 1001,--仙羽进阶大比拼
    [1387] = 1002,--神兵进阶大比拼
    [1388] = 1003,--仙器进阶大比拼
    [1389] = 1004,--法宝进阶大比拼
    [1390] = 1005,--伙伴仙羽进阶大比拼
    [1391] = 1006,--伙伴神兵进阶大比拼
    [1392] = 1007,--伙伴仙器进阶大比拼
    [1393] = 1008,--伙伴法宝进阶大比拼
    [1394] = 1091,--神器排行
    [1395] = 1041,--等级排行
    [1396] = 1075,--宠物排行
    [1397] = 1051,--装备排行

}
local TITLEICON = {
    [1385] = "ui://kaifu/jinjiepaihang_008",--坐骑进阶大比拼
    [1386] = "ui://kaifu/jinjiepaihang_010",--仙羽进阶大比拼
    [1387] = "ui://kaifu/jinjiepaihang_009",--神兵进阶大比拼
    [1388] = "ui://kaifu/jinjiepaihang_011",--仙器进阶大比拼
    [1389] = "ui://kaifu/jinjiepaihang_012",--法宝进阶大比拼
    [1390] = "ui://kaifu/jinjiepaihang_013",--伙伴仙羽进阶大比拼
    [1391] = "ui://kaifu/jinjiepaihang_014",--伙伴神兵进阶大比拼
    [1392] = "ui://kaifu/jinjiepaihang_015",--伙伴仙器进阶大比拼
    [1393] = "ui://kaifu/jinjiepaihang_016",--伙伴法宝进阶大比拼
    [1394] = "ui://kaifu/jinjiepaihang_002",--神器排行
    [1395] = "ui://kaifu/jinjiepaihang_003",--等级排行
    [1396] = "ui://kaifu/jinjiepaihang_004",--宠物排行
    [1397] = "ui://kaifu/jinjiepaihang_005",--装备排行
}

local ShowObj = {
    [1385] = "Active1023",--坐骑进阶大比拼
    [1386] = "Active1023",--仙羽进阶大比拼
    [1387] = "Active1023",--神兵进阶大比拼
    [1388] = "Active1023",--仙器进阶大比拼
    [1389] = "Active1023",--法宝进阶大比拼
    [1390] = "Active1023",--伙伴仙羽进阶大比拼
    [1391] = "Active1023",--伙伴神兵进阶大比拼
    [1392] = "Active1023",--伙伴仙器进阶大比拼
    [1393] = "Active1023",--伙伴法宝进阶大比拼
    [1394] = "Active1091",--神器排行
    [1395] = "Active1041",--等级排行
    [1396] = "Active1048",--宠物排行
    [1397] = "Active1048",--装备排行
}


function JinJieRankMain:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function JinJieRankMain:initView()
    self.window = self.view:GetChild("n0")
    local btnClose = self.window:GetChild("n4")
    btnClose.onClick:Add(self.onBtnClose,self)
    self.container = self.view:GetChild("n7")
end

function JinJieRankMain:initData(data)
    --活动id
    self.actId = ActId[data.id]
    --标题
    self.window.icon = TITLEICON[data.id]

    if self.showObj then
        for k ,v in pairs(self.showObj) do
            v:Dispose()
        end 
    end
    self.showObj = {}
    self.classObj = {}
    local falg = false
    if not self.showObj[self.actId] then --用来缓存
        local index = self.actId 
        if self.actId <= 1008 or self.actId == 1023 then 
            index = 1023
        elseif self.actId == 1091 then
            index = 1091
        elseif self.actId == 1041 then
            index = 1041
        elseif self.actId == 1075 or self.actId == 1051 then
            index = 1048--这个比较特殊， 1048小类里包含1075 ,1051
        end 
        local var = "Active"..index
        self.showObj[self.actId] = UIPackage.CreateObject("kaifu",var)
        falg = true
    end
    self.container:AddChild(self.showObj[self.actId])
    if self.actId <= 1008 or self.actId == 1023 then-- 请求开服进阶大比拼排行榜信息
        if falg then
            self.classObj[self.actId] = Active1023.new(self.showObj[self.actId])
        end
        self.classObj[self.actId]:setCurId(self.actId)
        proxy.ActivityProxy:sendMsg(1030109, {actId = self.actId})
    elseif self.actId == 1091 then--开服神奇排行
        if falg then
            self.classObj[self.actId] = Active1091.new(self.showObj[self.actId])
        end
        self.classObj[self.actId]:setCurId(self.actId)
        proxy.ActivityProxy:sendMsg(1030409)
    elseif self.actId == 1041 then--等级排行
        if falg then
            self.classObj[self.actId] = Active1041.new(self.showObj[self.actId])
        end
        self.classObj[self.actId]:setCurId(self.actId)
        proxy.ActivityProxy:sendMsg(1030207,{actId = 1041})
    elseif self.actId == 1075  or self.actId == 1051 then --宠物排行&装备排行
        if falg then 
            self.classObj[self.actId] = Active1048.new(self.showObj[self.actId])
        end 
        self.classObj[self.actId]:setCurId(self.actId)
        if self.actId == 1075 then
            proxy.ActivityProxy:sendMsg(1030183,{actId = 1075})
        elseif self.actId == 1051 then
            proxy.ActivityProxy:sendMsg(1030150,{actId = 1051})
        end
    end
    self:addTimer(1,-1,handler(self,self.onTimer))
end

function JinJieRankMain:onTimer()
    if not self.actId then
        return
    end
    if not self.classObj then
        return
    end
    if not self.classObj[self.actId] then
        return
    end
    self.classObj[self.actId]:onTimer()
end
function JinJieRankMain:addMsgCallBack(data)
    local mData = cache.ActivityCache:get5030111()
    local openDay = mData.openDay
    if 5030109 == data.msgId and (self.actId <= 1008 or self.actId == 1023) then 
        self.classObj[self.actId]:add5030109(data)
    elseif 5030409 == data.msgId and self.actId == 1091 then
        self.classObj[self.actId]:add5030409(data)
    elseif 5030207 == data.msgId and self.actId == 1041 then 
        self.classObj[self.actId]:setOpenDay(openDay)
        self.classObj[self.actId]:add5030207(data)
    elseif 5030183 == data.msgId and self.actId == 1075 then 
        self.classObj[self.actId]:add5030148(data)
    elseif 5030150 == data.msgId and self.actId == 1051 then 
        self.classObj[self.actId]:setOpenDay(openDay)
        self.classObj[self.actId]:add5030148(data)
    end
end

function JinJieRankMain:onBtnClose()
    self:closeView()
end

return JinJieRankMain