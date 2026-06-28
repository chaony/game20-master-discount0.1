return{
["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 512,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["active"] = true,
                  ["activeNode"] = "body",
                  ["hpBarActive"] = true,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 1536,
                  ["active"] = false,
                  ["activeNode"] = "body",
                  ["hpBarActive"] = true,
              },

          },
     },
},

["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 1024,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill"] = 
{
     ["animName"] = "skill",
     ["animLength"] = 256,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 0,
                  ["dispatchEventName"] = "ball_move",
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["active"] = true,
                  ["activeNode"] = "W_TaiJ_Skill3_Buff_001",
                  ["hpBarActive"] = true,
              },

              [3] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 256,
                  ["active"] = false,
                  ["activeNode"] = "W_TaiJ_Skill3_Buff_001",
                  ["hpBarActive"] = true,
              },

          },
     },
},

["skill_end"] = 
{
     ["animName"] = "skill_end",
     ["animLength"] = 256,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 0,
                  ["moveType"] = "MoveGeneral",
                  ["isSelectTarget"] = false,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "master",
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = false,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 0,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = true,
                      ["curveMoveType"] = "line",
                      ["curveMoveDistance"] = 0,
                      ["curveMoveTime"] = 512,
                      ["curveDistanceType"] = "targetDistance"
                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 0,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["active"] = true,
                  ["activeNode"] = "W_TaiJ_Skill3_Buff_001",
                  ["hpBarActive"] = true,
              },

              [3] = 
              {
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 0,
                  ["dispatchEventName"] = "return_move",
              },

              [4] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 256,
                  ["active"] = false,
                  ["activeNode"] = "W_TaiJ_Skill3_Buff_001",
                  ["hpBarActive"] = true,
              },

          },
     },
},

["spawn"] = 
{
     ["animName"] = "spawn",
     ["animLength"] = 512,
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