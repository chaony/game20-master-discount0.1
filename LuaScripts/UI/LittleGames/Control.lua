local M = class("LittleGamesControl",LikeOO.OOControlBase)

local __bank_name = "UI_LittleGame"

function M:onEnter()
    ResourceUtil:LoadRoleSound(__bank_name)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent")
        self:updateMsg("refresh_red_point",nil,"Hotel")
        self:closeView()
    elseif msg == "choose_btn" then
        self:openView(data.cell_data.view_name)
    elseif msg == "start_btn" then
        if self.m_model.m_game_type == 1 then -- 飞刀
            if self.m_model.is_mult == true then
                self:openView("LittleGames.PirateCask", {group_id = self.m_model.m_version, mult = true})
            else
                self:openView("LittleGames.PirateCask", {group_id = self.m_model.m_data.group_id})
            end
        elseif self.m_model.m_game_type == 2 then -- 开锁
            if self.m_model.is_mult == true then
                self:openView("LittleGames.StopTheLock", {group_id = self.m_model.m_version, game_id = self.m_model.m_game_id, mult = true})
            else
                self:openView("LittleGames.StopTheLock", {group_id = self.m_model.m_data.group_id, game_id = self.m_model.m_game_id})
            end
        elseif self.m_model.m_game_type == 3 then -- 连连看
            if self.m_model.m_open_type and self.m_model.m_open_type == "raccon" then
                self:openView("LittleGames.FindThePairs.FindThePairsMissionsRaccon", {open_type = "Raccon", group_id = self.m_model.m_version, game_id = self.m_model.m_game_id, mult = true})
            elseif self.m_model.is_mult == true then
                self:openView("LittleGames.FindThePairs.FindThePairsMissions", {group_id = self.m_model.m_version, game_id = self.m_model.m_game_id, mult = true})
            else
                self:openView("LittleGames.FindThePairs.FindThePairsMissions", {group_id = self.m_model.m_data.group_id, game_id = self.m_model.m_game_id})
            end
        elseif self.m_model.m_game_type == 4 then -- 打地鼠
            if self.m_model.is_mult == true then
                self:openView("LittleGames.WhackGame", {group_id = self.m_model.m_version, game_id = self.m_model.m_game_id, mult = true})
            else
                self:openView("LittleGames.WhackGame", {group_id = self.m_model.m_data.group_id, game_id = self.m_model.m_game_id})
            end
        elseif self.m_model.m_game_type == 5 then -- 拼图
            if self.m_model.is_mult == true then
                self:openView("LittleGames.JigsawPuzzle", {group_id = self.m_model.m_version, game_id = self.m_model.m_game_id, mult = true})
            else
                self:openView("LittleGames.JigsawPuzzle", {group_id = self.m_model.m_data.group_id, game_id = self.m_model.m_game_id})
            end
        else
            Logger.logError(self.m_model.m_game_id, "self.m_model.m_game_id not found : ")
        end
    elseif msg == "rank_reward_btn" then
        self:openView("LittleGames.LittleGamesRankReward", {mult = self.m_model.is_mult, key = self.m_model.m_key})
    elseif msg == "box_click" then
        local rewards = data.data.cfg.reward or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.data.status == -1})
    elseif msg == "box_reward" then
        if self.m_model.is_mult == true then
            self:gameMultStreetReceive(data.data)
        else
            self:gameStreetReceive(data.data)
        end
    elseif msg == "refresh_ui" then
        self:gameStreetIndex()
    elseif msg == "item_click" then
        local item_data = data.cell_data
        self:openView("Pops.PlayerInfo", {uid = item_data.user.uid})    
    end
end

-- 竞技场刷新
function M:gameStreetIndex()
    if self.m_model.is_mult == true then
        local function receivetCallback(response)
            self.m_model.m_data.score = response.score or self.m_model.m_cur_score
            self.m_model:initMultScoreRewardData()
            self:updateMsg("updateScore", {id = self.m_model.m_version, num = response.score}, "GiftBag.CelebrateNewYear.NewYearMiNiGame")
            self.m_view:refreshUI()
        end
        local params = {}
        params.version = self.m_model.m_version
        params.start = 1
        params.stop = 10
        self.m_model:getNetData("mult_rank_info", params, receivetCallback)
	else
        local function receivetCallback(response)
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        local params = {group_id = self.m_model.m_group_id}
        self.m_model:getNetData("game_street_index", params, receivetCallback)
	end
end

-- -领奖 group_id: 组id  reward_id: 奖励id
function M:gameStreetReceive(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    local params = {group_id = self.m_model.m_data.group_id, reward_id = data.id}
    self.m_model:getNetData("game_street_receive", params, receivetCallback)
end

-- -多期领奖 group_id: 组id  reward_id: 奖励id
function M:gameMultStreetReceive(data)
    local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self:updateMsg("updateData", response, "GiftBag.CelebrateNewYear.NewYearMiNiGame")
        self.m_model.m_data.score = response.scores[tostring(self.m_model.m_version)] or self.m_model.m_cur_score
        table.merge(self.m_model.m_params.recv, response.recv_dict[tostring(self.m_model.m_version)] or self.m_model.m_params.recv)
        self.m_model:initMultScoreRewardData()
        self.m_view:refreshUI()
    end
    local params = {version = self.m_model.m_version, reward_id = data.id}
    self.m_model:getNetData("mult_receive", params, receivetCallback)
end

function M:onDestroy()
    ResourceUtil:UnLoadRoleSound(__bank_name)
end

return M
