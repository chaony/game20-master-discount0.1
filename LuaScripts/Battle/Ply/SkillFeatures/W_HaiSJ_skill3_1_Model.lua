-- 海殤君釋放擎羊嘯天攻擊所有敵人，對5個敵方俠客分別造成300%攻擊力的傷害，若敵方俠客數量不足5人，則會隨機攻擊另外一個敵人
-- 若連續命中了同一個敵人2次以上，則該敵人還會被眩暈2秒

---@class W_HaiSJ_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HaiSJ_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.hurtBuff = self:getParam(1) --伤害buff
    self.count = self:getParam(2) -- 被击x次
    self.buffData = self:getParam(3) -- 眩晕buff
    self.hurtCount = 0 
    self.hurtMax = 5 -- 大招有5次伤害
    self.hitList = {} -- 被攻击的人
end

function M:spawn()
    M.super.spawn(self)
end

function M:skillStart(data)
    self.hurtCount = 0
    self.hitList = {}
    M.super.skillStart(self, data)
end

function M:skillEnd(data)
    self.hurtCount = 0
    self.hitList = {}
    M.super.skillEnd(self, data)
end

function M:skillDispatch(data)
    if data.eventName == "hit" then
        local enemy_list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
        for i = enemy_list.Count, 1, -1 do
            local enemy_player = enemy_list:get(i-1)
            if enemy_player:isLive() then
                self.hurtCount = self.hurtCount + 1
                enemy_player.bufMgr:addBufById(self.hurtBuff, self.player)
                if enemy_player.playerId then
                    self.hitList[enemy_player.playerId] = 1
                elseif enemy_player.plyData.id then
                    self.hitList[enemy_player.plyData.id] = 1
                end
            end
        end
        
        local enemyList = SelectTargetTool:findPlayerByType({
            ["count"] = "all",
            ["camp"] = "enemy",
            ["posIndex"] = "all",
            ["priority"] = false,
            ["ignoreSummon"] = true,
            ["campRace"] = "not",
            ["pos"] = "distanceRecently",
            ["profession"] = "all",
            ["area"] = "all",
            ["areaWidth"] = "",
            ["areaHeight"] = "",
            ["areaAngle"] = "",
            ["areaRadius"] = "",
            ["forceSelect"] = false,
            ["selectLast"] = false
        }, self.player)
        local count = math.max(0,self.hurtMax - self.hurtCount)
        for i = 1, count do
            local index = WRandom:randomNum(0, enemyList.Count-1, true)
            local enemy = enemyList:get(index)
            if enemy and enemy:isLive() then
                enemy.bufMgr:addBufById(self.hurtBuff, self.player)
                if self.hitList[enemy.playerId] or self.hitList[enemy.plyData.id] then
                    enemy.bufMgr:addBufById(self.buffData, self.player)
                end
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M