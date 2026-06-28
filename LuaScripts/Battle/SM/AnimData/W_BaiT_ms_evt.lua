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
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["prefab"] = "W_BaiT_Attack1_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
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

              [2] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 102,
                  ["soundName"] = "ShortVo_BiaoNv03_Attack_L1_1",
                  ["bankName"] = "ShortVo_BiaoNv03",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 102,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [4] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 256,
                  ["effectId"] = 0,
                  ["hitAudio"] = "attack1_hit",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_BaiT_Attack_Hit_001",
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

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2388,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["prefab"] = "W_BaiT_Skill1_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
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

              [2] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 716,
                  ["soundName"] = "ShortVo_BiaoNv03_Attack_L1_1",
                  ["bankName"] = "ShortVo_BiaoNv03",
              },

              [4] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 757,
                  ["effectId"] = 0,
                  ["hitAudio"] = "attack1_hit",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_BaiT_Skill1_Hit_001",
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
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2491,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1024,
                  ["soundName"] = "skill2_Burst",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1024,
                  ["soundName"] = "ShortVo_BiaoNv03_Attack_H1_1",
                  ["bankName"] = "ShortVo_BiaoNv03",
              },

              [4] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1126,
                  ["prefab"] = "W_BaiT_Skill2_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
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
                  ["autodestoryTime"] = 6,
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 3072,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["prefab"] = "W_BaiT_Skill3_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
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
                  ["autodestoryTime"] = 5,
              },

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["prefab"] = "Skill_ShiJing_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
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
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 2,
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 102,
                  ["soundName"] = "ShortVo_BiaoNv03_Attack_L1_2",
                  ["bankName"] = "ShortVo_BiaoNv03",
              },

              [5] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1433,
                  ["soundName"] = "skill3_hit",
                  ["bankName"] = "",
              },

              [6] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1638,
                  ["soundName"] = "skill3_Burst",
                  ["bankName"] = "",
              },

          },
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
     ["animLength"] = 1536,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["soundName"] = "ShortVo_BiaoNv03_Dead_2",
                  ["bankName"] = "ShortVo_BiaoNv03",
              },

          },
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

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 886,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 819,
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

["jumpin1"] = 
{
     ["animName"] = "jumpin1",
     ["animLength"] = 4608,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 921,
                  ["soundName"] = "",
                  ["bankName"] = "",
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

["hit3"] = 
{
     ["animName"] = "hit3",
     ["animLength"] = 921,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1228,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
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