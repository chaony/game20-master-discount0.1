local M = class("FightReportPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/FightDetailsPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "UnionWar_str_006")	
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = {}
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
			
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:updateTeam(obj, data, index)
	
end

return M