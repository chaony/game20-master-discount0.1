---@class BattleVS2:OOUIbase
---@field m_model RTAMainModel
--- 信息查看
local M = class("BattleVS2",LikeOO.OOUIbase)

M.m_uiName = "GamePanel/BattleVS2"
function M:onCreate()

	if self.m_model.battleVSMode==2 then
		self:setObjectVisible("right_head_node",false)
		self:setObjectVisible("left_head_node",false)
		self.m_model.battleVSMode=1
	elseif self.m_model.battleVSMode==1 then
		-- TODO 暂时无数据
		self.dan_icon={
			[1]="rta_dan_badge_qingtong",
			[2]="rta_dan_badge_baiyin",
			[3]="rta_dan_badge_gold",
			[4]="rta_dan_badge_zuanshi",
			[5]="rta_dan_badge_dashi",
		}
		local left_user = self.m_model:getUserInfoBySort(1)--{avatar = 1, level = 1, name = "one"}
		local right_user = self.m_model:getUserInfoBySort(2)--{avatar = 1, level = 1, name = "two"}

		local left_head_node = self:findGameObject("left_head_node")
		local real_left_head_node = self:findGameObject("real_left_head_node")
		local icon_str=self.dan_icon[left_user.tier]
		self:setImg(icon_str,"arena_ui","left_dan_img")
		icon_str=self.dan_icon[right_user.tier]
		self:setImg(icon_str,"arena_ui","right_dan_img")

		GameUtil:setUserAvatar(real_left_head_node, left_user, false, nil, {show_flag = true, scale = 1})
		UIUtil.setTextByLanKey(left_head_node.transform, "left_name_text", tostring(left_user.name))
		UIUtil.setTextByLanKey(left_head_node.transform, "lv_bg/lv_text", "Lv." .. tostring(left_user.level))
		UIUtil.setText(left_head_node.transform,left_user.guild_name,"left_faction_name_text")
		UIUtil.setText(left_head_node.transform,left_user.score,"left_score_text")

		local right_head_node = self:findGameObject("right_head_node")
		local real_right_head_node = self:findGameObject("real_right_head_node")
		GameUtil:setUserAvatar(real_right_head_node, right_user, false,nil,{show_flag = true, scale = 1})
		UIUtil.setTextByLanKey(right_head_node.transform, "right_name_text", tostring(right_user.name))
		UIUtil.setTextByLanKey(right_head_node.transform, "lv_bg/lv_text", "Lv." .. tostring(right_user.level))
		UIUtil.setText(right_head_node.transform,right_user.guild_name,"right_faction_name_text")
		UIUtil.setText(right_head_node.transform,right_user.score,"right_score_text")

		audio:SendEvtUI('UI_DuiJue2')
		self.m_model.battleVSMode=2
	end
end

function M:refreshUI()

end

return M