--
-- Author: 
-- Date: 2017-04-01 15:02:14
--

local SitDownView = class("SitDownView", base.BaseView)

function SitDownView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function SitDownView:initData()
    -- body
    self.countTime = conf.SysConf:getValue("add_sit_down")
    self._var = 0
    self.bar.max = self.countTime
    self.bar.value = 0
    self.timer.text = GTotimeString(0)

    if self.timeer then
        self:removeTimer(self.timeer)
    end

    self.timeer = self:addTimer(0.1,-1,handler(self,self.onTimer))

    self:setData()

    self.node = self.view:GetChild("n36")
    self.effect = self:addEffect(4020135,self.node)

    self.c1.selectedIndex = 0
end

function SitDownView:initView()
    self.c1 = self.view:GetController("c1")

    local btn = self.view:GetChild("n1")
    btn.onClick:Add(self.onBtnCall,self)

    local btnclose = self.view:GetChild("n31")
    btnclose.onClick:Add(self.onBtnCall,self)
    --收益率
    self.lab1 = self.view:GetChild("n3") 
    
    --
    self.timer = self.view:GetChild("n6")
    self.timer.text = ""

    self.exp = self.view:GetChild("n7")
    self.exp.text = ""

    local dec1 = self.view:GetChild("n4")
    dec1.text = language.dazuo01
    local dec1 = self.view:GetChild("n5")
    dec1.text = language.dazuo02

    self.bar = self.view:GetChild("n8")

    local dec1 = self.view:GetChild("n11")
    dec1.text = language.dazuo03
    self.dec1 = dec1 

    local dec1 = self.view:GetChild("n12")
    dec1.text = language.dazuo04
    self.dec2 = dec1

    local dec1 = self.view:GetChild("n17")
    dec1.text = language.dazuo05
    local dec1 = self.view:GetChild("n18")
    dec1.text = language.dazuo06

    local btnGoto = self.view:GetChild("n15")
    btnGoto.onClick:Add(self.onVip,self)
    self.btnGoto = btnGoto

    local btnZhucheng = self.view:GetChild("n16")
    btnZhucheng.onClick:Add(self.ontask,self)
    self.btnZhucheng = btnZhucheng
end

function SitDownView:onTimer()
    -- body

    if not self.starTime then
        return 
    end
    self._var = self._var + 0.1

    --plog(self._var,self.countTime)
    if self._var>=self.countTime  then
        proxy.PlayerProxy:send(1020403)
        self.bar.value = self.countTime
        self._var = 0
        local var = mgr.NetMgr:getServerTime()-self.starTime
        self.timer.text = GTotimeString(var)
    else
        self.bar.value = self._var
    end

    if self.isvip ~= cache.PlayerCache:VipIsActivate(1) then
        self:setData()
    end
end

function SitDownView:setData()
    local confdata = conf.SceneConf:getSceneById(cache.PlayerCache:getSId())  
    local isvip = cache.PlayerCache:VipIsActivate(1)
    local number = 100

    self.isvip = isvip

    if confdata.kind == 1 then
        number = number + 100

        self.btnZhucheng.touchable = false
        self.btnZhucheng.grayed = false
        self.btnZhucheng.enabled = false

        self.dec2.text = language.dazuo04 --mgr.TextMgr:getTextColorStr(str, color, clickHerf)
    else
        self.btnZhucheng.touchable = true
        self.btnZhucheng.grayed = true
        self.btnZhucheng.enabled = true

        self.dec2.text = mgr.TextMgr:getTextColorStr(language.dazuo04, globalConst.SitDownView01)
    end
    --plog(isvip,isvip)
    if isvip then
        number = number + 100

        self.btnGoto.touchable = false
        self.btnGoto.grayed = false
        self.btnGoto.enabled = false

        self.dec1.text = language.dazuo03
    else
        self.btnGoto.touchable = true
        self.btnGoto.grayed = true
        self.btnGoto.enabled = true
        self.dec1.text = mgr.TextMgr:getTextColorStr(language.dazuo03, globalConst.SitDownView01)
    end
    self.lab1.text = number
end

function SitDownView:onBtnCall()
    -- body 提升打坐
   -- plog("self.c1.selectedIndex",self.c1.selectedIndex)
    if self.c1.selectedIndex == 0 then
        self.c1.selectedIndex = 1
    else
        self.c1.selectedIndex = 0
    end
end

function SitDownView:onVip()
    -- body
    GGoVipTequan(2,0)
    self:onBtnCall()
end


function SitDownView:ontask()
    -- body
    self:onBtnCall()
    mgr.TaskMgr:setCurTaskId(9001)
    mgr.TaskMgr.mState = 2 --设置任务标识
    mgr.TaskMgr:resumeTask()
end

-- 请求开始打坐
function SitDownView:add5020401(data)
    -- body
    --starTime
    self.starTime = data.starTime
    self.exp.text = "0"
end
-- 请求打坐经验池累加
function SitDownView:add5020403(data)
    -- body
    --poolExp
    self.exp.text =data.poolExp
end

return SitDownView