local M = class("ShiguangControl",LikeOO.OOControlBase)

function M:onEnter()
    SceneManager:changeScene(SceneManager.SceneID.ShiGuangScene, {})
    SceneManager:scenestart()
    SceneManager.curScene:setServerData(self.m_model.m_chapter_id, self.m_model.m_data)
end

function M:onHandle(msg,data)
    if msg == 99999 then
        self:updateMsg("common_refresh", nil, "parent")  
        self:closeView()
    elseif msg == "get_reward_btn" then
        if SceneManager ~= nil then
            SceneManager:changeScene(SceneManager.SceneID.ShiGuangScene, self.m_model)
            SceneManager:scenestart()
        end
    elseif msg == "talk" then
        local function callback(event_data)
            if data.callback then
                data.callback(event_data)
            end
            if data.heirloom_reward and #data.heirloom_reward > 0 then
                self:openView("Pops.RelicReward", {heirlooms = data.heirloom_reward})
            end
        end
        self:openView("Guide.GuideDrama", {dialog_id = data.talk_id, callback = callback, choise = data.choise, choise_id = data.choise_id})
    elseif msg == "open_detail" then
        self:openDetail(data)
    elseif msg == "open_yiwu" then
        self:openYiWu(data)
    elseif msg == "open_yongbing" then
        self:openYongBing(data)
    elseif msg == "open_quanshui" then
        self:openQuanShui(data)
    elseif msg == "open_fuhuo" then
        self:openFuhuo(data)
    elseif msg == "rpg_goto" then
        self:rpgGoto(data)
    elseif msg == "rpgClickObj" then
        self:rpgClickObj(data)
    elseif msg == "rpg_chioce_option" then   
        self:rpgChioceOption(data)
    elseif msg == "goto_battle" then
        self.cell_data = data.data
        self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.TOP_OF_TIME, chapter_id = self.cell_data.chapter_id, block_id = self.cell_data.block_id, def_data = data.data, assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns})
    elseif msg == "battle_end_refresh_ui" then
        self.m_model:netData(data.data)
        if data.open_formation == 1 then -- 战斗失败去布阵
            if self.cell_data then
                local block_data = self.m_model:getBlockDataById(self.cell_data.block_id)
                self:openView("Formation",{mode = GlobalConfig.BATTLE_MODE.TOP_OF_TIME, chapter_id = self.cell_data.chapter_id, block_id = self.cell_data.block_id, def_data = block_data, assist_heros = self.m_model.m_data.assist_heros, heirlooms = self.m_model.m_data.heirlooms, dyns = self.m_model.m_data.dyns, enter_call_func = data.func})
            end
        else
            if SceneManager ~= nil then
                SceneManager:changeScene(SceneManager.SceneID.ShiGuangScene, self.m_model)
                SceneManager:scenestart()
                SceneManager.curScene:rpgBattleEnd(data.data);
            end
        end
    elseif msg == "hero_btn" then -- 武魂
        self:openView("Shiguang.ShiguangHeros", {data = self.m_model.m_data})
    elseif msg == "relic_formation_btn" then
        self:openView("Shiguang.ShiguangRelicFormationShow", {data = self.m_model.m_data})
    elseif msg == "event_list_btn" then -- 传记
        self:openView("Shiguang.ShiguangEventLog", {event_done = self.m_model.m_data.event_done, chapter_id = self.m_model.m_chapter_id})
    elseif msg == "change_scene" then
        SceneManager:changeScene(SceneManager.SceneID.ShiGuangScene,self.m_model)
    elseif msg == "shiguang_select_heirloom" then
        self:selectHeirLoom(data.data, data.heirloom_id)
    elseif msg == "shiguang_employ" then
        self:shiguang_employ(data.data, data.hero_oid)
    elseif msg == "game_over" then
        self:openBattleOver(data)
    elseif msg == "reset_btn" then
        self:rpgMapReset()
    elseif msg == "explain_btn" then --说明
        self:openView("Pops.CommonHelpPop", { title = "tid#rpg_rule1", content = "tid#rpg_rule2" })
    end
end

function M:openBattleOver(data)
    self:openView("Shiguang.ShiguangBattleOver", {ending_event = data.ending_event, chapter_id = self.m_model.m_chapter_id})
    local ending_reward_done = self.m_model.m_data.ending_reward_done or {}
    local ending_event = data.ending_event or -1
    local key = table.keyof(ending_reward_done, ending_event)
    if key == nil then -- 单独显示通关奖励
        local roleplaying_ending = ConfigManager:getCfgByName("roleplaying_ending")
        local roleplaying_ending_item_cfg = roleplaying_ending[self.m_model.m_chapter_id] or {}
        local team_cfg = roleplaying_ending_item_cfg[ending_event] or {}
        local ending_reward = team_cfg.ending_reward or {}
        if ending_reward and #ending_reward > 0 then
            self:openView("Shiguang.ShiguangBattleOverReward", {ending_reward = ending_reward})
        end
    end
end

function M:shiguang_employ(data, hero_oid)
    local chapter_id = data.chapter_id
    local block_id = data.block_id
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgClickObj(response);
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {chapter_id = chapter_id, block_id = block_id, hero_oid = hero_oid }
    self.m_model:getNetData("rpg_click_obj", params, netCallback,nil,nil,GlobalConfig.POST)
end


function M:selectHeirLoom(data, heirloom_id)
    local chapter_id = data.chapter_id
    local block_id = data.block_id
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgClickObj(response);
            RewardUtil:rewardTipsByData(response.reward)
            self.m_view:refreshUI()
        end
    end
    local params = {chapter_id = chapter_id, block_id = block_id, heirloom_id = heirloom_id }
    self.m_model:getNetData("rpg_click_obj", params, netCallback,nil,nil,GlobalConfig.POST)
end

function M:openDetail(data)
    self:openView("Shiguang.ShiguangDetail", {data = data})
end

function M:openYiWu(data)
    self:openView("Shiguang.ShiguangRelicSelect", {data = data, show_tips = false})
end

function M:openYongBing(data)
    self:openView("Shiguang.ShiguangHeroSelect", {data = data})
end

function M:openQuanShui(data)
    self:openView("Shiguang.ShiguangHospital", {data = data})
end

function M:openFuhuo(data)
    self:openView("Shiguang.ShiguangHospital", {data = data})
end

--选择选项
function M:rpgChioceOption(data)
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgChioceOption(response);
        end
    end
    self.m_model:getNetData("rpg_choice_option", data, netCallback,nil,nil,GlobalConfig.POST)
end

--chapter_id: 1001  block_id: 10010000  path: [10010000, 10010001]
--地图-前往某点
function M:rpgGoto( data )
    local chapter_id = data.chapter_id
    local block_id = data.block_id
    local path = data.path
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgGoto(response);
        end
    end
    local params = {chapter_id = chapter_id, block_id = block_id,path = path }
    self.m_model:getNetData("rpg_goto", params, netCallback,nil,nil,GlobalConfig.POST)
end


--chapter_id: 1001  block_id: 10010000  path: [10010000, 10010001]
--地图-前往某点
function M:rpgClickObj( data )
    local chapter_id = data.chapter_id
    local block_id = data.block_id
    local function netCallback(response)
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:rpgClickObj(response);
            RewardUtil:rewardTipsByData(response.reward)
        end
    end
    local params = {chapter_id = chapter_id, block_id = block_id }
    self.m_model:getNetData("rpg_click_obj", params, netCallback,nil,nil,GlobalConfig.POST)
end



--地图重置
function M:rpgMapReset()
    local params =
    {
        on_ok_call = function(msg)
            local function netCallback(response)
                SceneManager:clear("shiguang_block_net_data")
                GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey("new_str_0414"), delay_close = 2})
                self:closeView()
                -- SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
            end
            local params = { team_id =  self.m_model.m_team_id ,chapter_id = self.m_model.m_chapter_id }
            self.m_model:getNetData("rpg_map_reset", params, netCallback)
        end,
        text = Language:getTextByKey("new_str_0431"),
    }
    self:openView("Pops.CommonPop", params)
end

function M:onDestroy()
    SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
end

return M;
