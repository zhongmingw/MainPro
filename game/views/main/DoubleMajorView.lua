--
-- Author: Your Name
-- Date: 2017-08-29 11:00:44
--

local DoubleMajorView = class("DoubleMajorView", base.BaseView)

function DoubleMajorView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level1
end

function DoubleMajorView:initView()
    self.c1 = self.view:GetController("c1")
    self.totalTime = self.view:GetChild("n9")
    self.totalExp = self.view:GetChild("n10")
    self.xiulianBtn = self.view:GetChild("n3")
    self.xiulianBtn:GetChild("icon").url = UIPackage.GetItemURL("_icons" , "quanminxiulian_002")
    self.xiulianBtn.onClick:Add(self.onClickShuangXiu,self)
    self.expexpBar = self.view:GetChild("n2")
    self.closeBtn = self.view:GetChild("n5")
    self.closeBtn.onClick:Add(self.onClickCloseSX,self)
    self.view:GetChild("n12").text = "50"
    self.node = self.view:GetChild("n15")
end

function DoubleMajorView:initData()
    self.countTime = conf.SysConf:getValue("add_sit_down")
    self._var = 0
    self.expexpBar.max = self.countTime
    self.expexpBar.value = 0
    self.totalTime.text = GTotimeString(0)
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self.timer = self:addTimer(0.1,-1,handler(self,self.onTimer))
    self.effect = self:addEffect(4020136,self.node)
end

function DoubleMajorView:onTimer()
    if not self.startTime then
        return 
    end
    self._var = self._var + 0.1

    --plog(self._var,self.countTime)
    if self._var>=self.countTime  then
        proxy.PlayerProxy:send(1020413)
        self.expexpBar.value = self.countTime
        self._var = 0
        local var = mgr.NetMgr:getServerTime()-self.startTime
        self.totalTime.text = GTotimeString(var)
    else
        self.expexpBar.value = self._var
    end
end
--请求开始修炼
function DoubleMajorView:setData(data)
    self.startTime = data.startTime
    self.totalExp.text = "0"
end
--修炼经验池
function DoubleMajorView:add5020413(data)
    -- print("当前经验",data.exp)
    self.totalExp.text = data.exp
end
--打开双修弹框
function DoubleMajorView:onClickShuangXiu()
    local view = mgr.ViewMgr:get(ViewName.MajorSelectView)
    if view then
        proxy.PlayerProxy:send(1020414,{reqType = 1,auto = 0})
    else
        mgr.ViewMgr:openView(ViewName.MajorSelectView,function()
            proxy.PlayerProxy:send(1020414,{reqType = 1,auto = 0})
        end)
    end
    
end

--关闭双修
function DoubleMajorView:onClickCloseSX()
    proxy.PlayerProxy:send(1020412,{reqType = 2,roleId = 0})
end

--双修按钮状态
function DoubleMajorView:setMajorBtnState( state )
    self.c1.selectedIndex = state
end

--关闭修炼界面
function DoubleMajorView:onCloseView()
    proxy.PlayerProxy:send(1020412,{reqType = 2,roleId = 0})
    if self.timer then
        self:removeTimer(self.timer)
        self.timer = nil
    end
    self:closeView()
end

return DoubleMajorView