---@class RTAServerAllLogView:OOPopBase
---@field m_model RTAServerAllLogModel
local M = class("RTAServerAllLogView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaRTA/RTAServerAllLogPop"
M.m_size_type = 2

function M:onEnter()
	self.grade_icon={
		[1]="rta_dan_badge_qingtong",
		[2]="rta_dan_badge_baiyin",
		[3]="rta_dan_badge_gold",
		[4]="rta_dan_badge_zuanshi",
		[5]="rta_dan_badge_dashi",
	}

	self:setTextByLanKey("common_title_text", "arena_rta_str_0019")
	self:setTextByLanKey("common_no_have_text", "new_str_0351")
	self.m_gray_img = self:findImage("gray_img")
	self.refresh_btn_img=self:findImage("refresh_btn")
	if self.m_model.refresh_cd~=nil then
		if self.m_model.refresh_cd>0 then
			self:setTextByLanKey("refresh_text","arena_rta_str_0026",self.m_model.refresh_cd)
			self:startRefreshTimer()
		else
			self:setTextByLanKey("refresh_text","arena_rta_str_0026")
			self.refresh_btn_img.material=nil
		end
	else--无数据时
		self:setObjectVisible("refresh_btn",false)
		self:setObjectVisible("refresh_text",false)
		self:setTextByLanKey("common_no_have_text", "new_str_0351")
	end
	self:setObjectVisible("common_tips_node",self.m_model.refresh_cd==nil)
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end


function M:startRefreshTimer()
	self.refresh_btn_img.material = self.m_gray_img.material
	self.m_control:setTimer(1,function()
		self.m_model.refresh_cd=self.m_model.refresh_cd-1
		if self.m_model.refresh_cd<=0 then
			self:setTextByLanKey("refresh_text","arena_rta_str_0027")
			self.refresh_btn_img.material=nil
		else
			self:setTextByLanKey("refresh_text","arena_rta_str_0026",self.m_model.refresh_cd)
		end
	end)
end

function M:refreshTimeUI()

end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	local dataLen=#data
	self:setObjectVisible("common_tips_node",  dataLen== 0)

	self:setObjectVisible("refresh_btn",dataLen ~= 0)
	self:setObjectVisible("refresh_text",dataLen ~= 0)
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

	local winer,loser=self.m_model:getWinerAndLoser(data)
	if type(winer.score)~="number" or type(data.atk.avatar)=="function" or type(data.def.avatar)=="function" then
		Logger.logError("not number")
		return
	end
	local tm=TimeUtil.gmTime(cell_data.log_ts)
	local time_str = string.format("%d/%02d/%02d %02d:%02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec)
	LuaBehaviourUtil.setText(luaBehaviour, "time_text",time_str)

	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "win_side_score_text","arena_rta_str_0014",winer.score)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lose_side_score_text", "arena_rta_str_0014",loser.score)


	LuaBehaviourUtil.setText(luaBehaviour,"win_side_name_text",winer.name)
	LuaBehaviourUtil.setText(luaBehaviour,"lose_side_name_text",loser.name)

	local icon=self.grade_icon[winer.tier]
	UIUtil.setImg(transform,icon,"arena_ui","cell_item_node/winSide/win_side_lv_img")
	--self:setImg(icon,"arena_ui","win_side_lv_img")
	if icon==nil then
		Logger.log("sddddddddddd")
	end

	icon=self.grade_icon[loser.tier]

	--if icon2==nil then
	--	Logger.log("sddddddddddd")
	--end
	--self:setImg(icon2,"arena_ui","lose_side_lv_img")
	UIUtil.setImg(transform,icon,"arena_ui","cell_item_node/loseSide/lose_side_lv_img")

	self:setHero(winer.heros,"win_hero_",true,luaBehaviour)
	self:setHero(loser.heros,"lose_hero_",false,luaBehaviour)

end


function M:setHero(heros, prefixstr, isWiner,luaBehaviour)
	local hero_trans =nil
	if heros~=nil then
		if table.nums(heros)==0 then
			Logger.logWarning("00000000000000")
		end
		if isWiner then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"winSideHeros",true)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"loseSideHeros",true)
		end
		local hero_num=#heros
		for i = 1, 5 do
			hero_trans =LuaBehaviourUtil.findGameObject(luaBehaviour,prefixstr..i).transform

			local hero_tid =nil
			if i<=hero_num then
				hero_tid =heros[i]
			end
			if hero_tid then
				hero_trans.gameObject:SetActive(true)
				local itemData = RewardUtil:getProcessRewardData({ RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_tid, 1})
				GameUtil:updateItemElementByData(hero_trans.transform, itemData)
				--luabehaviour=UIUtil.findLuaBehaviour(hero_trans)
				--LuaBehaviourUtil.setObjectVisible(luabehaviour,"banned_img",hero_data.ban==1)
			else
				hero_trans.gameObject:SetActive(false)
			end
		end
	else
		if isWiner then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"winSideHeros",false)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"loseSideHeros",false)
		end
	end
end

--function M:setBanHeroInfo(id,node,parent)
--	local forbiddenNode =UIUtil.findTrans(parent,node)
--	UIUtil.setObjectVisible(forbiddenNode,id==nil,"blank_text")
--	UIUtil.setObjectVisible(forbiddenNode,id~=nil,"tx_mask")
--	if id then
--		local hero_cfg=UserDataManager.hero_data:getHeroConfigByCid(id)
--		UIUtil.setImg(forbiddenNode, hero_cfg.icon, "hero_head_ui","tx_mask/tx_img")
--	end
--end

return M