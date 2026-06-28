---
---
local M = class("AwakeSystemResultPopModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self.m_result = self.m_params.result or 0
    self.m_mode = self.m_params.mode or 1
    if self.m_mode == 0 then
        self.m_mode = 1
    end
    self.m_currentHeroIndex = self.m_params.oid or 0
    self.m_select_id = 0
    self.m_awaken_cfg = ConfigManager:getCfgByName("awaken")  --开启羽化的配置
   self:initHerosData()
end

function M:getHeroData()
    local data,cfg = UserDataManager.hero_data:getHeroDataById(self.m_currentHeroIndex)
    return data,cfg
end

function M:getHeroid(index)
    local data,cfg = UserDataManager.hero_data:getHeroDataById(index)
    return data.id
end

function M:initHerosData()
    local awakensystemdata =  UserDataManager:getmAwakenSystemData()
    self.m_god_god_heros = awakensystemdata.god_heros or {}
    self.m_fly_heros = awakensystemdata.fly_heros or {}
end

return M