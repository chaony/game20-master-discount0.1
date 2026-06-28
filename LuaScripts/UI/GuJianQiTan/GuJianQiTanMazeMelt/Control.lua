local M = class("GuJianQiTanMazeMeltControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( {select_index= -1} )
        end
        self:closeView()
    elseif msg == "use_btn" then --邪剑熔炉
        local hero_id_selected = self.m_model:getSelectedHeroID()
        if hero_id_selected ~= 0 then
            local moveFinish = {
                select_index = hero_id_selected,
                callback = function()
                    self:updateMsg("maze_melt", {hero_id = hero_id_selected}, "GuJianQiTan.GuJianQiTanMaze")
                end,
            }
            if self.m_model.m_callBack ~= nil then
                self.m_model.m_callBack( moveFinish )
            end
            self:closeView()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gu_jian_qi_tan_str_059"), delay_close = 2})
        end
    end
end

return M
