local M = class("SyncLoadBigLoadingModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
    local params = self.m_params or  {}
    self.callback = params.callback;
    self.isShowBg = params.isShowBg;
    self.m_show_time = params.show_time or 0 -- 显示多长时间自动关闭
    self.m_callfunc = params.callfunc
    self.m_delay_show = params.delay_show or 0 -- 延迟显示
    self:initPreloadRes()
    -- 预加载后不移除atlas资源
    self.m_preload_atlas = {
        "active_ui",
        "arena_ui",
        "battle_ui",
        "coach_ui",
        "common_ui",
        "equip_icon",
        "hero_head_ui",
        "hero_ui",
        "item_icon",
        --"language_zh_cn",
        --"login_ui",
        "main_ui",
        "main_ui2",
        "maze_stage_ui",
        "mystic_ui",
        "pub_ui",
        "skill_icon",
    }

    self.m_preload_cfg = ConfigManager:analysisPreloadCfg()
    self.m_max_preload_num = #self.m_preload_atlas + #self.m_preload_heros + #self.m_preload_cfg
    self.m_preload_index = 0
    self.m_load_flag = false

    Logger.log(self.m_preload_atlas, "self.m_preload_atlas->")
    Logger.log(self.m_preload_heros, "self.m_preload_heros->")
    Logger.log(self.m_preload_cfg, "self.m_preload_cfg->")

end

--修改特效
function M:getFxName( name ) 
    return "fx_"..name..LODUtil:getLodKey();
end

--修改人物名字
function M:getRoleName( name ) 
   return "role3d_"..name; 
end

--初始化
function M:initPreloadRes()
    -- 预加载的英雄
    local preload_heros = {}
    -- local stage = UserDataManager.hero_data:getTeamByKey("stage")
    -- for k, v in pairs(stage) do
    --     local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
    --     if hero_cfg then
    --         preload_heros[hero_cfg.prefab] = 1
    --     end
    -- end
    ResourceUtil:AddNoUnLoadBundle("commoneffect");
    ResourceUtil:AddNoUnLoadBundle("material");
    --推图
    local stage_data = UserDataManager.hero_data:getTeamByKey("stage")
    for k, v in pairs(stage_data) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            local str_table = string.split(hero_cfg.prefab,'/');
            local name = "";
            if #str_table > 1 then
                name = string.lower( str_table[1] )
                local bundleName = self:getRoleName(name);
                local effectBundleName = self:getFxName(name)
                ResourceUtil:AddNoUnLoadBundle(bundleName);
                ResourceUtil:AddNoUnLoadBundle(effectBundleName);
            end
        end
    end

    --挂机
    local hang_up_data = UserDataManager.hero_data:getStagePassTeam()
    for k, v in pairs(hang_up_data) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            local str_table = string.split(hero_cfg.prefab,'/');
            local name = "";
            if #str_table > 1 then
                name = string.lower( str_table[1] )
                local bundleName = self:getRoleName(name);
                local effectBundleName = self:getFxName(name)
                ResourceUtil:AddNoUnLoadBundle(bundleName);
                ResourceUtil:AddNoUnLoadBundle(effectBundleName);
            end
            preload_heros[hero_cfg.prefab] = 1
        end
    end
    
    --迷宫maze
    local maze_data = UserDataManager.hero_data:getTeamByKey("maze")
    for k, v in pairs(maze_data) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            local str_table = string.split(hero_cfg.prefab,'/');
            local name = "";
            if #str_table > 1 then
                name = string.lower( str_table[1] )
                local bundleName = self:getRoleName(name);
                local effectBundleName = self:getFxName(name)
                ResourceUtil:AddNoUnLoadBundle(bundleName);
                ResourceUtil:AddNoUnLoadBundle(effectBundleName);
            end
        end
    end

    --五行阵
    local five_data = UserDataManager.hero_data:getTeamByKey("five_element")
    for k, v in pairs(five_data) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        if hero_cfg then
            local str_table = string.split(hero_cfg.prefab,'/');
            local name = "";
            if #str_table > 1 then
                name = string.lower( str_table[1] )
                local bundleName = self:getRoleName(name);
                local effectBundleName = self:getFxName(name)
                ResourceUtil:AddNoUnLoadBundle(bundleName);
                ResourceUtil:AddNoUnLoadBundle(effectBundleName);
            end
        end
    end
    
    --预加载挂机怪物
    local hero_detail = ConfigManager:getCfgByName("hero_detail")
    local data = GameUtil:getCurStageIdleData()
    local monster = data.monster or {}
    for k, v in pairs(monster) do
        if next(v) ~= nil and v.iid > 0 then
            local hero_cfg = hero_detail[v.iid]
            if hero_cfg then
                preload_heros[hero_cfg.prefab] = 1
            end
        end
    end
    self.m_preload_heros = {}
    self.m_preload_heros_effect = {}
    for k, v in pairs(preload_heros) do
        local str_table = string.split(k,'/');
        local name = "";
        if #str_table > 1 then
            name = string.lower( str_table[1] ) 
            table.insert(self.m_preload_heros, { self:getRoleName(name), k})
            table.insert(self.m_preload_heros_effect, { self:getFxName(name), k})
        end
    end
end

function M:getPreloadHeros()
    return self.m_preload_heros or {}
end

function M:getPreloadHeroEffects()
    return self.m_preload_heros_effect or {}
end

function M:getPreloadAtlas()
    return self.m_preload_atlas or {}
end

return M
