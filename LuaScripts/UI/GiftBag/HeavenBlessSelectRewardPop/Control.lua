local M = class("HeavenBlessSelectRewardPopControl", LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        self:closeView()
    elseif msg == "btn_ok" then
        if #self.m_model.select_reward_list < 3 then
            GameUtil:lookInfoTips(self , {
                msg = Language:getTextByKey("gf_str_0144"), --选择奖励填入轮盘
                delay_close = 2
            })
            return
        end
        
        local params = {
            on_ok_call = function(msg)
                local saveRewardNetCallback = function(response)
                    if response.vsn_data == nil then
                        GameUtil:lookInfoTips(self , {
                            msg = Language:getTextByKey("gf_str_0144"),
                            delay_close = 2
                        })
                        return
                    end
                    self:closeView()
                    EventDispatcher:dipatchEvent("HeavenBless_RefreshNetData")
                end
                local temp_rewards = self.m_model:getLevel3RewardId() --这里传的是所有12个包含选择的奖励的id
                table.merge(temp_rewards,self.m_model.select_reward_list)
                local params1 ={
                    open_id = 400,
                    vsn = self.m_model.version,
                    ids = temp_rewards,
                }
                self.m_model:getNetData("weekend_sevent_save_ids",params1 ,saveRewardNetCallback )
            end,
            text = string.format(Language:getTextByKey("gf_str_0149"))
        }
        self:openView("Pops.CommonPop", params)
    end
end

return M