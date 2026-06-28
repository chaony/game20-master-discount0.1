local M = class("EquipSublimingControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "close_btn" then
        self:updateMsg(99999)    
    elseif msg == "replace_btn" then
        self:netEvolution()
    end
end

function M:netEvolution()
    local function callfunc()
        -- 升阶成功
        self:updateMsg("update_equip", nil, "HeroInfo")
        self:updateMsg(99999)
    end
    self.m_model:getNetData("eqp_evolution",{ hero_oid = self.m_model.hero_id, pos = self.m_model.m_pos }, callfunc)	
end

return M
