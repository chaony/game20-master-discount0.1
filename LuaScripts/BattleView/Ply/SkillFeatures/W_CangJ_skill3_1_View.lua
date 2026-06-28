---@class W_CangJ_skill3_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_CangJ_skill3_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model )
end

function M:spawn()
    M.super.spawn(self)
    if IsNull(self.player.tranformHelper) == false and IsNull(self.player.tran) == false then
        self.weapon1_1 = self.player.tranformHelper:FindObj(self.player.tran, "W_CangJ_Weapon01")
        self.weapon1_2 = self.player.tranformHelper:FindObj(self.player.tran, "W_CangJ_Weapon01_1")
        self.weapon2_1 = self.player.tranformHelper:FindObj(self.player.tran, "W_CangJ_Weapon02")
        self.weapon2_2 = self.player.tranformHelper:FindObj(self.player.tran, "W_CangJ_Weapon02_1")
        self.weapon1_1:SetActive(false)
        self.weapon1_2:SetActive(true)
        self.weapon2_1:SetActive(false)
        self.weapon2_2:SetActive(true)
        self:addEventListener_Local(Battle.SkillEventType.W_CangJ_skill3_1_Model_ChangeState, {self,self.W_CangJ_skill3_1_Model_ChangeState});
    end
end

function M:W_CangJ_skill3_1_Model_ChangeState(eventName, data)
    local state = data.state

    if state == 1 then
        self.weapon1_1:SetActive(false)
        self.weapon1_2:SetActive(true)
        self.weapon2_1:SetActive(false)
        self.weapon2_2:SetActive(true)
    elseif state == 2 then
        self.weapon1_1:SetActive(true)
        self.weapon1_2:SetActive(false)
        self.weapon2_1:SetActive(true)
        self.weapon2_2:SetActive(false)
    end
end

return M