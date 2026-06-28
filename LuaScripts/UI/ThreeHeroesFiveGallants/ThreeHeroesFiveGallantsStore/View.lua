local M = class("ThreeHeroesFiveGallantsStoreView",LikeOO.OOPopBase)

M.m_uiName = "ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsStore"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	--滑动条组件
	self.m_bg_obj = self:findGameObject("bg")
	self.m_box_node = self:findGameObject("box_node")
	self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
	self.m_week_box_reward_slider = self:findSlider("week_box_reward_slider")
	local name = self.m_model:getActiveName()
	self:setTextByLanKey("close_title_text", name)
	self:refreshUI()
end

function M:refreshUI()
	self:refreshBG()
	self:refreshStoreStage()
	self:refreshReward()
end

function M:refreshBG()
	GameUtil:updateResourcesImg(self.m_bg_obj, "Texture/map_plot/" .. self.m_model:getCurrentBGName())
end

--刷新故事状态
function M:refreshStoreStage()
	--故事信息
	local store_data = self.m_model:getStoreData()
	local start_id = (self.m_model.current_tab - 1) * 4 + 1
	local end_id = self.m_model.current_tab * 4
	for i = start_id, end_id do
		local btn_id = i - start_id + 1
		local btn_name = "btn_"..btn_id
		local btn_text_name = "btn"..btn_id.."_text"
		local btn_suo_name = "suo_"..btn_id
		self:setObjectVisible(btn_name,store_data[i] ~= nil)
		if store_data[i] ~= nil then
			local data = store_data[i]
			self:setTextByLanKey(btn_text_name,data.cfg.name)
			self:setObjectVisible(btn_suo_name,data.open_condition == -1 or data.open_condition > self.m_model.m_score)
		end
	end

	--左右按钮
	self:setObjectVisible("btn_right",self.m_model.current_tab > 1)
	self:setObjectVisible("btn_left",self.m_model.current_tab * 4 < #store_data)
end


--里程碑奖励
function M:refreshReward()
	local box_trans = self.m_box_node.transform
	UIUtil.destroyAllChild(box_trans)
	local show_data, cur_num = self.m_model:getRewardBoxData() --获取显示奖励，领取进度
	local width = self.m_box_node_rt.rect.width
	local max_num = 0
	local box_num = #show_data
	if show_data[box_num] then
		max_num = show_data[box_num].cfg.parameter
	end
	max_num = max_num > 0 and max_num or 100
	self.m_week_box_reward_slider.value = cur_num/max_num
	for i=1,box_num do
		local data = show_data[i]
		local cfg = data.cfg
		local task_box = GameUtil:createPrefab("ThreeHeroesFiveGallants/ThreeHeroesFiveGallantsReward", box_trans)
		local transform = task_box.transform
		UIUtil.setLocalScale(transform, 0.7, 0.7, 1.0)
		local luaBehaviour = UIUtil.findLuaBehaviour(transform)
		UIUtil.setLocalPosition(task_box, width*cfg.parameter/max_num - width*0.5, 20)
		local function btns(trans,params)
			if data.status == 1 then -- 可领取
				self:updateMsg("box_reward", {click_transform = trans, data = data})
			else
				self:updateMsg("box_click", {click_transform = trans, data = data})
			end
		end
		UIUtil.setButtonClick(transform, btns, i)
		local score_text = UIUtil.setText(transform, tostring(cfg.parameter), "score_text") --设置奖励位置标识
		local box_img = luaBehaviour:FindGameObject("box_img") --奖励父物体
		GameUtil:createRewards(box_img.transform, cfg.reward, true, true, nil, 0.85)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"got_flag_img",data.status == 2)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light_img", data.status == 1)
	end
end

return M