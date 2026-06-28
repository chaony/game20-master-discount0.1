---@class ArenaTopDefendTeamView:OOPopBase
---@field m_model ArenaTopDefendTeamModel
local M = class("ArenaTopDefendTeamView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRace/ArenaTopDefendTeam"
M.m_size_type = 2

function M:onEnter()
	if self.m_model.m_battle_array == true then
		self:setTextByLanKey("common_title_text", "peak_str_0047")
	else
		self:setTextByLanKey("common_title_text", "new_str_0275")
	end
	
	self:setTextByLanKey("order_btn_text", "new_str_0266")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("ok_btn_text", "new_str_0267")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	local edit_status = self.m_model.m_edit_status
	self:setObjectVisible("edit_btn_node", edit_status ~= 1 and self.m_model.m_show_order_btn_flag ~= false)
	self:setObjectVisible("help_btn", self.m_mode and self.m_mode == GlobalConfig.BATTLE_MODE.TOP_RACE_ARENA_DEFENSE)
	self:setObjectVisible("order_btn", false)
	
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

local team_index_name = {"arena_str_0012", "arena_str_0013", "arena_str_0027"}
--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", team_index_name[index] )
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")

	local edit_status = self.m_model.m_edit_status
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", edit_status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "exchange_btn", edit_status ~= 1 and self.m_model.m_select_cell_index ~= index)
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text",  self.m_model.m_edit_status == 2 and "new_str_0884" or "new_str_0885")
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_heros_data = data.team_heros_data or {}
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shili_root", true)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "shili_name",  "new_str_0971")
	self:refreshRacesIcon(luaBehaviour, index)
	
	for i = 1, 5 do
		local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
		local item_data = team_heros_data[i]
		if item_data and _G.next(item_data) then
			GameUtil:updateItemElementByData(hero_node.gameObject,item_data,false,false)
		else
			local ui_element = GameUtil:updateItemElementNoData(hero_node)
			ui_element.add_img.gameObject:SetActive(false)
		end
		local item_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
		local season_buff_num = self.m_model:checkSeasonBuffByHero(item_data.data_id)
        if season_buff_num > 0 then
            local str = "+%d\n %%"
            LuaBehaviourUtil.setTextByLanKey(item_luaBehaviour, "season_buff_num", string.format(str, season_buff_num) )
            LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "season_buff_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "season_buff_img", false)    
        end
	end
end

function M:refreshRacesIcon(luaBehaviour, index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "shili_name",  "new_str_0971")
	for i = 1, 3 do
		local race_id = 0
		if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_RACE_ARENA_DEFENSE then
			if self.m_model.m_races[index] and self.m_model.m_races[index][i] then
				race_id = self.m_model.m_races[index][i]
			end
			if race_id > 0 and race_id ~= 7 then --有个bug，从无到有，设置阵容后，会有7，不知道啥原因，临时先屏蔽7
				local race_img_info = GlobalConfig.TYPE_HERO_RACE[race_id];
				LuaBehaviourUtil.setImg(luaBehaviour, "shili" .. i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shili" .. i, true)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shili" .. i, false)
			end
		else
			local shili = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shili" .. i, false)
			if i == index or i == 3 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shili" .. i, true)
				race_id = self.m_model.m_races[i]
				local race_img_info = GlobalConfig.TYPE_HERO_RACE[race_id];
				LuaBehaviourUtil.setImg(luaBehaviour, "shili" .. i, race_img_info.race_icon, ResourceUtil:getLanAtlas())
			end
		end
	end
end

return M