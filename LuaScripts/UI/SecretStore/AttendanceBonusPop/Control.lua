local M = class("AttendanceBonusControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "close_btn" then    -- 返回
        self:closeView()
    elseif type(msg) == "number" then
        self:getAttendanceReward(msg)
    end
end

function M:getAttendanceReward(index)
    if self.m_model.m_record_total_days >= index  then
        local function callback(response)
            if response.reward then
                RewardUtil:rewardTipsByData(response.reward)
                self.m_model:initData(response)
                self.m_view:refreshUI()
                --\SecretStore\AttendanceBonusPop
                self:updateMsg("updateRed",response,"SecretStore")
            end
        end
        local params = {current_day = index}
        self.m_model:getNetData("mystery_shop_attendance",params,callback)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M;