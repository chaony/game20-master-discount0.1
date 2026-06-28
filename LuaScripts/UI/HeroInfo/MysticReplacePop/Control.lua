local M=class("MysticReplacePopControl",LikeOO.OOControlBase)

function M:onHandle(msg,data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView()
    --elseif msg=="replace_equip" then
    --    local function callfunc()
    --        self:updateMsg("update_mystic",{state = "up",pos = self.m_model.m_pos},"HeroBag")
    --        self:updateMsg(99999)
    --    end
    --    self.m_model:getNetData("hero_mystic_wear",{hero_oid = self.m_model.m_heroid, pos = self.m_model.m_pos ,mystic_id = data.id, mystic_owner = data.owner}, callfunc)
    end
end
return M