local M = class("RoomUpgradeNode",LikeOO.OOUIbase)

M.m_uiName = "Hotel/RoomUpgradeNode"
M.m_iphoneXAdapter = true

function M:onCreate()

end

function M:onEnter()
    self:setTextByLanKey("attr_name_1", "hotel_text_015")
    self:setTextByLanKey("attr_name_2", "hotel_text_016")
    self:setTextByLanKey("attr_name_3", "hotel_text_017")
    self:setTextByLanKey("gain_name", "hotel_text_021")
    self:setTextByLanKey("cost_text", "hotel_text_022")
    self:setTextByLanKey("update_btn_text", "hotel_text_019")
    local room = self.m_model:getSelectRoom()
    self:setTextByLanKey("title", "hotel_text_028", room.name, room.level + 1)
    local cur_cfg, next_cfg = self.m_model:isCanRoomUpgrade(self.m_model.m_select_room)
    local length = 3
    for i = 1, length do
        self:setTextByLanKey("attr_cur_value_" .. i, cur_cfg.attr_aims[i])
        self:setTextByLanKey("attr_next_value_" .. i, next_cfg.attr_aims[i])
    end
    self:setTextByLanKey("gain_cur_value", cur_cfg.run_gain)
    self:setTextByLanKey("gain_next_value", next_cfg.run_gain)
    self:setTextByLanKey("cost_value", next_cfg.up_cost)
end

function M:destroy()
    M.super.destroy(self)
end

return M