return{
["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 1091,
     ["isLoop"] = true,
     ["events"] = 
     {
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

["battle_idle"] = 
{
     ["animName"] = "battle_idle",
     ["animLength"] = 1091,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 545,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill0"] = 
{
     ["animName"] = "skill0",
     ["animLength"] = 1467,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2217,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill2_1"] = 
{
     ["animName"] = "skill2_1",
     ["animLength"] = 2286,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Sendfor",
                  ["triggerTime"] = 1536,
                  ["summonName"] = 1083,
                  ["aiType"] = "command",
                  ["hpType"] = "percentValue",
                  ["fixValue"] = 102400,
                  ["percentValue"] = 307,
                  ["targetPos"] = "back",
                  ["distance"] = 1536,
                  ["dirToTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "friend",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = true,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "hpRateLeast",
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
                  ["summonType"] = "primary",
                  ["follow"] = false,
                  ["alwaysfollow"] = false,
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["id"] = 2048,
                  ["delayTime"] = 0,
                  ["is_sign"] = true,
                  ["is_border"] = true,
                  ["dieWithMaster"] = true,
              },

          },
     },
},

["skill3_1"] = 
{
     ["animName"] = "skill3_1",
     ["animLength"] = 5734,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1638,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081102",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2150,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081102",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2662,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081102",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081102",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1638,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081202",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2150,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081202",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2662,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081202",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081202",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1638,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2150,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2662,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081303",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1638,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2150,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2662,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081302,1081304",
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

["skill3_2"] = 
{
     ["animName"] = "skill3_2",
     ["animLength"] = 5734,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1536,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2150,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2662,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081101",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081101",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1433,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081201",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2048,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081201",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2560,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081201",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081201",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1433,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2048,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2560,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081303",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081303",
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
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 1433,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [2] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2048,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [3] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 2560,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081304",
                  ["EditorBuffName"] = "nil",
                  ["useMaster"] = false,
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
              },

              [4] = 
              {
                  ["eventName"] = "AddBuf",
                  ["triggerTime"] = 3379,
                  ["count"] = 
                  {
                      ["count"] = "three",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = true,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 368640,
                      ["areaRadius"] = 5120,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["angerAirPercent"] = 0,
                  ["buffId"] = "1081301,1081304",
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

["skill2_2"] = 
{
     ["animName"] = "skill2_2",
     ["animLength"] = 2286,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Sendfor",
                  ["triggerTime"] = 1536,
                  ["summonName"] = 1082,
                  ["aiType"] = "command",
                  ["hpType"] = "percentValue",
                  ["fixValue"] = 102400,
                  ["percentValue"] = 307,
                  ["targetPos"] = "back",
                  ["distance"] = 1536,
                  ["dirToTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "friend",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "bloodLeast",
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
                  ["summonType"] = "primary",
                  ["follow"] = false,
                  ["alwaysfollow"] = false,
                  ["offset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["id"] = 2048,
                  ["delayTime"] = 0,
                  ["is_sign"] = true,
                  ["is_border"] = true,
                  ["dieWithMaster"] = true,
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