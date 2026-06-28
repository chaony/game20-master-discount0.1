return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1160,
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
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 136,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 136,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1loop"] = 
{
     ["animName"] = "hit1_1loop",
     ["animLength"] = 272,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit1_2"] = 
{
     ["animName"] = "hit1_2",
     ["animLength"] = 204,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_2end"] = 
{
     ["animName"] = "hit1_2end",
     ["animLength"] = 204,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_2loop"] = 
{
     ["animName"] = "hit1_2loop",
     ["animLength"] = 272,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 512,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_2"] = 
{
     ["animName"] = "hit2_2",
     ["animLength"] = 852,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_fly"] = 
{
     ["animName"] = "hit2_fly",
     ["animLength"] = 681,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 614,
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
     ["animLength"] = 1364,
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
     ["animLength"] = 750,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["moveType"] = "MoveGeneral",
                  ["isSelectTarget"] = false,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "self",
                      ["posIndex"] = "all",
                      ["roleType"] = 0,
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "fixPoint",
                  ["targetPos"] = "spawnPoint",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = true,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = true,
                  ["distance"] = 0,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = true,
                      ["curveMoveType"] = "line",
                      ["curveMoveDistance"] = 0,
                      ["curveMoveTime"] = 1842,
                      ["curveDistanceType"] = "forceDistance"
                  },
                  ["ignoreArea"] = true,
                  ["effect"] = "",
                  ["speed"] = 0,
                  ["endAnimName"] = "",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["moveType"] = "MoveBlink",
                  ["isSelectTarget"] = false,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "self",
                      ["posIndex"] = "all",
                      ["roleType"] = 0,
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "spawnPoint",
                  ["targetPos"] = "back",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = false,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 10240,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["ignoreArea"] = true,
                  ["effect"] = "",
                  ["speed"] = 0,
                  ["endAnimName"] = "",
                  ["bufid"] = 0,
              },

              [3] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 368,
                  ["eventId"] = 0,
                  ["anim"] = "run",
                  ["isLoop"] = false,
                  ["endAnim"] = "nil",
              },

          },
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

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 2729,
     ["isLoop"] = false,
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