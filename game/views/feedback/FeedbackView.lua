--
-- Author: EVE 
-- Date: 2017-05-24 14:34:13
--

local FeedbackView = class("FeedbackView", base.BaseView)

function FeedbackView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.uiClear = UICacheType.cacheTime
end 

function FeedbackView:initData()
    self.inputTitle.text = ""
    self.inputContent.text = ""
    self.isStar = 0
    self.btnStar01.selected = false
    self.btnStar02.selected = false
    self.btnStar03.selected = false
    self.btnStar04.selected = false
    self.btnStar05.selected = false
    local vipExp = cache.PlayerCache:getVipExp()
    local vipNeedExp = conf.SysConf:getValue("vip_exp_limit")
    if vipExp >= vipNeedExp then
        self.view:GetChild("n48").visible = true
        self.view:GetChild("n55").visible = true
    else
        self.view:GetChild("n48").visible = false
        self.view:GetChild("n55").visible = false
    end
end

function FeedbackView:initView()
    --关闭窗口逻辑
    local bgView = self.view:GetChild("n2")
    local BtnClose = bgView:GetChild("n5")
    BtnClose.onClick:Add(self.onClickClose,self)
    --标题文本
    self.inputTitle = self.view:GetChild("n31")   --inputTxt
    --内容文本
    self.inputContent = self.view:GetChild("n32")
    self.inputContent.onChanged:Add(self.onChangeInput,self)
    --满意度评星
    self.btnStar01 = self.view:GetChild("n35")
    self.btnStar02 = self.view:GetChild("n36")
    self.btnStar03 = self.view:GetChild("n37")
    self.btnStar04 = self.view:GetChild("n38")
    self.btnStar05 = self.view:GetChild("n39")
    local data = {status = 1} --第一颗
    self.btnStar01.data = data
    self.btnStar01.onClick:Add(self.onClickStarsEvent,self)
    local data = {status = 2} --第二颗
    self.btnStar02.data = data
    self.btnStar02.onClick:Add(self.onClickStarsEvent,self)
    local data = {status = 3} --第三颗
    self.btnStar03.data = data
    self.btnStar03.onClick:Add(self.onClickStarsEvent,self)
    local data = {status = 4} --第四颗
    self.btnStar04.data = data
    self.btnStar04.onClick:Add(self.onClickStarsEvent,self)
    local data = {status = 5} --第五颗
    self.btnStar05.data = data
    self.btnStar05.onClick:Add(self.onClickStarsEvent,self)
    --提交按钮
    local btnSubmit = self.view:GetChild("n9")
    btnSubmit.onClick:Add(self.onClickSubmit,self)
    --意见/Bug 控制器
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onFirstReward,self)
    --奖励
    self.reward = self.view:GetChild("n16")
    self.confData = conf.SysConf:getFirstReward()
    
    self.isGet = self.view:GetChild("n44")
    self.isGet.visible = false
    --输入字符长度
    self.inputLen = self.view:GetChild("n42")

    self.weixinhao = self.view:GetChild("n53")
    self.dianhua = self.view:GetChild("n54")
    self.vipkefu = self.view:GetChild("n55")
end

function FeedbackView:onChangeInput()
    self.inputLen.text = string.utf8len(self.inputContent.text) .. "/300"
end

--评星设置
function FeedbackView:onClickStarsEvent(context)
    local cell = context.sender
    local data = cell.data    
    if data.status then 
        self.isStar = data.status  --评星
 
        if data.status == 1 then
            self.btnStar02.selected = false
            self.btnStar03.selected = false
            self.btnStar04.selected = false
            self.btnStar05.selected = false
        elseif data.status == 2 then
            self.btnStar01.selected = true
            self.btnStar03.selected = false
            self.btnStar04.selected = false
            self.btnStar05.selected = false
        elseif data.status == 3 then
            self.btnStar01.selected = true
            self.btnStar02.selected = true
            self.btnStar04.selected = false
            self.btnStar05.selected = false
        elseif data.status == 4 then
            self.btnStar01.selected = true
            self.btnStar02.selected = true
            self.btnStar03.selected = true
            self.btnStar05.selected = false
        elseif data.status == 5 then
            self.btnStar01.selected = true
            self.btnStar02.selected = true
            self.btnStar03.selected = true
            self.btnStar04.selected = true
        end
    end
end

--设置奖励物品显示
function FeedbackView:onFirstReward()
    local itemId = 0
    local itemNum = 0
    if 0 == self.c1.selectedIndex then
        if self.data.ideaFirst ~= 1 then
            self.reward.grayed = true
            self.isGet.visible = true
        else
            self.reward.grayed = false
            self.isGet.visible = false
        end
        itemId = self.confData[1][1][1]
        itemNum = self.confData[1][1][2]
        bind = self.confData[1][1][3]
        local info = {mid=itemId,amount=itemNum,bind=bind}
        GSetItemData(self.reward,info,true)
    elseif 1 == self.c1.selectedIndex then
        if self.data.bugFirst ~= 1 then
            self.reward.grayed = true
            self.isGet.visible = true
        else
            self.reward.grayed = false
            self.isGet.visible = false
        end
        itemId = self.confData[2][1][1]
        itemNum = self.confData[2][1][2]
        bind = self.confData[2][1][3]
        local info = {mid=itemId,amount=itemNum,bind=bind}
        GSetItemData(self.reward,info,true)
    elseif 2 == self.c1.selectedIndex then
        local arr = string.split(g_var.pack_version, ".")
        local pid = arr[2]
        local url = g_var.kefu_info_url.."?p_id="..pid
        print("@请求客服信息："..url)
        mgr.HttpMgr:http(url, 1, 1, function(state, data)
            if state == "success" then
                self.weixinhao.text = data.web_chat
                self.dianhua.text = data.phone_num
                self.vipkefu.text = data.qq
            end
        end)
    end
end

--确认提交
function FeedbackView:onClickSubmit()
    self.isTitle = self.inputTitle.text
    self.isContent = self.inputContent.text
    if self.isTitle == "" then
        GComAlter(language.feedback01)
    elseif self.isStar == 0 then
        GComAlter(language.feedback02)
    elseif self.isContent == "" then
        GComAlter(language.feedback03)
    end

    if self.isTitle ~= "" and self.isStar ~= 0 and self.isContent ~= "" then
        proxy.ActivityProxy:sendMsg(1030201,{reqType = self.c1.selectedIndex+1, title=self.isTitle, satisfy=self.isStar, content=self.isContent})
        self:initData()
        self:onChangeInput()
        GComAlter(language.feedback04)
    end
end

--服务器数据接收
function FeedbackView:setData(data)
    self.data = data
    -- self:onFirstReward()    
end

--关闭窗口
function FeedbackView:onClickClose()
    
    self:initData()
    self.c1.selectedIndex = 0
    self:closeView()
end

return FeedbackView