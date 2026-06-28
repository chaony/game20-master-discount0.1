--- 竞技场结算 成功
local M = class("SettlementFulwinArenaWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementFulwinArenaWinNode"

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    local player_left_node = self:findGameObject("player_left_node")
    local player_right_node = self:findGameObject("player_right_node")
    local left_user = self.m_model:getUserInfoBySort(1)
    local right_user = self.m_model:getUserInfoBySort(2)
    self:setPlayerInfo(player_left_node, left_user)
    self:setPlayerInfo(player_right_node, right_user)
end

function M:setPlayerInfo(obj, user, cur_score, pre_score )
    if user then
        local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        GameUtil:setUserAvatar(HeadNode, user, true,nil,{show_flag = true, scale = 1})
    end
end

function M:setAnimation()
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
end

return M