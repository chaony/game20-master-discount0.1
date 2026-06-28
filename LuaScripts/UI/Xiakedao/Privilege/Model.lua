---@class PrivilegeModel:OODataBase
local M=class("PrivilegeModel",LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData("hero_isle_privilege_show")
end

function M:onEnter()
    self.visitor=self.m_params.visitor
    self.season=self.m_params.season
    self.m_end_ts=self.m_params.end_ts
   self:refreshData()
end

function M:refreshData()
    self.privilege_bought=self.m_data.privilege_bought
    self.visitor_bought=self.m_data.visitor_bought
end

function M:getVisitorChargeId()
    local cfg=ConfigManager:getCfgByName("hero_isle_visitor")
    local visitor_cfg=cfg[self.season]
    if visitor_cfg==nil then
        visitor_cfg=cfg[-1]
    end
    return visitor_cfg.charge_id
end

function M:getPrivilegeChargeId()
    local cfg=ConfigManager:getCfgByName("hero_isle_privilege")
    local privilege_cfg=cfg[self.season]
    if privilege_cfg==nil then
        privilege_cfg=cfg[-1]
    end
    return privilege_cfg.charge_id
end

return M