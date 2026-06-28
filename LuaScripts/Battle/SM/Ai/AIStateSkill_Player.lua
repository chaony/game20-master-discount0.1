--[[    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:17:50
]]
---@class AIStateSkill_Player : AIState @
---@field super AIState @AIState
local M = class("AIStateSkill_Player", Battle.AIState)

--进入大招技能状态
function M:enter( data )
    M.super.enter(self)
    local sceneInfo = SceneManager.curScene:getBattleModeCfg()
    if sceneInfo.showSkill3Effect == true then
        if self.player.camp == 1 and self.player.canBlackScreen == true then
            self.player:skill3Start();
            --遍历宠物进入大招
            for i = 1, self.player.summonList.list.Count do
                local key = self.player.summonList.list:get(i-1)
                local plys = self.player.summonList:get(key)
                for i, v in ipairs(plys) do
                    v:skill3Start();
                end
            end
        end
    end

    --大招开始
    if self.player.skill3Start_Model ~= nil then
        self.player:skill3Start_Model();
    end

    self.player.isInSkillState = true;
    local skill = self.player.plySkill:getSkillByName("skill3")
    if skill == nil then
        skill = self.player.plySkill:getSkillByName("skill3_plus")
    end
    if skill ~= nil then
        self.player:set_curSkillConfig(skill.cur_skill_config)
    end
    local cfg = self.player.curSkillConfig
    --是否清空怒气
    if self.player.skill3ClearAnger == true then
        self.player.data:clear_anger()
    end
    cfg:use()
    local skill_name = cfg:getAnimName()

    if self.player:get_enemy() ~= nil then
        --我和敌人的方向
        local dir = GlobalTools:Dir(self.player.enemy.position, self.player.position)
        if self.player.isBoss == false then
            self.player:rotaTo(dir, 0);
        end
    end

    self.player.animator:changeState(skill_name, {normalEnd = true})
    self.player.beforePos.x = self.player.position.x
    self.player.beforePos.y = self.player.position.y
    self.player.beforePos.z = self.player.position.z

    if self.player.camp == 1 and self.player.master == nil then
        SceneManager:getCurSceneModel():sendEvent("useSkill",{index = self.player.index}, "GamePanel")
    end
    if sceneInfo.showSkill3Effect == true then
        SceneManager:getCurSceneModel():sendEvent("playerSkillName",self.player, "GamePanel")
    end
    --设置动画速度
    self.player:setAnimSpeed(self.player.data:getHaste())
    self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelEnterAISkill)
end


--更新移动状态
function M:update(dt)
    M.super.update(self, dt)
    if self.player ~= nil then
        --找到敌人了
        if self.player.animator.curState ~= nil then
            if self.player.animator.curState.running == false and self.player.animator:get_loopCount() <= 0 then
                self.player.aiEngine:changeState("patrol", {normalEnd = true})
            end
        else
            self.player.aiEngine:changeState("patrol", {normalEnd = true})
        end
    end
end

--退出当前状态
function M:exit()
    --self.player.animator:setAnimUnscale(0)
    M.super.exit(self)
    --self.player:skill3Over();
    self.player.isInSkillState = false;
    --还原动画速度
    self.player:setAnimSpeed( GlobalTools.base1 )
    --大招结束
    if self.player.skill3Over_Model ~= nil then
        self.player:skill3Over_Model();
    end
end


return M