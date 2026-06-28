---@class ArenaRTALogView:OOPopBase
---@field m_model ArenaRTALogModel
local M = class("ArenaRTALogView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRTA/ArenaRTALog"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0218")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self:refreshUI()
	--UserDataManager:removeRedDotByKey("race_arena_beat")
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
                self:updateMsg(click_name, {id = index , match_id= cell_data.match_id,log_time=cell_data.log_ts})
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
    --local user = data.user_info or {}
    --local user = UserDataManager.user_data.user_status
	local rival=data.rival
    local name = rival.name
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",rival.uid)
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end
    local head_node = luaBehaviour:FindGameObject("head_node")
	--GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
	local change_score = data.cur_score-data.pre_score
	local change_score_str = tostring(change_score)
	if change_score >=0 then
		change_score_str = "+" .. tostring(change_score)
	else
		change_score_str = tostring(change_score)
	end
	local score_change_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_change_text", change_score_str)
	score_change_text.color = change_score >= 0 and Color( 74/255, 203/255, 57/255) or GlobalConfig.COMMON_COLLOR.COMMON_11

	local log_time = data.log_ts or 0
	local time = math.max(UserDataManager:getServerTime() - log_time, 0)
	local time_str = GameUtil:formatEndTimeBySecond(time)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", tostring(time_str))
	LuaBehaviourUtil.setText(luaBehaviour, "score_text2", data.pre_score)
	LuaBehaviourUtil.setText(luaBehaviour, "score_text1", data.cur_score)

	local isVictory=self.m_model:isVictory(data.winer)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sheng_img",isVictory)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bai_img",not isVictory)
	GameUtil:setUserAvatar(head_node, {avatar =rival.avatar, frame =rival.frame,level=rival.level}, true)

	local isTao=cell_data.battle_id==0 or cell_data.battle_id==nil
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "detail_btn", not isTao)
	if isTao then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "other_tao_img",isVictory)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_tao_img",not isVictory)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "other_tao_img",false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "self_tao_img",false)
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