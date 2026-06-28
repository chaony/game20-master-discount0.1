---@class BattleVS:OOUIbase
---@field m_model GamePanelModel
--- 信息查看
local M = class("BattleVS",LikeOO.OOUIbase)

M.m_uiName = "GamePanel/BattleVS"

function M:onCreate()
	-- TODO 暂时无数据
	local left_user = self.m_model:getUserInfoBySort(1)--{avatar = 1, level = 1, name = "one"}
	local right_user = self.m_model:getUserInfoBySort(2)--{avatar = 1, level = 1, name = "two"}
    local left_head_node = self:findGameObject("left_head_node")
    local real_left_head_node = self:findGameObject("real_left_head_node")
	GameUtil:setUserAvatar(real_left_head_node, left_user, false, nil, {show_flag = true, scale = 1})
	UIUtil.setTextByLanKey(left_head_node.transform, "left_name_text", tostring(left_user.name))
	UIUtil.setTextByLanKey(left_head_node.transform, "lv_bg/lv_text", "Lv." .. tostring(left_user.level))
	local right_head_node = self:findGameObject("right_head_node")
	local real_right_head_node = self:findGameObject("real_right_head_node")
	GameUtil:setUserAvatar(real_right_head_node, right_user, false,nil,{show_flag = true, scale = 1})
	UIUtil.setTextByLanKey(right_head_node.transform, "right_name_text", tostring(right_user.name))
	UIUtil.setTextByLanKey(right_head_node.transform, "lv_bg/lv_text", "Lv." .. tostring(right_user.level))
	audio:SendEvtUI('UI_DuiJue2')
end

function M:refreshUI()

end

return M