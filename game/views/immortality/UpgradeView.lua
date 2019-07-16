--修仙升级
local UpgradeView = class("UpgradeView", base.BaseView)

local effectId = 4020104--特效id

function UpgradeView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level2 
    self.isBlack = true --黑色的底
end

function UpgradeView:initData(data)
    -- body
    self.data = data
    self:setData(data)
    self:playEffect()
end

function UpgradeView:initView()
    local btnSure = self.view:GetChild("n6")
    self.btnSure = btnSure
    btnSure.onClick:Add(self.onSureCallBack,self)
    self.attrList = {} --属性列表
    for i=51,56 do
        local text = self.view:GetChild("n"..i)
        text.text = ""
        table.insert(self.attrList,text)
    end
    self.awardsList = {} --升级奖励
    for i=15,18 do
        local awardItem = self.view:GetChild("n"..i)
        awardItem.visible = false
        table.insert(self.awardsList,awardItem)
    end
    self.icon = self.view:GetChild("n5")
    -- self.power = self.view:GetChild("n21")
    self.xingxing = self.view:GetChild("n49")
    self.xingxing.visible = false
    -- self.controllerC1 = self.view:GetController("c1") --星星控制
    self.periodImg = self.view:GetChild("n50")
end

function UpgradeView:setData(data)
    self.level = data.level
    self.items = data.items
    local attrConf = conf.ImmortalityConf:getAttrDataByLv(self.level)
    --属性设置
    local attrData = GConfDataSort(attrConf)
    if attrConf.period == 1 then
        self.periodImg.url = UIPackage.GetItemURL("_icons" , "xiuxian_032")
    elseif attrConf.period == 2 then
        self.periodImg.url = UIPackage.GetItemURL("_icons" , "xiuxian_033")
    elseif attrConf.period == 3 then
        self.periodImg.url = UIPackage.GetItemURL("_icons" , "xiuxian_034")
    end
    for k,v in pairs(attrData) do
        local key = v[1]
        local value = v[2]
        local decTxt = self.attrList[k]
        local attName = conf.RedPointConf:getProName(key)
        decTxt.text = attName..":+"..value
    end
    -- self.power.text = attrConf.power
    for i=1,4 do
        self.awardsList[i].visible = false
    end
    --奖励设置
    local awardLv = (math.floor((self.level-1)/10)+1)*10
    -- print("当前等级>>>>>>>>>>>>>>>>",self.level,awardLv)
    local awardsConf = conf.ImmortalityConf:getAttrDataByLv(self.level)
    local awardsData = awardsConf.awards
    if awardsData and self.level == awardLv then
        local tab = {
                        [1] = 612,
                        [2] = 681,
                        [3] = 543,
                        [4] = 750,
                    }
        for k,v in pairs(awardsData) do
            local mid = v[1]
            local num = v[2]
            local bind = v[3]
            local awardItem = self.awardsList[k]
            awardItem.visible = true
            if #awardsData < 4 then
                awardItem.x = tab[k] + 33
            else
                awardItem.x = tab[k]
            end
            -- local info = { mid=mid, amount = num,bind = conf.ItemConf:getBind(mid) or 0}
            local info = { mid=mid, amount = num,bind = bind}
            GSetItemData(awardItem,info,true)
        end
        self.view:GetChild("n14").visible = true
        self.btnSure:GetChild("icon").url = UIPackage.GetItemURL("_imgfonts" , "fulidating_108")
        for i=51,56 do
            self.view:GetChild("n"..i).visible = false
        end
    else
        self.btnSure:GetChild("icon").url = UIPackage.GetItemURL("immortality" , "gonggongsucai_yidong004")
        self.view:GetChild("n14").visible = false
        for i=1,4 do
            self.awardsList[i].visible = false
        end
        for i=51,56 do
            self.view:GetChild("n"..i).visible = true
        end
    end
    --icon设置
    local orderIcon = self.view:GetChild("n5")
    orderIcon.url = UIPackage.GetItemURL("immortality" , attrConf.pic)
    local node = self.view:GetChild("n46")
    local effect = self:addEffect(4020109,node)
    effect.LocalPosition = Vector3(node.actualWidth/2,-node.actualHeight/2,100)
    self.xingxing:GetController("c1").selectedIndex = attrConf.start
end

function UpgradeView:playEffect()
    -- body
    -- self.oldTime = os.time()
    if self.effect then--出现特效
        self:removeUIEffect(self.effect)
        self.effect = nil
    end
    self.effect = self:addEffect(effectId, self.view:GetChild("n47"))
    mgr.SoundMgr:playSound(Audios[1])
end

function UpgradeView:onSureCallBack()
    -- body
    -- local cdTime = os.time() - self.oldTime
    local confEffectData = conf.EffectConf:getEffectById(effectId)
    local confTime = confEffectData and confEffectData.durition_time or 0
    -- if cdTime > confTime then
    -- mgr.FubenMgr:quitFuben()
    self:closeView()
    -- end
end

return UpgradeView