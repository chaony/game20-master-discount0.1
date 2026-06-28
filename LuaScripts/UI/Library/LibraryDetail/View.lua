local M = class("LibraryDetailView",LikeOO.OOPopBase)

M.m_uiName = "Library/LibraryDetail"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0311")
	self:setTextByLanKey("ok_btn_text", "new_str_0340")
	self:setTextByLanKey("cancle_btn_text", "new_str_0339")
	self:setTextByLanKey("story_btn_text", "new_str_0312")
	self.m_gray_image = self:findImage("gray_image")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	self:setHerosInfo()
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
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
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
	local total_count = data.total_count
	local activation_count = data.activation_count
	local evo = data.cfg.evo
	local quality_item = GlobalConfig.QUALITY_COMMON_SETTING[evo] or GlobalConfig.QUALITY_COMMON_SETTING[1]
	local name = Language:getTextByKey(quality_item.name)
	local name = string.format("<color=#%s>%s</color>",quality_item.HC, name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_title_text", "new_str_0313", tostring(total_count), name, activation_count, total_count)
	local attr_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_text", tostring(data.attr_des))
	attr_text.color = activation_count >= total_count and GlobalConfig.COMMON_COLLOR.COMMON_10 or GlobalConfig.COMMON_COLLOR.COMMON_5
end

function M:setHerosInfo()
	local heros_node = self:findGameObject("heros_node")
	local team_heros_data = self.m_model:getHeroShowData()
	local function click_hero_func(object, params)
    	self:updateMsg("look_hero", {hero_cid = params.data_id})
	end
	local function update_func(item_obj, item_data)
		local luaBehaviour = UIUtil.findLuaBehaviour(item_obj)
		local item_img = luaBehaviour:FindImage("item_img")
		local quality_img = luaBehaviour:FindImage("quality_img")
		if item_data.activation then
			item_img.material = nil
			quality_img.material = nil
		else
			item_img.material = self.m_gray_image.material
			quality_img.material = self.m_gray_image.material
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel",  item_data.show_add)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_quality_img", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img",  item_data.show_add)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_quality_up_img", false)		
	end
	GameUtil:createTeamHeros(heros_node.transform, team_heros_data, false, false, click_hero_func, 0.7, update_func)
end

return M