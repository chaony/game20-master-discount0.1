local M = class("PeakMyGuessPopView",LikeOO.OOPopBase)

M.m_uiName = "PeakArena/PeakMyGuessPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { 
	{btn_key = "tog_1", text_key = "tog_1_text", show_text = "peak_str_0016" }, -- 我的竞猜
	{btn_key = "tog_2", text_key = "tog_2_text", show_text = "peak_str_0017" }, -- 竞猜历史
}

function M:onEnter()
	self:setTextByLanKey("common_title_text", "peak_str_0016")	
	self:setTextByLanKey("guess_money_text", "peak_str_0050")
	self:setTextByLanKey("duijue_text", "peak_duijue_tex")
	self.head_title_img1 = self:findGameObject("head_title_img1")
	self.head_title_img2 = self:findGameObject("head_title_img2")
	self.m_toggle_btns = {}
	for k,v in pairs(__TAB_BTN_NODE) do
		self:setTextByLanKey(v.text_key, v.show_text)
		local tog_btn = self:findToggle(v.btn_key)
		self.m_toggle_btns[k] = tog_btn
		UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
		else
			self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
		end
	end
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

function M:switchNode(index)
    self:setObjectVisible("loopscroll", index == 2)
    self:setObjectVisible("guessNode", index == 1)
    self:refreshUI()
end

--刷新UI
function M:refreshUI()
	if self.m_model.m_sel_tab_index == 1 or self.m_model.m_sel_tab_index == 0 then
		self:updateGuessUI()
	else
		self:updateLoopScroll()
	end
end

function M:updateGuessUI()
	self.left_data, self.right_data = self.m_model:getGuessBattlePlayerData()
	local guess_get_data = self.m_model:getMyGuessData()
	local left_head = self:findGameObject("left_head")
	local right_head = self:findGameObject("right_head")
	if self.left_data == nil or self.right_data == nil then
		self:setObjectVisible("guessNode", false)
		return
	end
	local left_head_name = self:setTextByLanKey("left_head_name", self.left_data.user.name)
	local right_head_name = self:setTextByLanKey("right_head_name", self.right_data.user.name)
	local guess_left_btn = self:findGameObject("guess_left_btn")
	local guess_right_btn = self:findGameObject("guess_right_btn")
	GameUtil:setUserAvatar(left_head, self.left_data.user, false, false,{show_flag = true, scale = 1})
	GameUtil:setUserAvatar(right_head, self.right_data.user, false, false,{show_flag = true, scale = 1})
	local title_id1 = self.left_data.user.title
	local title_id2 = self.right_data.user.title
	self:setTitleImage(title_id1,self.head_title_img1)
	self:setTitleImage(title_id2,self.head_title_img2)
	if title_id1 and title_id1 ~= 0 then
		left_head_name.transform.anchoredPosition = Vector3.New(-181, -106, 0)
		guess_left_btn.transform.anchoredPosition = Vector3.New(-174, -150, 0)
	else
		left_head_name.transform.anchoredPosition = Vector3.New(-181, -83, 0)
		guess_left_btn.transform.anchoredPosition = Vector3.New(-174, -133, 0)
	end
	if title_id2 and title_id2 ~= 0 then
		right_head_name.transform.anchoredPosition = Vector3.New(172, -106, 0)
		guess_right_btn.transform.anchoredPosition = Vector3.New(178, -150, 0)
	else
		right_head_name.transform.anchoredPosition = Vector3.New(172, -83, 0)
		guess_right_btn.transform.anchoredPosition = Vector3.New(178, -133, 0)
	end
	local cost_data = RewardUtil:getProcessRewardData({135,0,0})
    self:setImg(cost_data.icon_name, cost_data.atlas_name, "money_icon")
    self:setTextByLanKey("guess_money_num", cost_data.user_num)
	self:setObjectVisible("left_zhichi_text", false)
	self:setObjectVisible("right_zhichi_text", false)
	if next(guess_get_data) ~= nil then
		self:setObjectVisible("guess_left_btn", false)
		self:setObjectVisible("guess_right_btn", false)
		if guess_get_data[1] == self.left_data.user.uid then
			self:setObjectVisible("left_zhichi_text", true)
		elseif 	guess_get_data[1] == self.right_data.user.uid then
			self:setObjectVisible("right_zhichi_text", true)
		end
	else
		self:setObjectVisible("guess_left_btn", true)
		self:setObjectVisible("guess_right_btn", true)
	end
end


function M:updateLoopScroll()
	local data = self.m_model:getQuizList()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local battle_id = self.m_model:getBattleId(cell_data.id) -- 结果
				local py_data, py_data2 = self.m_model:getGuessData(cell_data.id) --对阵数据
				if next(py_data) == nil or next(py_data2) == nil then
					return
				end
				if click_name == "huifang_btn" then
					self.m_control:openView("Arena.ArenaHigher.ArenaHigherBattleDetail", {battle_id = battle_id, top_arena = true})
				elseif click_name == "left_head_btn" then
					self:openView("Pops.PlayerInfo", {uid = py_data.user.uid, look_model = 2})
				elseif click_name == "right_head_btn" then
					self:openView("Pops.PlayerInfo", {uid = py_data.user.uid, look_model = 2})
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:updateTeam(cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		local guess_result_data = self.m_model:getGuessResult(cell_data.id) -- 结果
		local py_data, py_data2 = self.m_model:getGuessData(cell_data.id) --对阵数据
		local left_obj = luaBehaviour:FindGameObject("HeadNode_left")
		local right_obj = luaBehaviour:FindGameObject("HeadNode_right")
		if py_data == nil or py_data2 == nil or  next(py_data) == nil or next(py_data2) == nil  then
			return
		end
		local left_data = nil
		local right_data = nil
		if guess_result_data[1] == py_data.user.uid then
			left_data = py_data
			right_data = py_data2
		else
			left_data = py_data2
			right_data = py_data
		end
		local cost_data = RewardUtil:getProcessRewardData({135,0,0})
		LuaBehaviourUtil.setImg(luaBehaviour, "icon_img",cost_data.icon_name, cost_data.atlas_name )
		GameUtil:setUserAvatar(left_obj, left_data.user, nil,nil,{show_flag = true, scale = 1})
		GameUtil:setUserAvatar(right_obj, right_data.user,nil,nil,{show_flag = true, scale = 1})
		-- LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_sever", "peak_str_0043", left_data.user.server)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name", left_data.user.name )
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name", right_data.user.name )
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_jieguo", false)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title", self.m_model:getCurBattleStatusName(cell_data.id))
		if next(guess_result_data) == nil or guess_result_data[2] == 0 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guess_result", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "huifang_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guessing", true)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guessing", "peak_str_0018")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_1", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_2", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_1", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "win_2", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guess_result", true)
			if 	guess_result_data[2] == left_data.user.uid then
				LuaBehaviourUtil.setImg(luaBehaviour, "win_1", "a_sjjs_shengli", ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setImg(luaBehaviour, "win_2", "a_sjjs_shibai", ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guessing", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guessing", "peak_str_0043")
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_num", "+"..GameUtil:formatNum(guess_result_data[3] *1.5) or 0)	
			else
				LuaBehaviourUtil.setImg(luaBehaviour, "win_1", "a_sjjs_shibai", ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setImg(luaBehaviour, "win_2", "a_sjjs_shengli", ResourceUtil:getLanAtlas())
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "guessing", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "money_num", "+"..GameUtil:formatNum(guess_result_data[3] *0.5) or 0)	
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "guessing", "peak_str_0019")
			end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "huifang_btn", true)
		end
	end
end


-- 设置称号图片
function M:setTitleImage(title_id, titleObj)
	if title_id and title_id ~= 0 then
		titleObj:SetActive(true)
		local name_img = titleObj:GetComponent("Image")
		local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
		UIUtil.destroyAllChild(name_img.gameObject.transform)
		if cfg.title_effect and cfg.title_effect ~= "" then
			ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
			name_img.enabled = false
		else
			GameUtil:setTextureLoadTitleLanImgText(titleObj, cfg.icon) -- 设置称号图片
			name_img:SetNativeSize()
			name_img.enabled = true
		end
	else
		titleObj:SetActive(false)
	end
end



return M