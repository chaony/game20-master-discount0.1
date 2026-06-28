local M = class("FamilyDinnerTaskPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/FamilyDinner/FamilyDinnerTaskPop"
M.m_size_type = 2


function M:onEnter()
    self:refreshUI()
    self:setTextByLanKey("common_title_text", "qi_men_dun_jia_str_007")
end

--刷新UI
function M:refreshUI()
	self:createRewardLoopScroll()
end

----创建奖励列表------------------------------------------------------------------------------------------
function M:createRewardLoopScroll()
    local data = self.m_model.ranks_rewards
    if self.m_scroll_view2 == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("get_reward", cell_data)
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
        local reward_node = luaBehaviour:FindGameObject("reward_node")
        GameUtil:createRewards(reward_node.transform, data.data.reward,true,true)
        local des = self.m_model.m_value_des == "" and "family_dinner_text003" or self.m_model.m_value_des
        des = Language:getTextByKey(des)
        local des2 = self.m_model.m_value_own == "" and "family_dinner_text004" or self.m_model.m_value_own
        des2 = Language:getTextByKey(des2)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "family_dinner_text001", des, data.data.score)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "own_text", "family_dinner_text005", des2, data.data.personal_score or "0" )
        local task_type = self.m_model:getTaskData(data.id, data.data.score,data.data.personal_score)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn_text", false)
        if task_type == 0 then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn_text", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0057")
        elseif task_type == 1 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_btn_text", "new_str_0056")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", true)
        elseif task_type == 2 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "goto_btn_text", "new_str_0562")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "goto_btn_text", true)
        end
    end    
end

return M