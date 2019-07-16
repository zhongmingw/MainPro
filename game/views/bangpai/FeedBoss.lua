--
-- Author: EVE
-- Date: 2017-10-16 16:51:42
-- Desc: 喂养boss

local FeedBoss = class("FeedBoss", base.BaseView)

function FeedBoss:ctor()
    self.super.ctor(self)
    -- self.uiLevel = UILevel.level3 
    self.openTween = ViewOpenTween.scale
    self.isBlack = true
end

function FeedBoss:initView()
    local closeBtn = self.view:GetChild("n0"):GetChild("n7")
    closeBtn.onClick:Add(self.onCloseView, self)
    --规则
    local tipsBtn = self.view:GetChild("n1")
    tipsBtn.onClick:Add(self.onTipsBtn, self)
    --Boss名称/位置
    self.bossName = self.view:GetChild("n4")
    self.bossName.text = ""
    self.bossPos = self.view:GetChild("n13")
    --击杀奖励
    self.rewardList = self.view:GetChild("n12") 
    --进度条
    self.progress = self.view:GetChild("n6") --进度条
    self.progressDesc = self.progress:GetChild("title")
    --升级
    self.upgradeBtn = self.view:GetChild("n7")
    self.upgradeBtn.onClick:Add(self.onUpgradeBtn, self)
    --普通喂养
    local normalFeedBtn = self.view:GetChild("n9")
    normalFeedBtn.data = {status=1}
    normalFeedBtn.onClick:Add(self.onFeedBtn, self)
    self.normalFeedBtn = normalFeedBtn
    --普通喂养花费
    self.normalCost = self.view:GetChild("n19")
    self.normalCost.text = ""
    --元宝喂养
    local ingotFeedBtn = self.view:GetChild("n8")
    ingotFeedBtn.data = {status=2}
    ingotFeedBtn.onClick:Add(self.onFeedBtn, self)
    --元宝喂养花费
    self.ingotCost = self.view:GetChild("n20")
    self.ingotCost.text = ""  
    --满级LOGO
    self.maxLevelLogo = self.view:GetChild("n25")
    self.maxLevelLogo.visible = false
    --连续喂养10次功能
    self.tenTimesOfItem = self.view:GetChild("n26")
    self.tenTimesOfGold = self.view:GetChild("n29")
    --喂养的帮贡奖励
    self.view:GetChild("n36").text = conf.BangPaiConf:getValue("gang_feed_award_item")[1][2]
    self.view:GetChild("n37").text = conf.BangPaiConf:getValue("gang_feed_award_yb")[1][2]
end

function FeedBoss:initData(data)
    self.isCanUpgrade = false --Boss是否可以升级
    --普通喂养红点
    local param = {} 
    param.panel = self.normalFeedBtn:GetChild("red")
    param.ids = {10251}
    mgr.GuiMgr:registerRedPonintPanel(param,"bangpai.BangPaiMain.2") 

    self:setData(data)  --注意：这个data是从PanelFlame.lua传过来的
end

function FeedBoss:setData(data)
    -- printt(data)
    -- print("仙盟boss信息请求返回~1111111111~~~~~~~~")
    self.data = data

    self.curBossInfor = self:getConfData(self.data.curLevel)

 
    if self.data and self.data.curLevel and not self:getConfData(self.data.curLevel+1) then
        self.maxLevelLogo.visible = true
        self.upgradeBtn.scale = Vector3.zero
    else
        self.maxLevelLogo.visible = false
        self.upgradeBtn.scale = Vector3.one
    end 

    self:setFeedReturnData()
   
    self.ingotCost.text = self.curBossInfor.cost_yb or 0 --花费元宝

    self:setProgressBar(self.data.curExp) --设置进度条

    local confData = conf.MonsterConf:getInfoById(self.curBossInfor.monster[1])

    GSetAwards(self.rewardList,confData.normal_drop) --BOSS奖励

    self.bossName.text =  string.format(language.bangpai161, self.data.curLevel,confData.name) 

    self:setModel(confData.src,self.bossPos) --boss模型
end

function FeedBoss:getConfData(curLv)
    local confGangData = conf.BangPaiConf:getExpAndRewardById(curLv)
    return confGangData
end

function FeedBoss:setFeedData(data)
    -- printt(data)
    -- print("boss喂养请求返回~~~~~~~~~~~~")
    self.data = data

    self:setFeedReturnData()

    self:setProgressBar(self.data.bossExp)

    if self.data.items then 
        GOpenAlert3(self.data.items)
    end

    mgr.GuiMgr:refreshRedBottom()
end

--设置道具喂养BOSS时候，道具数量显示的问题
function FeedBoss:setFeedReturnData()
    local ownedCount = cache.PackCache:getPackDataById(self.curBossInfor.cost_item[1]).amount --TODO 已经拥有的道具数量
    if ownedCount >= self.curBossInfor.cost_item[2] then 
        self.normalCost.text = string.format(language.bangpai178, 
                                ownedCount,
                                self.curBossInfor.cost_item[2]) or 0 --花费物品
    else
        self.normalCost.text = string.format(language.bangpai178, 
                                mgr.TextMgr:getTextColorStr(tostring(ownedCount), 14),
                                self.curBossInfor.cost_item[2]) or 0 --花费物品
    end
end

function FeedBoss:onUpgradeBtn() 
    -- --判满级
    -- if self.data and self.data.curLevel and not self:getConfData(self.data.curLevel+1) then
    --     GComAlter(language.bangpai187)
    --     return
    -- end

    if not self.isCanUpgrade then --成长值不足
        GComAlter(language.bangpai157)
    else
        proxy.BangPaiProxy:sendMsg(1250502,{reqType = 2})
    end
end

function FeedBoss:onFeedBtn(context)
    local status = context.sender.data.status
    if status == 1 then 

        if self.tenTimesOfItem.selected then 
            --TODO 连升10次请求
            -- print("等待服务端提供喂养十次的请求")
            proxy.BangPaiProxy:sendMsg(1250504,{reqType = status,times = 10})
        else
            proxy.BangPaiProxy:sendMsg(1250504,{reqType = status})
        end 
    else      

        if self.tenTimesOfGold.selected then 
            --TODO 连升10次请求
            -- print("等待服务端提供喂养十次的请求")
            proxy.BangPaiProxy:sendMsg(1250504,{reqType = status,times = 10})
        else
            self:setNotice(status) --警告公共弹窗
        end
    end 
end

function FeedBoss:setNotice(status)
    if self.notTips then
        proxy.BangPaiProxy:sendMsg(1250504,{reqType = status})
        return 
    end

    local param = {}
    param.type = 8
    param.richtext = language.bangpai176
    param.richtext1 = language.bangpai177
    param.sureIcon = UIItemRes.imagefons01
    param.sure = function(flag) --注意这个加flag的用法
        self.notTips = flag
        proxy.BangPaiProxy:sendMsg(1250504,{reqType = status})
    end
    GComAlter(param) 
end

function FeedBoss:setProgressBar(data) --进度条
    if data then
        if data < self.curBossInfor.need_exp then 
            self.isCanUpgrade = false     
        else
            self.isCanUpgrade = true
        end
        self.progress.max = self.curBossInfor.need_exp
        self.progress.value = data  
        self.progressDesc.text = language.bangpai156 .. data .."/"..self.curBossInfor.need_exp         
    end
end

function FeedBoss:setModel(modelConf,modelPos)
    local modelObj = self:addModel(modelConf, modelPos)--添加模型
    modelObj:setPosition(modelPos.actualWidth/2-30,-modelPos.actualHeight-200,500)
    modelObj:setRotation(180)
    modelObj:setScale(90)
end

function FeedBoss:onTipsBtn()
    GOpenRuleView(1049)
end

function FeedBoss:onCloseView()
    self:closeView()
end

return FeedBoss