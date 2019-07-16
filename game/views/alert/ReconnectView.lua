--
-- Author: EVE
-- Date: 2017-05-20 17:58:53
--

local ReconnectView = class("ReconnectView", base.BaseView)

function ReconnectView:ctor()
    self.super.ctor(self)
    self.uiLevel = UILevel.level5
    self.isBlack = true
    --self.uiClear = UICacheType.cacheTime
end

function ReconnectView:initData(data)
    if data.type == 1 then  -- 返回登录
        self.btnRelogin.x = globalConst.ReconnectView01
        self.btnRelogin.y = globalConst.ReconnectView02
        self.btnReConnect.visible = false
        if data.status == 20010102 then  --顶号
            self.title.text = language.dinghao.."["..data.status.."]"
        elseif data.status == 21090010 then
            self.title.text = message.errorID[tonumber(data.status)].."["..data.status.."]"
        else
            self.title.text = language.duanxian.."["..data.status.."]"
        end
    else
        self.btnReConnect.visible = true
        self.btnReConnect.x = globalConst.ReconnectView03
        self.btnReConnect.y = globalConst.ReconnectView04
        self.btnRelogin.x = globalConst.ReconnectView05
        self.btnRelogin.y = globalConst.ReconnectView06
        self.title.text = language.duanxianchonglian.."["..data.status.."]"
    end
end

function ReconnectView:initView()
    -- 返回登录
    self.btnRelogin = self.view:GetChild("n2")
    self.btnRelogin.onClick:Add(self.onRelogin,self)

    self.btnReConnect = self.view:GetChild("n7")
    self.btnReConnect.onClick:Add(self.onReConnect,self)

    self.title = self.view:GetChild("n4")
end

--一键连接
function ReconnectView:onReConnect()
    mgr.NetMgr:connect(g_var.socketAddress,g_var.socketPort,function()
        proxy.LoginProxy:sReConnect()
    end, function()
        mgr.SceneMgr:backToLoginScene(false)
    end)
end

-- 返回登录
function ReconnectView:onRelogin()
    mgr.SceneMgr:backToLoginScene(false)
end

return ReconnectView