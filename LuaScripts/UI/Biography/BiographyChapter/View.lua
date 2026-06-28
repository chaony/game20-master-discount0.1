local M = class("BiographyChapterView",LikeOO.OOPopBase)

M.m_uiName = "Biography/BiographyChapter"
M.m_size_type = 2

function M:onEnter()
	local biography_chapter = ConfigManager:getCfgByName("biography_chapter")
	local chapter_cfg = biography_chapter[self.m_model.m_chapter]
	self:setTextByLanKey("common_title_text", chapter_cfg.name)
	self:setTextByLanKey("enemy_team_text", "biography_str_006")
	self:setTextByLanKey("reward_text", "biography_str_007")
	self:createStage()
	self:resfreshUI()
end

function M:resfreshUI()
	self:refreshStageInfo()
end

function M:createStage()
	local stage_nodes = self:findGameObject("stage_nodes")
	UIUtil.destroyAllChild(stage_nodes.transform)
	self.m_stage_table = {}
	local biography_chapter = ConfigManager:getCfgByName("biography_chapter")
	local biography_stage = ConfigManager:getCfgByName("biography_stage")
	local chapter_cfg = biography_chapter[self.m_model.m_chapter]
	for i,v in ipairs(chapter_cfg.group or {}) do
		local stage_cfg = biography_stage[v]
		local stage_node = GameUtil:createPrefab("Biography/BiographyStageNode", stage_nodes.transform)
		UIUtil.setLocalPosition(stage_node,stage_cfg.pos[1],stage_cfg.pos[2])
		UIUtil.setButtonClick(stage_node.transform, handler(self,self.stageClickFunc), v, "stage_btn")
		self.m_stage_table[v] = stage_node
	end
	self:refreshStageInfo()
end

function M:stageClickFunc(obj, data)
	self:updateMsg("stage_click", data)
end

function M:refreshStageInfo()
	for k,v in pairs(self.m_stage_table) do
		local luaBehaviour = UIUtil.findLuaBehaviour(v)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"select_img", k == self.m_model.m_cur_stage)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"battle_img", k == self.m_model.m_battle_stage)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"UI_Biography_BiaoJi_001", k == self.m_model.m_battle_stage)
		local stage_img = v:GetComponent("Image")
		if k > self.m_model.m_stage then
			stage_img.color = Color(1,1,1,0.5)
		else
			stage_img.color = Color(1,1,1,1)
		end
	end
	local biography_stage = ConfigManager:getCfgByName("biography_stage")
	local stage_cfg = biography_stage[self.m_model.m_cur_stage]
	if stage_cfg then
		self:setTextByLanKey("stage_title_text", stage_cfg.name)
		self:setTextByLanKey("stage_des_text", stage_cfg.des)
		self:updateHeroScroll()
		self:updateRewardScroll(stage_cfg.reward)
	end

	if self.m_model:stageIsDone(self.m_model.m_cur_stage) then
		self:setTextByLanKey("look_btn_text", "biography_str_003")
		self:setObjectVisible("look_btn", true)
		self:setObjectVisible("battle_btn", false)
	elseif self.m_model.m_cur_stage == self.m_model.m_stage then
		self:setTextByLanKey("battle_btn_text", "new_str_0386")
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("battle_btn", true)
	else
		self:setTextByLanKey("battle_btn_text", "rpg_scroll_3")
		self:setObjectVisible("look_btn", false)
		self:setObjectVisible("battle_btn", true)
	end
end

function M:updateHeroScroll()
	local data = self.m_model:getStageEnemy()
	if self.m_hero_scroll == nil then
		local list_scroll = self:findGameObject("hero_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				CommonUIUtil:updateHeroElement(transform, data, false)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_hero_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_hero_scroll:reloadData(data)
	end
end

function M:updateRewardScroll(data)
	local data = data or {}
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("reward_scroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				GameUtil:updateItemElement(transform, data, true, true)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

return M