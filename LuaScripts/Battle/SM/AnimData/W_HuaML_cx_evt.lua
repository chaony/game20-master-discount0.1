return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1398,
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
     ["animLength"] = 1364,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 3241,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 340,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_end"] = 
{
     ["animName"] = "hit1_end",
     ["animLength"] = 340,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_loop"] = 
{
     ["animName"] = "hit1_loop",
     ["animLength"] = 340,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 784,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 681,
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
     ["animLength"] = 1638,
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
     ["animLength"] = 1808,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 819,
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
     },
},

["skill1_1"] = 
{
     ["animName"] = "skill1_1",
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2627,
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
                      ["y"] = 1024,
                      ["z"] = 0
                  },
                  ["originParent"] = "Xiong",
                  ["destination"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1024,
                      ["z"] = 0
                  },
                  ["destinationParent"] = "Xiong",
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
                  ["prefab"] = "W_HuaML_Skill2_Line_001",
                  ["hitEffect"] = "nil",
                  ["damageStart"] = 0,
                  ["damage"] = 0,
                  ["damageInterval"] = 0,
                  ["imprison"] = false,
                  ["forceHookMove"] = true,
                  ["fireTime"] = 153,
                  ["selfWaitTime"] = 0,
                  ["enemyWaitTime"] = 102,
                  ["selfBasePos"] = 0,
                  ["enemyBasePos"] = 0,
                  ["finishWaitTime"] = 102,
                  ["selfMoveTimer"] = 0,
                  ["enemyMoveTimer"] = 102,
                  ["selfDistance"] = 0,
                  ["enemyDistance"] = 1843,
                  ["selfCurve"] = "nil",
                  ["enemyCurve"] = "nil",
                  ["bufid"] = "nil",
              },

          },
     },
},

["skill2_plus"] = 
{
     ["animName"] = "skill2_plus",
     ["animLength"] = 3412,
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
                  ["isSelectTarget"] = false,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "enemy",
                      ["posIndex"] = "oppositeTarget",
                      ["roleType"] = 0,
                      ["priority"] = true,
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
                  ["targetPos"] = "back",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = true,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 1024,
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

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 2627,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_plus"] = 
{
     ["animName"] = "skill3_plus",
     ["animLength"] = 4232,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 1536,
                  ["eventId"] = 1024,
                  ["moveType"] = "MoveBlink",
                  ["isSelectTarget"] = false,
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
                  ["targetPos"] = "back",
                  ["useSceneDir"] = false,
                  ["faceToTarget"] = true,
                  ["isBackMove"] = false,
                  ["isAnewEnemy"] = false,
                  ["isDirZero"] = false,
                  ["distance"] = 1024,
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