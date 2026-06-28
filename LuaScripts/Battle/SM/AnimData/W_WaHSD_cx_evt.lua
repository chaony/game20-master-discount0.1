return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1193,
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
     ["animLength"] = 1569,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 102,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 545,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1loop"] = 
{
     ["animName"] = "hit1_1loop",
     ["animLength"] = 340,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 1193,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 886,
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
     ["animLength"] = 3412,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1057,
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

["skill0_1"] = 
{
     ["animName"] = "skill0_1",
     ["animLength"] = 1569,
     ["isLoop"] = false,
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
                  ["moveType"] = "MoveBlink",
                  ["isSelectTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = true,
                  ["faceToTarget"] = true,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 1228,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 0,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 819,
                  ["eventId"] = 2048,
                  ["dispatchEventName"] = "skill0_move_back",
              },

          },
     },
},

["skill0_2"] = 
{
     ["animName"] = "skill0_2",
     ["animLength"] = 1569,
     ["isLoop"] = false,
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
                  ["moveType"] = "MoveBlink",
                  ["isSelectTarget"] = true,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
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
                  ["moveOrder"] = "order",
                  ["isTargetPoint"] = false,
                  ["selectDis"] = "number",
                  ["targetPos"] = "front",
                  ["useSceneDir"] = true,
                  ["faceToTarget"] = true,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 1228,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "nil",
                  ["speed"] = 0,
                  ["endAnimName"] = "nil",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 1126,
                  ["eventId"] = 2048,
                  ["dispatchEventName"] = "skill0_move_back",
              },

          },
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2729,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 1910,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 3072,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_2"] = 
{
     ["animName"] = "skill3_2",
     ["animLength"] = 3072,
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
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "Hook",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1024,
                  ["origin"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["originParent"] = "Xiong",
                  ["destination"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["destinationParent"] = "Xiong",
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "forceMax",
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
                  ["prefab"] = "W_WaHSD_Skill2_Line_001",
                  ["hitEffect"] = "nil",
                  ["damageStart"] = 0,
                  ["damage"] = 0,
                  ["damageInterval"] = 0,
                  ["imprison"] = false,
                  ["fireTime"] = 0,
                  ["selfWaitTime"] = 1022976,
                  ["enemyWaitTime"] = 1022976,
                  ["selfBasePos"] = 0,
                  ["enemyBasePos"] = 0,
                  ["finishWaitTime"] = 1022976,
                  ["selfMoveTimer"] = 0,
                  ["enemyMoveTimer"] = 0,
                  ["selfDistance"] = 0,
                  ["enemyDistance"] = 0,
                  ["selfCurve"] = "nil",
                  ["enemyCurve"] = "nil",
                  ["bufid"] = "nil",
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Hook",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2048,
                  ["origin"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["originParent"] = "Xiong",
                  ["destination"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["destinationParent"] = "Xiong",
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "friendExceptSelf",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "forceMax",
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
                  ["prefab"] = "W_WaHSD_Skill2Plus_Line_001",
                  ["hitEffect"] = "nil",
                  ["damageStart"] = 0,
                  ["damage"] = 0,
                  ["damageInterval"] = 0,
                  ["imprison"] = false,
                  ["fireTime"] = 0,
                  ["selfWaitTime"] = 1022976,
                  ["enemyWaitTime"] = 1022976,
                  ["selfBasePos"] = 0,
                  ["enemyBasePos"] = 0,
                  ["finishWaitTime"] = 1022976,
                  ["selfMoveTimer"] = 0,
                  ["enemyMoveTimer"] = 0,
                  ["selfDistance"] = 0,
                  ["enemyDistance"] = 0,
                  ["selfCurve"] = "nil",
                  ["enemyCurve"] = "nil",
                  ["bufid"] = "nil",
              },

          },
     },
},

}