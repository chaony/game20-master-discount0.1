
require("Battle.BattleData.EnvInit")

---@class DamageTest
---@field killer PlayerAttribute
---@field victim PlayerAttribute
local M = {
}

---@class PlayerAttribute
local PlayerAttribute = {
    atd = 0,--外伤减伤(乘，同类加异类乘)
    physicaldamage = 0,--外伤增伤(乘，同类加异类乘)
    res = 0,--内伤减伤(乘，同类加异类乘)
    magicdamage = 0,--内伤增伤(乘，同类加异类乘)
    disres = 0,		 --内伤加深1%
    disatd = 0,		 --外伤加深1%
    def = 0,
}

function M:init()
    --伤害系数(1,1,1,5)
    self.damageValue1 = ConfigManager:getBattleCommonValueById(24,0, true)
    self.damageValue2 = ConfigManager:getBattleCommonValueById(25,0, true)
    self.damageValue3 = ConfigManager:getBattleCommonValueById(26,0, true)
    self.damageValue4 =  ConfigManager:getBattleCommonValueById(27,0, true)


    --基础外伤减伤(1)
    local out_reduce_base = ConfigManager:getBattleCommonValueById(106,0, true)
    --基础内伤减伤(1)
    local in_reduce_base = ConfigManager:getBattleCommonValueById(107,0, true)
    --基础外伤增伤(1)
    local out_add_base = ConfigManager:getBattleCommonValueById(108,0, true)
    --基础内伤增伤(1)
    local in_add_base = ConfigManager:getBattleCommonValueById(109,0, true)
    
    PlayerAttribute.atd = out_reduce_base
    PlayerAttribute.res = in_reduce_base
    PlayerAttribute.physicaldamage = out_add_base
    PlayerAttribute.magicdamage = in_add_base
    
    PlayerAttribute.disres = 0
    PlayerAttribute.disatd = 0
end

--伤害计算
--skill：使用的技能
--killer：攻击者
--damageFront：技能系数
--damageLast：技能威力
--damageExtra：威力增加
--isCrit：是否暴击
--返回值：返回最终伤害
---@param skill SkillDataConfig
---@param killer PlayerModel
---@param damage number
---@param damageType number 内外功伤害
function M:damageCal(skill, killer, damage, damageFront, damageLast, damageType, damageExtra, isCrit)
    --damage = damage * damageFront + damageExtra
    damage = GlobalTools:Mul(damage, damageFront) + damageExtra
    --防御
    local def = self.victim.def
    --local value = self.damageValue3 * damage + self.damageValue4 * def
    --外伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * (外伤减伤率[防]-外伤加深[防]) * 外伤增伤率[攻]

    --[ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ]
    local value = GlobalTools:Mul(self.damageValue3, damage) + GlobalTools:Mul(self.damageValue4, def)
    if value == GlobalTools.base0 then
        value = GlobalTools.base1
    end
    --damage = (self.damageValue1 * damage) * (self.damageValue2 * damage) / value
    --[ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ]
    local damageValue1_result = GlobalTools:Mul(self.damageValue1, damage);
    local damgeValue_div = GlobalTools:Div(damageValue1_result, value);
    local damageValue2_result = GlobalTools:Mul(self.damageValue2, damage);
    damage = GlobalTools:Mul( damgeValue_div,damageValue2_result);
    damage = self:in_out_damageCal(damage, damageType, killer)
    
    --暴击系数  测试不计算暴击影响
    local crit = GlobalTools.base1
    --if isCrit then
    --    crit = killer.data:getCrit(self.discrit.value)    --
    --end

    -- 测试不计算等级压制
    local level_suppress = GlobalTools.base1
    --if killer:get_camp() == 1 then
    --    level_suppress = self:levelSuppress(true)
    --elseif self.player:get_camp() == 1 then
    --    level_suppress = self:levelSuppress(false)
    --end

    --damage = damage * crit * self:getRaceRate(killer) * damageLast * level_suppress
    local critDamage = GlobalTools:Mul(damage, crit);
    --种族相克系数
    local raceCritDamage = GlobalTools:Mul(critDamage, self:getRaceRate(killer));
    --和之前伤害系数相乘
    local raceCirtLastDamage = GlobalTools:Mul(raceCritDamage, damageLast);
    --level 系数相乘
    local raceCirtLastLvDamage = GlobalTools:Mul(raceCirtLastDamage, level_suppress);
    --damage = math.ceil(damage)
    damage = raceCirtLastLvDamage;
    if damage < GlobalTools.base1 then
        damage = GlobalTools.base1
    end
    return damage
end

--获取种族相克系数
function M:getRaceRate(killer)
    -- 测试不计算种族克制
    return GlobalTools.base1
end

--内外伤伤害计算
--返回内外伤计算后伤害
function M:in_out_damageCal_right(damage, damageType, killer)
    --(外伤减伤率[防]-外伤加深[防]) * 外伤增伤率[攻]

    --内伤加深1%
    --self.disres

    --外伤加深1%
    --self.disatd

    --外伤减伤(乘，同类加异类乘)
    --self.atd

    --外伤增伤(乘，同类加异类乘)
    --self.physicaldamage

    --内伤减伤(乘，同类加异类乘)
    --self.res

    --内伤增伤(乘，同类加异类乘)
    --self.magicdamage

    --伤害减免
    --self.resatd
    --伤害增加
    --self.pmdamage

    local killer = self.killer
    if killer ~= nil then
        --外伤伤害
        if damageType == 2 then
            --外伤减伤 atd
            local phy_damage_atd = 0
            if self.victim.atd > GlobalTools.base1 then
                local damage_atd = GlobalTools:Mul(damage, self.victim.atd);
                phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
            else
                local realAtd = self.victim.atd + killer.disatd
                if realAtd <= GlobalTools.base1 and realAtd > 0 then
                    --如果 (外伤减伤率[防]+外伤加深[攻]) >0.1且<=1
                    --外伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * (外伤减伤率[防]+外伤加深[攻]) * 外伤增伤率[攻]
                    --local damage_atd = GlobalTools:Mul(damage, (self.victim.atd + self.victim.disatd) );
                    local damage_atd = GlobalTools:Mul(damage, realAtd);
                    phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
                elseif realAtd > GlobalTools.base1 then
                    --(外伤减伤率[防]+外伤加深[防]) >1
                    --外伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * 1*外伤增伤率[攻]
                    phy_damage_atd = GlobalTools:Mul(damage, killer.physicaldamage);
                else
                    phy_damage_atd = 0
                end
            end
            --local damage_atd = GlobalTools:Mul(damage, self.victim.atd);
            --local phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
            damage = phy_damage_atd;
            --内功伤害
        elseif damageType == 1 then
            local mag_damage_atd = 0
            if self.victim.res > GlobalTools.base1 then
                local damage_res = GlobalTools:Mul(damage, self.victim.res );
                mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
            else
                local realRes = self.victim.res + killer.disres
                if realRes <= GlobalTools.base1 and realRes > 0 then
                    --如果 (内伤减伤率[防]+内伤加深[攻]) >0.1且<=1
                    --内伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * (内伤减伤率[防]+内伤加深[攻]) * 内伤增伤率[攻]
                    --local damage_res = GlobalTools:Mul(damage, (self.victim.res - self.victim.disres) );
                    local damage_res = GlobalTools:Mul(damage, realRes);	-- 暂时设定([防]内伤加深)对自己生效
                    mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
                elseif realRes > GlobalTools.base1 then
                    --(内伤减伤率[防]+内伤加深[防]) >1
                    --内伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * 1*内伤增伤率[攻]
                    mag_damage_atd = GlobalTools:Mul(damage, killer.magicdamage);
                else
                    mag_damage_atd = 0;
                end
            end
            --local damage_res = GlobalTools:Mul(damage, self.victim.res);
            --local mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
            damage = mag_damage_atd;
        end
    end
    return damage
end


--内外伤伤害计算
--返回内外伤计算后伤害
function M:in_out_damageCal_error(damage, damageType, killer)
    --(外伤减伤率[防]-外伤加深[防]) * 外伤增伤率[攻]

    --内伤加深1%
    --self.disres

    --外伤加深1%
    --self.disatd

    --外伤减伤(乘，同类加异类乘)
    --self.atd

    --外伤增伤(乘，同类加异类乘)
    --self.physicaldamage

    --内伤减伤(乘，同类加异类乘)
    --self.res

    --内伤增伤(乘，同类加异类乘)
    --self.magicdamage

    --伤害减免
    --self.resatd
    --伤害增加
    --self.pmdamage
    local killer = self.killer
    if killer ~= nil then
        --外伤伤害
        if damageType == 2 then
            --外伤减伤 atd
            local phy_damage_atd = 0
            if self.victim.atd > GlobalTools.base1 then
                local damage_atd = GlobalTools:Mul(damage, self.victim.atd);
                phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
            else
                if self.victim.atd + self.victim.disatd <= GlobalTools.base1 and self.victim.atd + self.victim.disatd > 0 then
                    local damage_atd = GlobalTools:Mul(damage, (self.victim.atd + self.victim.disatd) );
                    phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
                elseif self.victim.atd + self.victim.disatd > GlobalTools.base1 then
                    phy_damage_atd = GlobalTools:Mul(damage, killer.physicaldamage);
                else
                    phy_damage_atd = 0
                end
            end
            --local damage_atd = GlobalTools:Mul(damage, self.victim.atd);
            --local phy_damage_atd = GlobalTools:Mul(damage_atd, killer.physicaldamage);
            damage = phy_damage_atd;
            --内功伤害
        elseif damageType == 1 then
            local mag_damage_atd = 0
            if self.victim.res > GlobalTools.base1 then
                local damage_res = GlobalTools:Mul(damage, self.victim.res );
                mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
            else
                if self.victim.res + self.victim.disres <= GlobalTools.base1 and self.victim.res + self.victim.disres > 0 then
                    local damage_res = GlobalTools:Mul(damage, (self.victim.res - self.victim.disres) );
                    mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
                elseif self.victim.res + self.victim.disres > GlobalTools.base1 then
                    mag_damage_atd = GlobalTools:Mul(damage, killer.magicdamage);
                else
                    mag_damage_atd = 0;
                end
            end
            --local damage_res = GlobalTools:Mul(damage, self.victim.res);
            --local mag_damage_atd = GlobalTools:Mul(damage_res, killer.magicdamage);
            damage = mag_damage_atd;
        end
    end
    return damage
end

function M:doTest()
    self:init()

    
    local disatd = 0
    for i = 1, 100 do
        disatd = disatd + GlobalTools.base0_0_2
        self.killer = table.copy(PlayerAttribute)
        self.victim = table.copy(PlayerAttribute)
        self.victim.atd = GlobalTools.base0_7
        self.victim.disatd = disatd
        self.killer.disatd = GlobalTools:Mul(disatd, GlobalTools.base0) 
        
        local damageInfo = self:callDamage( 2)
        Logger.log(Json.encode({"RealDamage:",  
                                {
                                    self.victim.atd + self.killer.disatd,
                                    self.victim.atd + self.victim.disatd,
                                }, 
                                damageInfo} ))
        --assert(damageInfo[1] == damageInfo[2])
    end
end

function M:callDamage(damageType)
    local damage = GlobalTools.base10000
    local damageFront = GlobalTools.base1
    local damageLast = GlobalTools.base1
    local damageExtra = 0
    local isCrit = false


    self.in_out_damageCal = self.in_out_damageCal_right
    local realDamage1 = self:damageCal(
            {},
            self.killer,
            damage,
            damageFront,
            damageLast,
            damageType,
            damageExtra,
            isCrit)
    
    self.in_out_damageCal = self.in_out_damageCal_error
    local realDamage2 = self:damageCal(
            {},
            self.killer,
            damage,
            damageFront,
            damageLast,
            damageType,
            damageExtra,
            isCrit)
    return {realDamage1, realDamage2}
end

M:doTest()


return M