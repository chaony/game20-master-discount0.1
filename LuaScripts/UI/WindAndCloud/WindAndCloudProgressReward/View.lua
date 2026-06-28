local M = class("WindAndCloudProgressRewardView",LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudProgressReward"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
	self.gray_img = self:findImage("hui")
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
	self:setTextByLanKey("score_name_text", "wind_clouds_text_0001") --全服修行积分：
	self:setTextByLanKey("self_score_name_text", "wind_clouds_text_0002") --个人修行：
	if self.m_model.active_data then
		self:setTextByLanKey("close_title_text", self.m_model.active_data.name)
	end
	self:setObjectVisible("fengyunjihui_2",false)
	self:refreshUI()
end

function M:refreshUI()
	self:setTextByLanKey("self_score_value_text", self.m_model.m_data.self_score) --个人修行
	local Intimacy_text = self.m_model.m_data.score
	self:setTextByLanKey("score_value_text", Intimacy_text) --全服修行
	self.current_milepost_id = self.m_model:getCurrentMilepost()
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
		max_num = show_data[box_num].cfg.score
	end
	max_num = max_num > 0 and max_num or 100
	self.m_week_box_reward_slider.value = self.m_model.m_data.score/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("WindAndCloud/WindAndCloudRewardBox", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalScale(transform, 1.0, 1.0, 1.0)
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.score/max_num - width*0.5, 0)
		local function btns(trans,params)
			if data.status == 1 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local show_num = cfg.score
		if show_num > 10000 then
			show_num = math.ceil(show_num/10000).."W"
		end
		local score_text = UIUtil.setText(transform, tostring(show_num), "score_text") --设置奖励位置标识
		local box_img = luaBehaviour:FindGameObject("box_img") --奖励父物体
		--GameUtil:createRewards(box_img.transform, cfg.reward, true, true, nil, 0.85)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_img", data.status == 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "box_bg", data.status == 0)
		self:setObjectVisible("fengyunjihui_3_"..i,self.m_model.m_data.score >= cfg.score)
		self:setObjectVisible("mileage_not_reached_"..i,self.m_model.m_data.score < cfg.score)
		self:setObjectVisible("mileage_reached_"..i,self.m_model.m_data.score >= cfg.score)
		self:setObjectVisible("mileage_light_text_"..i,self.m_model.m_data.score >= cfg.score)
		self:setObjectVisible("mileage_text_"..i,self.m_model.m_data.score < cfg.score)
		self:setObjectVisible("mileage_current_reached_"..i,i == self.current_milepost_id)
		self:setTextByLanKey("mileage_light_text_"..i,show_num)
		self:setTextByLanKey("mileage_text_"..i,show_num)
	end
end

--播放烟花
function M:showFireworks()
	self:setObjectVisible("fengyunjihui_2",true)
	self.m_control:setOnceTimer(5.0,function()
		self:setObjectVisible("fengyunjihui_2",false)
	end)
end

function M:destroy()
	M.super.destroy(self)
end

return M