return{
["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["battle_idle"] = 
{
     ["animName"] = "battle_idle",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 6518,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1364,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 583,
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
                  ["prefabName"] = "B_XuanW_Attack_Hit_001",
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

["attack2"] = 
{
     ["animName"] = "attack2",
     ["animLength"] = 1774,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 870,
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
                      ["areaWidth"] = 4096,
                      ["areaHeight"] = 2048,
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
                  ["prefabName"] = "B_XuanW_Attack_Hit_001",
                  ["hitAudio"] = "attack2_hit",
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
     ["animLength"] = 2217,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit"] = 
{
     ["animName"] = "hit",
     ["animLength"] = 955,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill0"] = 
{
     ["animName"] = "skill0",
     ["animLength"] = 1705,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill0_end"] = 
{
     ["animName"] = "skill0_end",
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill0_loop"] = 
{
     ["animName"] = "skill0_loop",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 8532,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2048,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "self",
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
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "90013101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 6313,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 2867,
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
                      ["area"] = "all",
                      ["areaWidth"] = 3072,
                      ["areaHeight"] = 30720,
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
                  ["prefabName"] = "B_XuanW_Skill4_Hit_001",
                  ["hitAudio"] = "nil",
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

              [2] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 3686,
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
                      ["area"] = "all",
                      ["areaWidth"] = 3072,
                      ["areaHeight"] = 30720,
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
                  ["prefabName"] = "B_XuanW_Skill4_Hit_001",
                  ["hitAudio"] = "nil",
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

              [3] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 4505,
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
                      ["area"] = "all",
                      ["areaWidth"] = 3072,
                      ["areaHeight"] = 30720,
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
                  ["prefabName"] = "B_XuanW_Skill4_Hit_001",
                  ["hitAudio"] = "nil",
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
                  ["buffId"] = "90011101",
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

["skill1_loop"] = 
{
     ["animName"] = "skill1_loop",
     ["animLength"] = 1024,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1_end"] = 
{
     ["animName"] = "skill1_end",
     ["animLength"] = 2252,
     ["isLoop"] = false,
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2027,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "self",
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
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "90012101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
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