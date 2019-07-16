--
-- Author: wx
-- Date: 2018-09-17 16:04:46
--

local ShenShouZC = class("ShenShouZC",import("game.base.Ref"))

function ShenShouZC:ctor(parent)
    self.parent = parent
    self.view = parent.view:GetChild("n65")
    self:initView()
end

function ShenShouZC:initView()
    -- body
    self.condata = conf.SceneConf:getAllScenesIdByKind(SceneKind.shenshoushengyu)
    table.sort(self.condata,function(a,b)
        -- body
        return a<b
    end)

    self.ssjt_act_sec = conf.FubenConf:getBossValue("ssjt_act_sec")
    self.ssjt_join_max_sec = conf.FubenConf:getBossValue("ssjt_join_max_sec")

    

    self.c2 = self.view:GetController("c2")

    self.btnlist = {}
    local btn1 = self.view:GetChild("n4")
    btn1.onClick:Add(self.onBtnCallBack,self)
    table.insert(self.btnlist,btn1)

    local btn2 = self.view:GetChild("n6")
    btn2.onClick:Add(self.onBtnCallBack,self)
    table.insert(self.btnlist,btn2)

    local btn3 = self.view:GetChild("n3")
    btn3.onClick:Add(self.onBtnCallBack,self)
    table.insert(self.btnlist,btn3)

    local btn4 = self.view:GetChild("n5")
    btn4.onClick:Add(self.onBtnCallBack,self)
    table.insert(self.btnlist,btn4)

    local btn5 = self.view:GetChild("n7")
    btn5.onClick:Add(self.onBtnCallBack,self)
    table.insert(self.btnlist,btn5)

    local btn6 = self.view:GetChild("n14")
    btn6.onClick:Add(self.onBtnCallBack,self)
    self.btn = btn6

    local temp = GGetTimeData(self.ssjt_act_sec[1])
    local temp1 = GGetTimeData(self.ssjt_join_max_sec)
    local temp2 = GGetTimeData(self.ssjt_act_sec[2])
    local str = string.format("%02d:%02d~%02d:%02d",temp.hour,temp.min,temp1.hour,temp1.min)
    local dec1 = self.view:GetChild("n8")
    dec1.text = string.format(language.bangpai205,str) --

    local str = string.format("%02d:%02d~%02d:%02d",temp1.hour,temp1.min,temp2.hour,temp2.min)
    local dec2 = self.view:GetChild("n9")
    dec2.text = string.format(language.bangpai206,str)

    local dec3 = self.view:GetChild("n15")
    dec3.text = string.format(table.concat(language.bangpai207),"")

    local dec4 = self.view:GetChild("n20")
    dec4.text = language.bangpai203

    --self.bossaward = conf.ZhongQiuConf:getGlobal("boss_award")
    self.rewardlist = self.view:GetChild("n19")
    self.rewardlist.itemRenderer = function(index,obj)
        self:cellData(index, obj)
    end
    self.rewardlist.numItems = 0 --#self.bossaward

    self.lablist = {}
    table.insert(self.lablist,self.view:GetChild("n22"))
    table.insert(self.lablist,self.view:GetChild("n24"))
    table.insert(self.lablist,self.view:GetChild("n26"))
    table.insert(self.lablist,self.view:GetChild("n28"))

    self.c1 = self.view:GetController("c1")
    self.c1.onChanged:Add(self.onController1,self)
    self.c1.selectedIndex = 0
    self:onController1()


    
end

function ShenShouZC:cellData(index, obj)
    -- body
    local data = self.bossaward[index+1]
    local t = {}
    t.mid = data[1]
    t.amount = data[2]
    t.bind = data[3] or 1
    GSetItemData(obj, t, true) 
end

function ShenShouZC:onBtnCallBack(context )
    -- body
    if not self.data then
        return
    end

    local btn = context.sender
    local data = btn.data 

    if "n4" == btn.name then
        --青龙
        self.c1.selectedIndex = 0
    elseif "n6" == btn.name then
        --白虎
        self.c1.selectedIndex = 1
    elseif "n3" == btn.name then
        --朱雀
        self.c1.selectedIndex = 2
    elseif "n5" == btn.name then
        --玄武
        self.c1.selectedIndex = 3
    elseif "n7" == btn.name then
        --麒麟
        self.c1.selectedIndex = 4
    elseif "n14" == btn.name then
        --挑战
        -- if cache.PlayerCache:getGangId() == "0" then
        --     local param = {}
        --     param.type = 2 
        --     param.richtext = language.zhangchang07
        --     param.sure = function( ... )
        --         -- body
        --         GOpenView({id = 1013})
        --     end
        --     param.cancel = function( ... )
        --         -- body
        --     end
        --     return GComAlter(param)
        -- elseif self:getTimeStep()~= 1 then
        --     return GComAlter(language.zhangchang06)
        -- end
       
        
        mgr.FubenMgr:gotoFubenWar(self.curSceneInfo.id)
    end
end

function ShenShouZC:getTimeStep()
    -- body
    local temp = os.date("*t",mgr.NetMgr:getServerTime())
    local numtime = temp.hour * 3600 + temp.min * 60 + temp.sec 
    if numtime >= self.ssjt_act_sec[1] and numtime < self.ssjt_join_max_sec then
        --入场时间
       return 1
    elseif numtime >= self.ssjt_join_max_sec and numtime < self.ssjt_act_sec[2] then
        --挑战时间
        return 2
    else
        --活动时间外
        return 0
    end
end

function ShenShouZC:onController1()
    -- body
    local sceneId = self.condata[self.c1.selectedIndex+1]

    self.curSceneInfo = conf.SceneConf:getSceneById(sceneId)
    self.bossaward = self.curSceneInfo.normal_drop
    self.rewardlist.numItems = self.bossaward and #self.bossaward or 0


    
    local step = self:getTimeStep()
    --print("step",step)
    if self.c1.selectedIndex == 4 then
        self.btn.visible = false
    else
        self.btn.visible = true
    end
    if step == 0 then
        self.c2.selectedIndex = 0
    else
        self.c2.selectedIndex = 1
    end
end

function ShenShouZC:addMsgCallBack(data)
    -- body
    if data.msgId == 5331401 then
        self.data = data 


        -- 默认青龙 白虎 朱雀 玄武 麒麟的顺序
        for k ,v in pairs(self.condata) do
            self.btnlist[k].data = v
			if self.lablist[k] then
               -- print(k,v,self.data.sceneRoleNums[v])
				self.lablist[k].text = mgr.TextMgr:getTextColorStr(tostring(self.data.sceneRoleNums[v] or 0), 10)  .. language.zhangchang05
			end
        end
    end
end


return ShenShouZC