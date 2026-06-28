--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-17 09:54:05
]]

---@class SkillCondtion @
local M = class("SkillCondtion")

M.player = nil
M.skill = nil
M.data = nil
--计数器{最大数量，当前数量}
M.count = nil
--事件类型
M.eventContenet = 
{
    "enemyHpLess50",--血量小于50%的敌人
    "critCount",--暴击次数
    "nearEnemyDist",--最近敌人的距离
    "debuffCount",--debuff数量
}

function M:init(ply, skill, data)
    self.player = ply
    self.skill = skill
    self.data = data
    self.count = Battle.ListMap.new()
    for i = 1, #data do
        local key = data[i][1]
        local count_data = {}
        count_data.minCount = data[i][2]
        count_data.maxCount = data[i][3]
        count_data.count =  0
        self.count:add( key, count_data )
        EventDispatcher:registerEvent(data[i][1], {self,self.conditionHandler})
    end
end

--检测是否能够触发技能
function M:canUse()
    for i = 1, self.count.list.Count do
        local k = self.count.list:get(i-1)
        local v = self.count:get(k)
        if v.count < v.minCount then
            return false
        end
        if v.maxCount ~= nil and v.count > v.maxCount then
            return false
        end
    end
    return true
end

function M:update(dt,unsdt)
end

--技能释放
function M:skillStart()
    for i = 1, self.count.list.Count do
        local k = self.count.list:get(i-1)
        local v = self.count:get(k)
        if v.reset == nil or v.reset == true then
            v.count = 0
        end
    end
end

--技能结束
function M:skillEnd()

end

--数据模型
--data = 
--{
--    ["ply"] = ply,
--    ["type"] = "self",
--    ["operator"] = "+",
--    ["value"] = 1,
--    ["reset"] = true,
--    ["ignoreSkills"] = {"skill1", "skill2"}
--    ["breakAnim"] = true,
--}
--发生暴击
function M:conditionHandler( eventName, data )
    local ply = data["ply"]
    --不生效的技能列表
    local ignoreSkills = data["ignoreSkills"]
    --使用技能后是否重置
    --self.count[eventName]["reset"] = data["reset"]
    local count_data = self.count:get(eventName)
    count_data.reset = data["reset"]
    
    --生效的人
    local useful = nil
    local type = data["type"]
    if type == "self" then
        useful = (ply == self.player)
    elseif type == "enemy" then
        useful = (ply.camp ~= self.player.camp)
    elseif type == "friend" then
        useful = (ply.camp == self.player.camp)
    end
    
    if useful then
        if ignoreSkills ~= nil and self.player.curSkillConfig ~= nil then
            for i = 1, #ignoreSkills do
                if ignoreSkills[i] == self.player.curSkillConfig.anim_name then
                    useful = false
                    break
                end
            end
        end
        
        if useful then
            local value = 1
            if data["value"] ~= nil then
                value = data["value"]
            end
            --增加还是减少
            if data["operator"] == nil or data["operator"] == "+" then
                count_data.count = count_data.count + value
            elseif data["operator"] == "-" then
                count_data.count = count_data.count - value
            elseif data["operator"] == "=" then
                count_data.count = value
            end

            --是否立即尝试使用该技能
            if data["breakAnim"] == true then
                if count_data.count >= count_data.minCount then
                    if count_data.maxCount == nil or (count_data.count <= count_data.maxCount) then
                        if self.skill:canUse() then
                            self.player:set_curSkillConfig(self.skill)
                            if self.player:get_curSkillConfig() ~= nil then
                                if self.player:get_curSkillConfig().type == 1 then
                                    self.player.aiEngine:changeState("skill")
                                else
                                    self.player.aiEngine:changeState("attack")
                                end
                            else
                                self.player.aiEngine:changeState("attack")
                            end
                        end
                    end
                end
            end
        end
    end
end

function M:destroy()
    for i = 1, #self.data do
        EventDispatcher:unRegisterEvent(self.data[i][1], {self,self.conditionHandler})
    end
end

return M