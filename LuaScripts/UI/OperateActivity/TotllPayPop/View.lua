---@class TotllPayPopView:OOPopBase
local M = class("TotllPayPopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/TotllPayPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "gf_str_0023")
	self:refreshUI()
end

function M:refreshUI()
	self.m_end_ts = self.m_model:getActiveEndTime()
	local play_img = self:findGameObject("hero_spine")
	local cfg, curDayCfg = self.m_model:getHeroBigAnimCfg()
	local hero_spine = nil
	if cfg then
		self:setTextByLanKey("tips_text", Language:getTextByKey(curDayCfg.show_des))
		hero_spine = cfg.hero_spine
		if hero_spine then
			GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. hero_spine, "idle", 0, true)
		end
	end
	
	self:createLoopScroll()
end

function M:createLoopScroll()
	local data = self.m_model:get_gontinuous_cfg()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self:update_Gift(cell_obj, cell_data, index)
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

function M:update_Gift(cell_obj, cell_data, index)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local data = self.m_model:getRechargeById(cell_data.id)
		local rewardNode = luaBehaviour:FindGameObject("rewardNode")
		local show_num = 0
		if next(data) ~= nil then
			show_num = GameUtil:formatNum(data.price) 
		end
		local show_max = GameUtil:switchMoneyType( cell_data.price)
		local status = self.m_model:getReceived(cell_data.id)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_num",  show_num.."/"..show_max)
		local lableTxt = Language:getTextByKey("continue_store_yuan", show_max)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", lableTxt)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", "gf_str_0028",  cell_data.id)
		
		UIUtil.destroyAllChild(rewardNode.transform)
		for k,v in pairs( cell_data.server_reward) do
            local itemNode = GameUtil:createItemElement(v, true, true)
            itemNode.transform:SetParent(rewardNode.transform, false)
            GameUtil:creatChargeEffect(itemNode, v)
			local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
			if itemLuaBehaviour then
				LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", status == 2)
			end
        end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_reward_btn_text", "reward_recive_btn")
		if show_num >= show_max then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", status == 1)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_num", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_text", false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_reward_btn", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_num", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_text", true)
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_img", status == 2)
	end
end

function M:updateTime()

end

return M