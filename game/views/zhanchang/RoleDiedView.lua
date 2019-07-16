--角色死亡界面
local RoleDiedView = class("RoleDiedView",base.BaseView)

function RoleDiedView:ctor()
    -- body
    self.super.ctor(self)
    self.uiLevel = UILevel.level3
end

function RoleDiedView:initData(data)
    -- body
    self.overTime = 60
    self:addTimer(1, -1, handler(self,handler(self,self.onTimer)))

    self.data = data
end

function RoleDiedView:initView()
    --原点复活按钮
    local btnRebirth1 = self.view:GetChild("n10")
    btnRebirth1.onClick:Add(self.onOriginRebirth,self)
    --当前位置复活按钮
    local btnRebirth2 = self.view:GetChild("n11")
    btnRebirth2.onClick:Add(self.onRebirth,self)
    --复选按钮
    self.checkBtn = self.view:GetChild("n7")
    self.checkBtn.onChanged:Add(self.onClickSign,self)
    self.time = self.view:GetChild("n14")
    self.time.text = ""
end

function RoleDiedView:onTimer()
    -- body
    if self.overTime <= 0 then
        self:onOriginRebirth()
        return
    end
    self.overTime = self.overTime - 1
    self.time.text = string.format(language.kaifu38,self.overTime)
end

--自动购买复选按钮
function RoleDiedView:onClickSign( context )
    -- body
    if self.checkBtn.selected then
    else
    end
end

--原点复活
function RoleDiedView:onOriginRebirth( context )
    -- body

end

--原地复活
function RoleDiedView:onRebirth( context )
    -- body
end

return RoleDiedView