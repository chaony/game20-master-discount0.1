local M = class("FiveLinesRewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Fivelines.FiveLinesRewardPop.Guide"
    audio:SendEvtUI("UI_CWBZ_Clear")
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("guide_check", nil, "Fivelines")
        self:closeView() 
    elseif msg == "box1" then    -- 返回
        self.m_model:getNetData("five_element_receive_reward", nil, function( data )
            --弹奖励接口
            RewardUtil:rewardTipsByData(data.reward, nil, function()
            end, {allDouble = false})
            self:handlerReceiveRewardHandler( data )
        end)
    elseif msg == "replay_btn" then
        --点击再次挑战
        if self.m_model.finish == true then
            --发送结束接口
            self.m_model:getNetData("five_element_over", nil, function( data )
                Logger.logError(data," 点击再次挑战 ")
                self:updateMsg("five_over", {floor = data.floor, finish = data.finish}, "Fivelines")
                self:closeView()
            end)
        else
            self:closeView()
        end
    elseif msg == "mopping_btn" then
        --点击再次挑战
        --发送结束接口
        self.m_model:getNetData("five_element_sweep", nil, function( data )
            --服务器返回值
            --'reward': {},
            --'remain_times': 0,
            --"open_times": 0,
            --"four_tower_id": 0,
            Logger.logError(data," 扫荡 ")
            --关闭界面
            self:closeView();

            local params = {
                open_times = data.open_times,
                remain_times = data.remain_times,
                reward = data.finish_gift,
            }
            
            TimeTools:delayTimeUnity(0.5, function()
                --发送到五行阵主界面更新奖励
                static_rootControl:updateMsg("five_mopping", params , "Fivelines")
            end)
        end)
    end
end

--处理收到奖励的回调
function M:handlerReceiveRewardHandler(data)
    --付费开启次数
    self.m_model.m_open_times = data.open_times;
    --免费次数
    self.m_model.m_free_times = data.free_times;
    Logger.logError(data," 购买后返回数据 ")
    self.m_view:refreshUI();
end


function M:destroy()
    M.super.destroy(self)
end

return M
