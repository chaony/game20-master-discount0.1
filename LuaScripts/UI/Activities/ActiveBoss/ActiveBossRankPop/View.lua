local M = class("ActiveBossRankPopView",LikeOO.OOPopBase)

M.m_uiName = "Activities/ActiveBoss/ActiveBossRankPop"
M.m_size_type = 2
local rank_name_pos = {{x=-2,y=-19},{x=0,y=-7},{x=2,y=-10},{x=0,y=-10},{x=0,y=-10}}
local TITLE_TEXT ={"world_boss_str_0035", "world_boss_str_0043"}
function M:onEnter()
	self.m_timer_text_tab = {}
	self:setTextByLanKey("auto_text", "mail_str_0017")
	self.m_gray_img = self:findImage("gray_img")
	self.m_new_box_reward_slider = self:findSlider("new_box_reward_slider")
	self:refreshUI()
end

function M:refreshUI()
	self:updateRankNode()
	self:setObjectVisible("auto_btn", self.m_model:isHaveRewardCanGet())
	self:refreshBoxStatus()
	
	self:setTextByLanKey("title_text", TITLE_TEXT[self.m_model.m_boss_id or 1])
end

function M:updateRankNode()
	local rank_data = self.m_model:getRankData()
	local recv = self.m_model.m_data.recv
	for i = 1, 5 do
		local rank_cell = self:findGameObject("rank_cell" .. i)
		local transform = rank_cell.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_content_node", rank_data[i] ~= nil)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_rank_text", rank_data[i] == nil)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "statistics_btn", rank_data[i] ~= nil)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_rank_text",  "world_boss_str_0038")
		local rank_bg_img = luaBehaviour:FindImage("rank_bg_img")
		--local reward_box = luaBehaviour:FindGameObject("ArenaRewardWeekBox")
		--reward_box:SetActive(false)
		local good = luaBehaviour:FindGameObject("good")
		if rank_data[i] then
			--rank_bg_img.material = nil
			local data = rank_data[i]
			local HeadNode = luaBehaviour:FindGameObject("HeadNode")
			local statistics_btn = luaBehaviour:FindGameObject("statistics_btn")
			GameUtil:setUserAvatar(HeadNode, data.user, false,nil,{show_flag = true, scale = 1})
			local rank_name_text = LuaBehaviourUtil.setText(luaBehaviour, "rank_name_text",  data.user.name)
			local title_id = data.user.title
			if title_id and title_id ~= 0 then
				rank_name_text.transform.anchoredPosition = Vector3.New(rank_name_pos[i].x,rank_name_pos[i].y-10,0)
			else
				rank_name_text.transform.anchoredPosition = Vector3.New(rank_name_pos[i].x,rank_name_pos[i].y,0)
			end
			LuaBehaviourUtil.setText(luaBehaviour, "good_num_txt",  data.score)
			local function btns()
				self:updateMsg("good", { uid = data.user.uid, like_index = i })
			end
			UIUtil.setButtonClick(good.transform, btns, i)

			local function headNodeClick()
				self:updateMsg("HeadNode", { uid = data.user.uid})
			end
			UIUtil.setButtonClick(HeadNode.transform, headNodeClick, i)

			local function statisticsClick()
				self:updateMsg("statistics_btn", { battle_id = data.battle_id})
			end
			UIUtil.setButtonClick(statistics_btn.transform, statisticsClick)
			local use_time = tostring(math.floor(data.time / 1000))
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_countime_text",  "world_boss_str_0042", use_time)
			if self.m_model:isLike(data.user.uid) then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "good", false)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "good", true)
			end
		else
			--rank_bg_img.material = self.m_gray_img.material
		end
	end
end

function M:refreshBoxStatus()
	local cur_value = 0
	local max_index = 5
	for i = 1, max_index do
		local box_status = self.m_model:getBoxStatus(i)
		local task_box = self:findGameObject("one_box_node" .. i)
		task_box:SetActive(true)
		local transform = task_box.transform
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		local function btns(trans,params)
			if box_status == 2 then -- 可领取
				self:updateMsg("box_reward", {click_transform = transform, data = i})
			else
				self:updateMsg("box_click", {click_transform = transform, data = i, is_look = box_status == 0})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, "", "score_text")
		--local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
		--score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_1 or Color( 255/255, 235/255, 68/255)
		local box_effect = UIUtil.findRectTransform(transform, "UI_Arena_BX_01")
		local box_effect2 = UIUtil.findRectTransform(transform, "UI_Arena_BX_02")
		if box_status == 0 then
			UIUtil.setImg(transform, "a_xwyj_phb_chestoff", "mystic_ui", "box_img")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", false)
			--LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_weidadao", "active_ui")
		elseif box_status == 2 then
			cur_value = cur_value + 1
			UIUtil.setImg(transform, "a_xwyj_phb_chestoff", "mystic_ui", "box_img")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", false)
			--LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_zhengzaidadao", "active_ui")
		elseif box_status == -1 then
			UIUtil.setImg(transform, "a_xwyj_phb_cheston", "mystic_ui", "box_img")
			cur_value = cur_value + 1
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", true)
			--LuaBehaviourUtil.setImg(luaBehaviour, "line_img", "a_dsmz_jingdutiao_yidadao", "active_ui")
		end
		if box_effect ~= nil then
			box_effect.gameObject:SetActive(false)
		end
		if box_effect2 ~= nil then
			box_effect2.gameObject:SetActive(false)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Arena_BX_02", box_status == 2)
		if box_status == 2 then
			if box_effect ~= nil then
				box_effect.gameObject:SetActive(true)
			end
			if box_effect2 ~= nil then
				box_effect2.gameObject:SetActive(true)
			end
		end
	end
	self.m_new_box_reward_slider.value = cur_value / 5
end
function M:updateTime()
	
end

return M