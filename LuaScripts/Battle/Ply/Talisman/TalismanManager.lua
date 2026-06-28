Talisman = require("Battle.Ply.Talisman.Talisman")
---@class TalismanManager
---@field player PlayerModel
local M = class("TalismanManager")

--初始化
function M:init(player )
    self.player = player;
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:destroy()
        end
    end
    self.talismanScript_tab = {}
    --符篆套裝
    local seal_character = self.player.heroData.seal_character_buffs or {}
    self.seal_suit_cfg = ConfigManager:getCfgByName("seal_character_buff") or {}
    for i = 1, #seal_character do
        local tailsman_id = seal_character[i] or 0
        local cur_seal_item = self.seal_suit_cfg[tailsman_id]
        if cur_seal_item ~= nil and cur_seal_item.type ~= "" then
            local talismanScript = require("Battle.Ply.Talisman.Talisman" .. cur_seal_item.type).new()
            if talismanScript ~= nil then
                talismanScript:init(self.player, cur_seal_item.param)
                self.talismanScript_tab[i] = talismanScript
            end
        else
            Logger.logError("符篆套裝 ~~~~ 配置seal_character_buff没有找到 id： " .. tailsman_id)
        end
    end
   
end

--游戏开始时
function M:gameStart()
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:gameStart()
        end
    end
end

function M:spawnFinish()
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:spawnFinish()
        end
    end
end

--更新
function M:update( dt )
    --Logger.logError("玩家更新 ~~~~~~~~~~~~~~~~~~ ")
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:update()
        end
    end
end

--攻击时
function M:Attack( attackData, wantdata )
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:Attack(attackData, wantdata)
        end
    end
end

--被攻击时
function M:BeHit( attackData )
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:BeHit(attackData)
        end
    end
end

--被攻击技术时
function M:BeHitOver()
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:BeHitOver()
        end
    end
end

--死亡之前的攻击
function M:attackBeforeDead(damage)
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            return self.talismanScript_tab[i]:attackBeforeDead(damage)
        end
    else
        return damage
    end
end

-- 技能开始
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillStart(ply, skill)
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:skillStart(ply, skill)
        end
    end
end

-- 技能结束
---@param ply PlayerModel
---@param skill SkillDataConfig
function M:skillEnd(ply, skill)
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:skillEnd(ply, skill)
        end
    end
end


--释放大招开始
function M:skill3Start()
    --Logger.logError(self.player.plyType.." 释放大招开始 ~~~~~~~~~~~~~~~~~~ ")
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:skill3Start()
        end
    end
end

--释放大招结束
function M:skill3Over()
    --Logger.logError(self.player.plyType.." 释放大招结束 ~~~~~~~~~~~~~~~~~~ ")
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:skill3Over()
        end
    end
end

--游戏结束时
function M:gameOver()
    --Logger.logError(" 战斗结束时 ~~~~~~~~~~~~~~~~~~ ")
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:gameOver()
        end
    end
end

function M:destroy()
    if self.talismanScript_tab ~= nil then
        for i = 1, #self.talismanScript_tab do
            self.talismanScript_tab[i]:destroy()
        end
    end
    self.talismanScript_tab = {}
end

return M;