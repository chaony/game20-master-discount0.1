return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1160,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["prefab"] = "M_LongT2_Attack_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "effectpoint0",
                  ["isPutUpInParent"] = true,
                  ["effectType"] = "nearFight",
                  ["directionType"] = "parent",
                  ["scaleType"] = "parent",
                  ["positionType"] = "parentOffset",
                  ["prefabTrans"] = 
                  {
                      ["useUserSet"] = false,
                      ["position"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = 1,
                          [2] = 1,
                          [3] = 1,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 1,
              },

              [3] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 620,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "attack1_hit",
                  ["prefab"] = "M_LongT2_Attack_Fly_001",
                  ["speed"] = 26,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 1.5,
                      ["z"] = 0
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "body",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "M_LongT2_Attack_hit_001",
                          ["parent"] = "Xiong",
                          ["position"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0,
                              ["z"] = 0
                          },
                          ["eulerAngle"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0,
                              ["z"] = 0
                          },
                          ["scale"] = 
                          {
                              ["x"] = 1,
                              ["y"] = 1,
                              ["z"] = 1
                          },
                          ["autoDestroy"] = 3,
                      },

                  },
                  ["EditorBuffName"] = "nil",
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
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "ShortVo_BiaoNan01_Dead",
                  ["bankName"] = "ShortVo_BiaoNan01",
              },

          },
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 136,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "Vox_Hit",
                  ["bankName"] = "",
              },

          },
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
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["prefab"] = "M_LongT2_Skill3_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "effectpoint0",
                  ["isPutUpInParent"] = true,
                  ["effectType"] = "nearFight",
                  ["directionType"] = "parent",
                  ["scaleType"] = "parent",
                  ["positionType"] = "parentOffset",
                  ["prefabTrans"] = 
                  {
                      ["useUserSet"] = false,
                      ["position"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = 1,
                          [2] = 1,
                          [3] = 1,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [3] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 1873,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "skill3_hit",
                  ["prefab"] = "M_LongT2_Skill3_Fly_001",
                  ["speed"] = 26,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1,
                      ["z"] = 0
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "body",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "M_LongT2_Skill3_hit_001",
                          ["parent"] = "Xiong",
                          ["position"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0,
                              ["z"] = 0
                          },
                          ["eulerAngle"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0,
                              ["z"] = 0
                          },
                          ["scale"] = 
                          {
                              ["x"] = 1,
                              ["y"] = 1,
                              ["z"] = 1
                          },
                          ["autoDestroy"] = 3,
                      },

                  },
                  ["EditorBuffName"] = "nil",
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