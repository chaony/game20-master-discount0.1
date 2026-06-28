--==================================
-- file:  View.lua
-- brief:  巅峰帮会战结算界面
-- author:  LiuMiao
-- date:  2022/7/28
--==================================
local M = class("GuildHighWarMachineMainView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMachineMain/GuildHighWarMachineBuff3"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode =50})
	self:setTextByLanKey("close_title_text", "guild_high_war_text_0082")

	self:setTextByLanKey("cur_des_text", "guild_high_war_text_0085")
	self:setTextByLanKey("last_des_text", "guild_high_war_text_0086")
	self:setTextByLanKey("big_close_btn_txt", "guild_high_war_text_0087")
	self:setObjectVisible("guide_btn",false)
	self:refreshUI()
end

--刷新UI
function M:refreshUI()
	--刷新界面
	--self:updateButtonAndScreen()
	self:updatePoint()
end
local ImgPath = {
	[1] = {di = "a_dfbhz_zwss_jn_dilv",empty = "a_dfbhz_zwss_jn_jianhui",icon = "a_dfbhz_zwss_jn_jianlv"},
	[2] = {di = "a_dfbhz_zwss_jn_dilv",empty = "a_dfbhz_zwss_jn_dunhui",icon = "a_dfbhz_zwss_jn_dunlv"},
	[3] = {di = "a_dfbhz_zwss_jn_dilv",empty = "a_dfbhz_zwss_jn_xinhui",icon = "a_dfbhz_zwss_jn_xinlv"},
	[4] = {di = "a_dfbhz_zwss_jn_dilv",empty = "a_dfbhz_zwss_jn_shuhui",icon = "a_dfbhz_zwss_jn_shulv"},
}
function M:updatePoint()
	for k,v in pairs(self.m_model.talent_point) do
		local pointNode = self:findGameObject("child_img"..v.point_id)
		--self:setImg(ImgPath[v.icon or 1].empty, "maze_stage_ui", "child_img"..v.point_id)
		--self:setImg(ImgPath[v.icon].icon, "maze_stage_ui", "child_img"..v.point_id)
		self:setImg(ImgPath[v.icon or 1].di, "maze_stage_ui", "child_img"..v.point_id)
		if pointNode then
			local pointLuaBehaviour = UIUtil.findLuaBehaviour(pointNode)
			LuaBehaviourUtil.setObjectVisible(pointLuaBehaviour,"child_use",false)
			LuaBehaviourUtil.setImg(pointLuaBehaviour,"child_use",ImgPath[v.icon or 1].icon,"maze_stage_ui")
			LuaBehaviourUtil.setImg(pointLuaBehaviour,"child_use_hui",ImgPath[v.icon or 1].empty,"maze_stage_ui")
			for m,n in pairs(v.open_connect) do
				self:setImg("a_dfbhz_zwss_xian1", "maze_stage_ui", "child_img_xian"..v.point_id.."_"..n)
				self:setImg("a_dfbhz_zwss_xian1", "maze_stage_ui", "child_img_xian"..n.."_"..v.point_id)
			end
		end
	end
	for k,v in pairs(self.m_model.talent_point) do
		local pointNode = self:findGameObject("child_img"..v.point_id)
		if pointNode then
			local pointLuaBehaviour = UIUtil.findLuaBehaviour(pointNode)
			LuaBehaviourUtil.setTextByLanKey(pointLuaBehaviour,"child_num_txt", "guild_high_war_yan_text_006",v.cur_level,v.level_max)
			if 1== v.open_unlock or  v.cur_level >0 then
				LuaBehaviourUtil.setObjectVisible(pointLuaBehaviour,"child_use",true)
				--for m,n in pairs(v.open_connect) do
				--	local pointNode2 = self:findGameObject("child_img"..v.point_id)
				--	local pointLuaBehaviour2 = UIUtil.findLuaBehaviour(pointNode2)
				--	LuaBehaviourUtil.setObjectVisible(pointLuaBehaviour2,"child_use",true)
				--end
			end
			if v.cur_level >= v.level_unlock then
				for m,n in pairs(v.open_connect) do
					self:setImg("a_dfbhz_zwss_xian2", "maze_stage_ui", "child_img_xian"..v.point_id.."_"..n)
					self:setImg("a_dfbhz_zwss_xian2", "maze_stage_ui", "child_img_xian"..n.."_"..v.point_id)
					local pointNode2 = self:findGameObject("child_img"..n)
					local pointLuaBehaviour2 = UIUtil.findLuaBehaviour(pointNode2)
					LuaBehaviourUtil.setObjectVisible(pointLuaBehaviour2,"child_use",true)
				end
			end
		end
	end
end

function M:setSpine(play_img, hero_id)
	local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
	local spine =  "hero_0101_SkeletonData"
	if cfg and next(cfg) ~= nil then
		spine = cfg.hero_spine
	else
		local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
		if cur_skin_cfg and next(cur_skin_cfg) ~= nil then
			spine = cur_skin_cfg.hero_spine
		end
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..spine, "idle", 0, true)
end

function M:setColorA( img, a, isImg )
	if isImg ~= false then
		local color = img.color
		color.a = a
		img.color = color
	else
		img.alpha = a
	end
end
function M:updateAlpha()
	for k,v in pairs(self.m_model.talent_point) do
			if v.cur_level >= v.level_unlock then
				for m,n in pairs(v.open_connect) do
					local data = self.m_model:getCurDataByPointId(n)
					if data.cur_level < data.level_max then
						local img1 = self:findImage("child_img_xian"..v.point_id.."_"..n)
						if img1 then
							self:setColorA(img1,self.m_model.m_alpha)
						end
						local img2 = self:findImage("child_img_xian"..n.."_"..v.point_id)
						if img2 then
							self:setColorA(img2,self.m_model.m_alpha)
						end
					else
						local img1 = self:findImage("child_img_xian"..v.point_id.."_"..n)
						if img1 then
							self:setColorA(img1,1)
						end
						local img2 = self:findImage("child_img_xian"..n.."_"..v.point_id)
						if img2 then
							self:setColorA(img2,1)
						end
					end
				end
			end
	end
end

function M:updateLevelSpine(point_id)
	local nodeObj = self:findGameObject("child_spine"..point_id)
	UIUtil.destroyAllChild(nodeObj.transform)
	local data = self.m_model:getCurDataByPointId(point_id)
	if data.cur_level >= data.level_max then
		local eqp_effect2 = ResourceUtil:GetUIEffectItem("GuildHighWar/UI_GuildHighWarMachineMain_ManJi_001", nodeObj)
	else
		local eqp_effect2 = ResourceUtil:GetUIEffectItem("GuildHighWar/UI_GuildHighWarMachineMain_JieSuo_001", nodeObj)
	end
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end


return M