local M = class("GuildHighWarBattlingPopView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarBattlingPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("battling_text", "guild_high_war_text_0018")
	self:setTextByLanKey("common_title_text", "guild_high_war_text_0008")
	self:setTextByLanKey("team_mine_text", "left_guild_name")
	self:setTextByLanKey("team_enemy_text", "right_guild_name")
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
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("global_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell" and cell_data.user and next(cell_data.user) then
					self:updateMsg("item_click", cell_data.user)
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
	local data = {  }
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local left_data = self.m_model.m_atk_data[index] or nil
	local right_data = self.m_model.m_def_data[index] or nil
	local headnode_self = luaBehaviour:FindGameObject("headnode_self")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_node", left_data and true or false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_node", right_data and true or false)
	if left_data then
		local self_node_luaBehaviour = UIUtil.findLuaBehaviour(self_node)
		self:updateCellNode(left_data, self_node_luaBehaviour)
	end
	if right_data then
		local enemy_node_luaBehaviour = UIUtil.findLuaBehaviour(enemy_node)
		self:updateCellNode(right_data, enemy_node_luaBehaviour)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "atk_img", index == 1)
	
end

function M:updateCellNode(data, luaBehaviour, is_left)
	local uid = data.uid
	local user_data = self.m_model:getUserInfoByUid(uid)
	if user_data and next(user_data) then
		--data.user.title = 30001
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_player_name_text", user_data.name)
		local headnode_self = luaBehaviour:FindGameObject("self")
		GameUtil:setUserAvatar(headnode_self, user_data, false,nil,{show_flag = false, scale = 1})
		local headnode_enemy = luaBehaviour:FindGameObject("enemy")
		GameUtil:setUserAvatar(headnode_enemy, user_data, false,nil,{show_flag = false, scale = 1})
	end
	for i = 1, 5 do
		local hero_node = luaBehaviour:FindGameObject("hero_node" .. i)
		local hero_id = data.team[i]
		local hero_data = data.heros[hero_id] or nil
		if hero_data then
			self:heroHandle(hero_node, hero_data)
		end
	end
end

function M:heroHandle(obj, hero_data)
	local data = hero_data
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	GameUtil:updateHeroContentByData(obj,data,cfg)
end

return M