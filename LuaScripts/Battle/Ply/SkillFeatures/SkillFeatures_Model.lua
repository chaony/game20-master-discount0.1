--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:32:45
]]

---@class SkillFeatures_Model : ModelBase @技能的特殊功能处理
---@field player PlayerModel @拥有者
---@field skill SkillDataConfig  @拥有者技能
local M = class("SkillFeatures_Model",Battle.ModelBase)

M.player = nil
M.skill = nil

---@param player PlayerModel
---@param skill SkillDataConfig
function M:init(player, skill, className)
    --玩家
    self.player = player
    --技能
    self.skill = skill
    --类名称
    self.className = className;
    --更新发送数据
    self.updateData = {}
    --技能Model创建完成
    self.player:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelCreateFinish, self);
end

--出生
function M:spawn()
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelSpawn)
end

--角色初始化结束
function M:initFinish()
end

--角色出生结束
function M:spawnFinish()
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelSpawnFinish)
end

function M:CreateHp()
    
end

--去技能里面获取参数
function M:getParam(index)
    if self.skill ~= nil then
        local param = self.player.skillImprove:featureHandle(self.skill.id) or self.skill.featureParam
        return param[index] or 0
    end
    return 0
end

--更新
function M:update(dt,unsdt)
    self.updateData.dt = dt;
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelUpdate, self.updateData)
end

function M:canUse()
    return true
end

--技能释放(仅当前技能调用)
function M:skillStart(data)
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelSkillStart, data)
end

--技能结束(仅当前技能调用)
function M:skillEnd(data)
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelSkillEnd, data)
end

--作为攻击者的属性临时调整
---@param victim PlayerModel
---@param skill SkillDataConfig
function M:killerDataChangeTemp(victim, skill)
end

--作为受伤者的属性临时调整
---@param killer PlayerModel
---@param skill SkillDataConfig
function M:victimDataChangeTemp(killer, skill)
end

--beforeAttack典型应用场景
--查看具体的技能实现（如 W_CiH_skill2_1_Model.lua），这些方法通常用于：
--减免伤害
--反弹伤害
--触发被动防御技能
--修改攻击者的属性
--添加buff/debuff
--总结：这是战斗系统中被攻击方的被动技能触发点，在实际受伤前让所有被动技能有机会进行干预和处理。
--攻击开始处理（主要是处理被动技能的）
---@param attackData Battle_AttackData
---@param killer PlayerModel
function M:beforeAttack(attackData, killer)
end

---@param attackData Battle_AttackData
---@param victim PlayerModel
function M:killerBeforeAttack(attackData, victim)
end


--与 beforeAttack 的区别
--beforeAttack: 在伤害计算前调用，主要用于触发防御性被动技能
--afterAttack: 在伤害计算后调用，主要用于：
--进一步调整最终伤害
--触发反击效果
--添加后续buff/debuff
--执行其他攻击后的逻辑
--典型应用场景
--技能可以在 afterAttack 中：
--减免部分伤害
--反弹伤害给攻击者
--触发反伤效果
--记录战斗统计数据
--触发连击或组合技
--总结：这是战斗系统中被攻击方的攻击后处理阶段，允许所有被动技能在受伤前对最终伤害进行最后的调整和干预。
--攻击结束处理
---@param afterAttackData Battle_EventData_AfterAttack
function M:afterAttack(afterAttackData)
end

--这个方法常用于实现：
--攻击后给自身添加buff
--吸血效果
--增益状态
--连击计数
--攻击后给敌人添加debuff
--中毒、灼烧等持续伤害
--减速、虚弱等负面状态
--标记目标
--触发特殊技能效果
--击杀刷新技能
--连招系统
--特殊条件触发
--统计和记录
--战斗数据统计
--成就进度更新
--攻击者攻击结束处理
---@param data Battle_HandleData_Attack
function M:killerAfterAttack(data)
end

--角色死亡
---@param data Battle_EventData_Dead
function M:dead(data)
    return true
end

--杀死敌人
---@param data Battle_EventData_KillPlayer
function M:killPlayer(data)
    
end

--查找敌人
---@param data Battle_List
---@return Battle_List
function M:findPlayer(data)
     return data
end

--范围hit攻击调整攻击中心点
function M:checkAoeTarget(targetPos)
    return targetPos
end

--技能事件
---@param data Battle_EventData_Dispatch
function M:skillDispatch(data)
    
end

--子弹命中
function M:bulletHit(data)

end

-- 攻击方hit攻击之前
---@param frameData AnimEvtFrame_Model
---@param data Battle_Frame_Data_Event_Hit
function M:hitFrame(frameData, data)
    return data
end

---@return SkillFeatures_Model
function M:getSkillFeature(skill_name)
    local skillItem = self.player.plySkill:getSkillByName(skill_name)
    if skillItem and skillItem.cur_skill_config then
        return skillItem.cur_skill_config.feature
    end
    Logger.logError(skill_name, tostring(self.player.plyType) .. " getSkillFeature 找不到技能 ")
end

function M:destroy()
    self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelDestroy)
end

return M