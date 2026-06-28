local M = class("CollectionPopView",LikeOO.OOPopBase)

M.m_uiName = "MagicWeapon/CollectionPop"
M.m_size_type = 2
--英雄信息
function M:onEnter()
	self:setTextByLanKey("common_title_text","weapon_str_0003")
	self:setTextByLanKey("des_tips_text","weapon_str_0004")
	self:refreshUI()
end

function M:refreshUI()
	self:updateHerosScroll()
	local get_reward_data = self.m_model:getAllRewards()
	if next(get_reward_data) ~= nil then
		local reward_data = RewardUtil:getProcessRewardData(get_reward_data)
		self:setImg(reward_data.icon_name, reward_data.atlas_name, "cost_img")
		self:setTextByLanKey("reward_num_text", reward_data.data_num)
	end
end

function M:updateHerosScroll()
    local data = {}
	for k,v in pairs(self.m_model.m_output) do
		table.insert( data, {id = k, data = v})
	end
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			one_line_count = 6,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
                    local hero_node = luaBehaviour:FindGameObject("HeroNode")
					local hero_data = RewardUtil:getProcessRewardData({101, tonumber(cell_data.id),1})
					local max_evo_data = UserDataManager:getHeroMaxEvo(cell_data.id)
					if max_evo_data then
						hero_data.quality = max_evo_data.max_evo
					end
                    CommonUIUtil:updateHeroElementByData(hero_node, hero_data)
					if next(cell_data.data) ~= nil then
						local reward_data = RewardUtil:getProcessRewardData(cell_data.data[1])
						LuaBehaviourUtil.setImg(luaBehaviour, "money_icon", reward_data.icon_name, reward_data.atlas_name)
						LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_num", "+"..reward_data.data_num)
					end 
                end
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
    
			end,
            ui_name = self.m_uiName,
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data, true)
	end
end




function M:destroy()
    M.super.destroy(self)
end

return M