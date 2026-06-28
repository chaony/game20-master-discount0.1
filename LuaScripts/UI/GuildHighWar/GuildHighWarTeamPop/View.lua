local M = class("GuildHighWarTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarTeamPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0043")

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
	self.m_sel_cell_index = nil
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name,{index =index,boss_team = cell_data.boss_team} )
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
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	----------------------特殊处理怪兽队伍
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node",  true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boss_img",  false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn",  true)
	------------------特殊处理怪兽队伍
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "upper_num_str_000" .. index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recall_btn_text", "UnionWar_str_021")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "go_btn_text", "bounty_str_0013")
	local city_id = self.m_model:getTeamCityId(index)
	local is_out = city_id > 0 and true or false 
	local city_name = self.m_model:getCfgValueByKey(city_id, "build_name") or ""
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn",  is_out)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", not is_out)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "go_btn",  not is_out and self.m_model.m_open_type ~= "" )
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "city_text", is_out)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "city_text",  city_name)
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_heros_data = data.team_heros_data or {}
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local item_data = team_heros_data[i]
		if item_data and _G.next(item_data) then
			GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false)
		else
			local function callBack()
				self:updateMsg("formation_edit_btn", {index = index})
			end
			local ui_element = GameUtil:updateItemElementNoData(hero_node, nil, nil, callBack)
			ui_element.add_img.gameObject:SetActive(true)
		end
	end

	if data.boss_team == true then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "team_node",  false)
		--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn",  false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn",  false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "boss_img",  true)
	end
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")

end

return M