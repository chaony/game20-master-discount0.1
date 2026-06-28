local M = class("MoonShadowBattleView",LikeOO.OOPopBase)

M.m_uiName = "MoonShadow/MoonShadowBattle"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self:setTextByLanKey("close_title_text", "moon_shadow_str_004")
	self:setTextByLanKey("chakan_btn_text", "moon_shadow_str_006")
	self:refreshUI()
	RedPointUtil:saveLocalRedPointFreshTime("MoonShadowBattle")
end

--刷新UI
function M:refreshUI()
	self:setText("damage_ward_1_text", self.m_model:getMaxDamage())
	self:updateLoopScroll()
	if self.m_model:getRankType() == 1 then
		self:setTextByLanKey("paihang_title_text", "moon_shadow_str_007")
	else
		self:setTextByLanKey("paihang_title_text", "moon_shadow_str_008")	
	end
	self:setObjectVisible("switch_btn", false)
	if self.m_model.m_open_status == 2 then
		self:setObjectVisible("Tiaozhan", false)
	end
end

function M:updateMaxDamage()
	self:setText("damage_ward_1_text", self.m_model:getMaxDamage())
end

function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	--只展示前三名
	local data_three = {}
	for i = 1, 3 do
		if data[i] ~= nil then
			table.insert(data_three, data[i])
		end
	end
	self:setObjectVisible("paihang_sub_img", #data_three == 0)
	self:setObjectVisible("paihang_sub_text", #data_three == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data_three,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data_three)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local user = data.user or {}
	local rank = data.rank or 0
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local top_three_flag = rank > 0 and rank < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "index_img", top_three_flag)
	if rank == 1 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_diyiicon", "active_ui")
	elseif rank == 2 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_diericon", "active_ui")
	elseif rank == 3 then
		LuaBehaviourUtil.setImg(luaBehaviour,"index_img", "a_yycs_disanicon", "active_ui")
	end
	LuaBehaviourUtil.setText(luaBehaviour, "index_text", rank)
	if user.name == nil or user.name == "" then
		LuaBehaviourUtil.setText(luaBehaviour, "name_text", tostring(user.uid))
	else
		LuaBehaviourUtil.setText(luaBehaviour, "name_text", tostring(user.name))
	end
end


return M