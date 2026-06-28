local M = class("CommonExclusivePopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/CommonExclusivePop"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn_name = "toggle1_btn", btn_text_name = "toggle1_btn_text", title_name = "专属装备强化", btn_text = "专属强化",},
    {btn_name = "toggle2_btn", btn_text_name = "toggle2_btn_text", title_name = "装备升阶", btn_text = "装备升阶",},
}

function M:onEnter()
	for i,v in ipairs(__TAB_BTN_NODE) do
        local tog_btn = self:findToggle(v.btn_name)
        self:setTextByLanKey(v.btn_text_name, v.btn_text)
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, i) end,nil,self.m_uiName)
    end
    self:updateLoopScroll()
end

function M:switchTabUpdate(is_on, update_key)
	if is_on then
        self:updateMsg("tab_btn",update_key)
	end
end

function M:refreshUI()
    local tab_data = __TAB_BTN_NODE[self.m_model.m_tab_index]
    self:setTextByLanKey("main_title_text",tab_data.title_name)
    self:updateLoopScroll()
end

--[[
	创建英雄列表
]]
function M:updateLoopScroll()
    self.m_hero_cell_tab = {} --缓存英雄数据
	local data = self.m_model:getHeros()
	if #data <= 0 then
		self:setObjectVisible("can_obj", false)
		self:setObjectVisible("node_obj", true)
		return
	else
		self:setObjectVisible("can_obj", true)
		self:setObjectVisible("node_obj", false)
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_hero_cell_tab[index] = cell_object
                local h_data, h_cfg = self.m_model:getHero(cell_data)
                local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, h_cfg.id, 1, h_data.oid})
                GameUtil:updateItemElementByData(cell_object, itemData, false, false)
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