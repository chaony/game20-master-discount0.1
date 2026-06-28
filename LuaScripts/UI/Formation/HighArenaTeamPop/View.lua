local M = class("HighArenaTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "Formation/HighArenaTeamPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0258")
	self:setTextByLanKey("order_btn_text", "new_str_0266")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("ok_btn_text", "new_str_0267")
	local left_headNode = self:findGameObject("left_headNode")
	local user_data = UserDataManager.user_data.user_status
	GameUtil:setUserAvatar(left_headNode,user_data, nil, nil,{show_flag = true, scale = 1})
	self:setText("left_name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
	self:initRihtHeadNode()
	self:refreshUI(true)
end

function M:initRihtHeadNode()
	local right_headNode = self:findGameObject("right_headNode")
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
		GameUtil:setUserAvatar(right_headNode,self.m_model.m_defender_user,false,nil,{show_flag = true, scale = 1})
		self:setTextByLanKey("right_name_text", self.m_model.m_defender_user.name)
	else
		GameUtil:setUserAvatar(right_headNode,self.m_model.m_def_data.user,true,nil,{show_flag = true, scale = 1})
		self:setTextByLanKey("right_name_text", self.m_model.m_def_data.user.name)
	end
end

local team_index_name = {"arena_str_0012", "arena_str_0013", "arena_str_0027"}
local team_index_name2 = {"mult_stage_text001", "mult_stage_text002", "mult_stage_text003"}
function M:initUi(parent_node, team_index, isLeft)
	local transform = parent_node.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", team_index_name2[team_index] )
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", team_index_name[team_index] )

	end
	if isLeft then
		local exchange_btn = luaBehaviour:FindGameObject("exchange_btn")
		UIUtil.setButtonClick(exchange_btn.transform, function()
			self:updateMsg("exchange_btn", {index = team_index})
		end)
	end
end

function M:refreshUI(isInit)
	local edit_status = self.m_model.m_edit_status
	for i = 1, 3 do
		self:setObjectVisible("left_team_node" .. i, i <= self.m_model.m_team_nums)
		self:setObjectVisible("right_team_node" .. i, i <= self.m_model.m_team_nums)
		local left_node = self:findGameObject("left_team_node" .. i)
		local right_node = self:findGameObject("right_team_node" .. i)
		local left_teams = self.m_model:getLeftTeamByIndex(i)
		local right_teams = self.m_model:getRightTeamByIndex(i)
		if isInit then
			self:initUi(left_node, i, true)
			self:initUi(right_node, i, false)
		end
		self:refreshTeamNode(i, left_node, left_teams, true)
		self:refreshTeamNode(i, right_node, right_teams)
	end
	self:setObjectVisible("order_btn_text", edit_status == 1)
	self:setObjectVisible("order_btn", edit_status == 1 )
	self:setObjectVisible("ok_btn_text", edit_status ~= 1)
	self:setObjectVisible("ok_btn", edit_status ~= 1)
	self:setObjectVisible("cancle_btn_text", edit_status ~= 1)
	self:setObjectVisible("cancle_btn", edit_status ~= 1)
end

function M:refreshTeamNode(team_index, parent_node, teams, isLeft)
	local transform = parent_node.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local edit_status = self.m_model.m_edit_status
	if isLeft then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "exchange_btn", edit_status ~= 1 and self.m_model.m_select_cell_index ~= team_index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_title_text", edit_status == 1 and self.m_model.m_select_cell_index ~= team_index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_rename_btn", edit_status == 1 and self.m_model.m_select_cell_index ~= team_index)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text",  self.m_model.m_edit_status == 2 and "new_str_0884" or "new_str_0885")
	end
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")
	local team_node = luaBehaviour:FindGameObject("team_node")
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local hero_id = teams[i]
		if teams[i] and teams[i] ~= "" then
			local hero_data = nil
			if isLeft then
				hero_data = self.m_model:getLeftHeroDataById(hero_id)
			else
				if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT
				or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.XIAKEDAO_MULTI then
					hero_data = self.m_model:getRightHeroDataByCfg(hero_id)
				else
					hero_data = self.m_model:getRightHeroDataById(hero_id)
				end
			end
			GameUtil:updateItemElementByData(hero_node.gameObject,hero_data,false,false)
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node.gameObject)
			ui_element.add_img.gameObject:SetActive(false)
		end
	end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_sel_cell_index = nil
	local all_cell_size = {}
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			--all_cell_size = all_cell_size,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

return M