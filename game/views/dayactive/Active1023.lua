--
-- Author: 
-- Date: 2017-08-24 16:05:06
--

local Active1023 = class("Active1023",import("game.base.Ref"))

function Active1023:ctor(param)
    self.view = param
    -- self.confData = clone(conf.ActivityConf:getRandrewardByid(1023))
    self:initView()
end

function Active1023:initView()
    self.c1 = self.view:GetController("c1")
    self.titleIcon = self.view:GetChild("n6")--第一名称号

    self.name = self.view:GetChild("n13")--第一名名字
    self.name.text = language.kaifu13

    self.lanjie = self.view:GetChild("n14")--第一名坐骑阶
    self.lanjie.text = ""

    self.powerText = self.view:GetChild("n10")--第一名战斗力
    self.powerText.text = ""

    self.awardsList = self.view:GetChild("n8")
    self.awardsList.itemRenderer = function(index,obj)--第一名奖励
        self:cellAwardData(index, obj)
    end
    self.awardsList.numItems = 0

    self.rankListView = self.view:GetChild("n9")--排行信息
    self.rankListView.itemRenderer = function(index,obj)
        self:cellRankData(index, obj)
    end
    self.rankListView.numItems = 0
    --倒计时
    self.view:GetChild("n20").text = language.kaifu55
    self.timeText = self.view:GetChild("n21")
    local rankBtn = self.view:GetChild("n23")
    rankBtn.onClick:Add(self.onRank,self)
    --规则
    local btnGuize = self.view:GetChild("n24")
    btnGuize.onClick:Add(self.onGuize,self)
end
function Active1023:onGuize()
    GOpenRuleView(1028)
end

--快速升级途径
function Active1023:initUpListView()
    local confData = conf.ActivityConf:getUpChannel(self.curId)
    local upListView = self.view:GetChild("n22")
    upListView.itemRenderer = function(index,obj)
        obj.data = confData.formViews[index + 1]
        obj.icon = UIPackage.GetItemURL("_icons2" , tostring(confData.icons[index + 1]))
        if not obj.icon then
            obj.icon = UIPackage.GetItemURL("_icons" , tostring(confData.icons[index + 1]))
        end
    end
    upListView.numItems = #confData.icons
    upListView.onClickItem:Add(self.onCallGoto,self)
end
--缓存当前活动id
function Active1023:setCurId(id)
    self.curId = id
    self.confData = clone(conf.ActivityConf:getRandrewardByid(id))
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
    self:initUpListView()
    -- if self.c1.selectedIndex == t[id] then
    --     self:onController1()
    -- else
    --     self.c1.selectedIndex = t[id]
    -- end
    self.c1.selectedIndex = t[id]
    local chenghao = nil 
    for k,v in pairs(self.confData[1].awards) do
        local itemdata = conf.ItemConf:getItem(v[1])
        if itemdata.auto_use_type == 9 then --这个是陈好
            chenghao = itemdata
            break
        end
    end
    if chenghao then
        local confData = conf.RoleConf:getTitleData(chenghao.ext01)
        --printt(confdata)
        if not confData then
            plog("@策划 ",chenghao.id,"称号配置里面没有",chenghao.ext01)
        else
            self.powerText.text = confData.power or 0
            self.titleIcon.url = UIPackage.GetItemURL("head" , tostring(confData.scr))
        end
        
    else
        self.powerText.text = 0
        -- self.icon.url = "" 
    end

    self.awardsList.numItems = #self.confData[1].awards

    --不要最高阶的
    self.rankListView.numItems = #self.confData - 1 
end
--服务器返回
function Active1023:add5030109(data)
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
--倒计时
function Active1023:onTimer()
    -- body
    if not self.data then
        return
    end
    self.data.lastTime = self.data.lastTime - 1 
    if self.data.lastTime >= 0 then
        if self.data.lastTime > 86400 then  --EVE 时间显示方式更改
            self.timeText.text = GTotimeString7(self.data.lastTime)
        else
            self.timeText.text = GTotimeString2(self.data.lastTime)
        end
    end
end
--第一名奖励
function Active1023:cellAwardData(index,obj)
    local data = self.confData[1].awards[index+1]
    local itemObj = obj:GetChild("n0")
    local t = {mid = data[1],amount=data[2],bind = data[3] }
    GSetItemData(itemObj,t,true)
end
--坐骑大比拼排行
function Active1023:cellRankData(index,obj)
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
        -- width = width + cell.actualWidth
        -- if ide + 1 == list.numItems then
        --     -- plog("width",width,width)
        --     list.viewWidth = width
        -- else
        --     width = width + list.columnGap
        -- end
    end
    list.numItems = #data.awards
    --奖励排名
    local lab = obj:GetChild("n1")
    local str = language.kaifu54[self.curId]
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
--排行榜
function Active1023:onRank()
    -- body
    mgr.ViewMgr:openView(ViewName.KaiFuRank,function(view)
        -- body
        --默认选中自己当前的ID
        view:setCurId(self.curId)
        view:setData(self.data)--当前排行
    end)
end
--跳转到对应系统
function Active1023:onCallGoto(context)
    local formView = context.data.data
    GOpenView({id = formView[1], childIndex = formView[2]})
end

return Active1023