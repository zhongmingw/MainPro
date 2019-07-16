--

local Active1009 = class("Active1009",import("game.base.Ref"))
local t = {
    [1009] = 2,
    [1010] = 0,
    [1011] = 3,
    [1012] = 1,
    [1013] = 6,
    [1014] = 4,
    [1015] = 7,
    [1016] = 5,
    [1040] = 8,
}

function Active1009:ctor(param)
    self.view = param
    self:initView()
end

function Active1009:initView()
    -- body
    self.c1 = self.view:GetController("c1")

    self.dec = self.view:GetChild("n4")
    self.dec.text = ""

    --排名奖励
    self.rewardlistRank = self.view:GetChild("n18")
    self.rewardlistRank.itemRenderer = function(index,obj)
        self:cellRankdata(index, obj)
    end
    self.rewardlistRank.numItems = 0
end

function Active1009:onTimer()
    -- body
end

function Active1009:cellRankdata(index,obj)
    -- body
    local data = self.condata[index+1]
    --printt(data)
    local lab = obj:GetChild("n4")
    lab.text = string.format(language.kaifu08[self.c1.selectedIndex+1],data.step) 
    --奖励
    for i = 1 , 2 do
        local itemObj =  obj:GetChild("n"..i)
        if data.awards and data.awards[i] then
            itemObj.visible = true
            local t = {mid = data.awards[i][1],amount = data.awards[i][2],
            bind = data.awards[i][3] }
            GSetItemData(itemObj,t,true)
        else
            itemObj.visible = false
        end
    end

    local c1 = obj:GetController("c1")
    c1.selectedIndex = self.data.gotGiftStatusMap[data.id] 

    local btn = obj:GetChild("n3")
    btn.onClick:Add(self.onget,self)
    btn.data = data
end

function Active1009:onget(context)
    -- body
    local data = context.sender.data
    local var = self.data.gotGiftStatusMap[data.id]
    if  var == 0 then
        GComAlter(language.kaifu09)
        return
    elseif var == 2 then
        return
    end
    local param = {
        actId = self.id,
        reqType = 1,
        awardId = data.id,
    }
    proxy.ActivityProxy:sendMsg(1030110,param)
end

function Active1009:setCurId(id)
    -- body
    self.id = id 

    self.c1.selectedIndex = t[id]

    self.dec.text = language.kaifu10[t[id]+1]

    self.condata = conf.ActivityConf:getOpenJieAwardByid(self.id)
end


function Active1009:add5030110(data)
    -- body
    self.data = data
    --printt(data)

    table.sort(self.condata,function(a,b)
        -- body
        local astatue = data.gotGiftStatusMap[a.id] 
        local bstatue = data.gotGiftStatusMap[b.id] 

        if astatue == 1 then
            astatue = 0
        elseif astatue == 0 then
            astatue = 1
        end

        if bstatue == 1 then
            bstatue = 0
        elseif bstatue == 0 then
            bstatue = 1
        end

        if astatue ~= bstatue then
            return astatue < bstatue
        else
            return a.step < b.step
        end

    end)
    self.rewardlistRank.numItems = #self.condata
    print("奖励数量",#self.condata)
    
    GOpenAlert3(data.items)
end

return Active1009