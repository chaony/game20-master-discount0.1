local M = class("NationalBeautifulBattleBreakView",LikeOO.OOPopBase)

M.m_uiName = "NationalBeautiful/NationalBeautifulBattleBreak"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
	self:setTextByLanKey("close_title_text", "national_beautiful_text_0002")
	self:refreshUI()
	self:setHeroInfo()
end

function M:refreshUI()
	--self.current_milepost_id = self.m_model:getCurrentMilepost()
	self:setTextByLanKey("full_server_text", self.m_model.m_data.all_attack_times)--总击破次数
	self:setTextByLanKey("break_text", self.m_model.m_data.self_attack_times)--个人击破次数
	self:refreshReward()
end

--里程碑奖励
function M:refreshReward()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data = self.m_model:getMilepostData() --获取显示奖励，领取进度
	local width = self.m_box_node_rt.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].cfg.times
	end
	max_num = max_num > 0 and max_num or 100
	self.m_week_box_reward_slider.value = self.m_model.m_data.all_attack_times/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("NationalBeautiful/NationalBeautifulRewardBox", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalScale(transform, 1.0, 1.0, 1.0)
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.times/max_num - width*0.5, 0)
		local function btns(trans,params)
			if data.status == 1 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local show_num = cfg.times
		if show_num > 10000 then
			show_num = math.ceil(show_num/10000).."W"
		end
		local score_text = UIUtil.setText(transform, tostring(show_num), "score_text") --设置奖励位置标识
		local box_img = luaBehaviour:FindGameObject("box_img") --奖励父物体
		--GameUtil:createRewards(box_img.transform, cfg.reward, true, true, nil, 0.85)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_img", data.status == 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_bg", data.status ~= 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "receive_img", data.status == 1)
	end
end

--设置spine
function M:setHeroInfo()
	local hero_cfg = self.m_model:getSkinData()
	local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
	local play_img = self:findGameObject("hero_spine")
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:destroy()
	M.super.destroy(self)
end

return M