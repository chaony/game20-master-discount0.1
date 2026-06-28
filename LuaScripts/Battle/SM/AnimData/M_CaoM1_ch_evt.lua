return{
["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 1705,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1536,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 808,
                  ["effectId"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "myenemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "all",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "M_CaoM1_Attack_Hit_001",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 1024,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

          },
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 2150,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 681,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_fly"] = 
{
     ["animName"] = "hit2_fly",
     ["animLength"] = 409,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyloop"] = 
{
     ["animName"] = "hit2_flyloop",
     ["animLength"] = 33,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit3"] = 
{
     ["animName"] = "hit3",
     ["animLength"] = 681,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 750,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 4096,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 808,
                  ["effectId"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 4096,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "nil",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 1228,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "2912101",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 2388,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 3584,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 819,
                  ["effectId"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 3584,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "nil",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 614,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

              [3] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 921,
                  ["effectId"] = 1,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 3584,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "nil",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 614,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

              [4] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 1054,
                  ["effectId"] = 2,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 3584,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "nil",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 614,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

              [5] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 1402,
                  ["effectId"] = 3,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "rectangle",
                      ["areaWidth"] = 1024,
                      ["areaHeight"] = 3584,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "nil",
                  ["hitAudio"] = "attack1_hit",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 614,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

          },
     },
},

["debuff1"] = 
{
     ["animName"] = "debuff1",
     ["animLength"] = 1364,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["battle_idle"] = 
{
     ["animName"] = "battle_idle",
     ["animLength"] = 1705,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 204,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 477,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1loop"] = 
{
     ["animName"] = "hit1_1loop",
     ["animLength"] = 33,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 750,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["common"] = 
{
     ["animName"] = "common",
     ["animLength"] = 0,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

}