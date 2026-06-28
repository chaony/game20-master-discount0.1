--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-25 13:35:09
]]

---@class ZhenFaManager @阵法管理器
local M = class("ZhenFaManager")

--初始化阵法
function M:init()
    --阵法数据
    self.data = require("Battle.Data.SceneInfo.zhenfa");
    self.deployment = ConfigManager:getCfgByName("deployment")
    --默认选择的阵法id
    self.selectHeroZhenFaID = 1;
    self.selectEnemyZhenFaID = 1;
end

function M:setHeroZhenFaID(id)
    self.selectHeroZhenFaID = id;
end

--设定当前选择的阵法id
function M:setEnemyZhenFaID( id )
    self.selectEnemyZhenFaID = id;
end


--阵法名称  zhenfa_key
--位置      pos_index
function M:getPosition( zhenfa_key, pos_index )
    local pos_list = self.data[zhenfa_key];
    return pos_list[pos_index]
end

--阵法名称  zhenfa_key
function M:getPositionList( zhenfa_key  )
    local pos_list = self.data[zhenfa_key];
    return pos_list
end


--获取 全局的 bufid
function M:getGlobalBufID( camp )
    local id = camp == 1 and  self.selectHeroZhenFaID or self.selectEnemyZhenFaID
    local deploy_data = self.deployment[id]
    if deploy_data ~= nil then
        return deploy_data.buff;
    end
end

function M:getPos( camp )
    local id = camp == 1 and  self.selectHeroZhenFaID or self.selectEnemyZhenFaID
    local deploy_data = self.deployment[id]
    if deploy_data ~= nil then
        return deploy_data.key_pos - 1;
    end
end

--获取 制定位置的 bufid
function M:getIndexBufID( camp )
    local id = camp == 1 and  self.selectHeroZhenFaID or self.selectEnemyZhenFaID
    local deploy_data = self.deployment[id]
    if deploy_data ~= nil then
        return deploy_data.key_buff;
    end
end


function M:getZhenFaData( zhenfa_id )
    return self.deployment[zhenfa_id]
end

--是否是前排
function M:isFront(camp, index)
    local id = 0
    if camp == 1 then
        id = self.selectHeroZhenFaID
    else
        id = self.selectEnemyZhenFaID
    end
    if self.deployment[id].front[index+1] == 1 then
        return true
    end
    return false
end

return M;