local M = class("SyncLoadBigLoadingControl",LikeOO.OOControlBase)

function M:onEnter()
    local show_time = self.m_model.m_show_time
    if show_time > 0 then
        self:setOnceTimer(show_time, function()
            self:updateMsg(99999)
        end)
    end
    if not GameVersionConfig.preload_res then
        ResourceUtil:LoadBundleSync("fx_commoneffect_fromab")
        ResourceUtil:LoadBundleSync("commoneffect")
        self.timer_id = self:setTimer(0.1, self.preloadResUpdate)
        GameVersionConfig.preload_res = true
        LODUtil:init();
    else
        if self.m_model.callback ~= nil then
            self.m_model.callback()
        end
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if type(self.m_model.m_callfunc) == "function" then
            self.m_model.m_callfunc()
        end
        self:closeView()
    end
end

function M:preloadResUpdate()
    if self.m_model.m_preload_index < self.m_model.m_max_preload_num then
        if not self.m_model.m_load_flag and self.m_model.m_preload_index >= 0 then
            local preload_heros = self.m_model:getPreloadHeros()
            local preload_heros_effects = self.m_model:getPreloadHeroEffects()
            if self.m_model.m_preload_index < #preload_heros then
                local function callBack()
                    if self.m_model ~= nil then
                        self.m_model.m_load_flag = false
                    end
                    -- self.m_view:setProgressSlider(self.m_model.m_preload_index, self.m_model.m_max_preload_num)
                end
                local function loadProgress(cur_num, max_num)
                    if self.m_view ~= nil then
                        self.m_view:setProgressSlider(self.m_model.m_preload_index + cur_num/max_num, self.m_model.m_max_preload_num)
                    end
                end
                self.m_model.m_preload_index = self.m_model.m_preload_index + 1
                local hero_names = preload_heros[self.m_model.m_preload_index]
                local effect_names = preload_heros_effects[self.m_model.m_preload_index]
                self.m_model.m_load_flag = true
                
                ResourceUtil:PreLoadAssetAllAsync(hero_names[1], callBack, loadProgress)
                ResourceUtil:PreLoadAssetAllAsync(effect_names[1]..LODUtil:getLodKey(), callBack, loadProgress)
                -- ResourceUtil:LoadRole3dAsync(hero_names[2], nil, "hero", callBack)
            else
                local preload_atlas = self.m_model:getPreloadAtlas()
                if self.m_model.m_preload_index - #preload_heros < #preload_atlas then
                    local function callBack()
                        if self.m_model ~= nil then
                            self.m_model.m_load_flag = false
                        end            
                        if self.m_view ~= nil then
                            self.m_view:setProgressSlider(self.m_model.m_preload_index, self.m_model.m_max_preload_num)
                        end
                    end
                    self.m_model.m_preload_index = self.m_model.m_preload_index + 1
                    local atlas_name = preload_atlas[self.m_model.m_preload_index - #preload_heros]
                    self.m_model.m_load_flag = true
                    ResourceUtil:LoadAtlasAsync(atlas_name, callBack)
                else
                    local preload_cfg = self.m_model.m_preload_cfg or {}
                    if self.m_model.m_preload_index - #preload_heros - #preload_atlas < #preload_cfg then
                        self.m_model.m_preload_index = self.m_model.m_preload_index + 1
                        local cfg_name = preload_cfg[self.m_model.m_preload_index - #preload_heros - #preload_atlas]
                        ConfigManager:loadCfg(cfg_name[1], cfg_name[2])
                        self.m_view:setProgressSlider(self.m_model.m_preload_index, self.m_model.m_max_preload_num)
                    else
                        self.m_model.m_load_flag = false
                    end
                end
            end   
        end
    else
        self.m_view:setProgressSlider(self.m_model.m_max_preload_num, self.m_model.m_max_preload_num)
        self.m_model.m_load_flag = false
        if self.timer_id then
            self:removeTimer(self.timer_id)
            self.timer_id = nil
        end
        if self.m_model.callback ~= nil then
            self.m_model.callback()
        end
    end
end

return M
