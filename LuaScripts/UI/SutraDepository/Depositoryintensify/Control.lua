local M = class("DepositoryintensifyControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.SutraDepository.Depositoryintensify.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "ok_btn" then
        local params = {slot_id = self.m_model.mystic_type}
        self:slotUpLv(params)
    end
end

function M:slotUpLv(params)
    local function evolutionCallback(response)
        self.m_view:show_effect(response)
        self:updateMsg("update_data", response, "SutraDepository")
        audio:SendEvtUI("UI_Property_LevelUp")
    end
    self.m_model:getNetData("mystic_slot_up_lv", {slot_id = self.m_model.mystic_type}, evolutionCallback)
end

return M
