---
--- Created by xingsheng.gao.
--- DateTime: 2021/10/17

---@class Battle_StartupData_Battle_ClientInput_Team_Hero_Attr
---@field atk number
---@field critrate number
---@field def number
---@field hp number
---@field wight number


---@class Battle_StartupData_Battle_ClientInput_Team_Hero
---@field attrs Battle_StartupData_Battle_ClientInput_Team_Hero_Attr
---@field clv number
---@field combat number
---@field ctime number
---@field equips table
---@field evo number
---@field evo number
---@field id number
---@field ievo number
---@field lock boolean
---@field lv number
---@field odi string
---@field sig table
---@field skill number[] @{41011,41022,41031,41041}

---@class Battle_StartupData_Battle_ClientInput_Team
---@field deployment number
---@field dyns table
---@field heros table
---@field team string[]
---@field team_id number

---@class Battle_StartupData_Battle_ClientInput
---@field attacker_team Battle_StartupData_Battle_ClientInput_Team
---@field defener_team Battle_StartupData_Battle_ClientInput_Team

---@class Battle_StartupData_Battle_Common


---@class Battle_StartupData_Battle
---@field Battle_StartupData_Battle_ClientInput Battle_StartupData_Battle_ClientInput[]
---@field Battle_StartupData_Battle_Common Battle_StartupData_Battle_Common


---@class Battle_StartupData @ 创建战斗数据
---@field battle Battle_StartupData_Battle @战斗数据



---@class Battle_CreatePlayerData  @ 创建角色数据
---@field skill table<number, number> @服务器传来的技能
---@field playerId number @玩家的id
---@field summonAiType string @AI类型
---@field playerType string @角色类型 player, pet
---@field summonType string @玩家是否是宠物类型
---@field buffs table @初始buff
---@field mystics table @秘籍
---@field mysticBuffs table @秘籍Buffs
---@field camp number @阵营
---@field index number @玩家的位置索引
---@field master number @玩家的主人
---@field lv number @玩家等级
---@field clv number;
---@field evo number
---@field skin string
---@field pos table[] @玩家一开始的出生位置
---@field plyMgr PlayerManager_Model @玩家管理器
---@field plyData ConfigHeroDetail @玩家配置数据
---@field ai AIEngine
---@field isStoryPlayer boolean @是否是剧情人物，这个是视图层的会挪动到视图层
---@field moveType number @移动方式，这个是视图层的会挪动到视图层
---@field custom_prefab userdata @指定模型


---@class Battle_CX_Data

---@class Battle_CH_Data

---@class Battle_MS_Data

---@class Battle_Frame_Data_Event_Prefab
---@field type string
---@field prefab string
---@field position FixVector3
---@field autoDestroy number
---@field parent string xiong、xxx
---@field eulerAnger FixVector3
---@field scale FixVector3

---@class Battle_Frame_Data_Event @帧数据的事件
---@field bankName string
---@field eventName string ShootEffect|xx
---@field soundName string
---@field targetTime number
---@field prefabList Battle_Frame_Data_Event_Prefab[]
---@field EditorBuffName string
---@field lifeTime number
---@field targetOffset FixVector3
---@field speed number
---@field effectId string
---@field prefab string
---@field rotate boolean
---@field triggerTime number
---@field isForward boolean
---@field firePoint FixVector3
---@field isY boolean
---@field bulletAudio string
---@field count BattleTargetSelectData

---@class Battle_Frame_Data_Event_Hit : Battle_Frame_Data_Event @Hit帧数据的事件

---@class Battle_Frame_Data_Event_Shoot : Battle_Frame_Data_Event @Shoot帧数据的事件
---@field bulletType number
---@field data table
---@field attackerAnger number 攻击增怒
---@field lifeTime number 生命周期
---@field Speed number 垂直方向速度
---@field elayTime number 延迟时长
---@field elayBoomTime number 延迟爆炸时长
---@field puncturedmg boolean 穿刺伤害
---@field damageReduce number 伤害衰减
---@field isCircle boolean 是否回旋
---@field isForward boolean 是否正前方
---@field isSpecial boolean 是否是特殊效果
---@field SpecialParam string 特殊效果参数
---@field circleCount number 回旋次数
---@field angerAirPercent number 怒气系数
---@field noAttack boolean 不产生伤害



---@class Battle_Frame_Data_Event_SendFor @召唤物帧数据
---@field summonName string
---@field targetPos FixNum
---@field distance FixNum
---@field dirToTarget boolean
---@field summonType string
---@field id number
---@field aiType string
---@field hpType number
---@field is_sign boolean
---@field is_border boolean
---@field dieWithMaster boolean  false
---@field offset FixVector3



---@field anim string
---@field endAnim string


---@class Battle_Frame_Data @帧数据
---@field animLength number
---@field animName string
---@field events table<string, Battle_Frame_Data_Event[]>
---@field isLoop boolean

---@class Battle_Frame_Data_Shoot_Count
---@field isFixPoint boolean 是都射击固定点
---@field fixpoint string 固定点

---@class Battle_Frame_Data_Shoot : Battle_Frame_Data_Event
---@field useSelf boolean 使用自身
---@field count Battle_Frame_Data_Shoot_Count
---@field angerAirPercent number 怒气百分比
---@field notFaceToTarget boolean

---@class BattleSkillConfig


---@class Battle_BulletEffect_Data

---@class Battle_CreateBullet_Data
---@field data Battle_Frame_Data_Shoot
---@field attackerAnger number
---@field position FixVector3
---@field target PlayerModel
---@field skill BattleSkillConfig
---@field bulletType string
---@field bulletEffectData Battle_BulletEffect_Data
---@field player PlayerModel

---@class Battle_AttackData_InjureMove
---@field injureType string
---@field endType string
---@field type string
---@field distance number
---@field time number
---@field injureAnimName number
---@field moveType number

---@class Battle_AttackData
---@field damage number @攻击
---@field injureBuf number 
---@field player PlayerModel
---@field skillConfig SkillDataConfig
---@field type number
---@field damageType number
---@field isSingleTarget boolean @是否是单体伤害
---@field damageType number
---@field attackerAnger number
---@field angerAir number @怒气系数
---@field damageFront number
---@field damageLast number
---@field mustCrit boolean
---@field mustHit boolean
---@field hitEffectList Battle_Frame_Data_Event_Prefab[]
---@field hitAudio string
---@field power number
---@field noAttack boolean 不产生伤害
---@field damageExtra number
---@field injureMove Battle_AttackData_InjureMove
---@field ignoreGuard boolean 忽略护盾
---@field buffId string
---@field richBuff Battle_AttackData_RichBuff[]
---@field extraParam string[] 透传参数
---@field sourceBuff PlayerBuf_Model 来源buff
---@field ignoreAvoidDeath boolean 无视免死

---@class Battle_AttackData_RichBuff
---@field id number
---@field target string self | target
---@field rate number 概率0~100

---@class Battle_EventData_AfterAttack @ { killer = player, victim = self, damage = wantdata["damage"], attackData = attackData,isCrit = isCrit}
---@field killer PlayerModel
---@field victim PlayerModel
---@field damage number
---@field attackData Battle_AttackData
---@field isCrit boolean

---@class Battle_BeHitDirectData_WantData @期望值
---@field damage number @伤害
---@field suck_value number @
---@field hasInjureMove boolean


---@class Battle_BeHitDirectData
---@field killer PlayerModel
---@field victim PlayerModel
---@field attackData Battle_AttackData
---@field wantdata Battle_BeHitDirectData

---@class Battle_EventData_Dead
---@field killer PlayerModel
---@field attackData Battle_AttackData

---@class Battle_EventData_KillPlayer
---@field victim PlayerModel
---@field attackData Battle_AttackData

---@class Battle_EventData_Dispatch @{ eventName = dispatchEventName, frame = self }
---@field eventName string
---@field frame AnimEvtFrame_Model


---@class Battle_HandleData_CritCount @ { ply = killer,victim = victim, operator = "+", value = 1, type = "self", ignoreSkills = {"skill2", "skill3"},breakAnim = true})
---@field ply PlayerModel @killer
---@field victim PlayerModel
---@field operator string @"+"
---@field value number
---@field type string
---@field ignoreSkills string[]
---@field breakAnim boolean

---@class Battle_HandleData_Attack
---@field killer PlayerModel 攻击者
---@field victim PlayerModel 自己
---@field damage number
---@field attackData Battle_AttackData
---@field isCrit boolean

---@class Battle_HandleData_Cure
---@field source PlayerModel 来源
---@field player PlayerModel 自己
---@field cure number

---@class Battle_HandleData_CureOverFlow @过量治疗 {source = source, player = self, overflow = overflow, sourceSkill = sourceSkill }
---@field source PlayerModel 来源
---@field player PlayerModel 自己
---@field sourceSkill SkillDataConfig
---@field sourceBuff PlayerBuf_Model
---@field overflow number


---@class Battle_HandleData_SelectTarget
---@field killer PlayerModel
---@field targets Battle_List
---@field evtFrame AnimEvtFrame_Model
---@field skill SkillDataConfig

---@class Battle_HandleData_KillPlayer
---@field killer PlayerModel 攻击者
---@field victim PlayerModel 自己

---@class Battle_HandleData_AddLine
---@field line Line_Model 攻击者

---@class Battle_HandleData_ChangeAiState
---@field player PlayerModel @角色
---@field curState AIState @自己
---@field targetState AIState @自己

---@class Battle_AddBuff_Data_BuffParam

---@class Battle_AddBuff_Data
---@field buffType string @ConfigBuff.type
---@field buffDes string @ConfigBuff.desc
---@field workRound number @ConfigBuff.work_round
---@field lastTime number @ConfigBuff.last_time
---@field workTime number @ConfigBuff.work_time
---@field max_times number @ConfigBuff.max_times
---@field delayTime number @ConfigBuff.delay_time
---@field buff_icon string @ConfigBuff.buff_icon
---@field is_bufficon_count number @ConfigBuff.is_bufficon_count
---@field group_id number @ConfigBuff.group_id
---@field level number @ConfigBuff.level
---@field effect_id string @ConfigBuff.effect_id
---@field buffTags table @ConfigBuff.tag  buff标签
---@field extra_buff table @ConfigBuff.extra_buff
---@field audio table @ConfigBuff.audio
---@field buffParam table Battle_AddBuff_Data
---@field buff_id number 


---@class Battle_CreateBuf_Data
---@field id number
---@field sourceSkill ConfigSkillDetail
---@field mgr BufManager_Model
---@field player PlayerModel @self
---@field source PlayerModel
---@field skillModel number @加入buf时当前的技能类型时必杀


---@class BattleTargetSelectData @目标选择桉树
---@field useSelf boolean @自己的Player
---@field priority boolean @是否优先选择
---@field ignoreSummon boolean @是否忽略低级召唤物
---@field targetNoRepeat boolean @是否能和上一次重复选择
---@field isFixPoint boolean @射击固定点
---@field selectLast boolean @使用上次目标
---@field forceSelect boolean @检测强制选择
---@field campRace string @"not"
---@field profession ETargetSelectProfession @类型(力量敏捷内功) "all"
---@field fixpoint string @"enemyBackCenter"
---@field pos ETargetSelectPosType @位置类型功能
---@field count ETargetSelectCount @ 人数
---@field camp ETargetSelectCamp @阵营
---@field posIndex string @索引位置："backrow"
---@field campRace ETargetSelectCount @
---@field gender string @性别 { man = 1,woman = 2 }
---@field area string @"all"
---@field areaWidth number @目标范围
---@field areaHeight number @目标范围
---@field areaAngle number @目标范围
---@field areaRadius number @目标范围
---@field roleType number @role_type 1 护卫 2战士 3刺客 4 射手 5辅助 6术士

---@class Battle_HandleData_AddBuff
---@field buff PlayerBuf_Model

---@class Battle_HandleData_ShootBullet
---@field bullet Bullet_Model | BulletTrack_Model | BulletLine_Mode

---@class Battle_HandleData_RemoveBuff
---@field buff PlayerBuf_Model

---@class Battle_HandleData_Injure @{ killer = player, victim = self, wantdata = wantdata, attackData = attackData}
---@field killer PlayerModel
---@field victim PlayerModel
---@field wantdata Battle_BeHitDirectData_WantData
---@field attackData Battle_AttackData

---@class Battle_HandleData_SkillAttackOver @{ killer = player, victim = self, wantdata = wantdata, attackData = attackData}
---@field killer PlayerModel
---@field victim PlayerModel
---@field wantdata Battle_BeHitDirectData_WantData
---@field attackData Battle_AttackData


---@class Battle_HandleData_PlayerAttackMove
---@field move MoveGeneral


---@class Battle_HandleData_SelfHp @{ ply = self.player, operator = "=", value = hpData.hpRate, type = "self", reset = false, breakAnim = false}
---@field ply PlayerModel


---@class Battle_HandleData_CalculateDamage @计算总的血量丢失
---@field player PlayerModel
---@field totalLostHp number


---@class Battle_HandleData_NoDeath @不死buff
---@field ply PlayerModel

---@class Battle_HandleData_PlayerDead @不死buff
---@field data PlayerModel

---@class Battle_HandleData_Relive @{ player = player}
---@field player PlayerModel

---@class Battle_HandleData_MaxHpChanged @{ player = player}
---@field player PlayerModel

---@class Battle_HandleData_LeaveField @{ player = player}
---@field player PlayerModel

---@class Battle_HandleData_SendForFinish @{ player = self.player }
---@field player PlayerModel

---@class Battle_HandleData_SkillEnd @{ player = self.player, skillConfig = self.player.curSkillConfig, aiState = self.curState, param = data}
---@field player PlayerModel
---@field skillConfig SkillDataConfig
---@field aiState AIState
---@field param table

---@class Battle_HandleData_SkillEnter @{ player = self.player, skillConfig = self.skillConfig, aiState = self.curState, param = data}
---@field player PlayerModel
---@field skillConfig SkillDataConfig
---@field aiState AIState
---@field param table

---@class Battle_HandleData_VictimBeforeAttack @{killer = self.killer, victim = self, attackData = attackData}
---@field killer PlayerModel 来源
---@field victim PlayerModel 自己
---@field attackData Battle_AttackData 


---@class BattleView_BuffIcon @{name = iconName, count = 1, showNum = showNum or false}
---@field name string
---@field count number
---@field showNum boolean


---@class BattlePlayerView_PetContestEffect
---@field autodestoryTime number @输入文件名 不可缺省, 销毁时间
---@field prefab string @输入文件目录 不可缺省, 特效预制体
---@field autoMirror boolean @输入文件目录 不可缺省， 是否自动镜像



---@class EBattleSummonType @召唤物类型
local EBattleSummonType = {
    special = "special",
}

---@class EBattleSummonAiType @召唤物类型
local EBattleSummonType = {
    human = "human", -- 类人
}

