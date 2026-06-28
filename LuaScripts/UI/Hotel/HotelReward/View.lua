local M = class("HotelRewardView",LikeOO.OOPopBase)

M.m_uiName = "Hotel/HotelReward"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("common_title_text", "hotel_text_006")
	self:setTextByLanKey("des_text", "hotel_text_008")
	self:setTextByLanKey("get_reward_btn_text", "new_str_0056")
    self:setTextByLanKey("got_flag_text", "new_str_0080")
    self:refreshUI()
end

function M:refreshUI()
	self:createRewardLoopScroll()
    self:setObjectVisible("get_reward_btn", self.m_model.m_is_daily_reward == false)
    self:setObjectVisible("got_flag", self.m_model.m_is_daily_reward == true)
end

function M:createRewardLoopScroll()
    local cfg = ConfigManager:getCfgByName("hotel_level")
    local data = cfg[self.m_model.m_level].awards
    if self.m_scroll_view == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 6,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_obj, cell_data)
                GameUtil:updateItemElement(cell_obj, cell_data, true, true)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

return M