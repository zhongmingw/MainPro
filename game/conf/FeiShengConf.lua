--
-- Author: 
-- Date: 2018-08-22 16:39:08
--
local FeiShengConf = class("FeiShengConf",base.BaseConf)

function FeiShengConf:init()
    self:addConf("fs_global")
    self:addConf("fs_lev_up")
    self:addConf("fs_xl_exchange")
    self:addConf("fs_xl_lev_up")
    self:addConf("xl_diff_lev_repress")
    self:addConf("fs_attach_attr")
end

function FeiShengConf:getValue(id)
    -- body
    return self.fs_global[tostring(id)]
end

function FeiShengConf:getLevUpItem(id)
    -- body
    return self.fs_lev_up[tostring(id)]
end

function FeiShengConf:getXlexchangeItem(id)
    -- body
    return self.fs_xl_exchange[tostring(id)]
end

function FeiShengConf:getXlLevUpItem(id)
    -- body
    return self.fs_xl_lev_up[tostring(id)]
end

function FeiShengConf:getdiffLevItem(id)
    -- body
    return self.xl_diff_lev_repress[tostring(id)]
end

function FeiShengConf:getFsAttachattr(id )
    -- body
    return self.fs_attach_attr[tostring(id)]
end
return FeiShengConf