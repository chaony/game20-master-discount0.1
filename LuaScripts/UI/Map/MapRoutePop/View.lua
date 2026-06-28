local M = class("MapRoutePopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Map/MapRoutePop"
M.m_iphoneXAdapter = true
function M:onEnter()
	self:creatRoute()
end

function M:creatRoute()
	self:setText("title_text", self.m_model:getMapName(self.m_model.mother_map_id))
	
	local scroll_obj = self:findGameObject("Scroll_View")
	local scroll = scroll_obj:GetComponent("ScrollRect")
	local route_obj = ResourceUtil:LoadUIGameObject("Map/MapRoute/Route"..self.m_model.mother_map_id, Vector3.zero, scroll.viewport.gameObject)
	local route_tran = route_obj:GetComponent("RectTransform")
	local pos = route_tran.anchoredPosition
	pos.x = 0
	pos.y = 0
	route_tran.anchoredPosition = pos
	scroll.content = route_tran

	for k,v in pairs(self.m_model.scene_lines) do
		local map_obj = UIUtil.findTrans(route_tran, "map_"..v)
		if map_obj ~= nil then
			local opened = UIUtil.setObjectVisible(map_obj, true, "opened")
			UIUtil.setText(opened.transform, self.m_model:getMapName(v), "opened_text")
			if v == self.m_model.cur_map_id then
				UIUtil.setObjectVisible(opened.transform, true, "current")
			end
			local path = UIUtil.findTrans(route_tran, "path_"..v)
			for i = 1, path.childCount do
				local child = path:GetChild(i - 1)
				child.gameObject:SetActive(true)
				if table.indexof(self.m_model.scene_lines, tonumber(child.name)) ~= false then
					UIUtil.setObjectVisible(child, true, "opened")
				end
			end
		end
	end
end

return M