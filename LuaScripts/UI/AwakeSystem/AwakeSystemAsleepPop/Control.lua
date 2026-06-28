---
---
local M = class("AwakeSystemAsleepPopControl",LikeOO.OOControlBase)

function M:onEnter()
    M.super.onCreate(self)
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
        self:updateMsg("smelt_refresh",nil,"AwakeSystem.AwakeSystemMain")
    elseif msg == "unlock" then
        local stage_id = data.data.stage_id
        local status = self.m_model:getStageStatus(data.index,stage_id)
        if status == 1 then
            local function Callback(response)
                if response then
                    self.m_model:initData(response)
                    self.m_view:refreshUI()
                end
            end
            local params = {stage_id = stage_id}
            self.m_model:getNetData("awaken_stage_unlock",params, Callback)
        elseif status == 3 then
            local params = {hero_id = self.m_model.m_cur_hero_id,stage_id = stage_id}
            self:openView("AwakeSystem.AwakeSystemChallengePop",params)
        elseif status == 2 then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0057"), delay_close = 2})
        end
    elseif msg == "fresh_data" then
        self.m_model:initData(data)
        self.m_view:refreshUI()
    elseif msg == "complete_btn" then
        if self.m_model.m_can_get then
            GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0024"), delay_close = 2})
        else
            --判断是否最后一关
            if self.m_model:canGetReward() then
                local function Callback(response)
                    if response then
                        self.m_model:initData(response)
                        self.m_view:refreshUI()
                        if response.reward then
                            RewardUtil:rewardTipsByData(response.reward)
                        end
                    end
                end
                local params = {hero_id = self.m_model.m_cur_hero_id}
                self.m_model:getNetData("awaken_stage_recv",params, Callback)
            else
                GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("awake_system_text_0022"), delay_close = 2}) 
            end
        end
    end
end

--function M:unlockStage()
--  
--end

function M:destroy()
    M.super.destroy(self)
end

return M