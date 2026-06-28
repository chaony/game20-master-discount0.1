local M = class("PeakArenaGameView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakArenaGame"
M.m_size_type = 1

local __TAB_BTN_NODE = { 
	{btn_key = "my_game_btn", lua_name = "UI.PeakArena.PeakArenaGame.MyGameNode", btn_text = "my_game_btn_text", text_key = "我的比赛", red_point_img = ""}, -- 我的比赛
	{btn_key = "guess_btn", lua_name = "UI.PeakArena.PeakArenaGame.GuessNode", btn_text = "guess_btn_text", text_key = "竞猜", red_point_img = ""}, -- 我的比赛
	{btn_key = "racn64_btn", lua_name = "UI.PeakArena.PeakArenaGame.FightInfoNode", btn_text = "racn64_btn_text", text_key = "64强", red_point_img = ""}, -- 我的比赛
	{btn_key = "racn8_btn", lua_name = "UI.PeakArena.PeakArenaGame.FightInfoNode", btn_text = "racn8_btn_text", text_key = "8强", red_point_img = ""}, -- 我的比赛
}

function M:onEnter()
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "巅峰论剑")
	self.m_content_panel = self:findGameObject("common_panel")
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.btn_text, v.text_key)
		if k == self.m_model.m_selete_index then
			self:setImg("a_ui_yeqian_h", "common_ui", v.btn_key)
		else
			self:setImg("a_ui_yeqian_n", "common_ui", v.btn_key)
		end
	end
	self:switchTabNode()
	self:refreshUI()
end

function M:selectTab(data)
	if data == "racn8_btn" and self.m_model:check8Win() == false then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("还未产生8强"), delay_close = 1})
		return
	end
	if data == "racn64_btn" and self.m_model:check64Win() == false then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("还未产生64强"), delay_close = 1})
		return
	end
	for k,v in pairs(__TAB_BTN_NODE) do
		if data == v.btn_key then
			self.m_model.m_selete_index = k
			self:setImg("a_ui_yeqian_h", "common_ui", v.btn_key)
		else
			self:setImg("a_ui_yeqian_n", "common_ui", v.btn_key)
		end
	end
	self:switchTabNode()
end

function M:switchTabNode()
    if self.m_cur_tab_node then
        self.m_cur_tab_node:destroy()
        self.m_cur_tab_node = nil
    end
	local btn_tab = __TAB_BTN_NODE[self.m_model.m_selete_index]
	if btn_tab and #btn_tab.lua_name > 0 then
		local tab_cls = CustomRequire(btn_tab.lua_name)
		self.m_cur_tab_node = tab_cls.new(self.m_control, {parent = self.m_content_panel})
	end
end

--刷新UI
function M:refreshUI()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:refreshUI()
	end
end

function M:updateTime()
	if self.m_cur_tab_node then
		self.m_cur_tab_node:updateTime()
	end
end

function M:destroy()
    if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	if self.m_cur_tab_node then
		self.m_cur_tab_node:destroy()
		self.m_cur_tab_node = nil
	end
    M.super.destroy(self)
end

return M