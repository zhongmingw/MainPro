--

local Active3001 = class("Active3001",import("game.base.Ref"))
local t = {
    [3001] = 2,
    [3002] = 0,
    [3003] = 3,
    [3004] = 1,
    [3005] = 6,
    [3006] = 4,
    [3007] = 7,
    [3008] = 5,
}

function Active3001:ctor(param)
    self.view = param
    self:initView()
end

function Active3001:initView()
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

function Active3001:onTimer()
    -- body
end

function Active3001:cellRankdata(index,obj)
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
            local t = {mid = data.awards[i][1],amount = data.awards[i][2], bind = data.awards[i][3]}
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

function Active3001:onget(context)
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

function Active3001:setCurId(id)
    -- body
    self.id = id 

    self.c1.selectedIndex = t[id]

    self.dec.text = language.kaifu10[t[id]+1]

    self.condata = conf.ActivityConf:getOpenJieAwardByid(self.id)
end


function Active3001:add5030110(data)
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
    -- print("奖励item数量",#self.condata)
    GOpenAlert3(data.items)
end

return Active3001