local FightView = class("FightView", base.BaseView)

function FightView:ctor()
  self.super.ctor(self)
end

function FightView:initView()
    local btn = self.transform:FindChild("Button1").gameObject
    self:addEvent(btn)
end

function FightView:onUIClickCall(go_)
  print("FightView:onUIClickCall--->>>"..go_.name)
  local name = go_.name
  if name == "Button1" then
      local par = mgr.SceneMgr:getNowScene().transform
      local xx = math.random(100, 600)
      local yy = math.random(100, 900)
      mgr.EffectMgr:playEffect({effectId=1001, pos=Vector3.New(xx,yy,0),parent=par})
  elseif name == "" then
      ----
  end
end


return FightView