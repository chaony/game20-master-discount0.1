local M = class("HeroFilterPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/HeroFilterPop"
M.m_size_type = 2

function M:onEnter()
	self.sound = audio:SendEvtUI('PLAY_UI_ITEM')
	self:updateLoopScroll()
end

function M:updateLoopScroll()
    self.m_cell_tab = {} --缓存英雄数据
	local m_data = {
		{race = 0, big_race_icon = "a_ui_all"}
	}
	for k,v in pairs(GlobalConfig.TYPE_HERO_RACE) do
		local tab = {race = k, big_race_icon = v.big_race_icon}
		table.insert(m_data, tab)
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = m_data,
			one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_cell_tab[index] = cell_object
                self:updateData(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("check_index", cell_data.race)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(m_data)
	end
end

function M:updateData(obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setImg(luaBehaviour, "race_img", data.big_race_icon,  ResourceUtil:getLanAtlas())
	end
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_text", data.name)
end

function M:destroy()
	audio:StopPlayingID(self.sound)
	self.sound = nil
    M.super.destroy(self)
end


return M