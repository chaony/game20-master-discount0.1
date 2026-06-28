local M = class("WindAndCloudRewardTaskView", LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudRewardTask"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0110")
	self:refreshUI()
end

function M:refreshUI()
	self:createLoopScroll()
end

--[[
    创建任务列表
]]
function M:createLoopScroll()
    local data = self.m_model:getQuestList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
                if luaBehaviour then
                    local show_num = cell_data.score
                    if show_num > 10000 then
                        show_num = math.ceil(show_num/10000).."W"
                    end
                    local title_name = Language:getTextByKey("wind_clouds_text_0003",show_num)
                    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_des_text", title_name)
                    local reward_node = luaBehaviour:FindGameObject("reward_node")
                    if reward_node then
                        GameUtil:createRewards(reward_node.transform, cell_data.reward, true, true)
                    end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end



return M