local M = class("DragonBoatChargePopView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DragonBoat/DragonBoatChargePop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", self.m_model.title_name)
	self:refreshUI()
end

function M:refreshUI()
	--self:refreshEndTs()
	self:createLoopScroll()
	--self:refreshRedPoint()
end

function M:refreshEndTs()
	self.m_end_ts = self.m_model:getActiveEndTime()
end

--刷新红点
function M:refreshRedPoint()
	for i = 1, 3 do 
		self:setObjectVisible("tog_"..i.."_red_point_img", self.m_model:checRedPoint(i) == true)
	end
end

function M:createLoopScroll()
	local data = self.m_model:get_recharge_cfg()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self:update_Gift(cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				self:updateMsg(click_name, cell_data.id)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
end

function M:update_Gift(cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local rewardNode = luaBehaviour:FindGameObject("rewardNode")
		local show_max =  cell_data.amount
		--local c_num = self.m_model.m_cmlt_recharge_data.value > show_max and show_max or self.m_model.m_cmlt_recharge_data.value
		local c_num = self.m_model.total_cook_times
		local show_num = GameUtil:formatNum(c_num)

		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "reward_recive_btn")
		

		local get_bl = self.m_model:getCmltReceived(cell_data.id)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_num",  show_num.."/"..show_max)
		local lableTxt = Language:getTextByKey("accumulate_store_yuan", show_max)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", cell_data.name)
		UIUtil.destroyAllChild(rewardNode.transform)
		for k,v in pairs(cell_data.reward) do
            local itemNode = GameUtil:createItemElement(v, true, true)
            itemNode.transform:SetParent(rewardNode.transform, false)
            GameUtil:creatChargeEffect(itemNode, v)
			local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
			if itemLuaBehaviour then
				--LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", get_bl == true)
			end
        end
		if show_num >= show_max then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", get_bl == false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_num", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_text", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_num", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_text", true)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_img", get_bl == true)
	end
end

return M