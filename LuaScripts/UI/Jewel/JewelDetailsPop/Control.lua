local M = class("JewelDetailsPopControl",LikeOO.OOControlBase)

function M:onEnter()
  	--self.m_guide_file_name = "UI.Jewel.JewelDetailsPop.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "upgrade_btn" then
        self:requestUpgrade(self.m_model.m_jewel.id)
    elseif msg == "awaken_btn" then
        self:requestAwaken(self.m_model.m_jewel.id)
    elseif msg == "effect" then
        self.m_view:closeEffect()
    end
end

function M:requestUpgrade(id)
    local function callback(response)
        self:updateMsg("update_jewel", {type = 2, id = response.jewel_id, evo = response.jewel_evo}, "Jewel")
        self.m_model:updateJewelEvo(response.jewel_id, response.jewel_evo)
        UserDataManager.jewel_data:updateEffects(response.effects) --秘宝效果
        local function timeCall()
            self.m_view:refreshUI()
            self.m_view:playEffect()
        end
        self:setOnceTimer(0.5, timeCall)
    end
    local params = {jewel_id = id}
    self.m_model:getNetData("jewel_evo_up", params, callback)
end

function M:requestAwaken(id)
    local function callback(response)
        self:updateMsg("update_jewel", {type = 3, id = response.jewel_id}, "Jewel")
        self.m_model:updateJewelAwaken(response.jewel_id, 1)
        UserDataManager.jewel_data:updateEffects(response.effects) --秘宝效果
        local function timeCall()
            self.m_view:refreshUI()
            self.m_view:playEffect(true)
        end
        self:setOnceTimer(0.5, timeCall)
    end
    local params = {jewel_id = id}
    self.m_model:getNetData("jewel_awake", params, callback)
end

return M