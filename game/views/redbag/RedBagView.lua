--
-- Author:
-- Date: 2017-01-19 14:40:55
--
--红包界面
local RedBagView = class("RedBagView", base.BaseView)

local RedbagBymax = conf.SysConf:getValue("day_redbag_bymax")
local RedbagTqmax = conf.SysConf:getValue("day_redbag_tqmax")

function RedBagView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
end

function RedBagView:initData( ... )
    --每次进来 自己拥有红包数量红点清零
    cache.PlayerCache:setAttribute(10202,0)
    local mainView = mgr.ViewMgr:get(ViewName.MainView)
    if mainView then
        mainView:refreshRedBottom()
    end
    local basePanel = self.view:GetChild("n0")
    GSetMoneyPanel(basePanel,self:viewName())

    local closeBtn = basePanel:GetChild("btn_close")
    closeBtn.onClick:Add(self.onClickClose,self)

    self.mainPanel = self.view:GetChild("n7")

    local btn = self.mainPanel:GetChild("n4")
    btn.onClick:Add(self.onClickRuleBtn,self)

    self.rightPanel = self.view:GetChild("n8")

    local worldBtn = self.rightPanel:GetChild("n5")
    worldBtn.onClick:Add(self.onClickPage,self)
    self:initRedPoint(worldBtn,{10238})
    local memberBtn = self.rightPanel:GetChild("n6")
    memberBtn.onClick:Add(self.onClickPage,self)
    self:initRedPoint(memberBtn,{10239})

    self.isQuickGetAward=false

    local label = self.rightPanel:GetChild("n13")
    label.text = language.redbag01

    local awardBtn = self.rightPanel:GetChild("n18")
    awardBtn.onClick:Add(self.onClickQuickGetAward,self)

    self.mainlist = self.mainPanel:GetChild("n5")
    self.mainlist.itemRenderer = function(index,obj)
        self:cellItemData1(index, obj)
    end
    self.mainlist:SetVirtual()
    self.mainlist.numItems = 0

    self.worldlist = self.rightPanel:GetChild("n7")
    self.worldlist.itemRenderer = function(index,obj)
        self:cellItemData2(index, obj)
    end
    self.worldlist:SetVirtual()
    self.worldlist.numItems = 0

    self.memberlist = self.rightPanel:GetChild("n17")
    self.memberlist.itemRenderer = function(index,obj)
        self:cellItemData3(index, obj)
    end
    self.memberlist:SetVirtual()
    self.memberlist.numItems = 0

    self.rightImg = self.rightPanel:GetChild("n19")
    self.rightImg.visible=false

    self.selectController = self.rightPanel:GetController("c1")
    self.selectController.selectedIndex = 0
    self.singleSelect = self.rightPanel:GetChild("n14")
    self.singleSelect.onChanged:Add(self.onClickSingleBtn,self)
    if UPlayerPrefs.GetInt("RedBag") == 11 then
        self.singleSelect.selected = false
    else
        self.singleSelect.selected = true
    end

    local view=mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setRedBag(0)
    end
    
    self.tipImage=self.mainPanel:GetChild("n8")
    self.tipImage.visible=false
    
    self.myRedBag={}
    self.myTimes = 0 --我的领取次数
    self.worldRedBag={}
    self.worldRedBag.redBagInfos={}
    self.memberRedBag={}
    self.memberRedBag.redBagInfos={}
    self.redtab={}
    proxy.RedBagProxy:send_1250401()
    proxy.RedBagProxy:send_1250403({channelId=1,page=1})
    proxy.RedBagProxy:send_1250403({channelId=2,page=1})
end

--注册红点
function RedBagView:initRedPoint(btn,ids)
    -- body
    --注册红点
    local redImg = btn:GetChild("n5")
    local param = {panel = redImg,ids = ids}
    mgr.GuiMgr:registerRedPonintPanel(param,self:viewName())
end

function RedBagView:initView()
    
end

function RedBagView:setData(data)
    
end

--我的红包
function RedBagView:cellItemData1(index,cell)
    local data = self.myRedBag[index+1]
    local amount = data.num or 0
    local btn1 = cell:GetChild("n15")
    btn1.data=data
    btn1.onClick:Add(self.onClickItem,self)
    if amount > 0 then
        btn1.touchable = true
        btn1.grayed = false
    else
        btn1.touchable = false
        btn1.grayed = true
    end
    cell:GetChild("n9").text=language.redbag02
    local extType = conf.ItemConf:getRedBagType(data.id)
    local icon = cell:GetChild("n20")
    if extType == 1 then--世界红包
        icon.url = UIPackage.GetItemURL("redbag","hongbao_016")
    else--帮派红包
        icon.url = UIPackage.GetItemURL("redbag","hongbao_017")
    end
    local title = cell:GetChild("n8")
    -- local confname=conf.ItemConf:getItemCome(data.id)
    title.text=data.name

    local labelm = cell:GetChild("n10")
    labelm.text=data.redbag_args[1][3]

    local labeln = cell:GetChild("n11")
    labeln.text=data.come_id
    
    local labelname = cell:GetChild("n12")
    local textData = {
                    {text=language.redbag09,color = 7},
                    {text=amount,color = 6},
                }
    labelname.text = mgr.TextMgr:getTextByTable(textData)
end

function RedBagView:cellItemData2(index,cell)
    if index + 1 >= self.worldlist.numItems then
        
        local redbagNum = #self.worldRedBag.redBagInfos
        local currPage = self.worldRedBag.page
        -- print("红包数量，页数",redbagNum,currPage,self.worldRedBag.sumPage)
        if self.worldRedBag.sumPage == currPage then 
            --没有下一页了
            --return
        else
            -- print("请求下一页")
            proxy.RedBagProxy:send_1250403({channelId=1,page=currPage+1})
        end
    end

    local data = self.worldRedBag.redBagInfos[index + 1]
    if data then
        cell:GetChild("n8").text=language.redbag02
        local icon = cell:GetChild("n15")
        icon.url = UIPackage.GetItemURL("redbag","hongbao_016")
        data.redBagSource=0
        local title = cell:GetChild("n7")
        local confname=conf.ItemConf:getItemCome(data.redBagMid)
        title.text=confname

        local money = conf.ItemConf:getRedBagMoney(data.redBagMid)
        local num = cell:GetChild("n9")
        num.text=money

        local name = cell:GetChild("n10")
        name.text=data.name

        local btn = cell:GetChild("n11")
        if data.redBagStatus==1 then
            btn.title=language.redbag07
        else
            btn.title=language.redbag08
        end
        btn.data=data
        btn.data.idx=index
        btn.data.Type=1
        btn.onClick:Add(self.onGetAward,self)
    end
end

function RedBagView:cellItemData3(index,cell)
    if index + 1 >= self.memberlist.numItems then
        
        local redbagNum = #self.memberRedBag.redBagInfos
        local currPage = self.memberRedBag.page
        -- print("当前数量",redbagNum)
        if self.memberRedBag.sumPage == currPage then 
            --没有下一页了
            --return
        else
            proxy.RedBagProxy:send_1250403({channelId=2,page=currPage+1})
        end
    end

    local data = self.memberRedBag.redBagInfos[index + 1]
    if data then
        cell:GetChild("n8").text=language.redbag02
        local icon = cell:GetChild("n15")
        icon.url = UIPackage.GetItemURL("redbag","hongbao_017")
        local title = cell:GetChild("n7")
        local confname=conf.ItemConf:getItemCome(data.redBagMid)
        title.text=confname

        local money = conf.ItemConf:getRedBagMoney(data.redBagMid)
        local num = cell:GetChild("n9")
        num.text=money

        local name = cell:GetChild("n10")
        name.text=data.name

        local btn = cell:GetChild("n11")
        if data.redBagStatus==1 then
            btn.title=language.redbag07
        else
            btn.title=language.redbag08
        end
        btn.data=data
        btn.data.idx=index
        btn.data.Type=2
        btn.onClick:Add(self.onGetAward,self)
    end
end
--世界和仙盟按钮
function RedBagView:onClickPage(context)
    self.worldRedBag={}
    self.worldRedBag.redBagInfos={}
    self.memberRedBag={}
    self.memberRedBag.redBagInfos={}
    if self.selectController.selectedIndex==0 then
        proxy.RedBagProxy:send_1250403({channelId=1,page=1})
    else
        proxy.RedBagProxy:send_1250403({channelId=2,page=1})
    end
end
--发红包
function RedBagView:onClickItem(context)
    local btn=context.sender
    local data=btn.data
    if data.num > 0 then
        local extType = conf.ItemConf:getRedBagType(data.id)
        if extType == 1 then
            proxy.RedBagProxy:send_1250402({redBagMid=data.id})
        else
            if cache.PlayerCache:getGangId().."" ~= "0" then --判断是否加入仙盟
                proxy.RedBagProxy:send_1250402({redBagMid=data.id})
            else
                GComAlter(language.redbag12)
                -- mgr.ViewMgr:openView(ViewName.BangPaiFind,function(view)
                --     -- body
                --     local param = {}
                --     param.gangName = ""
                --     param.page = 1
                --     proxy.BangPaiProxy:sendMsg(1250102, param)
                -- end)
            end      
        end
    end
end

--领红包
function RedBagView:onGetAward(context)
    local btn=context.sender
    local data=btn.data
    local getTiems = conf.SysConf:getValue("day_redbag_robtimes")
    -- print("领取数量",getTiems)

    proxy.RedBagProxy:send_1250404({redBagId=data.redBagId,reqType=1,page = 1})--抢红包
    
    -- if self.myTimes < getTiems then
        -- local currPage=math.ceil((data.idx+1)/10)
        -- if data.Type==1 then
        --     self.worldRedBag.redBagInfos={}
        --     proxy.RedBagProxy:send_1250403({page=1,channelId=data.Type})--刷新世界红包
        -- else
        --     self.memberRedBag.redBagInfos={}
        --     proxy.RedBagProxy:send_1250403({page=1,channelId=data.Type})--刷新帮派红包
        -- end
    -- end
end

function RedBagView:onClickRuleBtn(context)
    GOpenRuleView(1019)
end

function RedBagView:onClickSingleBtn(context)
    -- print("self.singleSelect.selected",self.singleSelect.selected)
    if not self.singleSelect.selected then
        UPlayerPrefs.SetInt("RedBag", 11)
    else
        UPlayerPrefs.SetInt("RedBag", 0)
    end
end
--一键领取
function RedBagView:onClickQuickGetAward(context)
    self.isQuickGetAward=true
    -- print("一键领取")
    -- local worldhasGet = false --世界可领取红包
    -- local memberGet = false   --帮派可领取红包
    -- for k,v in pairs(self.worldRedBag.redBagInfos) do
    --     if v.redBagStatus == 1 then
    --         worldhasGet = true
    --     end
    -- end
    -- for k,v in pairs(self.memberRedBag.redBagInfos) do
    --     if v.redBagStatus == 1 then
    --         memberGet = true
    --     end
    -- end
    -- if not worldhasGet and not memberGet then
    --     GComAlter(language.redbag11)
    -- else
    if #self.worldRedBag.redBagInfos == 0 and #self.memberRedBag.redBagInfos == 0 then
        GComAlter(language.redbag11)
    else
        if self.redbagByb >= RedbagBymax and self.redbagTq >= RedbagTqmax then
            GComAlter(language.redbag10)
        else
            proxy.RedBagProxy:send_1250404({redBagId=0,reqType=2,page = 1})
        end
    end
    -- end
end

function RedBagView:onClickClose()
    local view=mgr.ViewMgr:get(ViewName.MainView)
    local tag = UPlayerPrefs.GetInt("RedBag")
        -- print("主界面",view,tag)
    if view then
        if tag > 0 then
            -- print("主界面111111",view,tag,cache.PlayerCache:getRedPointById(10238),cache.PlayerCache:getRedPointById(10239))
            if cache.PlayerCache:getRedPointById(10238) > 0 or cache.PlayerCache:getRedPointById(10239) > 0 then
                view:setRedBag(tag)
            else
                view:setRedBag(0)
            end
        else
            view:setRedBag(0)
        end
    end
    self:closeView()
end

--我的红包列表返回
function RedBagView:add5250401(data)
    self.myRedBag = conf.ItemConf:getRedBagData()
    for k,v in pairs (self.myRedBag) do
        self.myRedBag[k].num = data.regBagCountMap[v.id] or 0
    end
    table.sort(self.myRedBag,function(a,b)
        if a.num ~= b.num then
            return a.num > b.num
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.mainlist.numItems = #self.myRedBag
    --需从新刷新listview
    --并滑动到原来点
    self.myTimes = data.redBagCount --我的领取次数
    if self.mainlist.numItems>0 then
        self.tipImage.visible=false
    else
        self.tipImage.visible=true
    end
    self.redbagByb = data.redbagByb --已领取的绑定元宝数量
    self.redbagTq = data.redbagTq   --已领取的绑定铜钱数量
    if cache.PlayerCache:getRedPointById(attConst.A10238) > 0 or
        cache.PlayerCache:getRedPointById(attConst.A10239) > 0 then
        if self.redbagByb >= RedbagBymax and self.redbagTq >= RedbagTqmax then
            self.rightPanel:GetChild("n18"):GetChild("red").visible = true
        else
            self.rightPanel:GetChild("n18"):GetChild("red").visible = false
        end
    else
       self.rightPanel:GetChild("n18"):GetChild("red").visible = false
    end
end
--发红包返回
function RedBagView:add5250402(data)
    --printt(data)
    for k,v in pairs(self.myRedBag) do
        if v.id == data.redBagMid then
            v.num = data.amount
        end
    end
    table.sort(self.myRedBag,function(a,b)
        if a.num ~= b.num then
            return a.num > b.num
        elseif a.id ~= b.id then
            return a.id < b.id
        end
    end)
    self.mainlist.numItems = #self.myRedBag
    if self.selectController.selectedIndex==0 then
        proxy.RedBagProxy:send_1250403({channelId=1,page=1})
    else
        proxy.RedBagProxy:send_1250403({channelId=2,page=1})
    end
    -- print("红包发送成功！")
end
--在抢红包列表返回
function RedBagView:add5250403(data)
    -- printt(data)
    if data.channelId==1 then
        self.worldRedBag.page=data.page
        self.worldRedBag.sumPage=data.sumPage
        
        for i=1,#data.redBagInfos do
            local index=(data.page-1)*10+i
            self.worldRedBag.redBagInfos[index]=data.redBagInfos[i]
        end

        if #self.worldRedBag.redBagInfos>0 then
            self.rightImg.visible=false
        else
            self.rightImg.visible=true
        end
        self.worldlist.numItems = #self.worldRedBag.redBagInfos
        --需从新刷新listview
        --并滑动到原来点
    else
        self.memberRedBag.page=data.page
        self.memberRedBag.sumPage=data.sumPage


        for i=1,#data.redBagInfos do
            local index=(data.page-1)*10+i
            self.memberRedBag.redBagInfos[index]=data.redBagInfos[i]
        end

        if #self.memberRedBag.redBagInfos>0 then
            self.rightImg.visible=false
        else
            self.rightImg.visible=true
        end
        self.memberlist.numItems = #self.memberRedBag.redBagInfos
        --需从新刷新listview
        --并滑动到原来点
    end
    if cache.PlayerCache:getRedPointById(attConst.A10238) > 0 or
       cache.PlayerCache:getRedPointById(attConst.A10239) > 0 then
       self.rightPanel:GetChild("n18"):GetChild("red").visible = true
    else
       self.rightPanel:GetChild("n18"):GetChild("red").visible = false
    end
end
--抢红包返回
function RedBagView:add5250404(data)--抢到红包
    --printt(data)
    proxy.RedBagProxy:send_1250401()
    if self.selectController.selectedIndex==0 then
        self.worldRedBag.redBagInfos={}
        proxy.RedBagProxy:send_1250403({channelId=1,page=1})
    else
        self.memberRedBag.redBagInfos={}
        proxy.RedBagProxy:send_1250403({channelId=2,page=1})
    end
    if self.isQuickGetAward then
        if data.moneyYb == 0 and data.copper == 0 then
            if self.redbagByb >= RedbagBymax and self.redbagTq >= RedbagTqmax then--两种全领满
                GComAlter(language.redbag10)
            -- elseif self.redbagByb >= RedbagBymax or self.redbagTq >= RedbagTqmax then--其中一种领满
            --     GComAlter(language.redbag11)
            else
                if self.redbagByb < RedbagBymax or self.redbagTq < RedbagTqmax then
                    GComAlter(language.redbag11)
                elseif self.redbagByb >= RedbagBymax then
                    GComAlter(language.redbag13)
                elseif self.redbagTq >= RedbagTqmax then
                    GComAlter(language.redbag14)
                else
                    GComAlter(language.redbag11)
                end
            end
        else
            local items = {}
            if data.moneyYb > 0 then
                local item = { mid = 221051002 , amount = data.moneyYb}
                table.insert(items,item) 
            end
            if data.copper > 0 then
                local item = { mid = 221051004 , amount = data.copper}
                table.insert(items,item)
            end
            if #items > 0 then
                GOpenAlert3(items)
            end
        end
        self.isQuickGetAward=false
    else
        if data.redBagInfo then
            mgr.ViewMgr:openView(ViewName.ReceiveAwardView,function(view)
                view:setData(data)
            end)
        end
    end
end

return RedBagView