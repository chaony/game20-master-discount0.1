local M = class("PlayerDataShowView",LikeOO.OOPopBase)

M.m_uiName = "GamePanel/PlayerDataShow"
M.m_size_type = 2

function M:onEnter()
	SceneManager:pause();
	self.hero_tog_names = {
		"hero-0",
		"hero-1",
		"hero-2",
		"hero-3",
		"hero-4",
		"hero-5",
		"hero-6",
		"hero-7",
		"hero-8",
		"hero-9",
	}
	self.data = self.m_model:getPropShowData();
	self.m_race_toggle_bg = self:findGameObject("race_toggle_bg")
	for i,v in ipairs(self.hero_tog_names) do
		local tog_btn = self:findToggle(v)
		if self.data[i] then
			local lan_text = self.data[i].name;
			self:setTextByLanKey(v.."_text", lan_text)
			UIUtil.addToggleListener(tog_btn, function(is_on, data)
				if is_on then
					self:updateMsg("selectHeroData", self.data[i])
				end
			end, i, self.m_uiName)
		else
			self:setObjectVisible(v, false);	
		end
	end
	self:refreshUI()
end

function M:refreshUI()
	self:updateInjureLoopScroll({})
	self:updateAttackLoopScroll({})
	self:updatePropLoopScroll({})
end


--[[
	创建列表
]]
function M:updateInjureLoopScroll( data)
	if data ~= nil then
		self:setObjectVisible("common_tips_node", #data == 0)
		if self.m_injure_loop_scroll_view == nil then
			local loopscroll = self:findGameObject("def_loopscroll")
			local params = {
				show_data = data,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					self:updateDamageScrollViewCell(index, cell_object, cell_data)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)
					self:updateMsg(click_name, {id = index , cell_data = cell_data})
				end
			}
			self.m_injure_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_injure_loop_scroll_view:reloadData(data, true)
		end
	end
end


--[[
	创建列表
]]
function M:updatePropLoopScroll( data )
	if data ~= nil then
		self:setObjectVisible("common_tips_node", #data == 0)
		if self.m_prop_loop_scroll_view == nil then
			local loopscroll = self:findGameObject("prop_loopscroll")
			local params = {
				show_data = data,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					self:updatePropScrollViewCell(index, cell_object, cell_data)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)
					self:updateMsg(click_name, {id = index , cell_data = cell_data})
				end
			}
			self.m_prop_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_prop_loop_scroll_view:reloadData(data, true)
		end
	end
end


function M:updateAttackLoopScroll( data )
	Logger.log(data, " Attack 更新数据 ")
	if data ~= nil then
		self:setObjectVisible("common_tips_node", #data == 0)
		if self.m_attack_loop_scroll_view == nil then
			local loopscroll = self:findGameObject("attack_loopscroll")
			local params = {
				show_data = data,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					self:updateDamageScrollViewCell(index, cell_object, cell_data)
				end,
				click_func = function(index, cell_object, cell_data, click_object, click_name)
					self:updateMsg(click_name, {id = index , cell_data = cell_data})
				end
			}
			self.m_attack_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_attack_loop_scroll_view:reloadData(data, true)
		end
	end
end

function M:updateDamageScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	local des = "    k "..tostring(cell_data.plyType).." d "..tostring(cell_data.damage).." s "..tostring(cell_data.skill)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Value", des)
end


--Scroll内cell的回调
function M:updatePropScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Name", cell_data.key)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "Value", cell_data.value)
end


function M:destroy()
	M.super.destroy(self)
	SceneManager:continue();
end

return M