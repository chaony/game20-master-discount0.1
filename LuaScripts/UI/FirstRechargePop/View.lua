local M = class("FirstRechargePopView",LikeOO.OOPopBase)

M.m_uiName = "Recharge/FirstRechargePop"
M.m_size_type = 2

function M:onEnter()
	self.hero_spine = self:findGameObject("hero_spine")
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
	self:setSpine()
end

function M:updateListScroll()
	local data = self.m_model.m_gift
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 4,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)

			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, id)
	local data = self.m_model:getDataByIndex(id)
	GameUtil:updateItemElement(obj, data, true, true)
end

function M:setSpine()
	Logger.log(self.m_model.m_hero,"hero ===")
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.m_hero)
 	local sg = self.hero_spine:GetComponent("SkeletonGraphic")
	local spine = cfg.hero_spine or "hero_0001_SkeletonData"
	local asset = ResourceUtil:GetSk(spine, "rolespine_"..string.lower(spine))
 	sg.skeletonDataAsset = asset
 	sg:Initialize(true)
end

return M