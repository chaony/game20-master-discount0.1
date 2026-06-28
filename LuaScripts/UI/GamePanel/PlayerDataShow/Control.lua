local M = class("PlayerDataShowControl",LikeOO.OOControlBase)

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
    self.isShow = false;
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "addDamageData" then
        self.m_model:AddDamageData( data );
    elseif msg == "heroSelect" then
        self.isShow = not self.isShow
        self.m_view:setObjectVisible("heroSelect_bg", self.isShow)
    elseif msg == "selectHeroData" then
        self.isShow = false
        self.m_view:setObjectVisible("heroSelect_bg", self.isShow)
        --SceneManager:getData(player:get_playerInstanceId());
        local localData = SceneManager:getData(data.playerInstanceId);
        self.m_view:updatePropLoopScroll( data.baseProp );
        if localData ~= nil then
            self.m_view:updateInjureLoopScroll( localData.attack_list );
            self.m_view:updateAttackLoopScroll( localData.injure_list );
        end
    end
end




return M
