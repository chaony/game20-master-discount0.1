--肥啾向天上随机洒出6根羽毛（其中至少有1根皓羽，1根玄羽）
--皓羽效果：立刻为己方1只奇兽恢复相当于旺财50%攻击力的生命值 
--玄羽效果：对任意1只敌方奇兽造成100%攻击力的伤害
--若肥啾在斗气阶段胜出，技能效果强化为：羽毛数量额外增加3根
---@class P_Niao_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.featherCount = self:getParam(1) -- x根羽毛
    self.buffData1 = self:getParam(2) -- 白羽buff
    self.buffData2 = self:getParam(3) -- 黑羽buff
    self.whiteFeather1 = self:getParam(4) --1白
    self.whiteFeather2 = self:getParam(5) --2白
    self.whiteFeather3 = self:getParam(6) --3白
    self.blackFeather1 = self:getParam(7) --1黑
    self.blackFeather2 = self:getParam(8) --2黑
    self.blackFeather3 = self:getParam(9) --3黑
    self.winFeatherCount = self:getParam(10) -- 胜出后x根
    self.battleWin = self.player.power_win == 1 -- 比斗气是否胜出
end

function M:spawn()
    M.super.spawn(self)
    local skill0 = self.player.plySkill:getSkillByName("skill0")
    if skill0 ~= nil and skill0.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill0 = skill0.cur_skill_config.feature
    end
    local skill1 = self.player.plySkill:getSkillByName("skill1")
    if skill1 ~= nil and skill1.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill1 = skill1.cur_skill_config.feature
    end
    local skill2 = self.player.plySkill:getSkillByName("skill2")
    if skill2 ~= nil and skill2.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill2 = skill2.cur_skill_config.feature
    end
    local skill4 = self.player.plySkill:getSkillByName("skill4")
    if skill4 ~= nil and skill4.cur_skill_config then
        ---@type SkillFeatures_Model
        self.skill4 = skill4.cur_skill_config.feature
    end
end

function M:skillStart(data)
    self:checkFeatherBuffAdd()
    if self.skill4 then
        if self.battleWin then
            self.player.bufMgr:addBufById(self.skill4.buffData2, self.player)
        else
            self.player.bufMgr:addBufById(self.skill4.buffData1, self.player)
        end
    end
    M.super.skillStart(self, data)
end

function M:checkFeatherBuffAdd()
    local count = self.battleWin == true and self.winFeatherCount or self.featherCount
    if self.skill0 and self.skill0.extCount then
        count = count + self.skill0.extCount
    end
    local baiNum = WRandom:randomNum(1, count-1, true) -- 白羽个数
    local heiNum = count - baiNum -- 黑羽个数
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp()) -- 我方所有人
    for i = 1, baiNum do
        ---@type PlayerModel
        local num = WRandom:randomNum(0, friends.Count-1, true)
        local player = friends:get(num)
        player.bufMgr:addBufById(self.buffData1, self.player)-- 白羽buff
        local buffList = player.bufMgr:findBufById(self.buffData1)
        local feather = nil
        if #buffList == 1 then
            feather = self.whiteFeather1
        elseif #buffList == 2 then
            feather = self.whiteFeather2
        elseif #buffList == 3 then
            feather = self.whiteFeather3
        end
        player.bufMgr:removeBufByTag("P_Niao_skill3_white")
        player.bufMgr:addBufById(feather, self.player)
        if self.skill2 and #buffList >= self.skill2.effectNum then
            player.bufMgr:removeBufById(self.buffData1)
            player.bufMgr:removeBufByTag("P_Niao_skill3_white")
            player.bufMgr:addBufById(self.skill2.buffData1, self.player) -- 皓羽普渡
        end
    end

    local enemys = self.player.plyMgr:getPlayers(-self.player:get_camp()) -- 敌方所有人
    for i = 1, heiNum do
        ---@type PlayerModel
        local enemy = enemys:get(WRandom:randomNum(0, enemys.Count-1, true))
        enemy.bufMgr:addBufById(self.buffData2, self.player) -- 黑羽buff
        local buffList = enemy.bufMgr:findBufById(self.buffData2)
        local feather = nil
        if #buffList == 1 then
            feather = self.blackFeather1
        elseif #buffList == 2 then
            feather = self.blackFeather2
        elseif #buffList == 3 then
            feather = self.blackFeather3
        end
        enemy.bufMgr:removeBufByTag("P_Niao_skill3_black")
        enemy.bufMgr:addBufById(feather, self.player)
        if self.skill1 and #buffList >= self.skill1.effectNum then
            enemy.bufMgr:removeBufById(self.buffData2)
            enemy.bufMgr:removeBufByTag("P_Niao_skill3_black")
            enemy.bufMgr:addBufById(self.skill1.buffData1, self.player)-- 暗夜绞杀
        end
    end
end



function M:destroy()
    M.super.destroy(self)
end

return M