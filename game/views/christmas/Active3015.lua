--
-- Author: Your Name
-- Date: 2017-12-18 21:38:14
--许愿袜
local Active3015 = class("Active3015",import("game.base.Ref"))

function Active3015:ctor(param)
    self.view = param
    self:initView()
end

function Active3015:initView()
    -- body
    self.timeTxt = self.view:GetChild("n3")
    self.listView = self.view:GetChild("n7")
    self.listView.numItems = 0
    self.listView.itemRenderer = function (index,obj)
        self:celldata(index, obj)
    end
    self.listView:SetVirtual()
    self.handInTxt = self.view:GetChild("n9")
    self.decTxt = self.view:GetChild("n4")
end

function Active3015:celldata( index,obj )
    local data = self.awardsConf[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = 0,bind = data[3]}
        GSetItemData(obj, itemInfo, true)
    end
end

function Active3015:onTimer()
    -- body
end

function Active3015:setCurId(id)
    -- body
    
end

function Active3015:isGet(id)
    local flag = false
    for i,v in ipairs(self.data.gotList) do
        if v == id then
            flag = true
            break
        end
    end
    return flag
end

--设置进度条
function Active3015:setProgressBar()
    local socksConf = conf.ActivityConf:getSocksData()
    for i=1,4 do
        local bar = self.view:GetChild("n"..(13+i))
        local getBtn = self.view:GetChild("n"..(22+i))
        local action = self.view:GetChild("n"..(26+i))
        local redImg = self.view:GetChild("n"..(40+i))
        local valueTxt = self.view:GetChild("n"..(32+i))
        local isGetIcon = self.view:GetChild("n"..(36+i))
        isGetIcon.visible = false
        valueTxt.text = socksConf[i].socks_num
        getBtn.data = i
        getBtn.onClick:Add(self.onClickGet,self)
        if i > 1 then
            bar.max = socksConf[i].socks_num - socksConf[i-1].socks_num
            local value = self.data.commitNum - socksConf[i-1].socks_num
            bar.value = value > 0 and value or 0
        else
            bar.max = socksConf[i].socks_num
            bar.value = self.data.commitNum
        end
        local item = self.view:GetChild("n"..(9+i))
        local itemInfo = {mid = socksConf[i].awards[1][1],amount = socksConf[i].awards[1][2],bind = socksConf[i].awards[1][3],isquan = true}
        GSetItemData(item, itemInfo, true)
        if not self:isGet(i) then
            if self.data.commitNum >= socksConf[i].socks_num then
                getBtn.visible = true
                action.visible = true
                redImg.visible = true
            else
                action.visible = false
                redImg.visible = false
                getBtn.visible = false
            end
        else
            isGetIcon.visible = true
            action.visible = false
            redImg.visible = false
            getBtn.visible = false
        end
    end
end

function Active3015:add5030163(data)
    -- body
    -- printt("许愿袜",data)
    self.data = data
    local startTab = os.date("*t",data.actStartTime)
    local endTab = os.date("*t",data.actEndTime)
    local startTxt = startTab.month .. language.gonggong79 .. startTab.day .. language.gonggong80 .. string.format("%02d",startTab.hour) .. ":" .. string.format("%02d",startTab.min)
    local endTxt = endTab.month .. language.gonggong79 .. endTab.day .. language.gonggong80 .. string.format("%02d",endTab.hour) .. ":" .. string.format("%02d",endTab.min)
    self.timeTxt.text = startTxt .. "-" .. endTxt
    self.handInTxt.text = string.format(language.active37,data.commitNum)
    self.awardsConf = conf.ActivityConf:getChristmasGlobal("socks_commit_awards")
    self.listView.numItems = #self.awardsConf
    self.decTxt.text = language.active43
    --当前圣诞袜数量
    local socksMid = conf.ActivityConf:getChristmasGlobal("socks_mid")
    self.socksAmount = cache.PackCache:getPackDataById(socksMid).amount
    self.view:GetChild("n19").text = self.socksAmount

    self:setProgressBar()
    --上交按钮
    local giveOneBtn = self.view:GetChild("n21")
    giveOneBtn.data = 1
    giveOneBtn.onClick:Add(self.onClickGive,self)
    local giveTenBtn = self.view:GetChild("n22")
    giveTenBtn.data = 10
    giveTenBtn.onClick:Add(self.onClickGive,self)

    if self.socksAmount > 0 then
        giveOneBtn:GetChild("red").visible = true
        if self.socksAmount >= 10 then
            giveTenBtn:GetChild("red").visible = true
        else
            giveTenBtn:GetChild("red").visible = false
        end
    else
        giveOneBtn:GetChild("red").visible = false
        giveTenBtn:GetChild("red").visible = false
    end
end

--上交
function Active3015:onClickGive( context )
    local data = context.sender.data
    if self.socksAmount < data then
        GComAlter(language.active47)
        return
    end
    if data == 1 then
        proxy.ActivityProxy:sendMsg(1030163, {reqType=2,commitCount = 1})
    elseif data == 10 then
        proxy.ActivityProxy:sendMsg(1030163, {reqType=2,commitCount = 10})
    end
end

--领取奖励
function Active3015:onClickGet(context)
    local data = context.sender.data
    print("当前领取的",data)
    proxy.ActivityProxy:sendMsg(1030163, {reqType=3,cid = data})
end

return Active3015