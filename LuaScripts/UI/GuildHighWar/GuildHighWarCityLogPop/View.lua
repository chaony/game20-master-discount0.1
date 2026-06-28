local M = class("GuildHighWarCityLogPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarCityLogPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "new_str_0853")

end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_logs
	self:setObjectVisible("common_tips_node", #data == 0)
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
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
		if self.m_control.m_load_end == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_load_end = false
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local round_data = data.round_data or {}
	local round = index
	local result = data.win == data.atk_user.uid and 1 or 0
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local left_user = data.atk_user
	local left_head_node = luaBehaviour:FindGameObject("left_head_node")
	GameUtil:setUserAvatar(left_head_node, left_user,nil,nil,{show_flag = true, scale = 1})
	local right_user = data.def_user
	local right_head_node = luaBehaviour:FindGameObject("right_head_node")
	GameUtil:setUserAvatar(right_head_node, right_user,nil,nil,{show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", tostring(left_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_guild_name_text", tostring(left_user.guild_name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", tostring(right_user.name))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_guild_name_text", tostring(right_user.guild_name))
	local decade = math.floor(round/10)
	local unitsdigit = round - decade*10
	local finaltext = round
	
	if 9 < round and round < 100 then
		if unitsdigit ~= 0 then
			finaltext = Language:getTextByKey("upper_num_str_000" .. tostring(decade * 10)) .. Language:getTextByKey("upper_num_str_000" .. tostring(unitsdigit))
		else
			finaltext = Language:getTextByKey("upper_num_str_000" .. tostring(decade * 10))
		end
	elseif decade < 10 then
		finaltext = Language:getTextByKey("upper_num_str_000" .. unitsdigit)
	elseif decade > 99 then
		
	end
	
	local leftNum = data.atk_tid or 0
	local rightNum = data.def_tid or 0
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"left_player_team_num_text",leftNum>0)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"right_player_team_num_text",rightNum>0)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"left_team_bg",leftNum>0)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"right_team_bg",rightNum>0)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_player_team_num_text",  Language:getTextByKey("upper_num_str_000" .. leftNum))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_player_team_num_text",  Language:getTextByKey("upper_num_str_000" .. rightNum))

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