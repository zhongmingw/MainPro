--
-- Author: ohf
-- Date: 2017-02-10 21:05:31
--
--道具属性表
local ItemArriConf = class("ItemArriConf",base.BaseConf)

function ItemArriConf:init()
    self:addConf("item_attri")
end

function ItemArriConf:getItemAtt(id)
    local item = self.item_attri[id..""]
    if not item then
        self:error(id)
        return nil
    end

    return item
end

return ItemArriConf