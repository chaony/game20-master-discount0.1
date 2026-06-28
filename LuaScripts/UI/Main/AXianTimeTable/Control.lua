local M = class("AXianTimeTableControl",LikeOO.OOControlBase)

local _TAB_NODE = {{"武道场","raidSweep"},
                   {"玄武遗迹","worldBossSweep"},
                   {"侠客试炼","trianSweep"},
                   {"江湖传奇","legendSweep"},
                   }

function M:onEnter()
    
end

--扫荡的活动

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif type(msg) == "number" then
        if msg <= self.m_model.m_course_nums then
            self.m_model.m_select_id = msg
            self.m_view:refreshUI()
        end
    elseif msg == "help_btn" then
        local content = Language:getTextByKey("tid#AXianTimeTable_des_1")
        local name = self.m_model.m_active_data.name
        self:openView("Pops.CommonHelpPop", { title = name, content = content})
    elseif msg == "complete_btn" then
        local course_data = self.m_model:getCurrentData()
        local state = -1
        state = self.m_model:getCurrentState(self.m_model.m_select_id)
        if state == 1 then
            for k,v in ipairs(_TAB_NODE) do
                if course_data.name == v[1] then
                    local func_name = v[2]
                    local func = self[func_name]
                    if type(func) == "function" then
                        func(self)
                    end
                end
            end
        end
    elseif msg == "completetheall_btn" then
        if self.m_model:getCompletetheAllState() then
            return
        end
        self:allSweep()
    end
end

--武道场
function M:raidSweep()
    self.m_model:getNetData("one_key_sweep_raid", nil, handler(self,self.getReward))
end

-- 玄武遗迹
function M:worldBossSweep()
    self.m_model:getNetData("one_key_sweep_world_boss", nil, handler(self,self.getReward))
end

--侠客试炼
function M:trianSweep()
    self.m_model:getNetData("one_key_sweep_train", nil, handler(self,self.getReward))
end

--江湖传奇
function M:legendSweep()
    self.m_model:getNetData("one_key_sweep_world_legend", nil, handler(self,self.getReward))
end

--全部扫荡
function M:allSweep()
    self.m_model:getNetData("one_key_sweep", nil, handler(self,self.getReward))    
end

function M:getReward(response)
    if response then
        if response.special_rewards then
            RewardUtil:rewardTipsByData(response.rewards,response.special_rewards)    
        else
            RewardUtil:rewardTipsByData(response.rewards)    
        end
        self:refreashData()
    end
end

function M:refreashData()
    self.m_model:refreshData(handler(self.m_view,self.m_view.refreshUI))
end

function M:destroy()
    M.super.destroy(self)
end

return M;
