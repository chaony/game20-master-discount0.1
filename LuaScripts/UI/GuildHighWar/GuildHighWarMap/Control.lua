local M = class("GuildHighWarMapControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    else  --点击了城市
        local city_id = string.sub(msg,1,3)
        local build_data =  self.m_model.guild_high_war_build
        for id, v in pairs(self.m_model.guild_high_war_build) do
            if city_id == tostring(id) then
                EventDispatcher:dipatchEvent("CameraPos", {id = city_id})
                self:closeView()
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
