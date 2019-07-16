--
-- Author: 
-- Date: 2017-03-11 14:38:36
--

local PanelFuben = class("PanelFuben",import("game.base.Ref"))
local number 
function PanelFuben:ctor(param)
    self.view = param
    self:initView()
end

function PanelFuben:initView()
    -- body
    self.c1 = self.view:GetController("c1")

    local item = self.view:GetChild("n21")
    item.onTouchBegin:Add(self.onTouchBegin,self)
    item.onTouchEnd:Add(self.onTouchEnd,self)
    self.item = item

    self.list = {}
    self.position = {}
    self.y = 0
    for i = 1 , 5 do
        local btn = item:GetChild("n"..i)
        self.position[i] = btn.x
        self.y =  btn.y
        btn.data = {index = i,pos = i}
        btn.onClick:Add(self.onItemCall,self)
        if i == 1 then
            self.position[0] = self.position[1] -  btn.actualWidth
        elseif i == 5 then
            self.position[6] = self.position[5] +  btn.actualWidth
        end
        table.insert(self.list,btn)
    end

    local btnget = self.view:GetChild("n6") 
    btnget:GetChild("title").text = language.bangpai125
    btnget.onClick:Add(self.onGetOneKey,self)

   
    local btnfightall = self.view:GetChild("n7") 
    btnfightall:GetChild("title").text = language.bangpai126
    btnfightall.onClick:Add(self.onFightOneKey,self)

    -- local btnStart = self.view:GetChild("n8")
    -- btnStart.onClick:Add(self.onGoon,self)

    --EVE 继续波次按钮优化 （优化对象：n8、n10、n11、n22）
    self.btnStart = self.view:GetChild("n8")
    self.btnStart.onClick:Add(self.onGoon,self)

    self.labCur = self.view:GetChild("n14")
    self.labCur.text = string.format(language.bangpai127,1)

    -- self.labCurbtn = self.view:GetChild("n11")
    -- self.labCurbtn.text = 1

    local btnGuize = self.view:GetChild("n9")
    btnGuize.onClick:Add(self.onGuize,self)

    self.listView = self.view:GetChild("n3")
    self.listView:SetVirtual()
    self.listView.itemRenderer = function(index,obj)
        self:celldata(index, obj)
    end
    self.listView.numItems = 0

    self:initDec()

    --EVE 仙盟秘境增加声望显示和声望商店入口
    self.prestigeValue = self.view:GetChild("n32")
    self.prestigeValue.text = "" 
    local prestigeShop = self.view:GetChild("n29")
    prestigeShop.onClick:Add(self.onPrestigeShop,self)
    self:initData()
end

function PanelFuben:initData()
    -- body
    self.prestigeValue.text = cache.PlayerCache:getTypeMoney(MoneyType.sw)
end

function PanelFuben:onPrestigeShop(  )
    -- body 声望商店跳转
    GOpenView({id = 1119})
end

function PanelFuben:initDec()
    -- body
    self.view:GetChild("n12").text = language.bangpai123
    self.view:GetChild("n13").text = language.bangpai124
    self.view:GetChild("n15").text = mgr.TextMgr:getTextByTable(language.bangpai128)

end

function PanelFuben:onTouchBegin(context)
    -- body
    self.bx = context.data.x
end

function PanelFuben:onTouchEnd(context)
    -- body
    if not self.bx then
        return
    end

    self.ex = context.data.x
    local dist = self.ex - self.bx
    if math.abs(dist) > 40 then
        if dist < 0 then --左动作
            self:move(-1)
        else --右动作
            self:move(1)
        end
    end
end

function PanelFuben:move(dist)
    -- body
    if self.action and table.nums(self.action)>0 then
        --plog("前面的动作还未结束")
        return
    end

    local min
    local max 
    for k ,v in pairs(self.list) do
        if v.data.pos == 1 then
            min = v.data.index
        elseif v.data.pos == 5 then
            max = v.data.index
        elseif v.data.pos == 3 then
            middle = v.data.index
        end
        v.x = self.position[v.data.pos]
    end

    if middle == 3 and dist == 1 then
        return
    elseif middle == number - 2 and dist == -1 then
        return
    end

    local speed = 0.4
    self.action = {}
    for k ,v in pairs(self.list) do
        --移动动作
        local pos = v.data.pos 
        if pos == 2 or pos == 4 then
            v.sortingOrder = 100
        end

        local topos = Vector2.New(self.position[pos+dist],self.y)
        self.action[k] = UTransition.TweenMove2(v,topos,speed, false, function(v)
            self.action[k] = nil 
            v.data.pos = pos + dist
            if v.data.pos > 5 then
                v.data.pos = 1
                v.data.index = min - 1 < 1 and number or min - 1
            elseif v.data.pos < 1 then
                v.data.pos = 5
                v.data.index = max + 1 > number and 1 or max + 1
            end
            self:initItem(v)
        end)
        --放大动作 缩小动作
        if pos == 3 then --缩小动作
            v:TweenScale( Vector2.New(1.0,1.0),speed)
        else
            if pos+dist == 3 then
                v:TweenScale( Vector2.New(1.2,1.2),speed)
            end
        end
        --渐变动作
        local fadeImage = v:GetChild("n2")
        if pos == 3 then 
            fadeImage:TweenFade( 0.8,speed)
        else
            if pos+dist == 3 then
                fadeImage:TweenFade( 0,speed)
            end
        end
    end
end

function PanelFuben:getInfoById(id)
    -- body
    for k ,v in pairs(self.data.passInfos) do
        if v.passId == tonumber(id) then
            return v 
        end
    end
    --避免错误
    local param = {
        passId = id,
        passMemNum = 0,
        tarAwardSign = 0,
        attrPercent = 0,
        firstAwardSign = 0,
    }
    return param
end

function PanelFuben:initReward(v,reward)
    -- body
    local frame1 = v:GetChild("n8")
    local frame2 = v:GetChild("n9")

    local c2 = v:GetController("c2")
    if not reward then
        c2.selectedIndex = 2
        return
    end

    if #reward == 1 then
        c2.selectedIndex = 0
    else
        c2.selectedIndex = 1
    end

    for i , j in pairs(reward) do
        if i > 2 then
            break
        end
        local t = {mid = j[1],amount = j[2],bind = j[3]}
        if i == 1 then
            GSetItemData(frame1,t,true)
        else
            GSetItemData(frame2,t,true)
        end
    end
end

function PanelFuben:initItem(v,flag)
    -- body
    local c1 = v:GetController("c1")
    local index = v.data.index --当前关卡
    if flag then
        local currid = self.data.currId
        if  currid == 0 then
            currid = tonumber(Fuben.gang.."001")
        else
            currid = currid + 1 
        end
        local data = self:getInfoById(currid)
        --当前第几张
        local dec1 = v:GetChild("n13")
        dec1.text = string.format(language.bangpai129,tonumber(self.btnStart.title))  --EVE 参数替换。原参数： self.labCurbtn.text
        --本波今日通过
        local dec2 = v:GetChild("n14")
        local t = clone(language.bangpai130)
        t[2].text = string.format(t[2].text,data.passMemNum)
        dec2.text = mgr.TextMgr:getTextByTable(t)
        --本波属性加成
        local dec3 = v:GetChild("n15")
        local t = clone(language.bangpai131)
        t[2].text = string.format(t[2].text,data.attrPercent)
        dec3.text = mgr.TextMgr:getTextByTable(t)
        --奖励信息
        local falg = false
        if self.data.saodangMaxId == 0 then --没有打过
            falg = true 
        elseif self.data.saodangMaxId%1000 < tonumber(self.btnStart.title) then --小于当前  --EVE 参数替换。原参数： self.labCurbtn.text
            falg = true
        end
		
		--plog(self.data.saodangMaxId,self.labCurbtn.text,falg)

        -- if falg then
        --     --首次奖励
        --     c1.selectedIndex = 0
        --     self:initReward(v,self.confData.first_pass_award)
        -- else
        --     --通关奖励
        --      c1.selectedIndex = 1
        --     self:initReward(v,self.confData.normal_drop)
        -- end
        c1.selectedIndex = 1
        self:initReward(v,self.confData.normal_drop)
    end

    local _num1 = v:GetChild("n17")
    local _num2 = v:GetChild("n18")
    local vv = (index-2)*conf.FubenConf:getValue("gang_fb_distance") - conf.FubenConf:getValue("gang_fb_distance") + 1
    _num1.text = vv
    _num2.text = (index-2)*conf.FubenConf:getValue("gang_fb_distance")
    --关卡分图片
    local condata = conf.FubenConf:getPassData(Fuben.gang,vv)
    local icon = v:GetChild("n0")
    if condata then
        icon.url = UIPackage.GetItemURL("bangpai" , condata.view_icon) 
    end

    local fadeImage = v:GetChild("n2")
    local chooseImage = v:GetChild("n1")

    if index < 3 then
        v.visible = false
    elseif index > number - 2 then
        v.visible = false
    else
        v.visible = true
    end

    if v.data.pos == 3 then
        v.scale = Vector2.New(1.2,1.2)
        v.sortingOrder = 100
        fadeImage.alpha = 0
        chooseImage.visible = true
    else
        v.sortingOrder = 90
        fadeImage.alpha = 0.8
        chooseImage.visible = false
    end 
end

function PanelFuben:onItemCall(context)
    -- body
    local data = context.sender.data 
    if data.pos <  3 then
        self:move(1)
    elseif data.pos > 3 then
        self:move(-1)
    end
end

function PanelFuben:celldata(index,obj)
    -- body
    local data = self.confMubiao[index+1]

    if index>0 then
        obj.width = 175
    else
        obj.width = 228
    end

    local cachedata = self:getInfoById(data.id)

    local dec1 = obj:GetChild("n5")
    dec1.text = string.format(language.bangpai127,data.id%1000)
    local flag
    if tonumber(cachedata.tarAwardSign) == 0 then
        flag = false
    else
        flag = true
    end

    local t = {grayed = flag,isGet = flag, mid = data.target_pass_award[1][1],amount= data.target_pass_award[1][2],bind=data.target_pass_award[1][3]
    ,func = function()
            -- body
            if not flag then --单个领取
                if data.target_pass_num <= cachedata.passMemNum then
                    local pp = {}
                    pp.passId = data.id
                    pp.reqType = 1
                    proxy.FubenProxy:send(1024502,pp)
                else
                    GComAlter(language.bangpai137)
                end
            end
    end}
    local itemObj = obj:GetChild("n0")
    GSetItemData(itemObj,t,true)
    local param = clone(language.bangpai133)
    param[1].text = string.format(param[1].text,data.target_pass_num)
    param[3].text = string.format(param[3].text,data.target_pass_num)
    --param[2].text = string.format(param[2].text,cachedata.passMemNum)

    if cachedata.passMemNum >= data.target_pass_num then
        param[2].color = 7
        param[2].text = string.format(param[2].text,data.target_pass_num)
    else
        param[2].text = string.format(param[2].text,cachedata.passMemNum)
    end

    local dec2 = obj:GetChild("n1")
    dec2.text = mgr.TextMgr:getTextByTable(param)

    
    local bar = obj:GetChild("n3")
    bar.value = cachedata.passMemNum
    bar.max = data.target_pass_num
end

function PanelFuben:setData(data)
    -- body
    self.data = data
    local _value = conf.FubenConf:getValue("gang_fb_distance")
    local condata =  conf.SceneConf:getSceneById(Fuben.gang)
    number = math.ceil(condata.max_pass/_value) +4
    self.max_pass = condata.max_pass --最大关卡数
    --初始化章节数据
    --print("data.currId",data.currId)
    local var = data.currId > 0 and data.currId%1000 or 1 --当前关卡
    self.var = var
    if data.currId%1000 == 0 or var == condata.max_pass  then
        -- self.labCurbtn.text = var  --EVE 
        self.btnStart.title = var

    else
        -- self.labCurbtn.text = var + 1  --EVE
        self.btnStart.title = var + 1
    end
    self.labCur.text = string.format(language.bangpai127,data.saodangMaxId%1000)
    --副本信息
    --print("var",var)
    self.confData = conf.FubenConf:getPassData(Fuben.gang,self.btnStart.title)
    for k , v in pairs(self.list) do
        v.data.index = math.ceil(var/_value)  + v.data.pos - 1
        self:initItem(v, true)
    end
    --初始化目标奖励  
    self.confMubiao = conf.FubenConf:getMubiaoData(Fuben.gang,condata.max_pass)
    self.listView.numItems = #self.confMubiao  

    if self.data.currId%1000 == self.max_pass then
        self.c1.selectedIndex = 1

        --EVE 添加控制器变化时候，按钮的title和icon改变
        self.btnStart.title = nil
        self.btnStart.icon = UIPackage.GetItemURL("bangpai" , "bangpai_109")
        --EVE END
    else
        self.c1.selectedIndex = 0

         --EVE 添加控制器变化时候，按钮的title和icon改变
        self.btnStart.icon = UIPackage.GetItemURL("bangpai" , "bangpai_073")
        --EVE END
    end
    
    ---注册红点信息
   
    local param = {}
    param.panel = self.view:GetChild("n23")
    param.ids = {50110}
    --plog("领取红点50110",cache.PlayerCache:getRedPointById(50110) )
    mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.1") 
    -- --扫荡红点
    local param = {}
    param.panel = self.view:GetChild("n24")
    param.ids = {50108}
    --plog("扫荡红点50108",cache.PlayerCache:getRedPointById(50108) )
    mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.1") 

    --EVE 战力达到要求，可挑战红点
    local redNum = cache.PlayerCache:getRedPointById(50112) or 0
    -- print("红点",redNum,self.confMubiao[1].power)
    if redNum > 0 then
        self.btnStart:GetChild("red").visible = true
    else
        self.btnStart:GetChild("red").visible = false
    end
end

function PanelFuben:onGetOneKey()
    -- body
    --plog("一键领取")
    if not self.data then
        return
    end

    local flag = false
    for k ,v in pairs(self.data.passInfos) do
        if v.tarAwardSign == 0 then
            local confData = conf.FubenConf:getPassDatabyId(v.passId) 
            if v.passMemNum >= confData.target_pass_num then
                flag = true
                break
            end
        end 
    end

    if not flag then
        GComAlter(language.bangpai132)
        return
    end

    local param = {}
    param.passId = 0
    param.reqType = 2
    proxy.FubenProxy:send(1024502,param)
end
--一件扫荡
function PanelFuben:onFightOneKey()
    -- body
    --plog(...)
    if self.data.saodangMaxId%1000 <= 0 then --压根没打过
        GComAlter(language.bangpai134)
        return
    elseif self.data.currId >= self.data.saodangMaxId then
        GComAlter(language.bangpai135)
        return
    end

    proxy.FubenProxy:send(1024503)
end
--继续挑战
function PanelFuben:onGoon()
    -- body
    --print(self.data.currId,self.max_pass)
    if self.data.currId%1000 == self.max_pass then
        GComAlter(language.bangpai136)
        return
    end

    mgr.FubenMgr:gotoFubenWar(Fuben.gang)
end
--看跪着
function PanelFuben:onGuize()
    -- body
    GOpenRuleView(1027)
end

--领取返回
function PanelFuben:add5024502(data)
    -- body
    if data.reqType == 2 then
        for k ,v in pairs(self.data.passInfos) do
            if v.tarAwardSign == 0 then
                local confData = conf.FubenConf:getPassDatabyId(v.passId) 
                if v.passMemNum >= confData.target_pass_num then
                    self.data.passInfos[k].tarAwardSign = 1
                end
            end 
           
        end
    else
        for k ,v in pairs(self.data.passInfos) do 
            if v.passId == data.passId then
                self.data.passInfos[k].tarAwardSign = data.tarAwardSign
                break
            end
        end
    end
    self.listView:RefreshVirtualList()
end

return PanelFuben