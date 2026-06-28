
local M = class("SettlementTempNode",LikeOO.OOUIbase)

function M:create()
    if self.m_model.bl_new_panel == 1 then
        M.m_uiName = "Settlement/SettlementTempNode_2"
        if self.m_model.m_result == 0 then
            self.m_anim_name = "SettlementTempNode_2_Win" 
        else    
            self.m_anim_name = "SettlementTempNode_2_Loser" 
        end
    else
        M.m_uiName = "Settlement/SettlementTempNode_1"   
        if self.m_model.m_result == 0 then
            self.m_anim_name = "SettlementTempNode_1_Win" 
        else    
            self.m_anim_name = "SettlementTempNode_1_Loser" 
        end
    end
    M.super.create(self)
end

function M:onEnter()
    self.reward_grid = self:findGameObject("reward_grid")
    self:refreshUI()
    self:showReward()
    self:playAnim()
end

function M:refreshUI()
    if self.m_model.m_result == 0 then
        self:setObjectVisible("Loser_obj",true)
        self:setObjectVisible("Win_obj",false)
    elseif self.m_model.m_result == 1 then    
        self:setObjectVisible("Loser_obj",false)
        self:setObjectVisible("Win_obj",true)
    end

    if UserDataManager.guide_data:isGuiding() then
        self:setObjectVisible("win_ok_btn", false)
        self:setObjectVisible("lost_ok_btn", false)
    else
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
            local stage = UserDataManager:getCurStage()
            self:setObjectVisible("win_ok_btn", false)
            self:setObjectVisible("lost_ok_btn", false)
        else
            self:setObjectVisible("win_ok_btn", false)
            self:setObjectVisible("lost_ok_btn", false)
        end
    end
end

function M:onButtonClick(obj, name)
    self:updateMsg(name)
end

function M:update_ok_btn(bl)
    self:setObjectVisible("win_ok_btn", bl)
    self:setObjectVisible("lost_ok_btn", bl)
end

--[[
    奖励列表
]]
function M:showReward()
	self.m_item = {}
    local num = math.min(10,#self.m_model.m_rewards)
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
		UIUtil.setScale(item.transform, 0.8)
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		UIUtil.setOpacity(item.transform, 0)
		self.m_item[i] = item
    end
    self.m_control:setOnceTimer(1,handler(self,self.revealItem))
	self.num = num
end


function M:revealItem()
    for k,v in pairs(self.m_item) do
        UIUtil.setOpacity(v.transform, 1)
    end
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim(self.m_anim_name, handler(self, self.endCallFunc), 1)
    end
end


function M:endCallFunc(animName)

end

function M:playSpine()
    self.win_spine = self:findGameObject("win_spine")
    self.animation = self.win_spine:GetComponent("SkeletonGraphic")
    self:addSpineComplete(self.animation.AnimationState, handler(self,self.setAnimation))
end

function M:setAnimation( )
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
end

return M