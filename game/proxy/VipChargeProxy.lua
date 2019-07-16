local VipChargeProxy = class("VipChargeProxy",base.BaseProxy)

function VipChargeProxy:init()
	self:add(5130101,self.returnRechargeList)--请求充值档次返回
	self:add(5130102,self.returnFirstGetVip)  --请求首次领取vip1返回
	self:add(5130103,self.returnVipPrivilege) --请求vip特权返回
	self:add(5130104,self.add5130104)         --请求白银仙尊卡体验
	self:add(5130105,self.add5130105)         --请求vip升级返回
	-- self:add(5130104,self.returnVipAwards)--请求vip礼包返回
	-- self:add(5130105,self.returnVipAwardsBuy) --请求领取vip礼包返回
	self:add(5130106,self.add5130106)         --折扣礼包
end

--请求充值档次
function VipChargeProxy:sendRechargeList()
	-- body
	self:send(1130101)
end

--请求首次领取vip1
function VipChargeProxy:sendFirstGetVipMsg()
	-- body
	self:send(1130102)
end

--请求VIP折扣显示数据
function VipChargeProxy:sendDiscountedPacksMsg()
	-- print("vip折扣消息已发送！")
	self:send(1130106,{reqType=0})
end

--请求vip特权
function VipChargeProxy:sendVipPrivilege(reqType,vipType)
	-- body
	self.reqType = reqType
	self.vipType = vipType
	local param = {reqType = reqType,vipType = vipType}
	self:send(1130103,param)
end

--请求vip升级
function VipChargeProxy:sendVipUpGrade(  )
	self:send(1130105)
end

--请求白银仙尊卡体验
function VipChargeProxy:sendXianzunTy(type,reqType)
	self:send(1130104,{type = type,reqType = reqType})
end

function VipChargeProxy:returnRechargeList( data )
	-- body
	if data.status == 0 then
		cache.VipChargeCache:keepRechargeList(data)
		if g_ios_test then
			local view = mgr.ViewMgr:get(ViewName.VipChargeIOSView) --EVE IOS
			if view then
				view:setData()
			end
		else
			local view = mgr.ViewMgr:get(ViewName.VipChargeView) 
			if view then
				view:setData()
				view.VipChargePanel:setData()
			end
		end
		
		
	else
		GComErrorMsg(data.status)
	end
end

function VipChargeProxy:returnFirstGetVip( data )
	-- body
	if data.status == 0 then
		-- if data.vipLevel > 0 then
		cache.PlayerCache:setAttribute(503, data.vipLevel)
		-- print("激活成功",cache.PlayerCache:getVipLv())
			local view = mgr.ViewMgr:get(ViewName.VipChargeView) --EVE IOS
			if view then
				view.VipAttributePanel:initView()
				view.VipChargePanel:setData()
			end
			-- GComAlter(language.vip16)
		-- end
	else
		GComAlter(language.vip15)
	end
end

function VipChargeProxy:returnVipPrivilege( data )
	-- body
	if data.status == 0 then
		cache.VipChargeCache:keepPrivilegeList(data.activeStatus)
		cache.VipChargeCache:setXianzunTime(data.lastTime)
		local view = mgr.ViewMgr:get(ViewName.XianzunView)
		if self.reqType == 1 then
			local id = nil
			local index = nil
			if self.vipType == 1 then
				local curTime = cache.VipChargeCache:getXianzunTyTime() or 0
				if curTime > 0 then
					cache.VipChargeCache:setXianzunTyTime(-1)
					if view then
						view:setData(data)
					end
					local view = mgr.ViewMgr:get(ViewName.MainView)
					if view and mgr.FubenMgr:isLevel(cache.PlayerCache:getSId()) then--刷新特权信息
						view:setTempData()
						view:setXianzunDiscount()--仙尊卡打折提示
					elseif view then
						view:setXianzunDiscount()--仙尊卡打折提示
						if self.reqType == 1 and self.vipType == 1 then
							cache.VipChargeCache:setXianzunTyTime(nil) --主界面仙尊体验卡提示隐藏
						end
					end
					return
				end
				cache.VipChargeCache:setXianzunTyTime(-1)
				id = 1001007
				index = 5
				if mgr.ModuleMgr:CheckView(1006) then
					if huobanId ~= 3050106 then
						proxy.HuobanProxy:send(1200107,{skinId = 1001007})
			            proxy.HuobanProxy:send(1200105,{skinId = 1001007,reqType = 0})
			        end
			    end
			elseif self.vipType == 2 then
				id = 10010002
				index = 13
			elseif self.vipType == 3 then
				id = {}
				local affectData = conf.VipChargeConf:getAffectDataById(self.vipType)
				id = affectData.model_id
				index = 12
			end
			local data = {id = id,index = index,isXianzun = true}
        	mgr.ViewMgr:openView2(ViewName.GuideZuoqi, data)
		end
		if view then
			view:setData(data)
		end
		local view = mgr.ViewMgr:get(ViewName.MainView)
		if view and mgr.FubenMgr:isLevel(cache.PlayerCache:getSId()) then--刷新特权信息
			view:setTempData()
			view:setXianzunDiscount()--仙尊卡打折提示
		elseif view then
			view:setXianzunDiscount()--仙尊卡打折提示
			if self.reqType == 1 and self.vipType == 1 then
				cache.VipChargeCache:setXianzunTyTime(nil) --主界面仙尊体验卡提示隐藏
			end
		end
	else
		GComErrorMsg(data.status)
	end
end

function VipChargeProxy:add5130104( data )
	-- body
	if data.status == 0 then
		-- print("激活白银体验",data.leftTime)
		if data.leftTime > 0 then
			cache.VipChargeCache:setXianzunTyTime(data.leftTime)
		else
			cache.VipChargeCache:setXianzunTyTime(nil)
		end
		-- local view = mgr.ViewMgr:get(ViewName.VipExperienceView)
		-- if view then
			
		-- end
	else
		GComErrorMsg(data.status)
	end
end

function VipChargeProxy:add5130105( data )
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.VipChargeView) --EVE IOS
		if view and view.VipAttributePanel then
			view.VipAttributePanel:initVipAtt()
			view:vipChargeRedPoint()
		end
	else
		GComErrorMsg(data.status)
	end
end

-- function VipChargeProxy:returnVipAwards( data )
-- 	-- body
-- 	if data.status == 0 then
-- 		local view = mgr.ViewMgr:get(ViewName.VipChargeView)
-- 		view.VipAttributePanel:setData(data)
-- 	else
-- 		GComErrorMsg(data.status)		
-- 	end
-- end

-- function VipChargeProxy:returnVipAwardsBuy( data )
-- 	-- body
-- 	if data.status == 0 then
-- 		local view = mgr.ViewMgr:get(ViewName.VipChargeView)
-- 		if view then
-- 			if self.giftType == 1 then --每日礼包
-- 				view.VipAttributePanel:refreshDayGift(data)
-- 			end
-- 			if self.giftType == 2 then --每周礼包
-- 				view.VipAttributePanel:refreshWeekGift(data)
-- 			end
-- 		end
-- 		GOpenAlert3(data.gotItems)
-- 	else
-- 		GComErrorMsg(data.status)
-- 	end
-- end

--请求折扣礼包
function VipChargeProxy:add5130106(data)
	-- print("vip折扣礼包消息返回成功")
	if data.status == 0 then
		local view = mgr.ViewMgr:get(ViewName.VipChargeView)
		if view and view.VipAttributePanel then
			view.VipAttributePanel:setDiscountedPacksData(data)
			-- view:vipChargeRedPoint()
		end
	else
		GComErrorMsg(data.status)
	end
end

return VipChargeProxy