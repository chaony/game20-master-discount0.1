return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 365,
                  ["eventId"] = 0,
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
                  ["prefabName"] = "nil",
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

          },
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

["debuff1"] = 
{
     ["animName"] = "debuff1",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 2013,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1loop"] = 
{
     ["animName"] = "hit1loop",
     ["animLength"] = 340,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 238,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 443,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 545,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 545,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_spin"] = 
{
     ["animName"] = "hit2_spin",
     ["animLength"] = 340,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit3"] = 
{
     ["animName"] = "hit3",
     ["animLength"] = 1331,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 3651,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1331,
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
     ["animLength"] = 2320,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "RangeShow",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["showTime"] = 1024,
                  ["rangeType"] = "sector",
                  ["areaWidth"] = 0,
                  ["areaHeight"] = 0,
                  ["areaAngle"] = 368640,
                  ["areaRadius"] = 4096,
                  ["center"] = "player",
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
              },

              [2] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 1024,
                  ["buffId"] = "2012101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
          ["level2"] = 
          {
              [1] = 
              {
                  ["eventName"] = "RangeShow",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["showTime"] = 1024,
                  ["rangeType"] = "sector",
                  ["areaWidth"] = 0,
                  ["areaHeight"] = 0,
                  ["areaAngle"] = 368640,
                  ["areaRadius"] = 4096,
                  ["center"] = "player",
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
              },

              [2] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 1024,
                  ["buffId"] = "2012201",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
          ["level3"] = 
          {
              [1] = 
              {
                  ["eventName"] = "RangeShow",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["showTime"] = 1024,
                  ["rangeType"] = "sector",
                  ["areaWidth"] = 0,
                  ["areaHeight"] = 0,
                  ["areaAngle"] = 368640,
                  ["areaRadius"] = 4096,
                  ["center"] = "player",
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
              },

              [2] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 1024,
                  ["buffId"] = "2012201,2012302",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
          ["level4"] = 
          {
              [1] = 
              {
                  ["eventName"] = "RangeShow",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["showTime"] = 1024,
                  ["rangeType"] = "sector",
                  ["areaWidth"] = 0,
                  ["areaHeight"] = 0,
                  ["areaAngle"] = 368640,
                  ["areaRadius"] = 4096,
                  ["center"] = "player",
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
              },

              [2] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 4096,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 1024,
                  ["buffId"] = "2012201,2012302,2012401",
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
     ["animLength"] = 1364,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "BlackScreen",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["blackTime"] = 1228,
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1361,
                  ["eventId"] = 0,
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
                  ["buffId"] = "2011101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
          ["level2"] = 
          {
              [1] = 
              {
                  ["eventName"] = "BlackScreen",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["blackTime"] = 1228,
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1361,
                  ["eventId"] = 0,
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
                  ["buffId"] = "2011101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

          },
          ["level3"] = 
          {
              [1] = 
              {
                  ["eventName"] = "BlackScreen",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["blackTime"] = 1228,
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1361,
                  ["eventId"] = 0,
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
                  ["buffId"] = "2011101",
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

["skill3_end"] = 
{
     ["animName"] = "skill3_end",
     ["animLength"] = 1126,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_loop"] = 
{
     ["animName"] = "skill3_loop",
     ["animLength"] = 1024,
     ["isLoop"] = true,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 102,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 3072,
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
                  ["hitAudio"] = "nil",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 1024,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 0,
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
          ["level2"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 102,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 3072,
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
                  ["hitAudio"] = "nil",
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
          ["level3"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 102,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 3072,
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
                  ["hitAudio"] = "nil",
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
          ["level4"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 102,
                  ["eventId"] = 0,
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
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 3072,
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
                  ["hitAudio"] = "nil",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 1331,
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