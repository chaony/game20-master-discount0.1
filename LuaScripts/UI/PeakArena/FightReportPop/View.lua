local M = class("FightDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/FightReportPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "UnionWar_str_006")	
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = self.m_model.m_battle_logs
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "huifang_btn" then
					if cell_data.battle_id then
						self.m_control:openView("Arena.ArenaHigher.ArenaHigherBattleDetail", {battle_id = cell_data.battle_id, top_arena = true})
					end
				else
					self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.id, look_model = 2})	
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:updateTeam(obj, data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		if data.win_id == self.m_model.m_id then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"result_win", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"result_fail", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"result_win", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"result_fail", true)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"time_text", false)
		local play_data = data.play_data
		if play_data.user then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", play_data.user.name)
			local HeadNode = luaBehaviour:FindGameObject("HeadNode")
			GameUtil:setUserAvatar(HeadNode,play_data.user,nil,nil,{show_flag = true, scale = 1})
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", play_data.name)
		end
	end
end

return M