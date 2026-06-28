local M = class("MythArenaBattleDetailPopView",LikeOO.OOPopBase)

M.m_uiName = "MythArena/MythArenaBattleDetailPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0268")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
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

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
	local round_data = data.round_data or {}
	local round = round_data.round or 0
	local result = round_data.result or 0
    local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local left_user = self.m_model:getUserInfoBySort(1)
    local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user,nil,nil,{show_flag = true, scale = 1})
	local right_user = self.m_model:getUserInfoBySort(2)
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user,nil,nil,{show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_guild_name_text", tostring(left_user.guild_name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_guild_name_text", tostring(right_user.guild_name))
	if self.m_model.m_top_arena == true then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_player_team_num_text", "upper_num_str_000" .. round_data.attacker_team_id)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_player_team_num_text", "upper_num_str_000" .. round_data.defender_team_id)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_player_team_num_text", "upper_num_str_000" .. round)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_player_team_num_text", "upper_num_str_000" .. round)
	end

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_team_text", "new_str_0890")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_team_text", "new_str_0891")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", round)
	local lan_atlas = ResourceUtil:getLanAtlas()
	LuaBehaviourUtil.setImg(luaBehaviour,"left_result",result == 1 and "a_bh_shengli_zi" or "a_bh_shibai_zi", lan_atlas)
	LuaBehaviourUtil.setImg(luaBehaviour,"right_result",result == 1 and "a_bh_shibai_zi" or "a_bh_shengli_zi", lan_atlas)
	local left_result_bg = LuaBehaviourUtil.setImg(luaBehaviour,"left_result_bg",result == 1 and "a_bh_shenglidi" or "a_bh_shibaidi", "arena_ui")
	local right_result_bg = LuaBehaviourUtil.setImg(luaBehaviour,"right_result_bg",result == 1 and "a_bh_shibaidi" or "a_bh_shenglidi", "arena_ui")
	UIUtil.setLocalScale(left_result_bg.transform, result == 1 and 1 or -1)
	UIUtil.setLocalScale(right_result_bg.transform, result == 1 and 1 or -1)
	
	--local left_team_node = luaBehaviour:FindGameObject("left_team_node")
	--local left_team_data = data.left_team_data or {}
	--GameUtil:createTeamHeros(left_team_node.transform, left_team_data, false, false, nil , 0.35)
	--local right_team_node = luaBehaviour:FindGameObject("right_team_node")
	--local right_team_data = data.right_team_data or {}
	--GameUtil:createTeamHeros(right_team_node.transform, right_team_data, false, false, nil , 0.35)
end

return M