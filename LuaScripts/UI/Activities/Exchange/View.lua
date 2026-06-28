local M = class("ExchangePopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/Exchange/ExchangePop"
M.m_size_type = 1

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
	local data = self.m_model.m_change_tab
	if self.m_list_scroll == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local data = cell_data
				self:listHandle(cell_object, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, index)
			end
		}
		self.m_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.m_list_scroll:reloadData(data)
	end
end

function M:listHandle(obj, data)
	local cfg = data
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local reward_content = luaBehaviour:FindGameObject("reward_content")
	--GameUtil:createRewards(reward_content.transform, cfg.reward, true, true)
	LuaBehaviourUtil.setImg(luaBehaviour,"cons_img", "icon_tongqian", "item_icon") --消耗货币图标
	LuaBehaviourUtil.setText(luaBehaviour, "cons_num_text", "0/200") --价格/拥有货币
	LuaBehaviourUtil.setText(luaBehaviour, "number", "可兑换1000次") --可兑换次数
	local function click(obj, name)
		self:updateMsg("change", data.id)
	end
	luaBehaviour:RegistButtonClick(click)
end

return M