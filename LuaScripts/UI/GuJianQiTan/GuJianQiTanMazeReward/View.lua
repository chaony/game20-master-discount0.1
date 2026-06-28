local M = class("GuJianQiTanMazeRewardView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeReward"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("common_title_text", "gu_jian_qi_tan_str_051")
	self:setTextByLanKey("rank_label_text", "gu_jian_qi_tan_str_052")
	self:setTextByLanKey("player_label_text", "gu_jian_qi_tan_str_053")
	self:refreshUI()
end

function M:refreshUI()
	self:createRewardLoopScroll()
end

function M:createRewardLoopScroll()
    local data = self.m_model.ranks_rewards
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
        
            end
        }
        self.m_scroll_view2 = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view2:reloadData(data)
    end
end

function M:updateRewardItem(obj, index, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", data.name or "")
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.finish_reward or {}, true, true)
    end    
end


return M