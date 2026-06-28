local guide = class("ThreeHeroesFiveGallantsStoreGuideDrama", LikeOO.OOGuideBase)

-- 点击选项
function guide:excuteGuideFunc1(info)
	if self.m_view.m_loop_scroll_view == nil then
		return
	end
	local id = info.target[1]
	local data = self.m_model:getSelectDramaData()
	local index = nil
	for i,v in ipairs(data) do
		if v.id == id then
			index = i
		end
	end

	if index then
		local cell = self.m_view.m_loop_scroll_view.m_cache_cells[index]
		if cell then
			local luaBehaviour = UIUtil.findLuaBehaviour(cell)
			local node = luaBehaviour:FindGameObject("Image")
			if node then
				self.m_listener = {
					key = "select_drama_Item",
				}
				self:guideTargetNode(node.transform, 3, 1)
			end
		end
	end
end

-- 进入剧情
function guide:excuteGuideFunc2(info)
	self:doNextGuide()
end

return guide
