local M = class("EqpBreakPopControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_Sfx_Stp")
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "big_close_btn" then    -- 返回
        if self.m_model.is_lock == true then
            return
        end
        self:closeView()
    elseif msg == "jump_btn" then
        self:openView("EquipAwaken")
        self:closeView()
    end
end

return M
