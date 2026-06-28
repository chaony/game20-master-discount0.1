local M = class("TowerStageControl",LikeOO.OOControlBase)

function M:onEnter()
	-- self:towerQueryFriendsData()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "explain_btn" then
		self:openView("Pops.CommonHelpPop", {title = "tid#tower1", content = "tid#tower2"})
	elseif msg == "rank_btn" then
		self:openView("TowerStage.TowerStageRank")
	elseif msg == "look_detail" then
		local stage_data = data.data
		self:openView("TowerStage.TowerStageDetail", {floor_id = stage_data.floor_id})
	elseif msg == "look_player" then
		local stage_data = data.data
		local players = self.m_model:getFloorPayersByFloorId(stage_data.floor_id)
		self:openView("TowerStage.TowerStagePlayer", {players = players})
	elseif msg == "challenge_btn" then
		self:openView("Pops.CommonPop",{text = Language:getTextByKey("new_str_0055")})
    end
end

--获取好友以及工会好友信息
function M:towerQueryFriendsData()
    local function netCallback(response)
    	if self.m_view then
	        self.m_model:initFloorPayersData(response.tower_data)
	        self.m_view:updatePlayersShow()
    	end
    end
    self.m_model:getNetData("tower_query_friends_data", {}, netCallback)
end

return M
