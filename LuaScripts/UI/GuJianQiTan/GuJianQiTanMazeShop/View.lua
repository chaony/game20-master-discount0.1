local M = class("GuJianQiTanMazeShopView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMazeShop"
M.m_size_type = 2

function M:onEnter()
	local cell_type = self.m_model.m_cell_data.type
	local maze_cell_type = ConfigManager:getCfgByName("maze_cell_type")
	local maze_cell_type_item = maze_cell_type[cell_type] or {}
	local explain = maze_cell_type_item.explain or "???"
	self:setTextByLanKey("tips_text", "tid#MazeCellTypeDes_7")
	self:setTextByLanKey("common_title_text", "tid#MazeCellTypeName_7")
	--self:setTextByLanKey("common_title_text", maze_cell_type_item.name or "???")
	-- self:setTextByLanKey("tips_text", "new_str_0197")
	-- self:setTextByLanKey("common_title_text", "new_str_0196")
	--if self.m_model.m_cell_data.status == 0 then
	--	self:setTextByLanKey("ok_btn_text", "new_str_0029")
	--else
	--	self:setTextByLanKey("ok_btn_text", "new_str_0198")
	self:setTextByLanKey("ok_btn_text", "new_str_0029")
	--end
	self:setObjectVisible("ok_btn", self.m_model.m_open_flag == true)
	self:refreshUI()
end

function M:refreshUI()
	--self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				local luaBehaviour = UIUtil.findLuaBehaviour(transform)
				local item_node = luaBehaviour:FindGameObject("item_node")				
				local ui_element = GameUtil:updateItemElement(item_node, cell_data.item or {}, true, false, nil)
				local remain = data.remain or 0
			    local sell_max_img = luaBehaviour:FindImage("sell_max_node")
			    if remain < 1 then
			        ui_element.item_img.material = sell_max_img.material
			        ui_element.quality_img.material = sell_max_img.material
			    else
			        ui_element.item_img.material = nil
			        ui_element.quality_img.material = nil
			    end
				local sell_data = RewardUtil:getProcessRewardData(cell_data.sell)
				LuaBehaviourUtil.setImg(luaBehaviour, "cost_icon", sell_data.icon_name, sell_data.atlas_name)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cost_num_text", tostring(sell_data.data_num))
				local discount = data.discount or 0
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"discount_img", discount < 100)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "discount_text", "new_str_0199", discount/10)
		        local hero_ids = data.hero_ids
		        LuaBehaviourUtil.setObjectVisible(luaBehaviour,"red_point_img", #hero_ids > 0 and remain > 0)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("cell_click", {data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M