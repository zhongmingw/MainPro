--[[
创建角色 --
-- Author: wx
--
--]]

local CreateRoleView = class("CreateRoleView", base.BaseView)

--EVE 随机数种子优化
--math.randomseed(os.time())  
math.randomseed(tostring(os.time()):reverse():sub(1,6)) 

function CreateRoleView:ctor()
    self.super.ctor(self)
    self.uiClear = UICacheType.cacheDisabled
end

function CreateRoleView:initData(data)
    -- body
    self:_addModel()
     --随机一个名字
    self:addTimer(0.1,1,function()
        -- body
        self:onbtnRandomName()
    end)

    --标志位，是否可发送创建角色消息
    self.isCanCreate = true
end

function CreateRoleView:initView()
    -- local bg = self.view:GetChild("n0")
    -- bg.url = UIItemRes.chuangjianjuese_014

	--创建角色
	local btnCreate = self.view:GetChild("n19")
    btnCreate.onClick:Add(self.onOkClick,self)
    --职业描述信息动效
    self.animationEffect = self.view:GetTransition("t0") 
    self.playerImg = self.view:GetChild("n58")--ios审核用到
    self.playerImg.visible = g_ios_test
    --职业描述特效位置 
    self.node = self.view:GetChild("n57")
    --人物模型添加
    self.panle_model = self.view:GetChild("n14"):GetChild("n0")
    --随机一个名字
    self.inputTxt = self.view:GetChild("n23")
    local btnRandom = self.view:GetChild("n24")
    btnRandom.onClick:Add(self.onbtnRandomName,self)
    --角色切换控制器
    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self._addModel,self)

	if math.random(1000)>300 then
    	self.c1.selectedIndex = 1 -- 0 男 1 女\
    end
    ---
    local btnBacklogin = self.view:GetChild("n4")
    btnBacklogin.onClick:Add(self.onbtnBackLogin,self)

    --背景粒子特效
    local node1 = self.view:GetChild("n43")
    local effectBG = self:addEffect(4030108,node1)
    effectBG.Scale = Vector3.New(70,70,70)      --背景特效缩放  --添加时间 2017/5/15
    effectBG.LocalPosition = Vector3.New(0,-142,0)   --背景特效位置
    --进入游戏按钮特效
    local btnEnterEfc = self.view:GetChild("n54")
    local effect = self:addEffect(4020117,btnEnterEfc)
    effect.Scale = Vector3.New(80,80,80)         --特效缩放
    effect.LocalPosition = Vector3.New(19,-1,0)  --特效位置
    -- --建筑物八卦特效
    -- local node2 = self.view:GetChild("n56")
    -- local effectGossip = self:addEffect(4030110,node2)
    -- effectGossip.Scale = Vector3.New(70,70,70)
end

function CreateRoleView:onbtnRandomName()
	-- body
    local sex = self.c1.selectedIndex+1
    self.inputTxt.text = conf.RoleConf:getRandName(sex)
end

--添加人物模型
function CreateRoleView:_addModel()

    --职业描述
    local image01 = self.view:GetChild("n41")
    image01.url = UIItemRes.chuangjianjuese_015[self.c1.selectedIndex+1]
    local image02 = self.view:GetChild("n42")
    image02.url = UIItemRes.chuangjianjuese_016[self.c1.selectedIndex+1]
    if g_ios_test then
        local playerUrl = "ui://guide/xinshouyingdao_107"
        if g_var.gameFrameworkVersion >= 18 then
            local imgs = {"role01.png","role02.png"}
            local imagePath = "res/images/"..imgs[self.c1.selectedIndex + 1]
            local check = PathTool.CheckResExist(imagePath)
            if check then
                playerUrl = "@"..imagePath
            end
            self.playerImg.url = playerUrl
            local imgs = {"roleicon01.png","roleicon02.png"}
            for i=1,2 do
                local icon = "res/images/"..imgs[i]
                local check = PathTool.CheckResExist(icon)
                if check then
                    self.view:GetChild("n2"..(i - 1)).icon = "@"..icon
                end
            end
        else
            unity.createUIPackage("res/ui/guide", "guide", function()
                local imgs = {"xinshouyingdao_107","xinshouyingdao_108"}
                playerUrl = "ui://guide/"..imgs[self.c1.selectedIndex + 1]
                self.playerImg.url = playerUrl
            end)
        end
    else
        self.animationEffect:Play()

        if self.timer then 
            self:removeTimer(self.timer)
            self.timer = nil
        end 
        self.timer = self:addTimer(5,1,function()
            if self.effect then
                self:removeUIEffect(self.effect)
                self.effect = nil
            end
            self.effect = self:addEffect(4020125,self.node)
        end)

        if self.c1.selectedIndex == 1 then--女
            mgr.SoundMgr:stopSound(Audios[5])
            mgr.SoundMgr:playSound(Audios[6])
        else--男
            mgr.SoundMgr:stopSound(Audios[6])
            mgr.SoundMgr:playSound(Audios[5])
        end

        --local t = {[1] = 3010997, [2] = 3010998}
        local id = RoleSexMode2[self.c1.selectedIndex+1]
        if not self.modelObj then
            local modelObj = self:addModel(id,self.panle_model)
            modelObj:setSkins(id, 3020101)
            modelObj:setPosition(self.panle_model.actualWidth/2,-self.panle_model.actualHeight,500)
            modelObj:setRotation(-180)
            modelObj:setScale(250)
            modelObj.goWrapper.rotationX = 0    --初始化模型自带旋转
            self.modelObj = modelObj
        else
            self.modelObj:setSkins(id, 3020101)
        end
        self.modelObj:playAnimation("skill1")
        self:onbtnRandomName()
    end
end

--服务器返回数据设置
function CreateRoleView:setData(data)
    -- body 
    -- plog("创建角色的返回信息：")
    -- printt(data)
    -- plog(data.status)

    if not self.isCanCreate then
        self.isCanCreate = true
        plog("创建失败信息已返回，可再次请求创建")
    end
end

function CreateRoleView:onOkClick()
	--plog(self.c1.selectedIndex)
	local roleName = self.inputTxt.text
	local sex = self.c1.selectedIndex + 1 
	if roleName == "" then
        GComAlter(language.chuanghao01)
		return
	end

	local reqData = {
		roleName = string.trim(roleName),
		roleKey	 = "",
		roleSex = sex,
		career = sex,
	}

    --发送创建角色消息(if判断用于防止连续点击时，不停地发创建请求)
    if self.isCanCreate then
        proxy.LoginProxy:reqCreateRole(reqData)
        self.isCanCreate = false
    end
end

function CreateRoleView:onbtnBackLogin()
	mgr.ViewMgr:openView2(ViewName.LoginView)
    mgr.SoundMgr:stopSound(Audios[5])
    mgr.SoundMgr:stopSound(Audios[6])
    self:closeView()
end

return CreateRoleView