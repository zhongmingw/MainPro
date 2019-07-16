
--神兵进阶..等等8个

local Active1001 = class("Active1001",import("game.base.Ref"))

function Active1001:ctor(param)
    self.view = param
    self:initView()
end

function Active1001:initView()
    -- body
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self) 
    --查询进阶排行
    local btnRank = self.view:GetChild("n7")
    self.btnTitle = btnRank:GetChild("title")
    btnRank.onClick:Add(self.onRank,self)
    --规则
    local btnGuize = self.view:GetChild("n8")
    btnGuize.onClick:Add(self.onGuize,self)
    --头名奖励
    self.rewardlist1 = self.view:GetChild("n18")
    self.rewardlist1.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.rewardlist1.numItems = 0
    --排名奖励
    self.rewardlistRank = self.view:GetChild("n30")
    self.rewardlistRank.itemRenderer = function(index,obj)
        self:cellRankdata(index, obj)
    end
    self.rewardlistRank.numItems = 0

    self:initDec()
    --self:addTimer(1,-1,handler(self,self.onTimer))
end

function Active1001:initDec()
    -- body
    self.btnTitle.text = language.kaifu01
    local dec = self.view:GetChild("n4")
    dec.text = language.kaifu03 
    local dec1 = self.view:GetChild("n19") 
    dec1.text = language.kaifu04
    local dec1 = self.view:GetChild("n20") 
    dec1.text = language.kaifu03
    --第一名的战斗了
    self.power = self.view:GetChild("n16")
    self.power.text = "0"

    self.icon = self.view:GetChild("n13") 

    self.name = self.view:GetChild("n21")
    self.name.text = language.kaifu13

    self.lanjie = self.view:GetChild("n22")
    self.lanjie.text = ""
    --倒计时
    self.hour = self.view:GetChild("n32")
    self.minute = self.view:GetChild("n33")
    self.second = self.view:GetChild("n34")
end

function Active1001:onTimer()
    -- body
    if not self.data then
        return
    end
    self.data.lastTime = self.data.lastTime - 1 
    if self.data.lastTime >= 0 then
        local temp = GGetTimeData(self.data.lastTime)
        self.hour.text = string.format("%02d",temp.hour)
        self.minute.text = string.format("%02d",temp.min)
        self.second.text = string.format("%02d",temp.sec)
    end
end

function Active1001:celldata(index,obj)
    -- body
    local data = self.confData[1].awards[index+1]
    local itemObj = obj:GetChild("n0")
    local t = {mid = data[1],amount=data[2],bind = data[3] }
    GSetItemData(itemObj,t,true)
    --动态居中
    self.width = obj.actualWidth + self.width
    if index + 1 == self.rewardlist1.numItems then
        self.rewardlist1.viewWidth = self.width
    else
        self.width = self.width + self.rewardlist1.columnGap
    end
end

function Active1001:cellRankdata( index,obj )
    -- body
    local data = self.confData[index+2]
    --奖励物品
    local width = 0
    local list = obj:GetChild("n2")
    
    list.itemRenderer = function(ide,cell)
        local param = data.awards[ide+1]
        local itemObj = cell:GetChild("n0")
        local t = {mid = param[1],amount=param[2],bind = param[3]  }
        GSetItemData(itemObj,t,true)
        --动态居中
        width = width + cell.actualWidth
        if ide + 1 == list.numItems then
            --plog("width",width,width)
            list.viewWidth = width
        else
            width = width + list.columnGap
        end
    end
    list.numItems = #data.awards
    --奖励排名
    local lab = obj:GetChild("n1")
    local str = language.kaifu02[self.c1.selectedIndex+1]
    if data.ranking[1]~=data.ranking[2] then
        str = string.format(str..language.kaifu11,data.ranking[1],data.ranking[2])
    else
        str = string.format(str..language.kaifu12,data.ranking[1])
    end
    if index == 0 then
        lab.text = mgr.TextMgr:getTextColorStr(str,15)
    elseif index == 1 then
        lab.text = mgr.TextMgr:getQualityStr1(str,3)
    else
        lab.text = mgr.TextMgr:getTextColorStr(str,7)
    end
end

function Active1001:onController1()
    -- body
end

--设置当前活动ID
function Active1001:setCurId(id)
    -- body 
    self.id = id 
    local t = {
        [1001]=2,
        [1002]=0,
        [1003]=3,
        [1004]=1,
        [1005]=6,
        [1006]=4,
        [1007]=7,
        [1008]=5,
        [1023]=8,
    }
    -- if self.c1.selectedIndex == t[id] then
    --     self:onController1()
    -- else
    --     self.c1.selectedIndex = t[id]
    -- end
    self.c1.selectedIndex = t[id]
    self.width = 0
    self.confData = clone(conf.ActivityConf:getRandrewardByid(id))

    local chenghao = nil 
    for k,v in pairs(self.confData[1].awards) do
        local itemdata = conf.ItemConf:getItem(v[1])
        if itemdata.auto_use_type == 9 then --这个是陈好
            chenghao = itemdata
            --table.remove(self.confData[1].awards,k)
            break
        end
    end
    if chenghao then
        local confdata = conf.RoleConf:getTitleData(chenghao.ext01)
        --printt(confdata)
        if not confdata then
            plog("@策划 ",chenghao.id,"称号配置里面没有",chenghao.ext01)
        else
            self.power.text = confdata.power or 0
            self.icon.url = UIPackage.GetItemURL("head" , tostring(confdata.scr))
        end
        
    else
        self.power.text = 0
        self.icon.url = nil 
    end

    self.rewardlist1.numItems = #self.confData[1].awards

    --不要最高阶的
    self.rewardlistRank.numItems = #self.confData - 1 
end
--

function Active1001:onRank()
    -- body
    mgr.ViewMgr:openView(ViewName.KaiFuRank,function(view)
        -- body
        --默认选中自己当前的ID
        view:setCurId(self.id)
        view:setData(self.data)--当前排行
    end)
end

function Active1001:onGuize()
    -- body
    GOpenRuleView(1028)
end

function Active1001:add5030109(data)
    -- body
    self.data = data

    if #data.rankInfos > 0 then
        self.name.text = data.rankInfos[1].roleName
        self.lanjie.text = string.format(language.kaifu061,data.rankInfos[1].power)
    else
        self.name.text = language.kaifu13
        self.lanjie.text = ""
    end

end

return Active1001