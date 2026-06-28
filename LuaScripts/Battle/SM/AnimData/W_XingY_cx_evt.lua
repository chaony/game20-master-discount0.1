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
     ["animLength"] = 1433,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 2184,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 307,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 374,
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

["hit1_2"] = 
{
     ["animName"] = "hit1_2",
     ["animLength"] = 340,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_2end"] = 
{
     ["animName"] = "hit1_2end",
     ["animLength"] = 340,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_2loop"] = 
{
     ["animName"] = "hit1_2loop",
     ["animLength"] = 340,
     ["isLoop"] = true,
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

["hit2_2"] = 
{
     ["animName"] = "hit2_2",
     ["animLength"] = 819,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_fly"] = 
{
     ["animName"] = "hit2_fly",
     ["animLength"] = 409,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 579,
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
     ["animLength"] = 716,
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

              [3] = 
              {
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 51,
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

["skill0"] = 
{
     ["animName"] = "skill0",
     ["animLength"] = 1024,
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
                  ["activeNode"] = "W_XingY_Skill0_Buff_001",
                  ["hpBarActive"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 1024,
                  ["active"] = true,
                  ["activeNode"] = "W_XingY_Skill0_Buff_001",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 1024,
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
                  ["activeNode"] = "W_XingY_Skill1_Buff_001",
                  ["hpBarActive"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 1024,
                  ["active"] = true,
                  ["activeNode"] = "W_XingY_Skill1_Buff_001",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 1024,
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
                  ["activeNode"] = "W_XingY_Skill2_Buff_001",
                  ["hpBarActive"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 1024,
                  ["active"] = true,
                  ["activeNode"] = "W_XingY_Skill2_Buff_001",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1808,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 921,
                  ["active"] = false,
                  ["activeNode"] = "W_XingY_Skill3_Buff_001",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill3_attack1"] = 
{
     ["animName"] = "skill3_attack1",
     ["animLength"] = 1024,
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