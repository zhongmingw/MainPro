--
-- Author: wx
-- Date: 2017-08-11 20:30:13
-- 部件

local Widget = class("Widget",import(".Thing"))

function Widget:ctor()
    self.headHeight = StaticVector3.monsterHeadH
    self.headRes = "HeadView2"
    
    self.tType = ThingType.monster
    self.character = UnityObjMgr:CreateThing(self.tType)
    self:createHeadBar()
    self.fly = true
    self.bodySrc = nil
    self.isAppear = false
    --额外添加组件
    self.componeents = {}
end

function Widget:setData(data)
    self.data = data
    self:setID(data.roleId)
    self:setPosition(data.pox, data.poy)
    --读取配置
    
    local mConf 
    if data.kind == WidgetKind.home then
        --是家园组件
        local condata = conf.HomeConf:getHomeThing(data.ext01)
        if condata.type == 5 then
            local _confdata = conf.HomeConf:getHomeLev(data.ext01,data.ext02)
            if data.ext02 > 0 then
                self:removeHome()
            end

            mConf = conf.NpcConf:getNpcById(_confdata.monster_id[1])
            self:setPosition(mConf.pos[1], mConf.pos[2])
            self.bodySrc = mConf["body_id"]
            --print(data.ext01,data.ext02,self.data.attris[605])
            if self.data.attris and self.data.attris[605] and self.data.attris[605]>0 then
                --种了东西
                local cc = conf.HomeConf:getSeedByid(data.mId)
                local var = self.data.attris[605]+self.data.attris[606]- mgr.NetMgr:getServerTime()
                if var <= 0 then
                    self:addBottomEffect(cc.src[2])   --
                else
                    self:addBottomEffect(cc.src[1])
                end
                            
            else
                mgr.EffectMgr:removeEffect(self.bottomEffect)
                self.bottomEffect = nil
                self.bottomEffectID = nil 
            end
        else
            mConf = conf.NpcConf:getNpcById(data.mId)
            self.bodySrc = mConf["body_id"]
        end
    else
        mConf = conf.MonsterConf:getInfoById(data.mId)
        self.bodySrc = mConf["src"]
    end

    
    if mConf["shadow"] then
        self:hideShadow()
    end
    --不能选中
    self:setCanSelect(false)
    --是否显示
    self:ignoreHide(true)

    if mConf["dead_fly"] then
        self.fly = false
    end
    if mConf["rotation"] then
        self.fixDir = 1
    end
    --名字高度
    if mConf["height"] then
        self.headHeight = Vector3.New(0,-mConf["height"],0)
        self.headBar.position = self.headHeight
    end

    --添加组件
    self:createHead()

    if not self.timer then
        self.timer = mgr.TimerMgr:addTimer(1, -1, handler(self, self.update), "Widget")
    end

    self.character.mModel.LocalRotation = Vector3.New(0,0,0)
end

function Widget:updateData(data)
    -- body
    self:setData(data)
    self:setSkins(self.bodySrc)
end

function Widget:removeHome()
    -- body
    if self.componeents["home1"] then
        self.componeents["home1"]:Dispose()
        self.componeents["home1"] = nil 
    end
    if self.componeents["home2"] then
        self.componeents["home2"]:Dispose()
        self.componeents["home2"] = nil 
    end
    if self.componeents["home3"] then
        self.componeents["home3"]:Dispose()
        self.componeents["home3"] = nil 
    end
    if self.componeents["home4"] then
        self.componeents["home4"]:Dispose()
        self.componeents["home4"] = nil 
    end
end
--点击的时候加入，家园组件
function Widget:addComponent()
    -- body
    local kind = self.data and self.data.kind or 0
    if kind == WidgetKind.home then --家园
        local condata = conf.HomeConf:getHomeThing(self.data.ext01)
        if condata.type == 5 then
            --种子
            if self.data.mId == 0 then
                if not cache.HomeCache:getisSelfHome() then
                    return
                end

                --没有种植
                if self.data.ext02 == 0 then
                    --这里是扩建
                    if self.componeents["home2"] then
                        --再次点击
                        if self.componeents["home2"].visible then
                            if  self.componeents["home1"] then 
                                mgr.HomeMgr:doKuoJian(self.data,function()
                                    -- body
                                    if self.componeents["home2"] then
                                        self.componeents["home2"]:Dispose()
                                        self.componeents["home2"] = nil 
                                    end
                                    mgr.HomeMgr:visibleOther(self)
                                end)
                            else
                                if self.componeents["home2"] then
                                    self.clicktime = os.time()
                                    self.componeents["home2"].visible = true
                                    mgr.HomeMgr:visibleOther(self)
                                end
                            end
                        else
                            self.componeents["home2"].visible = true
                            mgr.HomeMgr:visibleOther(self)
                        end
                    else
                        --点击创建
                        self.clicktime = os.time()
                        local _component = UIPackage.CreateObject("head" , "Component11")
                        if self.componeents["home1"] then
                            _component:GetChild("n1").text = language.home46 
                            _component:GetChild("n2").text = language.home47 
                        else
                            _component:GetChild("n1").text = language.home97 
                            _component:GetChild("n2").text = language.home98 
                        end
                        
                        _component:GetChild("n3").url = nil
                        _component.x = (self.headBar.width -  _component.width)/2
                        _component.y = self.headBar.height
                        _component.visible = true
                        self.componeents["home2"] = _component
                        mgr.HomeMgr:visibleOther(self)
                        self.headBar:AddChild(_component)
                    end
                else
                    --点在了空闲的灵田 
                    local osvar = cache.HomeCache:getOsTye()
                    if osvar then
                        --有选择特别操作
                        if osvar == 1 then
                            --种植操作
                            mgr.HomeMgr:doPlant(self.data)
                            --需要显示界面按钮
                            --
                        elseif osvar == 2 then
                            --浇水操作
                            GComAlter(language.home54) 
                        elseif osvar == 5 then
                            --偷窃
                        elseif osvar == 6 then
                            --清除
                        end
                    else
                        --单纯显示
                        self.clicktime = os.time()
                        if not self.componeents["home2"] then
                            local _component = UIPackage.CreateObject("head" , "Component11")
                            _component.x = (self.headBar.width -  _component.width)/2
                            _component.y = self.headBar.height
                            self.componeents["home2"] = _component
                            self.headBar:AddChild(_component)
                            
                        end
                        self.componeents["home2"]:GetChild("n1").text = string.format(language.home57,self.data.ext02)
                        self.componeents["home2"]:GetChild("n2").text = string.format(language.home93,self.data.ext02)
                        self.componeents["home2"]:GetChild("n3").url = nil
                        self.componeents["home2"].visible = true

                        mgr.HomeMgr:visibleOther(self)
                        if cache.HomeCache:getisSelfHome() then
                            --显示 种植 和升级按钮
                            local view = mgr.ViewMgr:get(ViewName.HomeOS)
                            if not view then
                                mgr.ViewMgr:openView2(ViewName.HomeOS,{data = self.data})
                            else
                                view:initData({data = self.data})
                            end
                        end
                    end
                end
            else

                local osvar = cache.HomeCache:getOsTye()
                if osvar then
                    if osvar == 1 then
                        if not cache.HomeCache:getisSelfHome() then
                            return
                        end
                        --如点击已种植灵田则飘字提示“当前无空闲灵田”
                        GComAlter(language.home52)
                    elseif osvar == 2 then
                        --浇水
                        mgr.HomeMgr:doWater(self.data)
                    elseif osvar == 5 then
                        --偷窃
                        mgr.HomeMgr:doSteal(self.data)
                    elseif osvar == 6 then
                        mgr.HomeMgr:doClear(self.data)
                    end
                else
                    if not cache.HomeCache:getisSelfHome() then
                        return
                    end
                    self.clicktime = os.time()
                    local var = self.data.attris[605]+self.data.attris[606]- mgr.NetMgr:getServerTime()
                    if self.componeents["home2"] then
                        if self.componeents["home2"].visible and var <= 0 then
                            local _view = mgr.ViewMgr:get(ViewName.HomeMainView)
                            if _view  then
                                _view:getOne(self.data)
                            end  
                        else
                            self.componeents["home2"].visible = true
                            mgr.HomeMgr:visibleOther(self)
                        end

                    end

                    if not self.componeents["home2"] then
                        local _component = UIPackage.CreateObject("head" , "Component11")
                        _component.x = (self.headBar.width -  _component.width)/2
                        _component.y = self.headBar.height
                        self.componeents["home2"] = _component
                        self.headBar:AddChild(_component)
                    end
                    
                    local mConf = conf.HomeConf:getSeedByid(self.data.mId)

                    local lab1 = self.componeents["home2"]:GetChild("n1")
                    local lab2 = self.componeents["home2"]:GetChild("n2")
                    if var > 0 then
                        lab1.text = string.format(language.home57,self.data.ext02)
                        lab2.text = "" 
                        
                    else
                        lab1.text = language.home46
                    end
                    self.componeents["home2"].visible = true
                    self.componeents["home2"]:GetChild("n3").url = UIItemRes.home2..mConf.icon 
                    mgr.HomeMgr:visibleOther(self)
                    local view = mgr.ViewMgr:get(ViewName.HomeOS)
                    if not view then
                        mgr.ViewMgr:openView2(ViewName.HomeOS,{data = self.data})
                    else
                        view:initData({data = self.data})
                    end
                    --mgr.ViewMgr:openView2(ViewName.HomeOS,{data = self.data})
                end
            end
        else

        end
    end
end

--添加组件
function Widget:createHead(param)
    self:clearComponents()
    local pack = "head"
    local kind = self.data and self.data.kind or 0
    --血条隐藏
    self.bloodBar.visible = false
    self.headBar:GetChild("n6").visible = false
    local component = nil
    if kind == WidgetKind.mb then--墓碑
        if not self.componeents["mb"] then
            component = UIPackage.CreateObject(pack , "MubeiView")
            self.componeents["mb"] = component
        end  
    elseif kind == WidgetKind.tree then--姻缘树
        if not self.componeents["tree"] then
            component = UIPackage.CreateObject(pack , "MarryiageTreeView")
            self.componeents["tree"] = component
        end  
    elseif kind == WidgetKind.home then --家园
        local condata = conf.HomeConf:getHomeThing(self.data.ext01)
        if condata.type == 5 then
            if self.data.ext02 == 0 
                and not self.componeents["home1"] 
                and (param and param.homeKuajian) then
                --拓建
                local _component = UIPackage.CreateObject("head" , "Component10")
                self.componeents["home1"] = _component
                _component.x = (self.headBar.width -  _component.width)/2
                _component.y = 170
                self.headBar:AddChild(_component)
            end
            local _component = UIPackage.CreateObject("head" , "Component15")
            self.componeents["home3"] = _component
            _component:GetChild("n0").text = ""
            _component.x = (self.headBar.width -  _component.width)/2
            _component.y = 240
            self.headBar:AddChild(_component)

            --添加一个时间显示的东西
            if not self.componeents["home4"] then
                self.componeents["home4"] = UIPackage.CreateObject("head" , "Component1")
                self.componeents["home4"].x = (self.headBar.width -  self.componeents["home4"].width)/2
                self.componeents["home4"].y = self.headBar.height + 65
            end
            self.componeents["home4"]:GetChild("n0").text = "" 
            self.headBar:AddChild(self.componeents["home4"])   
        end

    end
    if component then
        component.x = (self.headBar.width -  component.width)/2
        component.y = self.headBar.height - component.height
        self.headBar:AddChild(component)
        self:setMbData()
        self:setTreeData()
    end
end

function Widget:setMbData()
    local component = self.componeents["mb"]
    if component then
        self.mbTimeText = component:GetChild("n0")--墓碑倒计时
        component:GetChild("n1").text = self.data.name
    end
    
end
--设置姻缘树数据
function Widget:setTreeData()
    local component = self.componeents["tree"]
    if component then
        local data = self.data
        local mConf = conf.MonsterConf:getInfoById(data.mId)
        if mConf then
            local name = component:GetChild("n9")
            if self.data.name == "" then
                name.text = mConf.name
            else
                name.text = self.data.name.."的"..mConf.name
            end
        end
        self.createTime = data.ext02
        self.treeHead = component:GetChild("n14")
        local heights = conf.MarryConf:getValue("tree_starus_height")
        self.treeHead.y = heights[1]
        self.treeListView = component:GetChild("n12")
        self.treeTimeText = component:GetChild("n8")

        local tipImg = component:GetChild("n10")
        local coupleName = cache.PlayerCache:getCoupleName()
        if coupleName == "" or data.name == "" then
            tipImg.visible = false
        else
            if data.name == coupleName or data.name == cache.PlayerCache:getRoleName() then
                tipImg.visible = true
            else
                tipImg.visible = false
            end
        end
    end
end
--清理姻缘树
function Widget:clearTree()
    self.treeListView = nil
    self.treeTimeText = nil
end



--设置外部
function Widget:setSkins(body)
    if body then
        local resPath = ""
        if self.data.kind == WidgetKind.home then
            resPath = ResPath.npcRes(body) 
        else
            resPath = ResPath.monsterRes(body)
        end
        self.character.BodyID = resPath
        cache.ResCache:addMonsterCache(resPath)
    end
    self.isAppear = true
end
--显示
function Widget:appear()
    if not self.isAppear then
        self:setSkins(self.bodySrc)
    end
end

--这个部件的倒计时
function Widget:update()
    self:updateMb()
    self:updateTree()
    --plog("self.data.ext01",self.data.ext01,self.data.mId)
    self:updateHome()
end

function Widget:updateHome()
    -- body
    
    if self.data.kind ~= WidgetKind.home then
        return
    end
    local condata = conf.HomeConf:getHomeThing(self.data.ext01)
    if condata and condata.type == 5 then
        if self.data.mId~=0 then
            local cc = conf.HomeConf:getSeedByid(self.data.mId)
            if self.data and self.data.attris and self.data.attris[606] then
                local var = self.data.attris[605]+self.data.attris[606]- mgr.NetMgr:getServerTime()
                var = math.max(0,var)
                if self.componeents["home4"] then
                    local _tx = self.componeents["home4"]:GetChild("n0") 
                    if var > 0 then
                        _tx.text = GTotimeString4(var)
                    else
                        _tx.text = ""
                    end
                end
                if self.componeents["home2"] then
                    var = math.max(0,var)
                    local lab = self.componeents["home2"]:GetChild("n2")
                    if var > 0 then
                        lab.text = GTotimeString4(var)
                        
                    else
                        local _view = mgr.ViewMgr:get(ViewName.HomeMainView)
                        if _view then
                            _view:setRedPoint()
                        end

                        lab.text = language.home59
                        --修改种子模型
                        if self.bottomEffectID ~= cc.src[2] then
                            self:addBottomEffect(cc.src[2])
                        end
                    end
                end
                --被偷了几次
                if self.componeents["home3"] then
                    if var <= 0 then
                        local str = language.home99
                        if self.data.attris[608] and self.data.attris[608]>0 then
                            str = str .. "\n"..string.format(language.home100,self.data.attris[608]) 
                        end
                        self.componeents["home3"]:GetChild("n0").text = str
                    else
                        self.componeents["home3"]:GetChild("n0").text = ""
                    end
                end
            end
        else
            if not self.clicktime then
                return
            end
            if not self.componeents["home2"] then
                return
            end
            local cc = conf.HomeConf:getValue("lingtian_keeptime") or 5
            if os.time() - self.clicktime > cc then
                self.clicktime = nil
                self.componeents["home2"].visible = false
            end
        end  
    end
end

function Widget:updateMb()
    if self.componeents["mb"] then
        if self.mbTimeText then
            local endTime = self.data.ext01
            local time = endTime - mgr.NetMgr:getServerTime()
            self.mbTimeText.text = GTotimeString(time)
        end
    end
end

function Widget:updateTree()
    if self.componeents["tree"] then--姻缘树
        if self.createTime then
            local step = 1
            local leftTime = 0
            local timeTabs = conf.MarryConf:getValue("marry_tree_step_time")
            for k,v in pairs(timeTabs) do
                local time = mgr.NetMgr:getServerTime() - self.createTime
                local timeBegan = v[1]
                local timeEnd = v[2]
                if time >= timeBegan and time < timeEnd then
                    step = k
                    leftTime = timeEnd - time
                    break
                end
            end
            -- plog("树的状态",step,mgr.NetMgr:getServerTime(),self.createTime)
            local index = step + 1
            if index >= #language.marryiage14 then
                index = #language.marryiage14
            end
            local str = string.format(language.marryiage13, leftTime)..language.marryiage14[index]
            if self.treeTimeText then
                self.treeTimeText.text = str
            end
            self.treeStep = step--第几阶段
            --阶段性改变外观
            local mConf = conf.MonsterConf:getInfoById(self.data.mId)
            
            local culture = self.data.ext01--培养次数
            if self.treeListView.numItems ~= culture then
                self.treeListView.numItems = culture
            end
            if mConf then
                local stepSrc = mConf.step_src
                if stepSrc then
                    local treeStarus = conf.MarryConf:getValue("tree_starus")
                    local starus = 1
                    for k,v in pairs(treeStarus) do
                        if culture >= v[1] and culture <= v[2] then
                            starus = k
                            break
                        end
                    end
                    if self.bodySrc ~= stepSrc[starus] then
                        local heights = conf.MarryConf:getValue("tree_starus_height")
                        self.treeHead.y = heights[starus]
                        self.bodySrc = stepSrc[starus]
                        self:setSkins(self.bodySrc)
                    end
                end
            end
        end
    end
end

function Widget:addBottomEffect(id)
    -- body
    self.bottomEffectID = id
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffect = nil 
    end
    local bodyTransform = self.character.mRoot.mTransform
    self.bottomEffect = mgr.EffectMgr:playCommonEffect(id, bodyTransform)
    self.bottomEffect.LocalRotation = StaticVector3.vector3Z180
    self.bottomEffect.Scale = Vector3.one
    self.bottomEffect.LocalPosition = StaticVector3.home
    self.bottomEffect:AutoRotation(self:getID(), self.tType)
end

function Widget:setTreeCont(count)
    self.data.ext01 = count-- body
end

function Widget:addTreeEffect()
    local effect = mgr.EffectMgr:playCommonEffect(4040132, self:getRoot())
    effect.LocalPosition = Vector3.zero
end
--姻缘树的操作阶段
function Widget:getTreeStep()
    return self.treeStep or 1
end

function Widget:clearComponents()
    --移除多余添加控件
    for k ,v in pairs(self.componeents) do
        self.headBar:RemoveChild(v)
        v:Dispose()
        self.componeents[k] = nil 
    end
end

function Widget:dispose()
    if self.timer then
        mgr.TimerMgr:removeTimer(self.timer)
        self.timer = nil
    end
    if self.bottomEffect then
        mgr.EffectMgr:removeEffect(self.bottomEffect)
        self.bottomEffectID = nil
    end 
    self:clearComponents()
    self.super.dispose(self)
    self:clearTree()
end

return Widget