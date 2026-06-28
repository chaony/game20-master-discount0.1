local M = class("MasterApprenticeRedPacketPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView() 
    elseif msg == "CloseBtn" then
        self:closeView()    
    elseif msg == "get_red_packet" then
        self:requestReceiveRedPacket(data)
    elseif msg == "remove_red_packet" then
        self:removeData(data)
    end
end


--领红包
function M:requestReceiveRedPacket(data)
    local function callback(response)
        self:openView("Pops.CommonGetRedPacketPop", {reward =  response.reward })
        self.m_model:setStatus(data.id)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mentorship_receive_red_packet", {red_packet_id = data.id }, callback)
end

function M:removeData(data)
    self.m_model:removeData(data)
    self.m_view:refreshUI()
end

return M;
