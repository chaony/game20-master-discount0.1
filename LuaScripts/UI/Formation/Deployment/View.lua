local M = class("DeploymentView",LikeOO.OOPopBase)

M.m_uiName = "Formation/Deployment"
M.m_size_type = 2


function M:onEnter()
	self:setTextByLanKey("common_title_text", "阵法选择")
	self:setTextByLanKey("tips_text", "点击其他区域完成阵法选择")
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	self.m_model.m_select_data = nil
	self.m_select_cell = nil
	local data = self.m_model:getShowData()
	for i, v in ipairs(data) do
		if v.id == self.m_model.m_deployment_id then
			self.m_select_index = i
			break
		end
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = handler(self, self.updateScrollViewCell),
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if not cell_data.unlock_flag then
					self:updateMsg("lock_tips", {index = index , cell_data = cell_data})
					return
				end
				if self.m_select_cell then
					local luaBehaviour = UIUtil.findLuaBehaviour(self.m_select_cell)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"deployment_select_icon",false)
				end
				self.m_model.m_select_data = cell_data
				self.m_select_cell = cell_object
				self.m_select_index = index
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"deployment_select_icon",true)
				self:setSelectDeploymentInfo(cell_data)
				cell_data.is_new = false
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"new_text",false)
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
	local cfg = cell_data.cfg
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local new_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "new_text", "new_str_0421")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_dep_name", cell_data.cfg.name)
	new_text.gameObject:SetActive(cell_data.is_new == true)
	local deployment_cell_icon = LuaBehaviourUtil.setImg(luaBehaviour,"deployment_cell_icon", cfg.icon, "battle_ui")
	if cell_data.unlock_flag then
		deployment_cell_icon.material = nil
	else
		deployment_cell_icon.material = self.m_gray_img.material
	end
	if self.m_select_index == index then
		self.m_model.m_select_data = cell_data
		self.m_select_cell = cell_object
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"deployment_select_icon",true)
		self:setSelectDeploymentInfo(cell_data)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"deployment_select_icon",false)
	end
end

function M:setSelectDeploymentInfo(cell_data)
	local cfg = cell_data.cfg
	local deployment_icon = self:setImg(cfg.icon, "battle_ui", "deployment_icon")
	self:setTextByLanKey("deployment_name_text", cfg.name)
	self:setTextByLanKey("deployment_des_text", cfg.des)
	local deployment_cell_icon = self:setImg(cfg.icon, "battle_ui", "deployment_cell_icon")
	if cell_data.unlock_flag then
		deployment_icon.material = nil
	else
		deployment_icon.material = self.m_gray_img.material
	end
end

return M