local M = class("PetBreedingInteractionRewardsView", LikeOO.OOPopBase)

M.m_uiName = "PetBreeding/PetBreedingInteractionRewards"
M.m_size_type = 2


function M:onEnter()
    self:setText("common_title_text", "")
    self:setTextByLanKey("item_name_text", "tid#InteractGift_01")
    self:setTextByLanKey("item_des_text", "tid#InteractGift_02")
    self:updateLoopScroll()
end

function M:updateLoopScroll()
    local data = self.m_model.m_rewards
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 7,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                GameUtil:updateItemElement(cell_object, cell_data, true, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end,
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
        if self.m_control.m_load_end == true then
            self:pullRefreshListOffset()
        end
    end
end

return M