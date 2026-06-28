--角色的专属装备
-- 六扇 普通攻击现在会攻击额外攻击到被施加了“悬赏”印记的敌人
---@class W_LiuS_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_LiuS_Trait0", PlayerTrait)


function M:init()
    M.super.init(self)
    


    self.atk = self:getValue(1)


    self.bulletTable = 
    {
        ["eventName"] = "Shoot",
        ["triggerTime"] = "0.55",
        ["effectId"] = "0",
        ["bulletType"] = "Bullet",
        ["linePrefab"] = "",
        ["lineBuffId"] = "nil",
        ["isAverage"] = false,
        ["bulletCount"] = "0",
        ["delayTime"] = "0.55",
        ["delayBoomTime"] = "0",
        ["frontdamagePercent"] = "0",
        ["lastdamagePercent"] = "1",
        ["angerAirPercent"] = "1",
        ["count"] = 
        {
            ["count"] = "one",
            ["camp"] = "myenemy",
            ["posIndex"] = "all",
            ["priority"] = false,
            ["ignoreSummon"] = false,
            ["targetNoRepeat"] = false,
            ["campRace"] = "not",
            ["pos"] = "not",
            ["profession"] = "all",
            ["area"] = "all",
            ["areaWidth"] = "",
            ["areaHeight"] = "",
            ["areaAngle"] = "",
            ["areaRadius"] = "",
            ["forceSelect"] = false,
            ["selectLast"] = false,
            ["isFixPoint"] = false,
            ["useSelf"] = false,
            ["fixpoint"] = "enemyBackCenter"
        },
        ["isEnemy"] = false,
        ["mustHit"] = false,
        ["mustCrit"] = false,
        ["targetNoRepeat"] = false,
        ["bombName"] = "nil",
        ["bombParent"] = "body",
        ["prefabName"] = "nil",
        ["bulletAudio"] = "nil",
        ["prefab"] = "nil",
        ["speed"] = "0",
        ["noAttack"] = false,
        ["targetOffset"] = 
        {
            ["x"] = "0",
            ["y"] = "0",
            ["z"] = "0"
        },
        ["parent"] = "body",
        ["firePoint"] = 
        {
            ["x"] = "0",
            ["y"] = "0",
            ["z"] = "0"
        },
        ["isForward"] = false,
        ["isY"] = false,
        ["checkRange"] = "0",
        ["acceleration"] = "0",
        ["vSpeed"] = "0",
        ["gravity"] = "0",
        ["power"] = "0",
        ["lifeTime"] = "0",
        ["movePath"] = 
        {
            ["move"] = false,

        },
        ["puncturedmg"] = false,
        ["damageReduce"] = "0",
        ["punctureTime"] = "0",
        ["isCircle"] = false,
        ["circleCount"] = "0",
        ["trackCount"] = "0",
        ["rotate"] = false,
        ["aoeType"] = 
        {
            ["openAoe"] = false,

        },
        ["injureMove"] = 
        {
            ["move"] = false,

        },
        ["curveMove"] = 
        {
            ["move"] = false,

        },
        ["isDeadbuff"] = false,
        ["buffId"] = "nil",
        ["EditorBuffName"] = "nil",
        ["buffType"] = 
        {
            ["openBuff"] = false,

        },
        ["isSpecial"] = false,
        ["SpecialParam"] = "not",
        ["specialAudio"] = "nil",
        ["areaCheck"] = 
        {
            ["openAreaCheck"] = false,

        },
        ["useSelf"] = false,
        ["Effect"] = 
        {
        },
    }
    self.bulletEffectData = {
        ["data"] = 
        {
              ["eventName"] = "ShootEffect",
              ["triggerTime"] = "0.55",
              ["effectId"] = "0",
              ["bombName"] = "nil",
              ["bombParent"] = "body",
              ["prefabName"] = "W_LiuS_Attack_Hit_001",
              ["effectEulerAngle"] = 
              {
                  ["x"] = "180",
                  ["y"] = "0",
                  ["z"] = "0"
              },
              ["effectScale"] = 
              {
                  ["x"] = "1",
                  ["y"] = "1",
                  ["z"] = "1"
              },
              ["bulletAudio"] = "nil",
              ["prefab"] = "W_LiuS_Attack_Fly_001",
              ["hitEffectParent"] = "Xiong",
              ["hitEffectDestroy"] = "3",
              ["speed"] = "25",
              ["lifeTime"] = "0",
              ["firePoint"] = 
              {
                  ["x"] = "1.5",
                  ["y"] = "1",
                  ["z"] = "-0.5"
              },
              ["isForward"] = false,
              ["rotate"] = false,
              ["isY"] = false,
              ["parent"] = "body",
              ["targetOffset"] = 
              {
                  ["x"] = "0",
                  ["y"] = "0",
                  ["z"] = "0"
              },
              ["EditorBuffName"] = "nil",
        },
        
    }

    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})

end


--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    local buf_players = {}

    if self.player:equal(ply) and config ~= nil then
      if config.anim_name == "attack1" then
        local enemy = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
        for i = 1, enemy.Count do
            local ply = enemy:get(i-1)
            local buffs = ply.bufMgr:findBufByTag("W_LiuS_skill1")
            if #buffs > 0 then
             -- self.bulletTable.firePoint.y = WRandom:randomNum(5, 15)/10
              self.bulletTable.frontdamagePercent = self.atk or 0
              self:bulletInit(self.bulletTable, ply.position, ply)
            end
        end

      end
        
    end
end

function M:bulletInit(data, position, target)
    -- 神器功能已经移除了，所以这段代码注释掉了。
    -- 所有的子弹创建都总BulletManager:createBullet
    
    
    ----加载预制
    --local bullet = require("Battle.Blt.Bullet").new()
    --bullet.target = position
    --bullet.enemy = target
    --bullet.sourceSkill = self.skill
    --bullet:init(data["bulletType"], self.bulletEffectData, self.player,data)
    --
    ----将子弹加入到人物管理器
    --self.player.bulletMgr:addBullet(bullet)
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end

return M