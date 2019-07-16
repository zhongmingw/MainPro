--
-- Author: 
-- Date: 2017-01-14 11:03:07
--
--设置界面
local SiteView = class("SiteView", base.BaseView)

function SiteView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2
    self.isBlack = true
    self.openTween = ViewOpenTween.scale
end

function SiteView:initData()
    self:initDataFeedBack()

    local arr = string.split(g_var.pack_version, ".")
    local pid = arr[2]
    local url = g_var.kefu_info_url.."?p_id="..pid
    self.kefuBtn.visible = false
    self.kefuData = nil
    -- mgr.HttpMgr:http(url, 1, 1, function(state, data)
    --     local status = tonumber(data.stauts) or 0
    --     if state == "success" and status ~= 0 then
    --         self.kefuBtn.visible = true
    --         self.kefuData = data
    --     end-
    -- end)  
end

--意见反馈：初始化参数
function SiteView:initDataFeedBack()
    self.inputTitle.text = ""
    self.inputContent.text = ""
    self.isStar = 0
    self:onChangeInput()                --初始化内容字符数量
    for k,v in pairs(self.btnStart) do  --初始化评星
        self.btnStart[k].selected = false
    end
end

function SiteView:initView()
    local closeBtn = self.view:GetChild("n13")
    self.controller = self.view:GetController("c1")--主控制器
    self.controller.onChanged:Add(self.selelctPanel,self)--给控制器获取点击事件
    self:setCloseBtn(closeBtn)
    self.kefuBtn = self.view:GetChild("n20")--客服入口
    self:initDec1()
    self:initDec2()
    self:initDec3()
    self:initDec4()
    self:initDec5()        --EVE 意见反
    self:initDec6()--1.BOSS刷新关注默认勾选机制（分等级）
end
--性能设置
function SiteView:initDec1()
    local panel = self.view:GetChild("n9")
    local musicCheck1 = panel:GetChild("n4")--音乐静音
    self.musicCheck1 = musicCheck1
    musicCheck1.onClick:Add(self.onMusicCheck1,self)
    local musicCheck2 = panel:GetChild("n10")--音效静音
    self.musicCheck2 = musicCheck2
    musicCheck2.onClick:Add(self.onMusicCheck2,self)

    self.musicSlider1 = panel:GetChild("n8")--音乐音量控制
    self.musicSlider1.onChanged:Add(self.onChangedMusic1,self)
    self.musicSlider2 = panel:GetChild("n14")--音效音量控制
    self.musicSlider2.onChanged:Add(self.onChangedMusic2,self)

    self.gameController = panel:GetController("c1")--游戏表现控制器
    self.gameController.onChanged:Add(self.onChangeGame,self)--给控制器获取点击事件

    self.shieldBtnList = {}--屏蔽复选按钮
    local num = 0
    for i=55,68 do
        if i % 2 ~= 0 then
            local check = panel:GetChild("n"..i)
            check.selected = false
            check.onClick:Add(self.onShieldCheck,self)
            local index = #self.shieldBtnList + 1
            check.data = index
            table.insert(self.shieldBtnList, check)
        else
            local text = panel:GetChild("n"..i)
            num = num + 1
            text.text = language.site02[num]
        end
    end
    local accountBtn = panel:GetChild("n78")--切换账号
    accountBtn.onClick:Add(self.onClickQhzh,self)
    local topLockBtn = panel:GetChild("n79")--锁屏挂机
    topLockBtn.onClick:Add(self.onClickSpgj,self)
end
--聊天设置
function SiteView:initDec2()
    local panel = self.view:GetChild("n16")
    self.chatChanel = {}
    for i=54,69,3 do
        local check = panel:GetChild("n"..i)
        check.onClick:Add(self.onClickChanel,self)
        local len = #self.chatChanel + 1
        check.data = len
        self.chatChanel[len] = check
    end
    local num = 0
    for i=55,70,3 do
        local text = panel:GetChild("n"..i)
        num = num + 1
        text.text = language.site03[num]
    end
    self.voiceBtnList = {}
    local k = 0
    for i=75,90,3 do
        local btn = panel:GetChild("n"..i)
        k = k + 1
        btn.data = k
        btn.onClick:Add(self.onVoiceCheck,self)
        table.insert(self.voiceBtnList, btn)
    end
    
    local k = 0
    for i=76,91,3 do
        local text = panel:GetChild("n"..i)
        k = k + 1
        text.text = language.site05[k]
    end
end
--个性设置
function SiteView:initDec3()
    self.confBulleData = conf.ChatConf:getChatBubble()
    local panel = self.view:GetChild("n18")
    self.kidneyListView = panel:GetChild("n0")
    self.kidneyListView.itemRenderer = function(index,obj)
        self:cellKidneyData(index, obj)
    end
    self.kidneyListView.onClickItem:Add(self.onKidneyItem,self)
end
--联系客服
function SiteView:initDec4()
    local panel = self.view:GetChild("n21")
    panel:GetChild("n1").url = UIItemRes.qrcode
    local param = {
        {text = language.site09[1],color = 11},
        {text = language.site09[2],color = 7},
        {text = language.site09[3],color = 11},
    }
    panel:GetChild("n2").text = mgr.TextMgr:getTextByTable(param)
    self.weiChat = panel:GetChild("n3")
    self.phone = panel:GetChild("n4")
    self.kfweiChat = panel:GetChild("n5")
    self.kfPhone = panel:GetChild("n6")
    self.weiImg = panel:GetChild("n9")
    self.phoneImg = panel:GetChild("n10")
    panel:GetChild("n8").text = language.site12
end
--EVE 意见反馈
function SiteView:initDec5()
    local panel = self.view:GetChild("n23")
    --标题文本
    self.inputTitle = panel:GetChild("n13")   --inputTxt
    --内容文本
    self.inputContent = panel:GetChild("n14")
    self.inputContent.onChanged:Add(self.onChangeInput,self)
    --满意度评星(代码优化版)
    self.btnStart = {}
    for i=16,20 do        
        self.btnStart[i] = panel:GetChild("n"..i)
        local data = {status = i-15} 
        self.btnStart[i].data = data
        self.btnStart[i].onClick:Add(self.onClickStarsEvent,self)
    end
    --提交按钮
    local btnSubmit = panel:GetChild("n9")
    btnSubmit.onClick:Add(self.onClickSubmit,self)
    --奖励(列表模式) 
    self.rewardList = panel:GetChild("n8")
    self.rewardList.visible = false
    local mark = panel:GetChild("n6")
    mark.visible = false
    -- self:initListView()  
    --内容输入字符长度
    self.inputLen = panel:GetChild("n15")
end 
function SiteView:oncheckbox(context)
    -- body
    local btn = context.sender
    local data = btn.data 
    local param = {}
    param.kind = data.id
    if btn.selected then
        param.reqType = 1
    else
        param.reqType = 2
    end
    proxy.PlayerProxy:send(1331001,param)
end

function SiteView:initDec6()
    -- body
    self._boss_tip = conf.SysConf:getBossTips()

    local panel = self.view:GetChild("n27")
    panel:GetChild("n7").text = language.site13
    self.tishilistview = panel:GetChild("n5")
    self.tishilistview.itemRenderer = function(index,obj)
        --self:cellteamdata(index, obj)
        local data = self._boss_tip[index+1]

        local txt = obj:GetChild("n1")
        txt.text = data.name

        local btn =  obj:GetChild("n54")
        btn.data = data
        btn.onClick:Add(self.oncheckbox,self)

        btn.selected = self.data5331001.tips[data.id] and self.data5331001.tips[data.id]==1
    end
    self.tishilistview.numItems = 0

    --增加屏蔽加好友和消息按钮
    self.privacyBtnList = {}--隐私设置按钮
    local num = 0
    for i = 11,14 do
        if i%2 ~= 0 then
            local check = panel:GetChild("n"..i)
            local var = cache.PlayerCache:getAttribute(10328)
            if var == 1 then
                check.selected = true
            else
                check.selected = false
            end
            check.onClick:Add(self.onPrivateCheck,self)
            local index = #self.privacyBtnList + 1
            check.data = index
            table.insert(self.privacyBtnList, check)
        else
            local text = panel:GetChild("n"..i)
            num = num + 1
            text.text = language.site14[num]
        end
    end


end

--切换账号
function SiteView:onClickQhzh()
    mgr.SceneMgr:backToLoginScene(true)
end
--锁屏挂机
function SiteView:onClickSpgj()
    UnityEngine.Application.targetFrameRate = 15
    mgr.ViewMgr:openView(ViewName.TopLockView)
    self:closeView()
end
--意见反馈：内容长度
function SiteView:onChangeInput()
    self.inputLen.text = string.utf8len(self.inputContent.text) .. "/300"
end
--意见反馈：评星设置
function SiteView:onClickStarsEvent(context)
    local cell = context.sender
    local data = cell.data    
    if data.status then 
        self.isStar = data.status  --评星

        for k,v in pairs(self.btnStart) do
            if data.status + 15 < k then 
                self.btnStart[k].selected = false
            else
                self.btnStart[k].selected = true
            end 
        end
    end
end
--意见反馈：确认提交
function SiteView:onClickSubmit()
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
        proxy.ActivityProxy:sendMsg(1030201,{reqType = 1, title=self.isTitle, satisfy=self.isStar, content=self.isContent})
        self:initDataFeedBack()
        self:onChangeInput()
        -- self.rewardList.touchable = false  --第一次领取物品后，防止再次点击弹窗物品信息
        GComAlter(language.feedback04)
    end
end

-- function SiteView:initListView()
--     self.rewardList.numItems = 0
--     self.rewardList.itemRenderer = function(index,obj)
--         self:onFirstReward(index, obj)
--     end
--     self.rewardList:SetVirtual()
-- end
-- --意见反馈：设置奖励物品显示
-- function SiteView:onFirstReward(index, obj)
--     local isGet = false
--     local grayed = false
--     local isClick = false

--     itemId = self.confData[1][index+1][1]
--     itemNum = self.confData[1][index+1][2]
--     bind = self.confData[1][index+1][3]

--     if self.data.ideaFirst ~= 1 then
--         isGet = true
--         grayed = true
--     else
--         isGet = false
--         grayed = false
--         isClick = true
--     end

--     local info = {mid=itemId, amount=itemNum, bind=bind, isGet=isGet, grayed=grayed}
--     GSetItemData(obj,info,isClick)
-- end
-- --意见反馈：网络模块调用
-- function SiteView:setDataOfFeedBack(data)
--     self.data = data
--     self.confData = conf.SysConf:getFirstReward()
--     if self.confData then
--         self.rewardList.numItems = #self.confData[1]
--     end   
-- end

function SiteView:cellKidneyData(index,cell)
    local key = index + 1
    local title = cell:GetChild("n2")
    local bubbleData = self.confBulleData[key]
    title.text = bubbleData.name
    local bgKuang = cell:GetChild("n5")
    bgKuang.url = UIPackage.GetItemURL("chat" , bubbleData.icon_img)
    local icon = cell:GetChild("n6") 
    local sex = GGetMsgByRoleIcon(cache.PlayerCache:getRoleIcon()).sex
    icon.url = UIItemRes.chatIcon[sex]
    local bubble = cell:GetChild("n8")
    bubble.url = UIPackage.GetItemURL("chat" , bubbleData.bulle_img1)
    cell.data = bubbleData
    if bubbleData.id == self.curPId then
        cell.selected = true
        local context = {data = cell}
        self:onKidneyItem(context)
    end
end

function SiteView:onKidneyItem(context)
    local cell = context.data
    local data = cell.data
    local id = data.id
    if id ~= self.curPId then
        proxy.PlayerProxy:send(1020501,{reqType = 1,pId = id})
    end
end

function SiteView:onMusicCheck1(context)
    local checkBtn = context.sender
    mgr.SoundMgr:setMusicEnable(checkBtn.selected)
    self:setMainMusic()
end

function SiteView:onMusicCheck2(context)
    local checkBtn = context.sender
    mgr.SoundMgr:setSoundEnable(checkBtn.selected)
    self:setMainMusic()
    self:setMusicClick()
end

function SiteView:setMainMusic()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setMusicBtn()
    end
end

function SiteView:setMainShield()
    local view = mgr.ViewMgr:get(ViewName.MainView)
    if view then
        view:setShieldBtn()
    end
end
--音乐音量控制
function SiteView:onChangedMusic1( ... )
    --plog(self.musicSlider1.value)
    local value = self.musicSlider1.value/100
    mgr.SoundMgr:setMusicVolume(value)
    mgr.SoundMgr:setSiteMusic()
    mgr.SoundMgr:setMusicEnable(true)
    self:setMainMusic()
    self:setMusicClick()
end
--音效音量控制
function SiteView:onChangedMusic2( ... )
    --plog(self.musicSlider2.value)
    local value = self.musicSlider2.value/100
    mgr.SoundMgr:setSoundVolume(value)
    mgr.SoundMgr:setSiteSound()
    mgr.SoundMgr:setSoundEnable(true)
    self:setMainMusic()
    self:setMusicClick()
end

function SiteView:onVoiceCheck(context)
    local btn = context.sender
    local index = btn.data
    local open = 0
    if index == 2 then--语音就是0是开启
        if btn.selected then
            open = 1
        else
            open = 0
        end
    else
        if btn.selected then
            open = 0
        else
            open = 1
        end
    end
    cache.ChatCache:setVoiceChannel(language.site06[index],open)
end

function SiteView:onChangeGame()
    self:setGamePlay()
end
--游戏表现控制
function SiteView:setGamePlay()
    local selectedIndex = self.gameController.selectedIndex
    if selectedIndex == 0 then--高
        mgr.QualityMgr:setQuality(3)
    elseif selectedIndex == 1 then--中
        mgr.QualityMgr:setQuality(2)
    elseif selectedIndex == 2 then--低
        mgr.QualityMgr:setQuality(1)
    end
end
--（1..屏蔽其他玩家 2.屏蔽他人法器，3.屏蔽他人灵宠，4.屏蔽他人仙羽，5.屏蔽怪物，6.屏蔽称号,7.屏蔽技能特效）
function SiteView:onShieldCheck(context)
    local checkBtn = context.sender
    local index = checkBtn.data
    -- if isShield then
    --     plog(language.site02[index])
    -- else
    --     plog("解除"..language.site02[index])
    -- end
    local sId = cache.PlayerCache:getSId()
    local isShield = not checkBtn.selected
    if mgr.FubenMgr:isWenDing(sId) or mgr.FubenMgr:isXianMoWar(sId) then
        if index == 7 then
             mgr.QualityMgr:hitAllSkillEffect(isShield)
        end
        return
    end
    if index == 1 then
        mgr.QualityMgr:hitAllPlayers(isShield) 
    elseif index == 2 then
        mgr.QualityMgr:hitAllFaQi(isShield)
    elseif index == 3 then
        mgr.QualityMgr:hitAllPets(isShield)
    elseif index == 4 then
        mgr.QualityMgr:hitAllWing(isShield)
    elseif index == 5 then--
        mgr.QualityMgr:hitAllMonsters(isShield)
    elseif index == 6 then
        mgr.QualityMgr:hitAllChenghao(isShield)
    elseif index == 7  then
         mgr.QualityMgr:hitAllSkillEffect(isShield)
    end
    self:setMainShield()
end

--隐私设置
function SiteView:onPrivateCheck(context) --1:自动拒绝好友申请 2:自动屏蔽陌生人私聊信息
    local checkBtn = context.sender
    local index = checkBtn.data
    if checkBtn.selected then
        proxy.FriendProxy:send(1070106,{reqType = 1})
    else
        proxy.FriendProxy:send(1070106,{reqType = 0})
    end
    -- local sId = cache.PlayerCache:getSId()
    -- local isShield = not checkBtn.selected
 
    -- if index == 1 then 
    --     if not isShield then 
    --         proxy.FriendProxy:send(1070106,{reqType = 1})
    --     else
    --         proxy.FriendProxy:send(1070106,{reqType = 0})
    --     end
    --     -- mgr.QualityMgr:hitAllFriendShenQing(isShield) 

    -- elseif index == 2 then
    --     -- mgr.QualityMgr:hitAllStrangerChat(isShield) 
    -- end
end

function SiteView:setMusicClick()
    self.musicCheck1.selected = mgr.SoundMgr:getMusicEnable()
    self.musicCheck2.selected = mgr.SoundMgr:getSoundEnable()
end

function SiteView:setData()
    for k,v in pairs(self.shieldBtnList) do--初进来看看哪些屏蔽了
        if k == 1 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllPlayer()
        elseif k == 2 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllFaQi()
        elseif k == 3 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllPets()
        elseif k == 4 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllWing()
        elseif k == 5 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllMonsters()
        elseif k == 6 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllChenghao()
        elseif k == 7 then
            self.shieldBtnList[k].selected = not mgr.QualityMgr:getAllSkillEffect()  
        end
    end
    -- for k,v in ipairs(self.privacyBtnList) do
    --     if k == 1 then
    --         self.privacyBtnList[k].selected =  mgr.QualityMgr:getAllFriendShenQing()
    --     elseif k == 2 then
    --         self.privacyBtnList[k].selected = not mgr.QualityMgr:getAllStrangerChat()
    --     end
    -- end

    self.gameController.selectedIndex = mgr.QualityMgr:getQuality()
    self:setGamePlay()
    self:setMusicClick()

    self.musicSlider1.value = mgr.SoundMgr:getMusicVolume() * 100--音乐音量
    self.musicSlider2.value = mgr.SoundMgr:getSoundVolume() * 100--音效音量
    for k,v in pairs(self.chatChanel) do
        local open = cache.ChatCache:getChannel(language.site04[k])
        if open == 0 then
            self.chatChanel[k].selected = true
        else
            self.chatChanel[k].selected = false
        end
    end
    --语音屏蔽
    for k,v in pairs(self.voiceBtnList) do
        local open = cache.ChatCache:getVoiceChannel(language.site06[k])
        if k == 2 then--世界语音0就是关闭自动播放
            if open == 0 then
                self.voiceBtnList[k].selected = false
            else
                self.voiceBtnList[k].selected = true
            end
        else
            if open == 1 then
                self.voiceBtnList[k].selected = false
            else
                self.voiceBtnList[k].selected = true
            end
        end
    end

end

function SiteView:setKidneyData(data)
    self.curPId = data.curPId
    self.kidneyListView.numItems = #self.confBulleData
end

function SiteView:onClickChanel(context)
    local cell = context.sender
    local index = cell.data
    local open = 1
    if cell.selected then
        open = 0
    end
    cache.ChatCache:setChannel(language.site04[index],open)
    local view =  mgr.ViewMgr:get(ViewName.MainView)
    if view then
        -- view:setChatData()
    end
end

function SiteView:nextStep(index)
    self.controller.selectedIndex = index - 1
    self.kidneyListView.numItems = 0
    self:selelctPanel()
end
--
function SiteView:selelctPanel()
    local selectedIndex = self.controller.selectedIndex
    if selectedIndex == 0 then--设置
        self:setData()
    elseif selectedIndex == 1 then--聊天设置
        self:setData()
    elseif selectedIndex == 2 then--个性
        proxy.PlayerProxy:send(1020501,{reqType = 0,pId = 0})
    elseif selectedIndex == 3 then--联系客服
        if self.kefuData then
            self.kfweiChat.text = self.kefuData.web_chat
            self.kfPhone.text = self.kefuData.phone_num
            self.weiChat.visible = true
            self.phone.visible = true
            self.kfweiChat.visible = true
            self.kfPhone.visible = true
            self.weiImg.visible = true
            self.phoneImg.visible = true
        else
            self.kfweiChat.text = ""
            self.kfPhone.text = ""
            self.weiChat.visible = false
            self.phone.visible = false
            self.kfweiChat.visible = false
            self.kfPhone.visible = false
            self.weiImg.visible = false
            self.phoneImg.visible = false
        end
    elseif selectedIndex == 4 then--意见反馈
        -- plog("~~~~~~~我勒个去")
        proxy.ActivityProxy:sendMsg(1030201,{reqType = 0})
    elseif selectedIndex == 5 then--意见反馈
        local param = {}
        param.kind = 0
        param.reqType = 0
        proxy.PlayerProxy:send(1331001,param)
    end
end

function SiteView:addMsgCallBack(data)
    -- body
    if data.msgId == 5331001  then
        if self.controller.selectedIndex == 5 then
            self.data5331001 = data
            self.tishilistview.numItems = #self._boss_tip
        end
    end
end

return SiteView