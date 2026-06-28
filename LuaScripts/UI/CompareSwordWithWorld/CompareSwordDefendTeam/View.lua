local M = class("CompareSwordDefendTeamView",LikeOO.OOPopBase)

--剑试天下 设置阵容 
M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordDefendTeam"	--CompareSwordWithWorld.CompareSwordDefendTeam
M.m_size_type = 2

local __TAB_FORMATION_DATA = {{name = "loopscroll"},{name ="loopscroll_5"}}

function M:onEnter()
	--if self.m_model.m_battle_array == true then
		self:setTextByLanKey("common_title_text", "peak_str_0047")	--比赛阵容
	--else
		--self:setTextByLanKey("common_title_text", "new_str_0275")	--防守阵容 
	--end
	self.cur_loop_scroll_name = __TAB_FORMATION_DATA[1]
	for k,v in ipairs(__TAB_FORMATION_DATA) do
		if k == self.m_model.m_race_typ then
			self.cur_loop_scroll_name = v.name
			self:setObjectVisible(v.name, true)
		else
			self:setObjectVisible(v.name,false)		
		end
	end
	self:setTextByLanKey("order_btn_text", "new_str_0266")
	self:setTextByLanKey("cancle_btn_text", "new_str_0007")
	self:setTextByLanKey("ok_btn_text", "new_str_0267")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	local edit_status = self.m_model.m_edit_status
	self:setObjectVisible("order_btn", edit_status == 1 and self.m_model.m_show_order_btn_flag ~= false)
	self:setObjectVisible("edit_btn_node", edit_status ~= 1 and self.m_model.m_show_order_btn_flag ~= false)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_sel_cell_index = nil
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject(self.cur_loop_scroll_name)
		local params = {
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
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "upper_num_str_000" .. index)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")

	local edit_status = self.m_model.m_edit_status
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "formation_edit_btn", edit_status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "exchange_btn", edit_status ~= 1 and self.m_model.m_select_cell_index ~= index)
	--LuaBehaviourUtil.setImg(luaBehaviour, "exchange_btn", self.m_model.m_edit_status == 2 and "a_jjc_tiaozheng" or "a_jjc_tiaozheng_1", "arena_ui")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "exchange_btn_text",  self.m_model.m_edit_status == 2 and "new_str_0884" or "new_str_0885")
	local team_node = luaBehaviour:FindGameObject("team_node")
	local team_heros_data = data.team_heros_data or {}
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

return M