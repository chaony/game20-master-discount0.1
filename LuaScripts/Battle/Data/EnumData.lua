----------- 枚举数据

---@class BattlerEnum
local M = {}

---@class BATTLE_ATTACK_FROM
local BATTLE_ATTACK_FROM = {
    Hit = 1,    -- 攻击
    Shoot = 2,  -- 射击
    Buff = 3    -- Buff
}
M.BATTLE_ATTACK_FROM = BATTLE_ATTACK_FROM

---@class BATTLE_DAMAGE_TYPE
local BATTLE_ATTACK_FROM = {
    Normal = 0,    -- 正常
    Rebound = 3    -- 反弹
}
M.BATTLE_ATTACK_FROM = BATTLE_ATTACK_FROM

---阵营数据
M.BATTLE_RACE = {
    Jin = 1,
    Huo = 2,
    Mu = 3,
    Shui = 4,
    Yang = 5,
    Yin = 6,
    Yuan = 7,
}

M.BATTLE_RACE_NAME = {
    --[[1 金]] Jin = "LongTing",
    --[[2 火]] Huo = "CaoMang",
    --[[3 木]] Mu = "ShiZu",
    --[[4 水]] Shui = "YiZu",
    --[[5 阳]] Yang = "GuiZhou",
    --[[6 阴]] Yin = "ZhuiFeng",
    --[[7 元]] Yuan = "Yuan",
}

---阵营数据
M.BATTLE_SPECIAL_HERO_ID = {
    TianYC = 701,
    WuZT = 717,
    DiRJ = 718,
	XiaoQ = 721,
    ZhouY = 723,
}

---霹雳布袋戏系列英雄id数据
M.BATTLE_PLBDX_HERO_ID = {709, 710, 711, 712}

return M
