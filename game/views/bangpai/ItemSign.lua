--
-- Author: 
-- Date: 2017-03-07 11:52:07
--

local ItemSign = class("ItemSign",import("game.base.Ref"))

function ItemSign:ctor(param)
    self.view = param
    self:initView()
end

function ItemSign:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onbtnController1,self)
    self.c2 = self.view:GetController("c2")
    self.c2.onChanged:Add(self.onbtnController2,self)

    --签到人数
    self.labCur = self.view:GetChild("n12")
    self.labMax = self.view:GetChild("n14")
    --签到奖励
    -- self.rewardlist = {}
    -- local btn1 = self.view:GetChild("n3")
    -- self.x1 = btn1.x 
    -- local btn2 = self.view:GetChild("n4")
    -- self.x2 = btn2.x 
    -- local btn3 = self.view:GetChild("n65")
    -- self.x3 = btn3.x 
    -- table.insert(self.rewardlist,btn1)
    -- table.insert(self.rewardlist,btn2)
    -- table.insert(self.rewardlist,btn3)
    self.listView = self.view:GetChild("n66")
    self.listView.itemRenderer = function(index, obj)
        self:cellData(index, obj)
    end
    self.listView.numItems = 0
    --
    local btnGet = self.view:GetChild("n5")
    btnGet.onClick:Add(self.onGetReward,self)
    self.btnGet = btnGet
    --4个箱子
    self.rewardBox = {}
    for i = 7 , 10 do
        local btn = self.view:GetChild("n"..i)
        btn.data = i - 6
        btn.onClick:Add(self.onBoxCall,self)
        table.insert(self.rewardBox,btn)
    end 
    --4每个箱子对应的奖励
    self.rewardBoxlist = {}
    for i = 53 , 60 do 
        local itemObj = self.view:GetChild("n"..i)
        itemObj.data = itemObj.y
        table.insert(self.rewardBoxlist,itemObj)
    end
    --4进度位置
    self.barYuan = {}
    for i =  47,50 do
        table.insert(self.barYuan,self.view:GetChild("n"..i))
    end
    --4个是否领取标记
    self.isgetflag = {}
    for i = 61 , 64 do 
        table.insert(self.isgetflag,self.view:GetChild("n"..i))
    end

    self.bar = self.view:GetChild("n22")
     
    local btnSign = self.view:GetChild("n6")
    btnSign.onClick:Add(self.onSign,self)

    self:initDec()
end

function ItemSign:initDec()
    -- body
    self.labCur.text = 0
    self.labMax.text = 0
    


    self.confData = conf.BangPaiConf:getSign()
    for i = 1 , 4 do
        self.barYuan[i]:GetChild("n5").text = self.confData[i].sign_count
        self.barYuan[i].x = self.bar.width/self.confData[4].sign_count*self.confData[i].sign_count
    end
    self.bar.value = 0
    self.bar.max = self.confData[4].sign_count

    local pairs = pairs
    for k ,v in pairs(self.confData) do
        for i = 1 , 2 do
            local index = (2*k)-1 + (i-1)
            self.rewardBoxlist[index].visible = false
        end

        for i, j in pairs(v.items) do
            local t = {mid = j[1],amount = j[2],bind = j[3]}
            local index = (2*k)-1 + (i-1)
            self.rewardBoxlist[index].visible = true
            if #v.items == 1 then
                self.rewardBoxlist[index].y = (self.rewardBoxlist[index].data
                +self.rewardBoxlist[index+1].data)/2
            else
                self.rewardBoxlist[index].y = self.rewardBoxlist[index].data
            end
            GSetItemData(self.rewardBoxlist[index],t,true)
        end



    end
end

function ItemSign:setData(data)
    -- body
    self.data = data
    self.labCur.text = data.signedCount
    self.labMax.text = cache.BangPaiCache:getmemberNum()

    self.bar.value = data.signedCount
    if tonumber(data.signFlag) == 1 then
        self.c2.selectedIndex = 0
    else
        self.c2.selectedIndex = 1
    end
    self:initBar()
    --self:initReward()

    self.reward = {}
    local confdata = conf.BangPaiConf:getValue("sign_item")
    for k ,v in pairs(confdata) do
        table.insert(self.reward,{mid = v[1],amount = v[2],bind = v[3]})
    end
    table.insert(self.reward,{mid = PackMid.bangpaiexp,amount =conf.BangPaiConf:getValue("sign_gang_exp"),bind = 0})
    table.insert(self.reward,{mid = PackMid.bangpaigx,amount = conf.BangPaiConf:getValue("sign_bg"),bind = 0})
    self.listView.numItems = #self.reward

end

function ItemSign:initBar()
    -- body
    self.index = nil 
    --self.btnGet.touchable = false
    for i = 1 , 4 do
        local isget = string.sub(self.data.awardFlag,i,i)
        local c1 = self.barYuan[i]:GetController("c1")
        --plog("i",i,isget)
        if isget and tonumber(isget) == 1 then --已领取
            self.isgetflag[i].visible = true
            c1.selectedIndex = 1
        else
            self.isgetflag[i].visible = false
            if tonumber(self.labCur.text) < self.confData[i].sign_count then --未达到
                c1.selectedIndex = 2
            else
                if not self.index then
                    self.index = i
                end
                c1.selectedIndex = 0
            end
        end
    end

    if self.index then
        --self.btnGet.touchable = true
        self.c1.selectedIndex = 0
    else
        self.c1.selectedIndex = 2
    end


end

function ItemSign:cellData(index,obj)
    -- body
    local data = self.reward[index+1]
    GSetItemData(obj,data,true)

    -- local t = {mid = PackMid.bangpaiexp,amount = conf.BangPaiConf:getValue("sign_gang_exp"),bind=1}
    -- GSetItemData(self.rewardlist[1],t,true)

    -- local t = {mid = PackMid.bangpaigx,amount = conf.BangPaiConf:getValue("sign_bg"),bind=1}
    -- GSetItemData(self.rewardlist[2],t,true)

    -- local t = {mid = PackMid.bangpaigx,amount = conf.BangPaiConf:getValue("sign_bg"),bind=1}
    -- GSetItemData(self.rewardlist[2],t,true)



    --local condata = --self.confData[self.index]

    -- for k ,v in pairs(self.rewardlist) do
    --     v.visible = false
    -- end

    -- if #condata.items == 1 then
    --     self.rewardlist[1].x = (self.x2+self.x1)/2
    -- else
    --     self.rewardlist[1].x = self.x1
    --     self.rewardlist[2].x = self.x2
    -- end

    -- for k ,v in pairs(condata.items) do
    --     if k > 2 then
    --         break
    --     end
    --     local t = {mid = v[1],amount = v[2]}
    --     GSetItemData(self.rewardlist[k],t,true)
    -- end
    -- local isget =tonumber(string.sub(self.data.awardFlag,self.index,self.index)) --领取
    -- if isget and isget == 1 then
    --     self.c1.selectedIndex = 1
    -- else
    --     if tonumber(self.labCur.text) < self.confData[self.index].sign_count then --未达到
    --         self.c1.selectedIndex = 2
    --     else
    --         self.c1.selectedIndex = 0
    --     end
    -- end
end

function ItemSign:onBoxCall(context)
    -- body
    self.index = context.sender.data
    --self:initReward()
end

function ItemSign:onbtnController2()
    -- body
end

function ItemSign:onbtnController1()
    -- body
end


function ItemSign:onGetReward()
    -- body
    if self.c1.selectedIndex == 1 then
        GComAlter(language.bangpai43)
    elseif self.c1.selectedIndex == 2 then
        GComAlter(language.bangpai42)
    else
        plog(self.index,"self.index")
        if self.index then
            local param = {}
            param.reqType = 3
            param.cfgId = self.confData[self.index].id
            proxy.BangPaiProxy:sendMsg(1250301, param)
        end
    end
end

function ItemSign:onSign()
    -- body
    if self.c2.selectedIndex == 0 then
        GComAlter(language.bangpai41)
        return
    end
    local param = {}
    param.reqType =2
    param.cfgId = 0
    proxy.BangPaiProxy:sendMsg(1250301, param)
end

return ItemSign