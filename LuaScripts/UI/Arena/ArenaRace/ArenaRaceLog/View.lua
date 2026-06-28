---@class ArenaRaceLogView:OOPopBase
---@field m_model ArenaRaceLogModel
local M = class("ArenaRaceLogView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRace/ArenaRaceLog"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0218")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:refreshUI()
	UserDataManager:removeRedDotByKey("race_arena_beat")
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
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
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local user = data.user_info or {}
    local rank = data.rank or 0
    local name = user.name
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end
	local status = data.status -- 0自己 1敌人
	local free_time = self.m_model:getFreeTimes()
	local free_flag = free_time > 0

	local battle_btn_text=nil
	if self.m_model.m_is_zf then
		battle_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_btn_text", "new_str_0219")
		UIUtil.setLocalPosition(battle_btn_text.transform, 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", false)
	else
		battle_btn_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_btn_text", free_flag and "new_str_0231" or "new_str_0219")
		UIUtil.setLocalPosition(battle_btn_text.transform, free_flag and 0 or 15)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_item_node", not free_flag and status == 1)
	end

	--LuaBehaviourUtil.setImg(luaBehaviour, "battle_btn", free_flag and "ui_chenganniu_xiao" or "ui_lvanniu_xiao", "common_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_btn", status == 1)

	--battle_btn_text.gameObject:SetActive(free_flag)
	
    local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
	local change_score = data.change_score or 0
	local change_score_str = tostring(change_score)
	if change_score > 0 then
		change_score_str = "+" .. tostring(change_score)
	end
	local score_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", change_score_str)
	local change_score = data.change_score or 0
	score_text.color = change_score > 0 and GlobalConfig.COMMON_COLLOR.COMMON_12 or GlobalConfig.COMMON_COLLOR.COMMON_11
	local log_time = data.log_time or 0
	local time = math.max(UserDataManager:getServerTime() - log_time, 0)
	local time_str = GameUtil:formatEndTimeBySecond(time)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", tostring(time_str))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0232")
	if  status == 1 and self.m_model.m_master_uid and self.m_model.m_master_uid > 0 and data.revenge == 0 then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "master_battle_btn", true)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "master_battle_btn", false)
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "statistics_btn", cell_data.battle_id ~= 0)

	--争锋联赛需要显示ban侠客
	if self.m_model.m_is_zf then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"forbiddenNode", self.m_model.ban_num>=1)
		if self.m_model.ban_num>=1 then
			local forbiddenNodeTrans=LuaBehaviourUtil.findGameObject(luaBehaviour,"forbiddenNode").transform
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "forbidden_text", "arena_str_0049")
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"forbiddenNode2", self.m_model.ban_num==2)
			if data.heros_ban then
				self:setBanHeroInfo(data.heros_ban[1],"forbiddenNode1",forbiddenNodeTrans)
				if self.m_model.ban_num==2 then
					self:setBanHeroInfo(data.heros_ban[2],"forbiddenNode2",forbiddenNodeTrans)
				end
			else
				self:setBanHeroInfo(nil,"forbiddenNode1",forbiddenNodeTrans)
				if self.m_model.ban_num==2 then
					self:setBanHeroInfo(nil,"forbiddenNode2",forbiddenNodeTrans)
				end
			end
		end

	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"forbiddenNode", false)
	end
end

function M:setBanHeroInfo(id,node,parent)
	local forbiddenNode =UIUtil.findTrans(parent,node)
	UIUtil.setObjectVisible(forbiddenNode,id==nil,"blank_text")
	UIUtil.setObjectVisible(forbiddenNode,id~=nil,"tx_mask")
	if id then
		local hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(id)
		UIUtil.setImg(forbiddenNode, hero_cfg.icon, "hero_head_ui","tx_mask/tx_img")
	end
end

return M