return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 3003,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 614,
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

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 681,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 1740,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 409,
                  ["active"] = true,
                  ["activeNode"] = "JinYi_Weapon",
                  ["hpBarActive"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "Hook",
                  ["triggerTime"] = 409,
                  ["origin"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1024,
                      ["z"] = 0
                  },
                  ["originParent"] = "None",
                  ["destination"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1024,
                      ["z"] = 0
                  },
                  ["destinationParent"] = "None",
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
                  ["prefab"] = "W_JinY_Skill1_Fly_001",
                  ["hitEffect"] = "",
                  ["damageStart"] = 0,
                  ["damage"] = 0,
                  ["damageInterval"] = 0,
                  ["imprison"] = false,
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
                  ["selfCurve"] = "line",
                  ["enemyCurve"] = "JinYi10991_skill2",
                  ["bufid"] = "109913101",
              },

              [3] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 819,
                  ["active"] = false,
                  ["activeNode"] = "JinYi_Weapon",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 1536,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["idlewind"] = 
{
     ["animName"] = "idlewind",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["sprint"] = 
{
     ["animName"] = "sprint",
     ["animLength"] = 477,
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
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 1126,
                  ["moveType"] = "MoveBlink",
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
                  ["distance"] = 2048,
                  ["needBack"] = false,
                  ["dirToBoss"] = false,
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["ignoreArea"] = false,
                  ["effect"] = "",
                  ["speed"] = 0,
                  ["endAnimName"] = "",
                  ["bufid"] = 0,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 1126,
                  ["active"] = true,
                  ["activeNode"] = "body",
                  ["hpBarActive"] = true,
              },

              [3] = 
              {
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 2252,
                  ["anim"] = "skill3_1",
                  ["isLoop"] = false,
                  ["endAnim"] = "skill3_1",
              },

          },
     },
},

["skill3_1"] = 
{
     ["animName"] = "skill3_1",
     ["animLength"] = 1501,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["active"] = false,
                  ["activeNode"] = "body",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 3344,
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
                  ["eventName"] = "AttackMove",
                  ["triggerTime"] = 0,
                  ["moveType"] = "MoveBlink",
                  ["isSelectTarget"] = false,
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

          },
     },
},

["debuff1"] = 
{
     ["animName"] = "debuff1",
     ["animLength"] = 2048,
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