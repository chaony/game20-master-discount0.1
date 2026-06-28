local M = class("LibraryView",LikeOO.OOPopBase)

M.m_uiName = "Library/Library"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0336")
	self:setTextByLanKey("ok_btn_text", "new_str_0337")
	self:setTextByLanKey("detail_btn_text", "new_str_0338")
	self.m_talk_node = self:findGameObject("talk_node")
	self.m_gray_image = self:findImage("gray_image")
	self:setObjectVisible("talk_node", true)
	self:setObjectVisible("info_node", false)
	self:setRandomTalkInfo()
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_model.m_select_data = nil
	self.m_select_cell = nil
	local data = self.m_model:getShowData()
	self:setObjectVisible("right_btn", #data > 3)
	self:setObjectVisible("left_btn", #data > 3)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 3,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
				if self.m_select_cell then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell)
					LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "gzcg_jiban_a", "library_ui")
				end
				self.m_model.m_select_data = cell_data
				self.m_select_cell = cell_object
				self.m_select_index = index
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "gzcg_jiban_b", "library_ui")
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:loopScrollMoveToCellIndex(add_value)
	if self.m_loop_scroll_view then
		self.m_loop_scroll_view:moveHorizontalPage(add_value)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local cell_data = cell_data
    local data = cell_data.data
    local cfg = cell_data.cfg
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(cfg.name))
	if self.m_select_index == index then
		self.m_model.m_select_data = cell_data
		self.m_select_cell = cell_object
		self:setSelectLibraryInfo(cell_data)
		LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "gzcg_jiban_b", "library_ui")
	else
		LuaBehaviourUtil.setImg(luaBehaviour, "icon_img", "gzcg_jiban_a", "library_ui")
	end
end

function M:setSelectLibraryInfo(cell_data)
	local cfg = cell_data.cfg
	local data = cell_data.data
	self:setObjectVisible("talk_node", false)
	self:setObjectVisible("info_node", true)
	self:setTextByLanKey("title_name_text", tostring(cfg.name))
	self:setTextByLanKey("detail_text", tostring(cfg.des))
	local hero_ids = cfg.hero_ids or {}
	local heros_node = self:findGameObject("heros_node")
	local troop_heroes = data.troop_heroes or {}
	local team_heros_data = {}
	for k,v in ipairs(hero_ids) do
		local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, v, 0})
		local troop_heroes_data = troop_heroes[tostring(v)]
		data.activation = troop_heroes_data ~= nil
		data.quality = troop_heroes_data and troop_heroes_data.evo or cfg.evo
		table.insert(team_heros_data, data)
	end
	
	local function update_func(item_obj, item_data)
		local luaBehaviour = UIUtil.findLuaBehaviour(item_obj)
		local item_img = luaBehaviour:FindImage("item_img")
		local quality_img = luaBehaviour:FindImage("quality_img")
		if item_data.activation then
			item_img.material = nil
			quality_img.material = nil
		else
			item_img.material = self.m_gray_image.material
			quality_img.material = self.m_gray_image.material
		end
	end
	GameUtil:createTeamHeros(heros_node.transform, team_heros_data, false, false, nil, 0.7, update_func)
end

function M:setRandomTalkInfo()
	if self.m_talk_node.activeSelf then
		local talk_word = self.m_model:getTalkWord()
		self:setTextByLanKey("talk_text", tostring(talk_word))
	end
end

return M