local M = class("WorldMapEncounterDetailView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapEvent/WorldMapEncounterDetail"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	local event_data, team_cfg = self.m_model:getEventData()
	local event_battle = event_data.event_battle or 0
	local show_btn_flag = event_battle > 0
	self:setObjectVisible("battle_btn",show_btn_flag)
	self:setObjectVisible("event_loopscroll", not show_btn_flag)
	self:setTextByLanKey("common_title_text", team_cfg.team_name)
	self:setTextByLanKey("event_story_text", event_data.event_mission)
	self:setTextByLanKey("battle_btn_text", "new_str_0166")
	self.m_encounter_img = self:findImage("encounter_img")
	GameUtil:updateResourcesImg(self.m_encounter_img, "Texture/world_map/" .. tostring(event_data.pic))
	self:updateSelectDramaLoopScroll()
end

function M:refreshSelectInfo(id)
	local encounter_cfg = ConfigManager:getCfgByName("encounter")
	local encounter_cfg_item = encounter_cfg[id]
	if encounter_cfg_item then
		self:setTextByLanKey("event_story_text", encounter_cfg_item.event_mission)
	end
	self:updateSelectDramaLoopScroll()
end

--[[
	创建列表
]]
function M:updateSelectDramaLoopScroll()
	local data = self.m_model:getSelectDramaData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("event_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "event_des_text", tostring(cell_data.des))
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_drama_item", {index = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

return M