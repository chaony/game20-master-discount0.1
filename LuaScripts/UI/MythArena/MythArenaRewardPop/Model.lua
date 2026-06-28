local M = class("MythArenaRewardPopModel", LikeOO.OODataBase)

local __TAB_BTN_NODE = {
	{btn_key = "togglebtn_1", btn_text = "togglebtn_text_1", text_key = "new_str_0373", open = true}, -- 段位
	{btn_key = "togglebtn_2", btn_text = "togglebtn_text_2", text_key = "compass_str_006", open = true}, -- 排行
}

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_data = self.m_params.data
	self.m_open_tab_index = self.m_params.open_tab_index or 1
	self:initData(self.m_data)
end

function M:getRankData()
	local arena_reward_list_cfg = ConfigManager:getCfgByName("myth_reward_Exhibition") or {}
	local arena_reward_list_cfg_item = {}
	for i = 1, #arena_reward_list_cfg do
		if arena_reward_list_cfg[i] and arena_reward_list_cfg[i].type == 1 then
			table.insert(arena_reward_list_cfg_item, arena_reward_list_cfg[i])
		end
	end
	return arena_reward_list_cfg_item
end

function M:getTabBtnNode()
	return __TAB_BTN_NODE
end

--- 网络数据回调
function M:netData(data, tag)
	self:initData(data)
end

function M:initData(data)
	table.merge(self.m_data, data)
end

return M
