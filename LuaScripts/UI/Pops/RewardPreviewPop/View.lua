local M = class("RewardPreviewPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/RewardPreviewPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0724")
	self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getShowRewards()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 7, 
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateLoopScroll(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateLoopScroll(index, obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if self.m_model.m_openType == 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"probability_text", tostring(cell_data.name or ""))
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"probability_text", tostring(cell_data.weight) .. "%")
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Reward_LingQu_003", cell_data.hero == 1)
    GameUtil:updateItemElement(obj, cell_data.reward[1], true, true)
end

function M:destroy()
    M.super.destroy(self)
end

return M