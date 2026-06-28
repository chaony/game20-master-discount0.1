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

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 2969,
     ["isLoop"] = false,
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

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 1364,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 307,
                  ["moveType"] = "MoveGeneral",
                  ["isSelectTarget"] = false,
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
                      ["fixpoint"] = "Densearea"
                  },
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = false,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 2048,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = true,
                      ["curveMoveType"] = "line",
                      ["curveMoveDistance"] = 2048,
                      ["curveMoveTime"] = 480,
                      ["curveDistanceType"] = "forceDistance"
                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 0,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 1331,
                  ["dispatchEventName"] = "skill2_active",
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