local M = class("GuildHighWarDefendTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarDefendTeamPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("title_text1", "guild_high_war_text_0015")
	self:setTextByLanKey("title_text2", "guild_high_war_text_0016")
	self:setTextByLanKey("title_text3", "guild_high_war_text_0017")
	self:refreshUI()
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0014")

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
local G_CFG = GlobalConfig
function M:updateLoopScroll()
	local data = self.m_model.m_city_team_data.team_info or {}
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell" and cell_data.user and next(cell_data.user) then
					self:updateMsg("item_click", cell_data.user)
				elseif click_name == "recall_btn" then
					self:updateMsg("recall_btn", cell_data.team_id)
				elseif click_name == "hero_node" then
					self:updateMsg("look_hero", cell_data)
				end
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
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", GameUtil:formatValueToString(1))
	local uid = data.uid
	local user_data = self.m_model:getUserDataByUid(uid) or nil
	local ownUid = UserDataManager.user_data:getUserStatusDataByKey("uid")
	local flag = false
	if ownUid == uid then
		flag = true
	else
		flag = false
	end
	if uid == 0 then
		flag = (self.m_model.position == G_CFG.UNION_POS.PRESIDENT or self.m_model.position == G_CFG.UNION_POS.PRESIDENT_VICE) and self.m_model.can_chance == false
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"recall_btn",flag)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recall_btn_text", "jubaoShan_str_003")
	if user_data then
		--data.user.title = 30001
		local head_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "headnode_self", true)
		GameUtil:setUserAvatar(head_node, user_data, false,nil,{show_flag = false, scale = 1})
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", user_data.name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_lv_text", "new_str_0075", user_data.level)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", "player_name_text")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_lv_text", "player_lv_text")
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"boss_img",cell_data.boss_team==true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"self_team_node",cell_data.boss_team==false)
	for i = 1, 5 do
		local team = data.team or {}
		local hero_id = team[i] or ""
		local hero_node = luaBehaviour:FindGameObject("hero_node_" .. i)
		
		if hero_id and hero_id ~= "" then
			local show_hero = cell_data.show_hero[hero_id]
			GameUtil:updateItemElementByData(hero_node.gameObject,show_hero,false,false, callback)
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node)
			ui_element.add_img.gameObject:SetActive(false)
		end
	end
end

return M