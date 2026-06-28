
---@class JuBaoShanTaskItem @
local M = class("JuBaoShanTaskItem")

function M:init(scene, task_data, finish )
    self.m_scene = scene;
    self.m_data = task_data
    self.m_finish = finish
    self.next_cell = nil;
    self.m_start = false;
end

function M:start()
    --Logger.logError(" 任务开始 "..self.m_data.m_type )
    self.m_start = true;
    self.cur_cell_id = self.m_scene.cur_cell.cell_index;
    if self.m_data.m_type == "play_move" then
        self.m_scene:playerStartMove();
    end
end

function M:stop()
    --Logger.logError(" 任务结束 "..self.m_data.m_type )
    self.m_start = false;
    if self.m_data.m_type == "play_move" then
        self.m_scene:playerEndMove();
    end
end
local __xuanshangling_id = "5025"
function M:update( dt )
    if self.m_start then
        if self.m_data.m_type == "update_cells" then
            --更新格子
            for i, v in pairs(self.m_data.m_cells) do
                local index = tonumber(i);
                local data = v;
                self.m_scene:updateCellInfoByServerData(index, data);
            end
            if self.m_finish ~= nil then
                self.m_finish();
                self:stop();
            end
        elseif self.m_data.m_type == "update_global_cells" then
            --更新格子
            for i, v in pairs(self.m_data.m_cells) do
                local index = tonumber(i);
                local data = v;
                self.m_scene:updateGloablCells(index, data);
            end
            if self.m_finish ~= nil then
                self.m_finish();
                self:stop();
            end
        elseif self.m_data.m_type == "play_move" then
            if self.m_data.m_action == "forward" then
                --当前的索引
                if self.next_cell == nil then
                    self.cur_cell_id = self.cur_cell_id + 1;
                    if self.cur_cell_id > self.m_scene.max_cell_num then
                        self.cur_cell_id = self.m_scene.min_cell_num;
                    end
                    self.next_cell = self.m_scene:getCellInfoByIndex( self.cur_cell_id )
                end
                if self.next_cell ~= nil then
                    --玩家移动
                    self.m_scene:playerMove(dt, self.next_cell, function()
                        self.m_scene:setCurCell( self.next_cell);
                        self.next_cell = nil;
                        if self.cur_cell_id == self.m_data.m_target then
                            if self.m_finish ~= nil then
                                self.m_finish();
                            end
                            self:stop();
                        end
                    end)
                else
                    if self.m_finish ~= nil then
                        self.m_finish();
                    end
                    self:stop();
                end
            elseif self.m_data.m_action == "back" then
                --当前的索引
                if self.next_cell == nil then
                    self.cur_cell_id = self.cur_cell_id - 1;
                    if self.cur_cell_id < self.m_scene.min_cell_num then
                        self.cur_cell_id = self.m_scene.max_cell_num;
                    end
                    self.next_cell = self.m_scene:getCellInfoByIndex( self.cur_cell_id )
                end
                if self.next_cell ~= nil then
                    --玩家移动
                    self.m_scene:playerMove(dt, self.next_cell, function()
                        self.m_scene:setCurCell(self.next_cell);
                        self.next_cell = nil;
                        if self.cur_cell_id == self.m_data.m_target then
                            if self.m_finish ~= nil then
                                self.m_finish();
                            end
                            self:stop();
                        end
                    end)
                else
                    if self.m_finish ~= nil then
                        self.m_finish();
                    end
                    self:stop();
                end
            elseif self.m_data.m_action == "transfer" then
                --瞬移,直接移动到位置
                self.m_scene:setPlayerPositionByIndex(self.m_data.m_target);
                --获取奖励
                if self.m_finish ~= nil then
                    self.m_finish();
                    self:stop();
                end
            end
        elseif self.m_data.m_type == "get_reward" then
            local from_rewards = {}
            local reward_items = {}
            for type_id, type_item in pairs(self.m_data.m_reward) do
                for building_id, build_item in pairs(type_item) do
                    local from_reward_item = {}
                    from_reward_item.map_id = SceneManager:getCurSceneModel().m_data.map_id
                    from_reward_item.item_type = tonumber(type_id)
                    from_reward_item.item_id = tonumber(building_id)
                    table.insert(reward_items,build_item)
                    for build_key, build_value in pairs(build_item) do
                        local key = string.upper(build_key)
                        if type(build_value) == "table" then
                            if build_value[1] == nil then
                                for i, v in pairs(build_value) do
                                    key = key.."_"..i;
                                end
                                from_rewards[key] = from_reward_item;
                            else
                                for i, v in pairs(build_value) do
                                    key = key.."_"..v;
                                end
                                from_rewards[key] = from_reward_item;
                            end
                        elseif type(build_value) == "number" then
                            local key_value = RewardUtil.REWARD_TYPE_KEYS[key]
                            if key_value ~= nil then
                                from_rewards[key_value] = from_reward_item;
                            end
                        end
                    end
                end
            end

            if reward_items[1] and reward_items[1].reward_full_tips and reward_items[1].reward_full_tips[1] then
                if self.m_finish ~= nil then
                    self.m_finish();
                end
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey(reward_items[1].reward_full_tips[1]), delay_close = 2})
            else
                local reward_data = RewardUtil:mergeRewardList(reward_items)
                --Logger.logError(self.m_data.m_reward," 原始奖励数据 ")
                --Logger.logError(reward_items," 原始数据 ~~~~~~~~~~~~ ")
                --Logger.logError(from_rewards," 来自数据 ~~~~~~~~~~~~ ")
                --Logger.logError(reward_data," 领取建立数据 ~~~~~~~~~~~~")
                if next(reward_data) and reward_data.coin then --获取金币时播放音效
                     --audio:SendEvtUI("UI_Coin_Fx")
                elseif next(reward_data) and reward_data.item and reward_data.item[__xuanshangling_id]  then--获取悬赏令时播放音效
                     --audio:SendEvtUI("UI_XSTicket_Fx")
                end
                static_rootControl:updateMsg("got_jubaoshanAward", {awardData = reward_data, callBack = function()
                    --获取奖励
                    --点击关闭之后完成任务
                    if self.m_finish ~= nil then
                        self.m_finish();
                    end
                end,rewardCallBack = { from_rewards = from_rewards }}, "JuBaoShan")
            end
            self:stop();
        elseif self.m_data.m_type == "cycle_reward" then
            local reward = {}
            local from_rewards = 999;
            table.insert( reward,self.m_data.m_reward )
            local reward_data = RewardUtil:mergeRewardList(reward)
            --Logger.logError(self.m_data.m_reward," 跑圈奖励 " )
            --Logger.logError(reward_data," 跑圈奖励 XXXX " )
            static_rootControl:updateMsg("got_jubaoshanAward", {awardData = reward_data, callBack = function()
                --获取奖励
                --点击关闭之后完成任务
                if self.m_finish ~= nil then
                    self.m_finish();
                end
            end,rewardCallBack = { from_rewards = from_rewards }}, "JuBaoShan")
            self:stop();
        elseif self.m_data.m_type == "get_event" then
            local dice_event_type = ConfigManager:getCfgByName("dice_event_type");
            local dice_item = dice_event_type[self.m_data.m_event_type][self.m_data.m_event_id]
            if dice_item ~= nil then
                if dice_item.tips ~= "" then
                    GameUtil:lookInfoTips(static_rootControl, { msg = Language:getTextByKey(dice_item.tips), delay_close = 2 })
                end
            end
            TimeTools:delayTimeUnity(0.5, function()
                if self.m_finish ~= nil then
                    self.m_finish();
                end
            end)
            self:stop();
        end
    end
end

return M;