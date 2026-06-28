---@class PlayerData @玩家数据类
---@field player PlayerModel
---@field hp PlayerDataItem @血量(加，乘，同类加异类乘)
---@field atk PlayerDataItem @攻击(加，乘，同类加异类乘)
---@field def PlayerDataItem @防御(加，乘，同类加异类乘)
---@field atd PlayerDataItem @外伤减伤(乘，同类加异类乘)
---@field physicaldamage PlayerDataItem @外伤增伤(乘，同类加异类乘)
---@field res PlayerDataItem @内伤减伤(乘，同类加异类乘)
---@field magicdamage PlayerDataItem @内伤增伤(乘，同类加异类乘)
---@field critrate PlayerDataItem @暴击率（50.0=50.0%）(加)
---@field critrate_correct PlayerDataItem @暴击率修正值（50.0=50.0%）(加)
---@field resi PlayerDataItem @抗暴（50.0=50.0%）(加)
---@field resi_correct PlayerDataItem @抗暴修正值（50.0=50.0%）(加)
---@field crit PlayerDataItem @暴击效果（120=120%）(加)
---@field discrit PlayerDataItem @暴击效果减免（120=120%）(加)
---@field dodge PlayerDataItem @闪避等级(加)
---@field hr PlayerDataItem @命中等级(加)
---@field haste PlayerDataItem @攻速（120=120%）(加)
---@field spd PlayerDataItem @移速（120=120%）(加)
---@field cdup PlayerDataItem @冷却加速（120=120%）(加)
---@field leeching PlayerDataItem @吸血等级（20=20%）(加)
---@field atkrageregen PlayerDataItem @攻击回怒(加)
---@field hurtrageregen PlayerDataItem @受伤回怒(加)
---@field restore_anger PlayerDataItem @每秒怒气回复
---@field rageregenper PlayerDataItem @怒气回复百分比
---@field killAngerRate PlayerDataItem @击杀怒气回复比例
---@field hpRecover PlayerDataItem @生命恢复效果(加，乘，同类加异类乘)
---@field cureRate PlayerDataItem @治疗效果(加，乘，同类加异类乘)
---@field raceA PlayerDataItem @种族相克系数A
---@field raceB PlayerDataItem @种族相克系数B
---@field raceC PlayerDataItem @种族相克系数C
---@field fiveElement_raceA PlayerDataItem @五行阵种族相克系数A
---@field discontrol PlayerDataItem @ --坚韧
---@field resatd PlayerDataItem @   	 --伤害减免
---@field pmdamage PlayerDataItem @ 	 --伤害增加
---@field rediscontrol PlayerDataItem @--坚韧抵抗(减法抵扣坚韧最大至0)
---@field disres PlayerDataItem @ --内伤加深1%
---@field disatd PlayerDataItem @ --外伤加深1%
---@field power PlayerDataItem @ -- 宠物气势值
local M = class("PlayerData")

M.player = nil

-- ===========================================  属性列表  =====================================================
M.dataList = 
{
	"hp",--血量(加，乘，同类加异类乘)
	"atk",--攻击(加，乘，同类加异类乘)
	"def",--防御(加，乘，同类加异类乘)
	
	"atd",--外伤减伤(乘，同类加异类乘)
	"physicaldamage",--外伤增伤(乘，同类加异类乘)
	"res",--内伤减伤(乘，同类加异类乘)
	"magicdamage",--内伤增伤(乘，同类加异类乘)

	"critrate",--暴击率（50.0=50.0%）(加)
	"critrate_correct",--暴击率修正值（50.0=50.0%）(加)
	"resi",--抗暴（50.0=50.0%）(加)
	"resi_correct",--抗暴修正值（50.0=50.0%）(加)
	"crit",--暴击效果（120=120%）(加)
	"discrit",--暴击效果减免（120=120%）(加)
	
	"dodge",--闪避等级(加)
	"hr",--命中等级(加)
	
	"haste",--攻速（120=120%）(加)
	"spd",--移速（120=120%）(加)
	"cdup",--冷却加速（120=120%）(加)
	
	"leeching",--吸血等级（20=20%）(加)

	"atkrageregen",--攻击回怒(加)
	"hurtrageregen",--受伤回怒(加)
	"restore_anger",--每秒怒气回复
	"rageregenper",--怒气回复百分比
	"killAngerRate",--击杀怒气回复比例
	
	"hpRecover",--生命恢复效果(加，乘，同类加异类乘)
	"cureRate",--治疗效果(加，乘，同类加异类乘)

	"raceA",--种族相克系数A
	"raceB",--种族相克系数B
	"raceC",--种族相克系数C
	"fiveElement_raceA",--五行阵种族相克系数A
	
	"discontrol", 	 --坚韧
	"resatd",     	 --伤害减免
	"pmdamage",   	 --伤害增加
	"rediscontrol",  --坚韧抵抗(减法抵扣坚韧最大至0)
	"disres",		 --内伤加深1%
	"disatd",		 --外伤加深1%
	"power", 		 --宠物气势值
}


--初始化 data 外部数据
function M:init( player )	
	-- 所有玩家数值都使用定点数去计算
	-- 玩家model
	self.player = player
	--3 
	self.level_maxNum = GlobalTools.base3;
	--是否是无敌的
	self.isInvincible = 0
	--是否是内伤无敌的
	self.isIn_Invincible = 0
	--是否是外伤无敌的
	self.isOut_Invincible = 0
	--反弹伤害百分比
	self.reboundDmg = 0;
	--是否有边界限制
	self.limitByArea = true;
	--旋转速度
	self.rotaSpeed = GlobalTools.base4
	--玩家的周身半径
	self.radius = GlobalTools.base0_5
	--0.1
	self.level_minNum = GlobalTools.base0_1;
	--触发半径，子弹用的
	self.triggerRadius = GlobalTools.base0_1;
	--初始血量
	self.hpInit = GlobalTools.base1000;
	--初始攻击力
	self.atkInit = GlobalTools.base100;
	--最大怒气
	self.maxAnger = GlobalTools.base1000;
	--玩家当前怒气
	self.curAnger = 0;
	--怒气锁
	self.angerLock = false
	--怒气增加
	self.angerLockAdd = false;
	--怒气减少
	self.angerLockReduce = false;
	--玩家当前的血量
	self.curHp = 0;
	--血量锁定
	self.hpLock = false;
	--默认攻击范围
	self.atkRange = GlobalTools.base4;
	--检测半径
	self.check_radius = GlobalTools.base1;
	--移动速度
	self.moveSpeed = GlobalTools.base4;
	--固有闪避率(0.05)
	self.dodge_base = ConfigManager:getBattleCommonValueById(28,0, true)
	--闪避常量1(165)
	self.dodgeA = ConfigManager:getBattleCommonValueById(29,0, true)
	--吸血参数(100)
	self.leechingA = ConfigManager:getBattleCommonValueById(57,0, true)
	--伤害系数(1,1,1,5)
	self.damageValue1 = ConfigManager:getBattleCommonValueById(24,0, true)
	self.damageValue2 = ConfigManager:getBattleCommonValueById(25,0, true)
	self.damageValue3 = ConfigManager:getBattleCommonValueById(26,0, true)
	self.damageValue4 =  ConfigManager:getBattleCommonValueById(27,0, true)
	--攻速系数(200)
	self.hasteA = ConfigManager:getBattleCommonValueById(91,0, true)
	--移速系数(200)
	self.spdA = ConfigManager:getBattleCommonValueById(92,0, true)
	--击杀回怒(200)
	self.killEnergy = ConfigManager:getBattleCommonValueById(31,0, true)
	--基础暴击伤害(200)
	self.crit_base = ConfigManager:getBattleCommonValueById(23,0, true)
	--基础攻击速度(200)
	self.haste_base = ConfigManager:getBattleCommonValueById(99,0, true)
	--基础冷却加速(200)
	self.cd_base = ConfigManager:getBattleCommonValueById(100,0, true)
	--基础移动速度(200)
	self.spd_base = ConfigManager:getBattleCommonValueById(101,0, true)
	--基础攻击怒气回复速度(1)
	self.attackAnger_base = ConfigManager:getBattleCommonValueById(102,0, true)
	--基础受击怒气回复速度(1)
	self.injureAnger_base = ConfigManager:getBattleCommonValueById(103,0, true)
	--基础生命恢复效果(1)
	self.recoverHp_base = ConfigManager:getBattleCommonValueById(104,0, true)
	--基础治疗效果(1)
	self.cure_base = ConfigManager:getBattleCommonValueById(105,0, true)
	--基础外伤减伤(1)
	self.out_reduce_base = ConfigManager:getBattleCommonValueById(106,0, true)
	--基础内伤减伤(1)
	self.in_reduce_base = ConfigManager:getBattleCommonValueById(107,0, true)
	--基础外伤增伤(1)
	self.out_add_base = ConfigManager:getBattleCommonValueById(108,0, true)
	--基础内伤增伤(1)
	self.in_add_base = ConfigManager:getBattleCommonValueById(109,0, true)
	--种族相克系数A(被攻击者克制的种族)(1.25)
	self.raceA_base = ConfigManager:getBattleCommonValueById(70,0, true)
	--基础相克系数B(不被攻击者克制的种族)(1)
	self.raceB_base = ConfigManager:getBattleCommonValueById(96,0, true)
	--基础相克系数C(克制攻击者的种族)(1)
	self.raceC_base = ConfigManager:getBattleCommonValueById(97,0, true)
	--五行阵中的相克系数A(被攻击者克制的种族)(1.25)
	self.fiveElement_raceA_base = ConfigManager:getBattleCommonValueById(69,0, true)
	--等级压制
	self.level_suppress_base = ConfigManager:getBattleCommonValueById(291,0, true)
	
	local dataItem = require("Battle.Ply.PlayerDataItem")
	for k,v in ipairs(self.dataList) do
		self[v] = dataItem.new()
		self[v]:init(v)
	end
	self.atd:setCalType("reduce")
	self.res:setCalType("reduce")

	--初始值赋值
	self.hp:setInitialValue(self.hpInit)
	self.atk:setInitialValue(self.atkInit)
	self.def:setInitialValue(0)
	self.atd:setInitialValue(self.out_reduce_base)
	self.res:setInitialValue(self.in_reduce_base)
	self.physicaldamage:setInitialValue(self.out_add_base)
	self.magicdamage:setInitialValue(self.in_add_base)

	self.critrate:setInitialValue(GlobalTools.base1)
	self.critrate_correct:setInitialValue(GlobalTools.base0)
	self.resi:setInitialValue(GlobalTools.base1)
	self.resi_correct:setInitialValue(GlobalTools.base0)
	self.crit:setInitialValue(self.crit_base)
	self.discrit:setInitialValue(GlobalTools.base0)
	
	self.dodge:setInitialValue(GlobalTools.base0)
	self.hr:setInitialValue(GlobalTools.base0)
	
	self.haste:setInitialValue(self.haste_base)
	self.spd:setInitialValue(self.spd_base)
	self.cdup:setInitialValue(self.cd_base)

	self.leeching:setInitialValue(GlobalTools.base0)
	
	self.atkrageregen:setInitialValue(self.attackAnger_base)
	self.hurtrageregen:setInitialValue(self.injureAnger_base)
	self.restore_anger:setInitialValue(GlobalTools.base0)
	self.rageregenper:setInitialValue(GlobalTools.base1)
	self.killAngerRate:setInitialValue(GlobalTools.base1)
	
	self.hpRecover:setInitialValue(self.recoverHp_base)
	self.cureRate:setInitialValue(self.cure_base)

	self.raceA:setInitialValue(self.raceA_base)
	self.raceB:setInitialValue(self.raceB_base)
	self.raceC:setInitialValue(self.raceC_base)
	self.fiveElement_raceA:setInitialValue(self.fiveElement_raceA_base)

	--坚韧
	self.discontrol_value = ConfigManager:getBattleCommonValueById(111,GlobalTools.base0, true)
	self.discontrol:setInitialValue(GlobalTools.base0)
	--伤害减免
	self.resatd:setInitialValue(GlobalTools.base0);
	--伤害增加
	self.pmdamage:setInitialValue(GlobalTools.base0);
	--坚韧抵抗(减法抵扣坚韧最大至0)
	self.rediscontrol:setInitialValue(GlobalTools.base0);
	--内伤加深1%
	self.disres:setInitialValue(GlobalTools.base0);
	--外伤加深1%
	self.disatd:setInitialValue(GlobalTools.base0);
	-- 宠物气势值
	self.power:setInitialValue(GlobalTools.base0);
	--伤害减免
	local atd_links = { self.atd, self.res }
	self.resatd:setLinks( atd_links )
	--伤害增加
	local pm_links = { self.physicaldamage, self.magicdamage }
	self.pmdamage:setLinks( pm_links )
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 人物品质 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function M:set_evo( value )
	self.evo = value
end

function M:get_evo()
	return self.evo
end
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 人物等级 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 人物等级 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function M:set_level( value )
	self.level = value
end

function M:get_level()
	return self.level
end
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 人物等级 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 攻击力 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function M:get_atk()
	return self.atk:getValue()
end

function M:set_atk( value )
	self.atk:setForce( value );
end


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 攻击力 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 移动速度 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- speed 是个普通数值 
function M:set_moveSpeed( speed )
	self.moveSpeed = speed;
end

function M:get_moveSpeed()
	return self.moveSpeed;
end
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 移动速度 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 血量 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--获取hp的数值
function M:get_hp()
	return self.hp:getValue();
end

function M:set_hp( maxhp )
	self.hp:setForce( maxhp );
	self:maxHpChanged()
end

function M:maxHpChanged()
	EventDispatcher:dipatchEvent("MaxHpChanged", {player = self.player})
end

--返回 hp 比率
function M:get_hpRate()
	if self:get_curHp() == 0 then
		return 0;
	end
	return GlobalTools:Div(self:get_curHp(),self:get_hp())
end
--返回 扣血后的hp 比率
function M:get_hpRateAfterLost(lostHp)
	if self:get_curHp() == 0 then
		return 0;
	end
	return GlobalTools:Div(self:get_curHp() - lostHp,self:get_hp())
end

--获取当前的血量
function M:get_curHp()
	return self.curHp;
end

--设定血量
function M:set_curHp( hp, isDirect )
	if self.hpLock == true then
		return
	end
	
	--越界处理
	if hp > self.hp:getValue() then
		hp = self.hp:getValue()
	end

	if SceneManager.curScene.m_game_mode == Battle.BattleGlobalConfig.BATTLE_MODE.LEGEND and SceneManager.curScene.battle_mode == 2 then
		if self.player.camp == 1 and hp < self.hp:getValue() then
			return
		end
	end
	
	self.curHp = hp

	local hpData = {}
	hpData.maxHp = self.hp:getValue();
	hpData.curHp = self.curHp;
	hpData.hpRate = self:get_hpRate();
	hpData.isDirect = isDirect or 0;

	--给本地发送事件，只有对应的视图层才能接收到事件 
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelHpChange, hpData);

	--设定血量
	EventDispatcher:dipatchEvent("selfHp",{ ply = self.player, operator = "=", value = hpData.hpRate, type = "self", reset = false, breakAnim = false})
	EventDispatcher:dipatchEvent("HpUpdate",{ data = self.player, hp = GlobalTools:ToFloat(hpData.hpRate), type = 4 })

	--统计当前血量,这里需要改进
	if SceneManager.curScene.tongjiData then
		SceneManager.curScene.tongjiData:setPlayerHp(self.player:get_playerInstanceId(), self:get_curHp(), self.player.camp)
	end
end
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 血量 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 怒气值 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--怒气值
function M:get_curAnger()
	return self.curAnger;
end

--返回最大怒气值
function M:get_maxAnger()
	return self.maxAnger;
end

--获取当前怒气和最大怒气的比例
function M:get_AngerRate()
	--使用定点数处理怒气比例
	return GlobalTools:Div(self.curAnger,self.maxAnger)
end

--增加怒气(增量)
function M:addAnger( anger, showlabel )
	if self.angerLock == true then
		return
	end
	
	if anger > 0 and self.curAnger < self.maxAnger then
		--增加怒气
		self:set_anger(self.curAnger + anger)
		if showlabel ~= nil and self:isLockAnger(self.curAnger + anger,nil) == false then
			self.player:showLabel( anger,"+",4);
		end
		
	elseif anger < 0 and self.curAnger > 0 then
		--减少怒气
		self:set_anger(self.curAnger + anger)
		if showlabel ~= nil and self:isLockAnger(self.curAnger + anger,nil) == false then
			self.player:showLabel( anger,"",4);
		end
	end
end

function M:setHpLock(lock)
	self.hpLock = lock
end

--锁定怒气值
function M:setAngerLock(lock)
	self.angerLock = lock
end

function M:setAngerLockAdd( lock )
	self.angerLockAdd = lock 
end

function M:setAngerLockReduce( lock )
	self.angerLockReduce = lock
end

function M:isLockAnger( anger, isForce )
	if self.angerLock == true and isForce == nil then
		return true
	end
	--阻止增加
	if self.angerLockAdd == true and self.curAnger < anger and isForce == nil then
		return true 
	end
	--阻止减少
	if self.angerLockReduce == true and self.curAnger > anger and isForce == nil then
		return true
	end
	return false;
end

--设定怒气
function M:set_anger( anger, isForce )
	if self:isLockAnger(anger, isForce) then
		return
	end
	if SceneManager.curScene.collectData then
		SceneManager.curScene.collectData:causeAnger(self.player, anger - self.curAnger)
	end
	self.curAnger = anger
	--将当前怒气设置到 0 和 maxAnger 之间 
	if self.curAnger >= self.maxAnger then
		--发送怒气满了的事件
		local skill = self.player.plySkill:getSkillByName("skill3")
		if skill == nil then
			self.player.plySkill:getSkillByName("skill3_plus")
		end
		if skill ~= nil then
			local curSkillConfig = skill.cur_skill_config
			if curSkillConfig ~= nil and curSkillConfig:canUseSkill3() == true then
				EventDispatcher:dipatchEvent("AngerMax",{ data = self.player, type = 2 })
			end
		end
		self.curAnger = self.maxAnger
	elseif self.curAnger <= GlobalTools.base0 then
		self.curAnger = GlobalTools.base0;
	end
	--当前怒气和最大怒气的比例
	local rate = self:get_AngerRate();
	EventDispatcher:dipatchEvent("AngerUpdate",{ data = self.player,angerValue = GlobalTools:ToFloat(rate), type = 3 })
	if SceneManager.curScene.tongjiData then
		SceneManager.curScene.tongjiData:setPlayerRage(self.player:get_playerInstanceId(), self.curAnger, self.player.camp)
	end
	self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerModelAngerChange, {isDirect = 1});
end

--是否满怒气
function M:isMax_anger()
	if self.curAnger >= self.maxAnger then
		return true
	end
	return false
end

--清空怒气
function M:clear_anger()
	self:set_anger(GlobalTools.base0, true)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 怒气值 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 玩家攻击力 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


--每秒恢复怒气
function M:get_restore_anger()
	return self.restore_anger:getValue()
end

--闪避计算
--skill：使用的技能
--killer：攻击者
--返回值：是否闪避
function M:dodgeCal(skill, killer)
	if skill == nil then
		return false
	else
		--内伤不闪避
		if skill.atk_type == 1 then
			return false
		else
			--can_dodge 值为0时不会被闪避
			if skill.can_dodge ~= nil and skill.can_dodge == 0 then
				return false
			else
				local dodgeLevel = self.dodge:getValue() - killer.data.hr:getValue()
				if dodgeLevel <= -GlobalTools.base165 then
					return false
				end
				local dodge = self.dodge_base + GlobalTools:Div(dodgeLevel , (dodgeLevel + self.dodgeA))
				local random_fix = WRandom:randomNum(0,10000)
				return random_fix <= GlobalTools:Mul(dodge,GlobalTools.base10000);
			end
		end
	end
end

--暴击计算
---@param killer PlayerModel
---@param victim PlayerModel
---@return boolean 是否暴击
function M:critCal(killer,victim)
	if killer ~= nil then
		local crit = killer.data.critrate:getValue() + killer.data.critrate_correct:getValue()
		local k_crit = self.resi:getValue() + self.resi_correct:getValue()
		local rate = GlobalTools:Div((crit - k_crit), GlobalTools.base100)
		local random_fix = WRandom:randomNum(0,10000)
		local rate_value = GlobalTools:Mul(rate, GlobalTools.base10000)
		local isCrit = random_fix <= rate_value
		if isCrit then
			EventDispatcher:dipatchEvent("critCount",{ ply = killer,victim = victim, operator = "+", value = 1, type = "self", ignoreSkills = {"skill2", "skill3"},breakAnim = true})
		end
		return isCrit
	end
	return false
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
	local def = self.def:getValue()
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

	--暴击系数
	local crit = GlobalTools.base1
	if isCrit then
		crit = killer.data:getCrit(self.discrit:getValue())
	end

	local level_suppress = GlobalTools.base1
	if killer:get_camp() == 1 then
		level_suppress = self:levelSuppress(true)
	elseif self.player:get_camp() == 1 then
		level_suppress = self:levelSuppress(false)
	end
	
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

--等级压制系数
function M:levelSuppress(isKiller)
	local level_suppress = SceneManager.curScene.level_suppress
	local averageLevel = SceneManager.curScene.plyMgr.averageLevel
	if level_suppress > 0 and averageLevel > level_suppress then
		if isKiller == true then
			local baseNum = GlobalTools.base1 + GlobalTools:Mul(self.level_suppress_base, averageLevel - level_suppress);
			return GlobalTools:Min(baseNum, self.level_maxNum)
		else
			local baseNum = GlobalTools.base1 - GlobalTools:Mul(self.level_suppress_base, averageLevel - level_suppress);
			return GlobalTools:Max(baseNum, self.level_minNum)
		end
	end
	return GlobalTools.base1
end

--获取爆伤系数
function M:getCrit(discrit)
	local crit = Mathf.Max(GlobalTools.base100, self.crit:getValue() - discrit)
	return GlobalTools:Div(crit, GlobalTools.base100);
end

--计算暴击伤害
---@param killer PlayerModel
function M:calCritDamage(killer, damage)
	local crit = killer.data:getCrit(self.discrit:getValue())	--暴击系数
	return GlobalTools:Mul(damage, crit);
end

--获取种族相克系数
function M:getRaceRate(killer)
	--演武场战斗忽略种族克制
	if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.RAID then
		return self.raceB:getValue()
	else
		local result = GlobalTools:checkRace(killer, self.player)
		if result == 1 then
			if SceneManager.curScene.sceneId == SceneManager.SceneID.WuXingZhenScene then
				return self.fiveElement_raceA:getValue()
			else
				return self.raceA:getValue()
			end
		elseif result == 0 then
			return self.raceB:getValue()
		elseif result == -1 then
			return self.raceC:getValue()
		end
	end
end

--dot伤害
--返回最终伤害
function M:dotCal(skill, killer, param)
	local damage = param
	if skill ~= nil and killer ~= nil then
		damage = GlobalTools:Mul(damage, self:getRaceRate(killer))
		if skill ~= nil then
			damage = self:in_out_damageCal(damage, skill.atk_type, killer)
		end
	end
	
	if damage < GlobalTools.base1 then
		damage = GlobalTools.base1
	end
	
	return damage
end

---特殊兼容 在低于v1.3.0时，使用老版的战斗公式
function M:in_out_damageCal(damage, damageType, killer)
	if SceneManager.curScene.USE_NEW_DIS_ATD_DES_FORMULA then
		return self:in_out_damageCal_Right(damage, damageType, killer)
	else
        return self:in_out_damageCal_Old(damage, damageType, killer)
    end
end

--内外伤伤害计算
--返回内外伤计算后伤害
---真确的内外伤加深公式
function M:in_out_damageCal_Right(damage, damageType, killer)
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
	
	if killer ~= nil then
		--外伤伤害
		if damageType == 2 then
			--外伤减伤 atd
			local phy_damage_atd = 0
			if self.atd:getValue() > GlobalTools.base1 then
				local damage_atd = GlobalTools:Mul(damage, self.atd:getValue());
				phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
			else
				local realAtd = self.atd:getValue() + killer.data.disatd:getValue()
				if realAtd <= GlobalTools.base1 and realAtd > 0 then
					--如果 (外伤减伤率[防]+外伤加深[攻]) >0.1且<=1
					--外伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * (外伤减伤率[防]+外伤加深[攻]) * 外伤增伤率[攻]
					--local damage_atd = GlobalTools:Mul(damage, (self.atd:getValue() + self.disatd:getValue()) );
					local damage_atd = GlobalTools:Mul(damage, realAtd);
					phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
				elseif realAtd > GlobalTools.base1 then
					--(外伤减伤率[防]+外伤加深[防]) >1
					--外伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * 1*外伤增伤率[攻]
					phy_damage_atd = GlobalTools:Mul(damage, killer.data.physicaldamage:getValue());
				else
					phy_damage_atd = 0
				end
			end
			--local damage_atd = GlobalTools:Mul(damage, self.atd:getValue());
			--local phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
			damage = phy_damage_atd;
			--内功伤害
		elseif damageType == 1 then
			local mag_damage_atd = 0
			if self.res:getValue() > GlobalTools.base1 then
				local damage_res = GlobalTools:Mul(damage, self.res:getValue() );
				mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
			else
				local realRes = self.res:getValue() + killer.data.disres:getValue()
				if realRes <= GlobalTools.base1 and realRes > 0 then
					--如果 (内伤减伤率[防]+内伤加深[攻]) >0.1且<=1
					--内伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * (内伤减伤率[防]+内伤加深[攻]) * 内伤增伤率[攻]
					--local damage_res = GlobalTools:Mul(damage, (self.res:getValue() - self.disres:getValue()) );
					local damage_res = GlobalTools:Mul(damage, realRes);	-- 暂时设定([防]内伤加深)对自己生效
					mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
				elseif realRes > GlobalTools.base1 then
					--(内伤减伤率[防]+内伤加深[防]) >1
					--内伤伤害 = [ 伤害系数1 * 杀伤力 ] * [ 伤害系数2 * 杀伤力 ] / [ 伤害系数3 * 杀伤力 + 伤害系数4 * 防御力[防] ] * 1*内伤增伤率[攻]
					mag_damage_atd = GlobalTools:Mul(damage, killer.data.magicdamage:getValue());
				else
					mag_damage_atd = 0;
				end
			end
			--local damage_res = GlobalTools:Mul(damage, self.res:getValue());
			--local mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
			damage = mag_damage_atd;
		end
	end
	return damage
end

--内外伤伤害计算
--返回内外伤计算后伤害
--- 旧版的内外伤公式
function M:in_out_damageCal_Old(damage, damageType, killer)
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

	if killer ~= nil then
		--外伤伤害
		if damageType == 2 then
			--外伤减伤 atd
			local phy_damage_atd = 0
			if self.atd:getValue() > GlobalTools.base1 then
				local damage_atd = GlobalTools:Mul(damage, self.atd:getValue());
				phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
			else
				if self.atd:getValue() + self.disatd:getValue() <= GlobalTools.base1 and self.atd:getValue() + self.disatd:getValue() > 0 then
					local damage_atd = GlobalTools:Mul(damage, (self.atd:getValue() + self.disatd:getValue()) );
					phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
				elseif self.atd:getValue() + self.disatd:getValue() > GlobalTools.base1 then
					phy_damage_atd = GlobalTools:Mul(damage, killer.data.physicaldamage:getValue());
				else
					phy_damage_atd = 0
				end
			end
			--local damage_atd = GlobalTools:Mul(damage, self.atd:getValue());
			--local phy_damage_atd = GlobalTools:Mul(damage_atd, killer.data.physicaldamage:getValue());
			damage = phy_damage_atd;
			--内功伤害
		elseif damageType == 1 then
			local mag_damage_atd = 0
			if self.res:getValue() > GlobalTools.base1 then
				local damage_res = GlobalTools:Mul(damage, self.res:getValue() );
				mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
			else
				if self.res:getValue() + self.disres:getValue() <= GlobalTools.base1 and self.res:getValue() + self.disres:getValue() > 0 then
					local damage_res = GlobalTools:Mul(damage, (self.res:getValue() - self.disres:getValue()) );
					mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
				elseif self.res:getValue() + self.disres:getValue() > GlobalTools.base1 then
					mag_damage_atd = GlobalTools:Mul(damage, killer.data.magicdamage:getValue());
				else
					mag_damage_atd = 0;
				end
			end
			--local damage_res = GlobalTools:Mul(damage, self.res:getValue());
			--local mag_damage_atd = GlobalTools:Mul(damage_res, killer.data.magicdamage:getValue());
			damage = mag_damage_atd;
		end
	end
	return damage
end

--获取护盾值
function M:getGuardValue(source, type, param)
	local guard = 0
	if type == "atk" then
		guard = GlobalTools:Mul(source.data.atk:getValue() , param)
	elseif type == "hp" then
		guard = GlobalTools:Mul(self:get_hp() , param)
	elseif type == "fix" then
		guard = param
	end
	if guard < GlobalTools.base1 then
		guard = GlobalTools.base1
	end
	return guard
end

--获取治疗量
---@param player PlayerModel 释放治疗者，治疗者
---@return number 返回治疗最终结果
function M:getCureValue(type, param, player)
	local cureValue = 0
	
	if type == "atk" then
		if player ~= nil then
			cureValue = GlobalTools:Mul( player.data.atk:getValue(), param )
		else
			cureValue = GlobalTools:Mul( self.atk:getValue(), param )
		end
	elseif type == "hp" then
		if player ~= nil then
			cureValue = GlobalTools:Mul( player.data:get_hp(), param )
		else
			cureValue = GlobalTools:Mul( self:get_hp(), param )
		end
	elseif type == "fix" then
		cureValue = param or 0	
	end
	
	local cureRate = GlobalTools.base1
	if player ~= nil then
		cureRate = player.data.cureRate:getValue()
	end
	local hpRecoverCureValue = GlobalTools:Mul(cureValue, self.hpRecover:getValue())
	cureValue = GlobalTools:Mul(hpRecoverCureValue, cureRate)
	if cureValue < GlobalTools.base1 and self.hpRecover:getValue() > GlobalTools.base0 and cureRate > GlobalTools.base0 then
		cureValue = GlobalTools.base1
	end
	return cureValue
end

--攻击方吸血计算
--damage：最终伤害
--返回值：吸血量
function M:leechingCal(damage)
	local leech_damage = GlobalTools:Mul(damage, self.leeching:getValue());
	local leeching = GlobalTools:Div( leech_damage, self.leechingA )
	return leeching
end

--获取攻击速度
function M:getHaste()
	if self.haste:getValue() <= GlobalTools.base0 then
		return self.hasteA
	end
	return GlobalTools:Div(self.haste:getValue(),self.hasteA)
end

--获取普攻cd
function M:getAttackCd(cd)
	if self.haste:getValue() <= GlobalTools.base0 then
		local cd_hast = GlobalTools:Mul(cd , self.hasteA);
		return cd_hast;
	end
	local cd_hast_value = GlobalTools:Div(self.hasteA, self.haste:getValue())
	local cd_hast = GlobalTools:Mul(cd_hast_value, cd)
	return cd_hast;
end

--获取技能cd
function M:getSkillCd(cd)
	if self.cdup:getValue() <= GlobalTools.base0 then
		local cd_hast = GlobalTools:Mul(cd , self.hasteA);
		return cd_hast
	end
	local cd_hast_value = GlobalTools:Div(cd, self.cdup:getValue() )
	local cd_hast = GlobalTools:Mul(cd_hast_value , self.hasteA)
	return cd_hast;
end

--获取移动速度
function M:getSpd()
	local moveSpeed_value = GlobalTools:Mul(self.moveSpeed, self.spd:getValue());
	return GlobalTools:Div( moveSpeed_value, self.spdA )
end

--获取击杀回复怒气
function M:getKillEnergy()
	local kill_energy = GlobalTools:Mul(self.killEnergy, self.rageregenper:getValue())
	return GlobalTools:Mul(kill_energy, self.killAngerRate:getValue())
end

--获取攻击回怒
--skill:使用的技能
function M:getAtkEnemgy(skill, param)
	local hit_energy = GlobalTools.base1;
	if skill ~= nil then
		hit_energy = skill.hit_energy
	end
	param = param or GlobalTools.base1;
	local energy_value = GlobalTools:Mul(hit_energy, param);
	local atk_value = GlobalTools:Mul(self.atkrageregen:getValue(), self.rageregenper:getValue());
	return GlobalTools:Mul(energy_value,atk_value)
end

--获取受击回怒
--skill:使用的技能
--param：回怒系数
function M:getInjureEnemgy(skill, param)
	local injure_energy = GlobalTools.base1
	if skill ~= nil then
		injure_energy = skill.injure_energy
	end
	-- 一般是怒气百分比
	param = param or GlobalTools.base1
	-- 受伤怒气 x 百分比
	local injure_energy_value = GlobalTools:Mul(injure_energy, param);
	-- 受伤增怒
	local hurt_value = GlobalTools:Mul(self.hurtrageregen:getValue(), self.rageregenper:getValue());
	-- 计算最终怒气
	local final_anger = GlobalTools:Mul(injure_energy_value,hurt_value)
	return final_anger
end

function M:clearTempData()
	for k,v in ipairs(self.dataList) do
		self[v]:clearTemp()
	end
end

function M:clearAllData()
	for k,v in ipairs(self.dataList) do
		self[v]:clearAllData()
	end
end

function M:addInvincible(type)
	--内伤无敌
	if type == 1 then
		self.isIn_Invincible = self.isIn_Invincible + GlobalTools.base1
	--外伤无敌
	elseif type == 2 then
		self.isOut_Invincible = self.isOut_Invincible + GlobalTools.base1
	--都无敌
	else
		self.isInvincible = self.isInvincible + GlobalTools.base1
	end
end

function M:checkInvincible(type)
	if self.isInvincible > GlobalTools.base0 then
		return true
	else
		if type == 1 then
			if self.isIn_Invincible > GlobalTools.base0 then
				return true
			end
		elseif type == 2 then
			if self.isOut_Invincible > GlobalTools.base0 then
				return true
			end
		end
	end
	return false
end


function M:removeInvincible(type)
	if type == 1 then
		self.isIn_Invincible = self.isIn_Invincible - GlobalTools.base1
		if self.isIn_Invincible < GlobalTools.base0 then
			self.isIn_Invincible = GlobalTools.base0
		end
	elseif type == 2 then
		self.isOut_Invincible = self.isOut_Invincible - GlobalTools.base1
		if self.isOut_Invincible < GlobalTools.base0 then
			self.isOut_Invincible = GlobalTools.base0
		end
	else
		self.isInvincible = self.isInvincible - GlobalTools.base1
		if self.isInvincible < GlobalTools.base0 then
			self.isInvincible = GlobalTools.base0
		end
	end
end

--复制角色属性
function M:copyData(player, isInit, rate)
	rate = rate or GlobalTools.base1
	self.hp:setInitialValue(self:getCopyData(player.data.hp, isInit, rate))
	self.atk:setInitialValue(self:getCopyData(player.data.atk, isInit, rate))
	self.def:setInitialValue(self:getCopyData(player.data.def, isInit, rate))
	
	--self.atd:setInitialValue(self:getCopyData(player.data.atd, isInit, rate))
	--self.physicaldamage:setInitialValue(self:getCopyData(player.data.physicaldamage, isInit, rate))
	--self.res:setInitialValue(self:getCopyData(player.data.res, isInit, rate))
	--self.magicdamage:setInitialValue(self:getCopyData(player.data.magicdamage, isInit, rate))
	--
	--self.critrate:setInitialValue(self:getCopyData(player.data.critrate, isInit, rate))
	--self.resi:setInitialValue(self:getCopyData(player.data.resi, isInit, rate))
	--self.crit:setInitialValue(self:getCopyData(player.data.crit, isInit, rate))
	--
	--self.dodge:setInitialValue(self:getCopyData(player.data.dodge, isInit, rate))
	--self.hr:setInitialValue(self:getCopyData(player.data.hr, isInit, rate))

	--self.haste:setInitialValue(self:getCopyData(player.data.haste, isInit, rate))
	--self.spd:setInitialValue(self:getCopyData(player.data.spd, isInit, rate))
	--self.cdup:setInitialValue(self:getCopyData(player.data.cdup, isInit, rate))

	--self.leeching:setInitialValue(self:getCopyData(player.data.leeching, isInit, rate))
end

--获取面板属性或者当前属性
function M:getCopyData(dataItem, isInit, rate)
	if isInit then
		return GlobalTools:Mul(dataItem.initialValue, rate)
	else
		return GlobalTools:Mul(dataItem:getValue(), rate)
	end
end

--设置当前英雄的某个属性值变化的监听  listen_name消息事件名，atr_name要监听的属性
function M:registerAtrChangedByName(listen_name, atr_name)
	if self[atr_name] and self[atr_name].setAtrChangeListen then
		self[atr_name]:setAtrChangeListen(listen_name, atr_name)
	end
end
return M
