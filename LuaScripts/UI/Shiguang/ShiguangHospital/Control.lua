local M = class("ShiguangHospitalControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_cell_data.type == 5 then --5.医馆
            self:updateMsg("shiguang_add_blood", nil, "Shiguang")
        elseif self.m_model.m_cell_data.type == 6 then -- 6.药王庙
            self:updateMsg("shiguang_revive_one", nil, "Shiguang")
        end
        self:closeView()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
