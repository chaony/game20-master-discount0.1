local M = class("ArenaHigherSeasonRankView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaHigher/ArenaHigherSeasonRank"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0882")
	self:refreshUI()
end

function M:refreshUI()

end

return M