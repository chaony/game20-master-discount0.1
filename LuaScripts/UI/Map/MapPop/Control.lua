local M = class("MapPopControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()   
    elseif msg == "world_map_btn" then
       -- self:openView("Map.WorldMap")  
       -- self:closeView()
    elseif msg == "click_player" then
        self:openView("Pops.CommonPop",{text = Language:getTextByKey("new_str_0055")}) 
    elseif msg == "eqps_btn" then
        self:openView("Pops.CommonMapItemsPop", {rewards = self.m_model:getReward()}) 
    end
end

return M