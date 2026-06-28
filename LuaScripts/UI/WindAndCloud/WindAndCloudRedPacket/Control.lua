local M = class("WindAndCloudRedPacketControl", LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg, data)
    if msg == 99999 then -- 关闭
        if self.m_model.is_main_open then
            self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudRedEnvelope")
        else
            self:updateMsg("refresh_red_big_point", nil, "parent") --通知主界面
        end
        if self.m_model.is_send_redbag then
            self:updateMsg("update_red_bag_data", nil, "WindAndCloud.WindAndCloudRedEnvelope")
        end
        self:closeView()
    elseif type(msg) == "number" then
        self.m_model.m_mode = msg
        self.m_view:refreshUI()
    elseif msg == "receive_award_btn" then
        self:sentorGetRedPacket(data)
    end
end

function M:sentorGetRedPacket(data)
    if self.m_model.m_mode == 1 then
        local params = {open_id = self.m_model.open_id,vsn = self.m_model.m_version,bag_id = data}
        local function netCallback(response)
            if response then
                self.m_model:updateSendRedPacker(response)
                self.m_model.is_send_redbag = true
                self.m_view:refreshUI(true)
            end
        end
        self.m_model:getNetData("red_packet_send", params, netCallback)
    else
        local params = {open_id = self.m_model.open_id,vsn = self.m_model.m_version,bag_incr_id = tonumber(data[1])}
        local function netCallback(response)
            if response.reward then
                self.m_model.m_left_rec = #response.day_received or 0
                self.m_model.m_receive_redpacker_list = response.can_receive
                self.m_view:refreshUI(true)
                local param = {data = response,gameer_data = data}
                self:openView("WindAndCloud.WindAndCloudReceiveRedPacket",param)
            else
                self.m_model.m_receive_redpacker_list = response.can_receive
                self.m_view:refreshUI(true)
                GameUtil:lookInfoTips(self,{msg = Language:getTextByKey("wind_clouds_red_packet_text_00016"), delay_close = 2})
            end
        end
        self.m_model:getNetData("red_packet_receive", params, netCallback)
    end
end

return M
