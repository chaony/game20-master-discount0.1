local M = class("FindThePairsLevelsView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/FindThePairs/FindThePairsLevels"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	local levelsTableTrans = self:findRectTransform("LevelsTable")
	local count = levelsTableTrans.childCount
	if count > 0 then
		for i=count-1,0,-1 do
			local trans = levelsTableTrans:GetChild(i)
			UIUtil.setButtonClick(trans, function()
				local tableLevel = trans:GetComponent("TableLevel")
				CS.TableLevel.selectedLevel = tableLevel;
				CS.LevelsTable.selectedLevelID = tableLevel.ID
				self:updateMsg("open_game")
			end)
		end
	end
end


return M