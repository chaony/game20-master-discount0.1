---@class DeliciousFeastRankRewardPopView: OOPopBase
---@field m_model DeliciousFeastRankRewardPopModel
local M = class("DeliciousFeastRankRewardPopView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DeliciousFeast/DeliciousFeastRankRewardPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "openServerRank_str_0012")
    self:refreshUI()
end

function M:refreshUI()
    self:updateRankLoopScroll()
end

--[[
	创建排行列表
]]
function M:updateRankLoopScroll()
    local data = self.m_model.m_rankAwards_data
    self:setObjectVisible("common_tips_node", table.nums(data) == 0)
    if self.m_rank_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("rank_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateRankScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                --self:updateMsg(click_name, {id = index, cell_data = cell_data})
            end
        }
        self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_rank_loop_scroll_view:reloadData(data, false)
    end
end

--Scroll内cell的回调
function M:updateRankScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    if luaBehaviour then
        local reward = cell_data.award or {}
        local reward_node = luaBehaviour:FindRectTransform("reward_node")
        GameUtil:createRewards(reward_node, reward, true, true, nil, 1)
        
        local rank = cell_data.rank or {}
        local first_rank = rank[1] or 0
        local second_rank = rank[2] or 0
        local top_three_flag = first_rank > 0 and first_rank < 4
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
        local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[first_rank]
        if top_three_item and top_three_flag then
            LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
        else
            local max_index = self.m_model:getDataCountList()
            if index == max_index then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0894", first_rank)
            else
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", first_rank .. "-" .. second_rank)
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M