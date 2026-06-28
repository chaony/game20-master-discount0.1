local M = class("BossFightRewardView",LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/BossFight/BossFightReward"
M.m_size_type = 2


--积分赛  晋级赛
local __TAB_BTN_NODE1 = {
	{ btn_key = "tog_5", btn_text = "tog_5_text", text_key = "game_of_heaven_and_earth_reward_text_010", type = -1 },
	{ btn_key = "tog_1", btn_text = "tog_1_text", text_key = "game_of_heaven_and_earth_reward_text_002", type = 0 },
	{ btn_key = "tog_2", btn_text = "tog_2_text", text_key = "game_of_heaven_and_earth_reward_text_003", type = 2 },
}
--天赛 地赛
local __TAB_BTN_NODE2 = {
	{ btn_key = "tog_3", btn_text = "tog_3_text", text_key = "game_of_heaven_and_earth_reward_text_004", type = 2 },
	{ btn_key = "tog_4", btn_text = "tog_4_text", text_key = "game_of_heaven_and_earth_reward_text_005", type = 3 },
}

local __TAB_BTN_NODE2_COLOR = { Color(86 / 255, 52 / 255, 42 / 255), Color(58 / 255, 72 / 255, 94 / 255) }


function M:onEnter()
	self.m_race_type = -1
	self.m_type_type = 2
	self:setTextByLanKey("common_title_text", "game_of_heaven_and_earth_reward_text_001")
	for k, v in pairs(__TAB_BTN_NODE1) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_open_tab_index then
			--选中的那个
			tog_btn.isOn = true
			self.m_race_type = v.type
		end
		UIUtil.addToggleListener(tog_btn, function(is_on)
			self:switchTabUpdate1(is_on, k, v)
		end, nil, self.m_uiName)
	end

	for k, v in pairs(__TAB_BTN_NODE2) do
		self:setTextByLanKey(v.btn_text, v.text_key)
		local tog_btn = self:findToggle(v.btn_key)
		if k == self.m_model.m_select_type_index then
			--选中的那个
			tog_btn.isOn = true
			self.m_type_type = v.type
		end
		self:setTextColor(v.btn_text,k == self.m_model.m_open_tab_index and  __TAB_BTN_NODE2_COLOR[1] or __TAB_BTN_NODE2_COLOR[2])
		UIUtil.addToggleListener(tog_btn, function(is_on)
			self:switchTabUpdate2(is_on, k, v)
		end, nil, self.m_uiName)
	end
	self:refreshUI()
	
	self:setTextByLanKey("common_title_text", "boss_fight_reward_text_001")
end

function M:refreshUI()
	self:setTextByLanKey("name_text", "boss_fight_reward_text_003")
	self:setTextByLanKey("desc_text","boss_fight_reward_text_002")
	--设置排名的文字
	if self.m_model.m_rank == 0 or self.m_model.m_count == 0 then
		self:setTextByLanKey("rank_nums_text","boss_fight_reward_text_005")
	else
		local value = self.m_model.m_rank/self.m_model.m_count
		self:setTextByLanKey("rank_nums_text","boss_fight_reward_text_004",value)		
	end
	self:updateBossLoopScroll()
	self:updateLoopScroll()

	self:setObjectVisible("race_reward_node", self.m_race_type ~= -1)
	self:setObjectVisible("boss_reward_node", self.m_race_type == -1)
end

--[[
	创建列表
]]
function M:updateBossLoopScroll()
    local data = self.m_model:getReward(-1)
	if self.m_boss_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateBossRewardItemInfo(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", {id = index})
			end,
            ui_name = self.m_uiName
		}
		self.m_boss_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_boss_loop_scroll_view:reloadData(data)
	end
end

function M:updateBossRewardItemInfo(cell_object, celldata)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	if luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"top_three_rank_img",false)
		if #celldata.rank == 1 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_text", celldata.rank[1])
		elseif #celldata.rank >= 2 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_text", celldata.rank[1].." - "..celldata.rank[2])
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"rank_text", "0")
		end
		local reward_node = luaBehaviour:FindGameObject("reward_node")
		GameUtil:createRewards(reward_node.transform, celldata.reward, true, true)
	end
end



function M:switchTabUpdate1(is_on, update_key, data)
	if is_on then
		self:updateMsg("race", { key = update_key, value = data })
	end
end

function M:switchTabUpdate2(is_on, update_key, data)
	if is_on then
		self:updateMsg("type", { key = update_key, value = data })
	end
	self:setTextColor(data.btn_text,is_on and __TAB_BTN_NODE2_COLOR[1] or __TAB_BTN_NODE2_COLOR[2])
end


--[[
	创建列表
]]
function M:updateLoopScroll()
	local type = self.m_race_type + self.m_type_type
	local data = self.m_model:getReward(type)
	if self.m_race_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("race_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateRaceRewardItemInfo(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", { id = index })
			end,
			ui_name = self.m_uiName
		}
		self.m_race_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_race_loop_scroll_view:reloadData(data)
	end
end

function M:updateRaceRewardItemInfo(cell_object, celldata)
	local luaBehaviour = cell_object:GetComponent("LuaBehaviour")
	if luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
		if #celldata.rank == 1 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank[1])
		elseif #celldata.rank >= 2 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", celldata.rank[1] .. " - " .. celldata.rank[2])
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "0")
		end
		local reward_node = luaBehaviour:FindGameObject("reward_node")
		GameUtil:createRewards(reward_node.transform, celldata.reward, true, true)
	end
end

return M