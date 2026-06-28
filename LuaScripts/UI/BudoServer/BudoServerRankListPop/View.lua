local M = class("BudoServerRankListPopView",LikeOO.OOPopBase)

M.m_uiName = "BudoServer/BudoServerRankListPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
local __rank_title_key = {"budoServer_text_0016", "budoServer_text_0004", "budoServer_text_0005", "budoServer_text_0006"}

local __TAB_BTN_NODE = {
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "budoServer_text_0011" }, -- 跨服
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "budoServer_text_0012" }, -- 本服
}
function M:onEnter()
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_is_corss then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
		--self:setObjectVisible(v.red_point_img, false)
	end
	for i = 1, 4 do
		self:setTextByLanKey("title_text" .. i, __rank_title_key[i])
	end
	self.m_show_spine_id = 506
	self:refreshUI()

end

function M:switchTabUpdate(is_on, update_key)
	local tog_nod = __TAB_BTN_NODE[update_key]
	if is_on then
		self:updateMsg("check_tag", update_key)
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
	else
		self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
	end
end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI(is_change_sort)
	self:setTextByLanKey("close_title_text", "budoServer_text_0008")
	local listName = (self.m_model.m_cur_rank_sort == 1) and "new_str_0019" or "new_str_0370"
	self:refreshSelfNode()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getCurRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			pull_refresh = function() -- 下拉刷新
				self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
				self:updateMsg("load_rank")
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("item_click", cell_data)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
		if self.m_control.m_mail_load == true then
			self:pullRefreshListOffset()
		end
	end
end

function M:pullRefreshListOffset()
	self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	--local position = self.m_list_scroll:getVerticalNormalizedPosition()
	local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
	self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
	self.m_control.m_mail_load = false
end

function M:refreshSelfNode()
	local self_node = self:findGameObject("self_node")
	local self_rank_data = self.m_model:getCurMyRankData()
	if self_rank_data and next(self_rank_data) then
		self:setObjectVisible("self_node",  true)
		self:updateScrollViewCell(0, self_node, self_rank_data)
		local function btnCallBack(trans, self_rank_data)
			self:updateMsg("self_node", self_rank_data)
		end
		UIUtil.setButtonClick(self_node.transform, btnCallBack, self_rank_data)
	else
		self:setObjectVisible("self_node",  false)
	end
end
local rank_bg_path = {"a_bangdan_yi", "a_bangdan_er", "a_bangdan_san", "a_bangdan_qita"}
--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local user = data.user or {}
	if index == 0 and not(cell_data.user) then
		user = UserDataManager.user_data.user_status
		user.name = UserDataManager.user_data:getUserStatusDataByKey("name")
	end
	local rank = data.rank or 0
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)

	local rank_bg_name = rank_bg_path[rank] and rank_bg_path[rank] or rank_bg_path[4]
	LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", rank_bg_name, "mystic_ui")
	if rank < 1 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
		LuaBehaviourUtil.setImg(luaBehaviour, "rank_img", "a_bangdan_wsb", "language_zh_cn")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
	elseif rank > 3 then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "")
	end
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_num_text", GameUtil:formatValueToString(user.full_combat))
	local score = data.score or 0
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_score_text", GameUtil:formatValueToString(score))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text", "" )
	local name_text = nil
	local server_name_text = nil
	if user.name == nil or user.name == "" then
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
	else
		local server_name = UserDataManager.server_data:getServerName()
		if index ~= 0 then
			server_name = UserDataManager.server_data:getServerNameById(data.user.server) or server_name
		end
		server_name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_text", server_name )
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", user.name)
	end

	local head_node = luaBehaviour:FindGameObject("head_node")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", true)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image", false)
	GameUtil:setUserAvatar(head_node, user, false,nil,{show_flag = true, scale = 1})
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(154.66, -24.5, 0)
		name_text.transform.anchoredPosition = Vector3.New(154.66, index == 0 and -20 or -24.5, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(154.66, -7.6, 0)
	end

	local isShowRank = self.m_model.m_isShowRank
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_img", isShowRank == false)
end


return M