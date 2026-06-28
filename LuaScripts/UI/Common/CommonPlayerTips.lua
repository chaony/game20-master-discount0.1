--- 玩家信息
local M = class("CommonPlayerTips",LikeOO.OOUIbase)

M.m_uiName = "Common/CommonPlayerTips"
M.m_iphoneXAdapter = true

function M:onCreate()
    EventDispatcher:registerEvent("updatePlayerTips", {self,self.TipsHandler})
end

function M:onEnter()
    self.m_content = self:findGameObject("content")
    self:refreshUI()    
end

function M:onButtonClick(obj, name)
	-- if name == "close_btn" then
	-- 	self:destroy()
	-- end
end

function M:refreshUI()
    if self.m_params then
        local uid = self.m_params.model:get_playerInstanceId()-- .heroData.oid
		local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(uid)
        if hero_data and hero_cfg then
            local name_text = self:setTextByLanKey("hero_name", hero_cfg.name)
            local qu = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_data.evo]
            name_text.color = qu.RGBA
            --if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY  then
            --    hero_data = table.copy(hero_data)
            --    local lv = math.max(hero_data.lv, hero_data.clv)
            --    local r_lv = math.max(lv, 300)
            --    hero_data.lv = r_lv;
            --end
            local combat = UserDataManager:computeHeroCombat(hero_data, hero_cfg, true, nil)
            self:setTextByLanKey("combat_text", Language:getTextByKey("friend_str_0041")..combat)
            local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[hero_cfg.locate[1] or 1]
            local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[hero_cfg.locate[2] or 1]
            self:setImg(locate1_data.loc_icon, "hero_ui", "type_img")
            self:setImg(locate2_data.loc_icon, "hero_ui", "type_img2")
            self:setTextByLanKey("type_name_1", locate1_data.name)
            self:setTextByLanKey("type_name_2", locate2_data.name)
            self.m_content:SetActive(true)  
        else
            local hero_data = self:getFormationAssist_heros(uid)
            if hero_data ~= nil then
                local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
                if hero_cfg then
                    local name_text = self:setTextByLanKey("hero_name", hero_cfg.name)
                    local qu = GlobalConfig.HERO_QUALITY_COMMON_SETTING[hero_data.evo]
                    name_text.color = qu.RGBA
                    --if SceneManager:getCurSceneModel().mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY  then
                    --    hero_data = table.copy(hero_data)
                    --    local lv = math.max(hero_data.lv, hero_data.clv)
                    --    local r_lv = math.max(lv, 300)
                    --    hero_data.lv = r_lv;
                    --end
                    local combat = UserDataManager:computeHeroCombat(hero_data, hero_cfg, true, nil)
                    self:setTextByLanKey("combat_text", Language:getTextByKey("friend_str_0041")..combat or 0 )
                    local locate1_data = GlobalConfig.TYPE_HERO_LOCATION_1[hero_cfg.locate[1] or 1]
                    local locate2_data = GlobalConfig.TYPE_HERO_LOCATION_2[hero_cfg.locate[2] or 1]
                    self:setImg(locate1_data.loc_icon, "hero_ui", "type_img")
                    self:setImg(locate2_data.loc_icon, "hero_ui", "type_img2")
                    self:setTextByLanKey("type_name_1", locate1_data.name)
                    self:setTextByLanKey("type_name_2", locate2_data.name)
                    self.m_content:SetActive(true)  
                else
                    self.m_content:SetActive(false)
                end
            else
                self.m_content:SetActive(false)  
            end
        end
    end
end

function M:TipsHandler(data)
    local pos_3d = UIUtil.ScenePosToUI(data);
    if not IsNull(self.m_content) then
        self.m_content.transform.position = pos_3d 
    end
end

function M:getFormationAssist_heros(uid)
    for k,v in pairs(static_rootControl.m_chilrenList) do
		if v.m_model and v.m_model:getName() == "Formation" then
            if next(v.m_model.m_assist_heros) ~= nil then
                return v.m_model.m_assist_heros[uid]
            else
                return nil
            end 
        end
	end
    return nil
end

function M:destroy()
    self.m_content = nil
    EventDispatcher:unRegisterEvent("updatePlayerTips", {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M