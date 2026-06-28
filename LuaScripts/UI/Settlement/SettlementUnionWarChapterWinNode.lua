--- 章节结算 成功
local M = class("SettlementUnionWarChapterWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementUnionWarChapterWinNode"

function M:onEnter()
    self.m_gray_image = self:findImage("gray_image")
	self:setTextByLanKey("title_text", "new_str_0261")
    self:showReward()
    self:refreshUI()
end

function M:refreshUI()

    local star = self.m_model.m_data.star or 0
    for i = 1, 3 do
        local star_img = self:findImage('star_' .. i)
        if i > star then
            star_img.material = self.m_gray_image.material
            star_img.gameObject:SetActive(false)
        else
            star_img.material = nil
            star_img.gameObject:SetActive(true)
        end
    end
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim("SettlementChapterWinNode_show", nil, 1)
    end
end

--[[
    奖励列表
]]
function M:showReward()
    local reward_grid = self:findGameObject("reward_grid")
    local reward = self.m_model.m_rewards or {}
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(reward_grid.transform, false)
    end
end

function M:revealItem()
    for k,v in pairs(self.m_item) do
        UIUtil.setOpacity(v.transform, 1)
    end
end


return M