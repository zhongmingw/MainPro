--
-- Author: 
-- Date: 2017-01-22 16:19:23
--
local ShopConf = class("ShopConf",base.BaseConf)

function ShopConf:init()
    self:addConf("personal_shop")--随身商店
    self:addConf("bind_yb_shop") --绑定元宝商城
    self:addConf("yb_shop")      --元宝商城
    self:addConf("yb_shop_gh")      --公会元宝商城
    self:addConf("honor_shop")   --荣誉商城
    self:addConf("pata_shop")    --爬塔商城
    self:addConf("gongxun_shop") --功勋商城
    self:addConf("sw_shop") --声望商城
    self:addConf("weiming_shop") --威名商城
    self:addConf("waresid")      --充值商品id配置
    self:addConf("nuptial_shop") --婚宴商城
    self:addConf("home_shop")    --EVE 家园商店
    self:addConf("week_limit_shop")--VIP周限购bxp
    pcall(function()
        self:addConf("waresid_ext")  --充值商品id配置(不会热更文件)
    end)
end

function ShopConf:getPersonalItem(id)
    local item = self.personal_shop[""..id]
    if not item then 
        self:error(id)
        return nil
    end
    return item
end

function ShopConf:getPersonalShop()
    local data = {}
    for k,v in pairs(self.personal_shop) do
        table.insert(data, v)
    end
    table.sort(data,function(a, b)
        return a.sort < b.sort
    end)
    return data
end

function ShopConf:getYbShopData()
    local data = {}
    local confData = self.yb_shop
    local var = cache.PlayerCache:getRedPointById(10327)
    if G_IsGongHuiID(var) then
        confData = self.yb_shop_gh
    end
    for _,v in pairs(confData) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getBindYbShopData()
    local data = {}
    for _,v in pairs(self.bind_yb_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getHonorShopData()
    -- body
    local data = {}
    for _,v in pairs(self.honor_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getPataShopData()
    -- body
    local data = {}
    for _,v in pairs(self.pata_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getGongXunShopData()
    -- body
    local data = {}
    for _,v in pairs(self.gongxun_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getSwShopData()
    -- body
    local data = {}
    for _,v in pairs(self.sw_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getWmShopData()
    -- body
    local data = {}
    for _,v in pairs(self.weiming_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getWeddingShopData()
    -- body
    local data = {}
    for _,v in pairs(self.nuptial_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getWeddingItemByMid(mId)
    local data = {}
    for _,v in pairs(self.nuptial_shop) do
        if v.mid == mId then
            data = v
            break
        end
    end
    return data
end

function ShopConf:getShangPinID(price)
    if price then
        local info
        if g_var.platform == Platform.ios then
            info = self.waresid[tostring(g_var.packId)]
            --优先读取waresid， 如果没有则搜索waresid_ext。
            if not info and self.waresid_ext then
                info = self.waresid_ext[tostring(g_var.packId)]
            end
            --从后台获取
            if not info and g_var.shopId ~= "" then
                info = self.waresid["0"]
                local index = info["price_"..price]
                local shopId = string.gsub(g_var.shopId,"@",price)
                shopId = string.gsub(shopId,"#",index)
                return shopId
            end
        else
            info = self.waresid[tostring(g_var.channelId)]
        end
        if info then
            return info["price_"..price]
        end
    end
end

--EVE 家园商店
function ShopConf:getJiaYuanShopData()
    -- body
    local data = {}
    for _,v in pairs(self.home_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end

function ShopConf:getJiaYuanShopDataById(id)
    -- body
    return self.home_shop[tostring(id)]
end

--VIP周限购bxp
function ShopConf:getWeekLimitShopData()
    local data = {}
    for _,v in pairs(self.week_limit_shop) do
        table.insert(data,v)
    end
    table.sort(data,function(a,b)
        if a.sort ~= b.sort then
            return a.sort < b.sort
        end
    end)
    return data
end
return ShopConf