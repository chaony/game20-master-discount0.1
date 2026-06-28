---@class SkillDataConfig @技能配置数据
---@field feature SkillFeatures_Model
---@field data ConfigSkillDetail
---@field player PlayerModel
local M = class("SkillDataConfig")

--技能数据
M.data = nil
--玩家
M.player = nil
--锁定则不可用
M.lock = false

M.id = 0
--技能名字
M.name = nil
--技能类型
M.type = 1
--内外功类型，1为内功，2为外功
M.atk_type = 1
--技能等级
M.level = 1
--技能前置CD
M.pre_cd = 0
--技能后置CD
M.post_cd = 0
--技能攻击距离
M.skill_dis = 2
--临时技能攻击距离
M.skill_dis_temp = nil
--技能目标类型
M.target_type = 1
--动画名称
M.anim_name = nil
--技能优先级 技能使用优先级(1手动,2最高,5最低)
M.priority = 0
--被攻击到的特效
M.skillEffect = 0
--当前计算的技能前置CD
M.cur_pre_cd = 0
--技能后置CD
M.cur_post_cd = 0
--受伤时增加怒气
M.injure_energy = 0
--攻击时增加怒气
M.hit_energy = 0
--解锁等级
M.unlock_level = 0
--友军预警圈
M.friend_warning_zone = 0
--敌军预警圈
M.enemy_warning_zone = 0
--是否是开场技（1为开场技）
M.is_opening = 0
--当前技能是否可以被大招打断
M.break_by_self = 1
--攻击是否为范围攻击
M.is_aoe = false
--技能特殊效果
M.feature = nil
--关键帧控制的条件
M.evtCondition = nil

M.randomCount = 0

M.featureParam = nil

M.extra_anim_name = nil

--当前技能的特效
M.effect_list = nil

M.skill3Already = false

--技能开始生效
M.skill_work = false

--本次技能击杀数量
M.kill_num = 0

--是否触发过战斗内对话
M.hasTalk = false

--是否能自动使用大招
M.canAutoUseSkill3 = true

function M:init(data)
    self.data = data
    self.name = data["name"]
    --技能类型
    --1 必杀
    --2 普通攻击
    --3 主动
    --4 被动
    self.type = data["type"]
    self.atk_type = data["atk_type"]
    self.level = data["level"]
    self.unlock_level = data["unlock_lv"]
    self.pre_cd = data["pre_cd"]
    self.post_cd = data["post_cd"]
    --挂机中是否可以使用
    --0 不能使用 1 可以使用
    self.no_hangup = data["no_hangup"]
    self.skill_dis = data["trigger_distance"]
    if self.skill_dis == GlobalTools.base0 then
        self.skill_dis = GlobalTools.base999
    end
    self.target_type = data["target_type"]
    self.anim_name = data["anim_name"]
    self.priority = data["priority"]
    self.skillEffect = data["injure_effect"]
    self.injure_energy = data["injure_energy"]
    self.hit_energy = data["hit_energy"]
    self.randomCount =data["random_count"] 
    --挂机用得
    self.auto_trigger_distance = data["auto_trigger_distance"]
    if self.auto_trigger_distance == GlobalTools.base0 then
        self.auto_trigger_distance = GlobalTools.base999
    end
    self.auto_pre_cd = data["auto_pre_cd"]
    self.auto_post_cd =data["auto_post_cd"] 
    --脚本参数
    self.featureParam = data["param"]
    --子弹是否穿透
    self.effect_cross = data["effect_cross"] == 1
    --友军预警圈
    self.friend_warning_zone = data["friend_warning_zone"] == 1
    --敌军预警圈
     self.enemy_warning_zone = data["enemy_warning_zone"] == 1
    --开场技
    self.is_opening = data["is_opening"] == 1
    --是否能被大招打断
    self.break_by_self = data["break_by_self"] == 1
    --是否为范围攻击
    self.is_aoe = data["is_aoe"] == 1
    self.effect_list = {}
    --后置CD 先设置成 0
    self.cur_post_cd = GlobalTools.base0
    --前置CD 设置成表中的 
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        self.cur_pre_cd = self.auto_pre_cd
    else
        self.cur_pre_cd = self.pre_cd
    end
    self.skill3Already = false
end

function M:getAnimName()
    local anim = self.anim_name
    if self.extra_anim_name ~= nil then
        anim = self.extra_anim_name
        self.extra_anim_name = nil
    end
    local r = 1
    if self.randomCount ~= nil and self.randomCount > 1 then
        r = WRandom:randomNum(1, self.randomCount + 1)
        r = math.floor(r)
        anim = anim.. "_" .. r
    end 
    return anim,r
end
 

function M:setPlayer( player )
    self.player = player
    --不是挂机场景才这么设置,挂机场景单独设置
    if SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
        if self.type == 2 then
            self.player.data.atkRange = self.skill_dis
        end 
    end
end

function M:conditionInit()
    local alType = string.gsub(self.player.default_plyType,"%d+$","")
    --根据默认皮肤加载
    if self.anim_name ~= nil then
        local fileNameBase = "Ply.SkillFeatures."..alType.."_"..self.anim_name
        local full_fileNameBase = "Battle."..fileNameBase;
        local fileName_model = full_fileNameBase.."_Model"
        --local fileViewName = "BattleView.Ply.SkillFeatures."..self.player.plyType.."_"..self.anim_name
        if Battle.ClassPathUtil:Exists(fileName_model) then
            self.feature = require(fileName_model).new()
            self.feature:init(self.player, self, fileNameBase)
        else
            for i = self.level, 1, -1 do
                local fileNameLevelBase = fileNameBase.."_"..i;
                local fileNameLevel = "Battle."..fileNameLevelBase
                local fileNameLevel_model = fileNameLevel.."_Model"
                if Battle.ClassPathUtil:Exists(fileNameLevel_model) then
                    --Logger.logError(" 加载脚本 "..fileNameLevel_model )
                    self.feature = require(fileNameLevel_model).new()
                    self.feature:init(self.player, self, fileNameLevelBase)
                    break
                end
            end
        end
    else
        Logger.logError(alType, " 英雄 动画名称 找不到 ")
    end
end


--使用技能
function M:use()
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        self.cur_post_cd = self.auto_post_cd
    else
        if self.type == 2 then
            self.cur_post_cd = self.player.data:getAttackCd(self.post_cd)
        else
            self.cur_post_cd = self.player.data:getSkillCd(self.post_cd)
        end
    end
    self.skill_work = false
end


--技能攻击距离
function M:getSkillDis()
    if self.skill_dis_temp ~= nil then
        return self.skill_dis_temp
    end
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then
        return self.auto_trigger_distance
    else
        return self.skill_dis
    end
end

--[[
    @desc: 更新技能CD
    author:{author}
    time:2020-01-03 09:58:34
    --@dt:
	--@unsdt: 
    @return:
]]

function M:update(dt,unsdt)
    if SceneManager:getCurSceneModel():get_sceneState() == SceneManager.SceneState.SceneRunning then
        --黑屏状态下cd不更新
        if self.player.plyMgr.blackTimeManager.curBlackTime <= GlobalTools.base0 then
            --计算前置CD
            if self.cur_pre_cd > GlobalTools.base0 then
                self.cur_pre_cd = self.cur_pre_cd - dt
                if self.cur_pre_cd <= GlobalTools.base0 then
                    self.cur_pre_cd = GlobalTools.base0
                end
            end

            if self.cur_pre_cd <= GlobalTools.base0 then
                if self.cur_post_cd > GlobalTools.base0 then
                    self.cur_post_cd = self.cur_post_cd - dt
                    if self.cur_post_cd <= GlobalTools.base0 then
                        self.cur_post_cd = GlobalTools.base0
                    end
                end
            end
        end

        if self.feature ~= nil then
            self.feature:update(dt,unsdt)
        end

        if self.type == 1 then
            if self.player.data:isMax_anger() == true then
                local result = self:canUseSkill3()
                if self.skill3Already ~= result then
                    self:refreshCard(result)
                    self.skill3Already = result
                end
                if result == true then
                    local autoUse = false
                    if self.player.camp == 1 then
                        autoUse = SceneManager:getCurSceneModel():canAutoUseBigSkillHero()
                    else
                        autoUse = SceneManager:getCurSceneModel():canAutoUseBigSkillAll()
                    end
                    if autoUse == true and self.canAutoUseSkill3 and SceneManager.curScene.sceneId ~= SceneManager.SceneID.HangUpScene then
                        self.player:useSkill("skill3")
                    end
                end
            else
                if self.skill3Already ~= false then
                    self:refreshCard(false)
                end
                self.skill3Already = false
            end
        end
    end
end

--刷新UI
function M:refreshCard(show)
    if self.player.camp == 1 then
        self.player:refreshCard(show);
    end
end

--技能CD是否可以使用
function M:canUse()
    if self.player == nil then
        return false
    end
    if self.lock == true then
        return false
    end
    --如果是挂机场景
    if SceneManager.curScene.sceneId == SceneManager.SceneID.HangUpScene then 
        --这个技能的挂机是否可以使用 不能使用
        if self.no_hangup == 0 then
            return false
        end
    end

    --如果技能类型是 必杀
    if self.type == 1 then
        --if SceneManager.curScene.m_replay then
        --    --如果是重播，直接返回不放大招
        --    if not Battle.BattleGlobalConfig.BATTLE_MODE_CFG[SceneManager.curScene.mode].pvp then
        --        return false
        --    end
        --end

        ----如果不能自动放大
        --if not SceneManager:getCurSceneModel():canAutoUseBigSkillAll() then
        --    return false;
        --end
        --
        ----如果是我方的人物
        --if self.player.camp == 1 then
        --    --如果不能自动放大
        --    if not SceneManager:getCurSceneModel():canAutoUseBigSkillHero() then
        --        return false;
        --    end
        --end
        --
        ----如果是自动战斗，准备好就放
        --if self.skill3Already == false then
        --    return false
        --end
        return false

    elseif self.type == 4 then
        return false
    else
        --技能被禁止
        local noSkillBuff = self.player.bufMgr:findBufByType("NoSkill")
        for k,v in ipairs(noSkillBuff) do
            if v.bufWork[self.anim_name] == false then
                return false
            end
        end
        
        --禁锢buff，技能沉默buff
        local imprison = self.player.bufMgr:hasBufByType("Imprison")
        if imprison then
            return false
        end
        
        if self.cur_pre_cd > GlobalTools.base0 then
            return false
        end
        
        if self.cur_post_cd > GlobalTools.base0 then
            return false
        end

        if self:checkEvtCondition() == false then
            return false
        end

        if self.feature ~= nil and self.feature:canUse() == false then
            return false
        end
    end
    
    --技能可以释放，大招刷新卡牌
    --if self.type == 1 then
    --    if self.player.camp == 1 and self.player.plyMgr.isAutoFight == true then
    --        SceneManager.curScene:sendEvent("useSkill", {index = self.player.index}, "GamePanel")
    --        self.player.data:clearAnger()
    --        self.player:useSkill("skill3")
    --    end
    --end
    return true
end

function M:skillStart( data )
    if self.feature ~= nil then
        self.feature:skillStart(data)
    end
    --技能开始
    self.player.plyMgr.attacker_relicMgr:skillStart(self.player, self)
    self.player.plyMgr.defender_relicMgr:skillStart(self.player, self)
    if self.player.skyStar ~= nil then
        self.player.skyStar:skillStart(self.player, self)
    end
    if self.player.resonance ~= nil then
        self.player.resonance:skillStart(self.player, self)
    end
    if self.player.talismanMgr ~= nil then
        self.player.talismanMgr:skillStart(self.player, self)
    end
    self.player.mysticMgr:skillStart(self.player, self)
    self.kill_num = 0   
    self.hasTalk = false
end

function M:skillEnd( data )
    self.player:skillEnd(self, data)
    --技能结束
    self.player.plyMgr.attacker_relicMgr:skillEnd(self.player, self)
    self.player.plyMgr.defender_relicMgr:skillEnd(self.player, self)
    if self.player.skyStar ~= nil then
        self.player.skyStar:skillEnd(self.player, self)
    end
    if self.player.resonance ~= nil then
        self.player.resonance:skillEnd(self.player, self)
    end
    if self.player.talismanMgr ~= nil then
        self.player.talismanMgr:skillEnd(self.player, self)
    end
    self.player.mysticMgr:skillEnd(self.player, self)
    if self.feature ~= nil then
        local skill = self.feature:skillEnd(data)
        return skill
    end
end

function M:killPlayer()
    self.kill_num = self.kill_num + 1
end

function M:destroy()
    if self.feature ~= nil then
        self.feature:destroy()
    end
end

function M:checkEvtCondition()
    if self.evtCondition ~= nil then
        local targets = SelectTargetTool:findPlayerByType(self.evtCondition["count"],self.player)
        if self.evtCondition["noControl"] == true then
            for i = targets.Count, 1, -1 do
                local target = targets:get(i - 1)
                local buffs = target.bufMgr:findBufByType("Immunity")
                for k, v in ipairs(buffs) do
                    if v.bufWork:checkTag("control", self.player) == true then
                        targets:remove(target)
                        break
                    end
                end
            end
        end

        local count = 1
        if self.evtCondition["mustEnough"] == true then
            if self.evtCondition["count"]["count"] == "one" then
                count = 1
            elseif self.evtCondition["count"]["count"] == "two" then
                count = 2
            elseif self.evtCondition["count"]["count"] == "three" then
                count = 3
            elseif self.evtCondition["count"]["count"] == "four" then
                count = 4
            elseif self.evtCondition["count"]["count"] == "all" then
                count = 5
            end
        end

        if targets.Count < count then
            return false
        end
    end
    return true
end

function M:canUseSkill3()
    if self.lock == true then
        return false
    end
    --前置CD
    if self.cur_pre_cd > 0 then
        return false
    end
    --后置CD
    if self.cur_post_cd > 0 then
        return false
    end

    --禁锢buff
    local imprison = self.player.bufMgr:findBufByType("Imprison")
    if #imprison > 0 then
        return false
    end
    
    --技能被禁止
    local noSkillBuff = self.player.bufMgr:findBufByType("NoSkill")
    for k,v in ipairs(noSkillBuff) do
        if v.bufWork[self.anim_name] == false then
            return false
        end
    end

    --部分技能不能被打断
    if self.player.curSkillConfig ~= nil and self.player.curSkillConfig.break_by_self == false then
        return false
    end

    if self:checkEvtCondition() == false and self.player.plyMgr.isAutoFight == true then
        return false
    end
    
    --特殊条件
    if self.feature ~= nil and self.feature:canUse() == false then
        return false
    end

    --角色死亡后，不再释放技能3
    if not self.player:isLive() then
        return
    end

    return true
end

return M
