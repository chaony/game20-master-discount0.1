local M = class("UnionRelicLookView",LikeOO.OOPopBase)

M.m_uiName = "UnionBoss/UnionRelicLook"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("relic_look_title_text", "new_str_0276")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("relic_look_title_text", self.m_model.m_look_mode ~= 0)
	self:setObjectVisible("loopscroll", self.m_model.m_look_mode ~= 0)
	local info_node = self:findGameObject("info_node")
	local data = self.m_model.m_relic_data
	local luaBehaviour = UIUtil.findLuaBehaviour(info_node)
	local cfg = data.cfg
	local light_img = luaBehaviour:FindGameObject("light_img")
	light_img:SetActive(true)
	local attr_icon = luaBehaviour:FindGameObject("attr_icon")
	attr_icon:SetActive(true)
	-- local attr_icon_bg = luaBehaviour:FindGameObject("attr_icon_bg")
	-- attr_icon_bg:SetActive(true)
	CommonUIUtil:updateMazeStageRelicElement(info_node, cfg)
	if self.m_model.m_look_mode ~= 0 then
		self:updateLoopScroll()
	end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_select_cell = nil
	self.m_model.m_select_index = -1
	local data = self.m_model:getHeirloomAddHeros()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 1,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local item_node = luaBehaviour:FindGameObject("item_node")
				local ui_element = GameUtil:updateItemElementByData(item_node, cell_data, false, false)
				local add_combat = data.add_combat or 0
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", (add_combat > 0 and "+" or "") .. tostring(add_combat))
				LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour, "lv_bg_img", true)
				LuaBehaviourUtil.setObjectVisible(ui_element.luaBehaviour, "lv_text", true)
				if data.clv and data.clv > 0 then
					local lv_text = LuaBehaviourUtil.setTextByLanKey(ui_element.luaBehaviour, "lv_text", "new_str_0075",data.clv)
					lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_6
				else
					local lv_text = LuaBehaviourUtil.setTextByLanKey(ui_element.luaBehaviour, "lv_text", "new_str_0075",data.lv)
					lv_text.color = GlobalConfig.COMMON_COLLOR.COMMON_4
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M