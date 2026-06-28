local M = class("DepositoryPopNodeControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("effect_data", nil, "SutraDepository.DepositoryPop")
        self:updateMsg("common_refresh", nil, "HeroBag")
        local callback = self.m_model.m_callback
        self:closeView()
        if type(callback) == "function" then
            callback()
        end
    end
end

function M:putMysticRequest(params)
    if params then
        local function putCallback(response)
            self.m_view:showEffect(response)
            self:updateMsg("update_data", nil, "SutraDepository")
            audio:SendEvtUI("UI_MiJi_LevelUp")
        end
        self.m_model:getNetData("mystic_up_sta", params, putCallback)
    end
end

return M
