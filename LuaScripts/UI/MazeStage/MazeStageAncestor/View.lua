local M = class("MazeStageAncestorView",LikeOO.OOPopBase)

M.m_uiName = "MazeStage/MazeStageAncestor"
M.m_size_type = 2

function M:onEnter()
	--前往或挑战
	--if self.m_model.m_cell_data.status == 0 then
	--	self:setTextByLanKey("ok_btn_text", "new_str_0029")
	--else
		self:setTextByLanKey("ok_btn_text", "new_str_0167")
	--end
	self:setTextByLanKey("reward_title_text", "new_str_0389")
	self:setObjectVisible("ok_btn", self.m_model.m_open_flag == true)
	self:setObjectVisible("hero_name_text", false)
	
	local cell_type = self.m_model.m_cell_data.type
	local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
	local maze_cell_type_item = maze_cell_type[cell_type] or {}
	local explain = maze_cell_type_item.explain or "???"
	self:setTextByLanKey("tips_text", explain)
	self:setTextByLanKey("common_title_text", maze_cell_type_item.name or "???")
	if self.m_model.m_cell_data.type == 10 then --10.怨灵马车
		-- self:setTextByLanKey("common_title_text", "new_str_0168")
		-- self:setTextByLanKey("tips_text", "new_str_0171")
	elseif self.m_model.m_cell_data.type == 11 then -- 11.宝藏洞窟
		-- self:setTextByLanKey("common_title_text", "new_str_0169")
		-- self:setTextByLanKey("tips_text", "new_str_0170")
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
    -- 奖励
	local drop = self.m_model:getShowRewardData()
	local reward_node = self:findGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, drop, true, true, nil, 0.65)
	self:setTextByLanKey("combat_num_text", tostring(self.m_model.m_total_combat))
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowHeroData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("ItemNode")
				-- local ui_element = CommonUIUtil:updateHeroElementByData(item_node, cell_data)
				local ui_element = GameUtil:updateItemElementByData(item_node, cell_data)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lv_text", cell_data.lv)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_name_text", cell_data.item_cfg.name)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M