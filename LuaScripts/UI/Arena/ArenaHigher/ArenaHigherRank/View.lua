local M = class("ArenaHigherRankView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigherRank"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0284")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
    self:setTextByLanKey("tips_text", "new_str_0284")
	self.m_toggle_btns = {}
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		self:setTextByLanKey(v.btn_text, string.cutTextForString(Language:getTextByKey(v.text_key)))
		local tog_btn = self:findToggle(v.btn_key)
		tog_btn.gameObject:SetActive(v.open)
		self.m_toggle_btns[k] = tog_btn
		if k == self.m_model.m_open_tab_index then
			tog_btn.isOn = true
		end
		UIUtil.addToggleListener(tog_btn, function(is_on) 
			if is_on then
				self:updateMsg(k)
			end
		end,nil,self.m_uiName)
	end
	self:updateMsg(self.m_model.m_open_tab_index)
	self:setTextByLanKey("title_text", "new_str_0270")
	self:refreshUI()
end

function M:refreshUI()
	
end

function M:switchTabNode(index)
	local sel_btn_key = nil
	for k,v in pairs(self.m_model:getTabBtnNode()) do
		local cur_tab_text = self:findText(v.btn_text)
		cur_tab_text.color = index == k and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
		if index == k then
			sel_btn_key = v.btn_key
			self:setTextByLanKey("common_title_text", v.text_key)
		end
	end
    -- local loopscroll = self:findGameObject("loopscroll")
    -- local rt = UIUtil.findRectTransform(loopscroll)
	-- rt.offsetMax = Vector2(rt.offsetMax.x, sel_btn_key == "togglebtn_2" and -210 or -110)
	--self:setObjectVisible("tips_text", sel_btn_key == "togglebtn_2")
	self:setTextByLanKey("score_label_text", index == 1 and "world_boss_str_0027" or "new_str_0283")
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index, cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local user = data.user or {}
    local rank = data.rank or 0
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)

	local top_three_flag = rank > 0 and rank < 4
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", not top_three_flag)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
	local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
	if top_three_item then
		LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
	end
    if rank < 1 then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
    end  
    local power_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_text", tostring(user.full_combat))
	local name_text = nil
    if user.name == nil or user.name == "" then
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
		name_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
    end
    local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 0.6})
	
	local power_title_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "power_title_text", "friend_str_0041")
	local title_id = user.title
	if title_id and title_id ~= 0 then
		name_text.transform.anchoredPosition = Vector3.New(8, 0, 0)
		power_title_text.transform.anchoredPosition = Vector3.New(-163, -28, 0)
		power_text.transform.anchoredPosition = Vector3.New(17, -28, 0)
	else
		name_text.transform.anchoredPosition = Vector3.New(8, 17, 0)
		power_title_text.transform.anchoredPosition = Vector3.New(-163, -18, 0)
		power_text.transform.anchoredPosition = Vector3.New(17, -18, 0)
	end
	local sel_tab_index = self.m_model.m_sel_tab_index
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "segment_node", sel_tab_index == 1)
	if sel_tab_index == 1 then
		local cfg = ConfigManager:getHighArenaCfgByRank(rank)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", "")
		local segment_node = luaBehaviour:FindGameObject("segment_node")
		CommonUIUtil:setSegmentInfo(segment_node, cfg, true)
	elseif sel_tab_index == 2 then
		local score = data.score or 0
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0283")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", tostring(score))
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "gender_img", false)
	--GameUtil:setUserGender(luaBehaviour, user.gender, "gender_img")
end

return M