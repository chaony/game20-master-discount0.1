return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1228,
     ["isLoop"] = false,
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

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 4777,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 477,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 512,
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

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 681,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 477,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_spin"] = 
{
     ["animName"] = "hit2_spin",
     ["animLength"] = 272,
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
     ["animLength"] = 3753,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 3072,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 614,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 1876,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1160,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 1126,
                  ["eventId"] = 1024,
                  ["moveType"] = "MoveLockEnemy",
                  ["isSelectTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["roleType"] = 0,
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "distanceFarthest",
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = false,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = true,
                  ["isDirZero"] = false,
                  ["distance"] = 1024,
                  ["needBack"] = true,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = true,
                      ["curveMoveType"] = "line",
                      ["curveMoveDistance"] = 101376,
                      ["curveMoveTime"] = 101376,
                      ["curveDistanceType"] = "forceDistance"
                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 3584,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 1160,
                  ["eventId"] = 2048,
                  ["dispatchEventName"] = "startSkill3",
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 1160,
                  ["eventId"] = 3072,
                  ["anim"] = "skill3_loop",
                  ["isLoop"] = false,
                  ["endAnim"] = "skill3_loop",
              },

          },
     },
},

["skill3_end"] = 
{
     ["animName"] = "skill3_end",
     ["animLength"] = 1876,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_loop"] = 
{
     ["animName"] = "skill3_loop",
     ["animLength"] = 1228,
     ["isLoop"] = true,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1024,
                  ["moveType"] = "MoveLockEnemy",
                  ["isSelectTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["roleType"] = 0,
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "distanceFarthest",
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = false,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = true,
                  ["isDirZero"] = false,
                  ["distance"] = 1024,
                  ["needBack"] = true,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = true,
                      ["curveMoveType"] = "line",
                      ["curveMoveDistance"] = 101376,
                      ["curveMoveTime"] = 101376,
                      ["curveDistanceType"] = "forceDistance"
                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 3584,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

          },
     },
},

["skill3_plus"] = 
{
     ["animName"] = "skill3_plus",
     ["animLength"] = 1876,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 1876,
                  ["eventId"] = 1024,
                  ["anim"] = "skill3_plus_loop",
                  ["isLoop"] = false,
                  ["endAnim"] = "skill3_plus_loop",
              },

          },
     },
},

["skill3_plus_end"] = 
{
     ["animName"] = "skill3_plus_end",
     ["animLength"] = 1467,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_plus_loop"] = 
{
     ["animName"] = "skill3_plus_loop",
     ["animLength"] = 2525,
     ["isLoop"] = true,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 2525,
                  ["eventId"] = 1024,
                  ["anim"] = "skill3_plus_end",
                  ["isLoop"] = false,
                  ["endAnim"] = "skill3_plus_end",
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