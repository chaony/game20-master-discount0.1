local M = class("GuJianQiTanMazeMainControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.GuJianQiTan.GuJianQiTanMazeMain.Guide"
end

function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(33, 2)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refreshRedPoint" ,nil ,"Main.Outskirts")
        self:closeView()
    elseif msg == "guide_btn" then --快速导航
        self:openView("WorldMap.WorldMapGuide", {pop_from_func_id = 38})
    elseif msg == "task_cell_btn" then
        --点击进入迷宫
        if self.m_model.m_params.data.counter == 0 then
            --第一次进入
            data.id = 0;
        end
        if data.cell_data.is_complete == true then
            if self.m_model.m_params.data.left_times > 0 and data.id ~= 0 then
                local params = {
                    on_ok_call = function(msg)
                        self:mazeSweep(data);
                        --self:requestChooseFloor(data);
                    end,
                    new_cancel_call = function(msg)
                        --直接进入
                        self:requestChooseFloor(data);
                    end,
                    no_close_btn = false,
                    tow_close_btn = true,
                    --去掉文本
                    cancel_text = Language:getTextByKey("new_str_0973"),
                    tip_text = Language:getTextByKey("tid#MazeTipsDes_2"),
                    text = Language:getTextByKey("tid#MazeTipsDes_1")
                }
                static_rootControl:openView("Pops.CommonPop", params, nil, true)
            else
                self:requestChooseFloor(data);
            end
        else
            self:requestChooseFloor(data);
        end
    elseif msg == "explain_btn" then
        self:openHelpPop()
    elseif msg == "level_up_btn" then
        --点击升级迷宫
        self:requestUnlockMazeGroup(data);
    end
end


function M:mazeSweep( data )
    local function netCallback(response)
        if response.reward ~= nil then
            RewardUtil:rewardTipsByData(response.reward)
            self.m_model.m_params.data.left_times = response.left_times;
            self.m_view:refreshUI();
        end
    end
    local params = {}
    params.group = data.id
    params.mver = self.m_model.verson
    self.m_model:getNetData("maze_sweep", params, netCallback, nil,nil,GlobalConfig.POST)
end


function M:requestChooseFloor( data )
    local function netCallback(response)
        self.m_model.m_data = response;
        --清空本地数据
        UserDataManager.local_data:setLocalDataByKey("boxEffectLocalData", nil)
        self:openView("GuJianQiTan.GuJianQiTanMaze", {data = response});
        self:closeView();
    end
    local params = { mver = self.m_model.verson, group = data.id }
    self.m_model:getNetData("maze_choose_floor", params, netCallback)
end


function M:openHelpPop()
    local params = {}
    params.title = "tid#maze_text2"
    params.content = "tid#maze_text1"
    self:openView("Pops.CommonHelpPop", params)
end


function M:requestUnlockMazeGroup( data )
    local params = {
        on_ok_call = function(msg)
            local function netCallback(response)
                self.m_model.max_group = response.max_group;
                --self.m_model.m_params.data.remain_times = response.remain_times;
                self.m_view:refreshUI()
            end
            local params = {mver = self.m_model.verson,group = data.id }
            self.m_model:getNetData("maze_unlock_maze_group", params, netCallback)
        end,
        on_cancel_call = function(msg)

        end,
        no_close_btn = false,
        tow_close_btn = true,
        text = Language:getTextByKey("new_str_0634")
    }
    static_rootControl:openView("Pops.CommonPop", params)
end


function M:destroy()
    M.super.destroy(self)
end



return M