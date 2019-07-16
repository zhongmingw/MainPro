--
-- Author: 
-- Date: 2017-11-24 11:44:13
--

local MainIosView = class("MainIosView", import("game.views.main.MainView"))

function MainIosView:ctor()
    -- self.super.ctor(self)
    self.parent = nil
    self.view = nil  --游戏对象
    self.callBackFunc = nil
    self.uiLoadSuccess = false
    self.prefabsCount = 0
    self.isOpen = false
    self.isGuide = false
    self.drawcall = true

    self.models = {}
    self.timer = {} --定时器
    self.effects = {}  --界面特效
    self:initParams()
    self.extraui = {}

    self.sharePackage = {}

    self.time = 0    --弹窗效果专用计时变量
end

function MainIosView:initView()
    self.super.initView(self)
    self.hideXianzun.scaleX,self.hideXianzun.scaleY = 0,0
end

function MainIosView:setData(data_)

end

return MainIosView