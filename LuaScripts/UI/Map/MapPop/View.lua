local M = class("MapPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Map/MapPop"
M.m_iphoneXAdapter = true
function M:onEnter()
	self:creatPass()
	self:creatReward()
	self:setObjectVisible("go_btn",false)
	self:setObjectVisible("not_arrive_img",false)
	self:setObjectVisible("has_arrive_img",false)
	if self.m_model.m_stage_id then
		--self:setObjectVisible("world_map_btn",true)
	else
		self:setObjectVisible("world_map_btn",false)		
	end

end

function M:creatPass()
	self:setTextByLanKey("title_text",self.m_model:getTitleName())
	local parent = self:findGameObject("map_parent")
	if not IsNull(parent) then
		local cur_node = {}
		if self.m_model.m_stage_id then
			local map = GameUtil:creatMap(parent, self.m_model.m_stage_id, false, cur_node)
		elseif self.m_model.m_chapter then
			local map = GameUtil:creatMapByChapter(parent,self.m_model.m_chapter, cur_node)
		end
		if cur_node.node then
			cur_node.node:GetComponent("Transform"):SetAsLastSibling()
		end
	end
end

function M:creatReward()
	local reward_ = self.m_model:getReward()
	local reward_node = self:findGameObject("reward_count")
	local data = {}
	if #reward_ > 4 then
		for i = 1, 4 do
			data[i] = reward_[i]
		end
	else
		data = reward_
	end
	for k,v in pairs(data) do
		local eqp = GameUtil:createItemElement(v, false, true)
		eqp.transform.localScale = Vector3.New(0.9, 0.9, 1)
		eqp.transform:SetParent(reward_node.transform,false)
		local luaBehaviour = UIUtil.findLuaBehaviour(eqp)
		if luaBehaviour then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img", false)
		end
	end
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
	self.m_hero_cell_tab = {} --缓存英雄数据
	local rewards = self.m_model:getReward()
	local data = {}
	if #rewards > 4 then
		for i = 1, 4 do
			data[i] = rewards[i]
		end
	else
		data = rewards
	end
	
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("item_loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_hero_cell_tab[index] = cell_object
				--self:updateHeroData(cell_object, cell_data)
				GameUtil:updateItemElement(cell_object, cell_data,false,true)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if luaBehaviour then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_bg", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"camp_img", false)
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", cell_data)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

return M