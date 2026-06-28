--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:33:41
]]

---@class MysticManager_Model @秘籍管理器
---@field player PlayerModel
---@field mysticList Mystic[]
local M = class("MysticManager_Model")

--玩家
M.player = nil

M.mystic_group = nil

--- 看条件满足触发后给自己加buff的条件，其他的触发及逻辑通过脚本实现
M.ConditionEffect = {
    start = true,
    hpper = true,
    time = true,
    buff = true,
    controlend = true,
}


--初始化 
function M:init( player )
    self.player = player

    self.mysticList = {}
    self.repeatList = {"controlend"}
    
    self.condition_func = {}
    --开局增加
    self.condition_func["start"] = function(param, hpRate)
        return true
    end
    
    --生命下降至某个百分比（只能触发一次）
    self.condition_func["hpper"] = function(param, hpRate)
        return self:getParam(param, "hp", hpRate, "lessOrEqual")
    end

    --战斗进行到某个时间点之后
    self.condition_func["time"] = function(param, time)
        return self:getParam(param, "time", time, "greaterOrEqual")
    end
    
    --被加个某个类型的BUFF之后
    self.condition_func["buff"] = function(param, tag)
        return self:getParam(param, "tag", tag, "equal")
    end

    --在被控制结束后
    self.condition_func["controlend"] = function(param, tag)
        return self:getParam(param, "times", tag, "less")
    end
    self.condition_count = 0

    self.operation_func = {}
    self.operation_func["lessOrEqual"] = function(a,b)
        return a <= b
    end
    self.operation_func["less"] = function(a,b)
        return a < b
    end
    self.operation_func["equal"] = function(a,b)
        return a == b
    end
    self.operation_func["greater"] = function(a,b)
        return a > b
    end
    self.operation_func["greaterOrEqual"] = function(a,b)
        return a >= b
    end
    
    -- 激活条件
    self.active_condition = {}
    self.active_condition["check_role_type"] = function(mysticCfg, mysticBuffCfg, param)
        return (param == 1) and (mysticCfg.role_type == self.player.plyData.role_type)
    end
end


function M:spawn()
    self.condition_count = 0
    --local group = Battle.BattleConfigManager:getMysticGroup(self.player.heroData.mystics)
    -- 挂机界面秘籍不生效
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene and self.player.heroData.mystics ~= nil then
        local buffs = {}
        if SceneManager.curScene.isUseConfig == true then
            buffs = Battle.BattleConfigManager:getMysticBuffsByConfigBattle(self.player.heroData.mystics, self.player.heroData.mystic_buffs)
        else
            buffs = Battle.BattleConfigManager:getMysticBuffs(self.player.heroData.mystics, self.player.heroData.mystic_buffs)
        end
        --Logger.logError(buffs," 秘籍技能 buffs ")
        
        self.mystic_buff_config = {}
        for i, data in ipairs(buffs) do
            local mystic_cfg = data.mystic
            local mystic_buff_buff = data.mystic_buff
            
            --因为 condition 有多条
            --所以这里要这么写
            for i_cond, v_cond in ipairs(mystic_buff_buff.condition) do
                local activeFlag = true  -- 检查激活条件
                if mystic_buff_buff.condition_param[i_cond] then        -- 有些条件没有条件参数
                    for i, param in ipairs(mystic_buff_buff.condition_param[i_cond]) do
                        if self.active_condition[param[1]] then
                            if not self.active_condition[param[1]](mystic_cfg, mystic_buff_buff, param[2]) then
                                activeFlag = false
                                break
                            end
                        end
                    end
                end
                
                if activeFlag then
                    if self.ConditionEffect[v_cond] then
                        if self.mystic_buff_config[v_cond] == nil then
                            self.mystic_buff_config[v_cond] = {};
                        end
                        local item = table.shallow_copy(mystic_buff_buff);
                        item.condition = {[1] = mystic_buff_buff.condition[i_cond]}
                        item.condition_param = {[1] = mystic_buff_buff.condition_param[i_cond]}
                        table.insert(self.mystic_buff_config[v_cond], item)
                    else
                        if #mystic_buff_buff.condition > 1 then
                            Logger.logError(mystic_buff_buff,"复杂秘籍只能有一个触发条件：技能脚本名")
                        end
                        self:registerMystic(mystic_cfg, mystic_buff_buff)
                    end
                end
            end
        end
        
        --Logger.logError(self.mystic_buff_config," 秘籍技能 all ")
        
        EventDispatcher:registerEvent("selfHp", {self,self.selfHpHandler})
        EventDispatcher:registerEvent("addBuff", {self,self.addBuffHandler})
        EventDispatcher:registerEvent("TimeUpdate", {self,self.TimeUpdateHandler})
        EventDispatcher:registerEvent("remove_control", {self,self.removeControlBuffHandler})
        --for k1,v1 in pairs(group) do
        --    for k2,v2 in pairs(v1.condition) do
        --        if self.mystic_group[v2] == nil then
        --            self.mystic_group[v2] = Battle.List.new()
        --        end
        --        local can_repeat = table.indexof(self.repeatList, v2) ~= false 
        --        self.mystic_group[v2]:add({group_id = v1.group, param = v1.condition_param[k2], buff = v1.param, can_repeat = can_repeat, canUse = true})
        --    end
        --end

        self:checkCondition("start")
    end
end

-- 注册秘籍逻辑脚本
---@param mysticCfg ConfigMystic
---@param mysticBufConfig ConfigMysticBuff
function M:registerMystic(mysticCfg, mysticBufConfig)
    local scriptName = mysticBufConfig.condition[1]
    local className = "Battle.Ply.Mystic."..tostring(scriptName)
    if Battle.ClassPathUtil:Exists(className) then
            ---@type Mystic
            local mystic = require(className).new()
            mystic:init(self, mysticCfg, mysticBufConfig)
            table.insert(self.mysticList, mystic)
    else
        Logger.logError(className, " 没有找到秘籍的控制类")
    end
end

-- 删除秘籍逻辑脚本
---@param mysticCfg ConfigMystic
---@param mysticBufConfig ConfigMysticBuff
function M:removeRandomMystic()
    if #self.mysticList > 0 then
        local index = WRandom:randomNum(0,#self.mysticList)
        local mystic = self.mysticList[index]
        if mystic ~= nil then
            table.removebyvalue(self.mysticList, mystic)
            local mysticCfg = mystic.mysticCfg
            local mysticBufConfig = mystic.data
            mystic:destroy()
            return mysticCfg, mysticBufConfig
        end
    end
end

--血量改变
function M:selfHpHandler( eventName, data )
    local player = data["ply"]
    local hpRate = data["value"]
    if self.player:equal(player) then
        --Logger.logError(" 血量百分比 "..hpRate )
        self:checkCondition("hpper", hpRate)
    end
end

--游戏时间
function M:TimeUpdateHandler( eventName, data )
    local curTime = data["cur_time"]
    self:checkCondition("time", curTime)
end


--获得buff
function M:addBuffHandler( eventName, data )
    local buff = data["buff"]
    if self.player:equal(buff.player) then
        for k,v in ipairs(buff.tag) do
            self:checkCondition("buff", v)
        end
    end
end

--控制buff结束
function M:removeControlBuffHandler( eventName, data )
    local buff = data["buff"]
    if self.player:equal(buff.player) then
        if table.nums(buff.tag) > 0 then
            self:checkCondition("controlend", self.condition_count)
            self.condition_count = self.condition_count + 1
        end
    end
end

--检测触发
function M:checkCondition(condition, param)
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
        if self.mystic_buff_config[condition] ~= nil then
            for i, v in ipairs(self.mystic_buff_config[condition]) do
                if _G.next(v) ~= nil then
                    if self.condition_func[condition](v.condition_param, param) == true then
                        for buff_i, buff_id in ipairs(v.param) do
                            local isDelete = true;
                            for i, v in ipairs(self.repeatList) do
                                if condition == v then
                                    isDelete = false;
                                end
                            end
                            
                            -- 先删除触发条件，再添加buff【防止出现添加buff后仍然满足条件并继续触发造成多次触发，在特殊情况先会造成循环卡死】
                                -- 出现的bug:[100072004 当生命降低至30%时，恢复20%血量（每场战斗触发一次）]当双方属性差距过大，会造成血量小于-10000000%，
                                --  恢复20%后依旧满足条件并触发，这个buff会多次触发402遗物，扩大属性差距，如果有另一人有这个秘籍，又开始一轮更大的循环
                            if isDelete then
                                self.mystic_buff_config[condition][i] = {};
                            end
                            self.player.bufMgr:addBufById(buff_id, self.player)
                        end
                    end
                end
            end
        end
        --if self.mystic_group[condition] ~= nil then
        --    for i = self.mystic_group[condition].Count, 1, -1 do
        --        local mystic = self.mystic_group[condition]:get(i - 1)
        --        if mystic ~= nil and mystic.canUse == true and self.condition_func[condition](mystic.param, param) == true then
        --            if mystic.can_repeat == false then
        --                mystic.canUse = false
        --            end
        --            for k,v in pairs(mystic.buff) do
        --                self.player.bufMgr:addBufById(v, self.player)
        --            end
        --        end
        --    end
        --end
    end
end

function M:getParam(param, key, value, operation)
    local res = false
    for k,v in pairs(param) do
        for k1,v1 in ipairs(v) do
            if v1[1] == key then
                if self.operation_func[operation](value, v1[2]) then
                    res = true
                    break
                end
            end
        end
    end
    return res
end

---------------------------- 秘籍技能脚本逻辑
--出生结束开始战斗
function M:spawnFinish()
    for i, v in ipairs(self.mysticList) do
        v:spawnFinish()
    end
end


-- 技能开始
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
    for i, v in ipairs(self.mysticList) do
        v:skillStart(ply, skill)
    end
end

-- 技能结束
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd( ply, skill)
    for i, v in ipairs(self.mysticList) do
        v:skillEnd(ply, skill)
    end
end

-- 攻击结束时
---@param victim PlayerModel
---@param killer PlayerModel
---@param wantdata Battle_BeHitDirectData_WantData
-----@param attackData Battle_AttackData
function M:attackOver(victim, killer, wantdata, attackData)
    for i, v in ipairs(self.mysticList) do
        v:attackOver(victim, killer, wantdata, attackData)
    end
end

--销毁
function M:destroy()
    -- 销毁秘籍
    for i, v in ipairs(self.mysticList) do
        v:destroy()
    end
    self.mysticList = {}
    EventDispatcher:unRegisterEvent("selfHp", {self,self.selfHpHandler})
    EventDispatcher:unRegisterEvent("addBuff", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("TimeUpdate", {self,self.TimeUpdateHandler})
    EventDispatcher:unRegisterEvent("remove_control", {self,self.removeControlBuffHandler})
end

return M