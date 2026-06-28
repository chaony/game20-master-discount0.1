return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1569,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 358,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LuJY_Attack_SF_001",
                  ["autoMirror"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 460,
                  ["eventId"] = 2,
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
                          ["prefab"] = "W_LuJY_Attack_Hit_001",
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

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "",
                  ["bankName"] = "",
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
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1,
                  ["soundName"] = "ShortVo_BiaoNan03_Dead_02",
                  ["bankName"] = "ShortVo_BiaoNan03",
              },

          },
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 204,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 477,
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
     ["animLength"] = 3072,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 443,
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
     ["animLength"] = 2048,
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
     ["animLength"] = 3993,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1569,
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

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2286,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 849,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LuJY_Skill1_SF_001",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
                  ["prefab"] = "W_LuJY_Skill1_SF_002",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Bip001 R Hand",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999996,
                          [2] = 0.9999996,
                          [3] = 0.9999992,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 860,
                  ["eventId"] = 3,
                  ["effectId"] = 0,
                  ["hitAudio"] = "skill1_hit",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_LuJY_Skill1_Hit_001",
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

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 4,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 614,
                  ["eventId"] = 5,
                  ["soundName"] = "skill1_1",
                  ["bankName"] = "",
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 471,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LuJY_Skill2_SF_001",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 542,
                  ["eventId"] = 2,
                  ["prefab"] = "W_LuJY_Skill2_SF_002",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 552,
                  ["eventId"] = 3,
                  ["prefab"] = "W_LuJY_Skill2_SF_003",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 4,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 307,
                  ["eventId"] = 5,
                  ["soundName"] = "skill2_1",
                  ["bankName"] = "",
              },

              [6] = 
              {
                  ["eventKey"] = 6,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 512,
                  ["eventId"] = 6,
                  ["soundName"] = "skill2_2",
                  ["bankName"] = "",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 3174,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LuJY_Skill3_SF_001",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1484,
                  ["eventId"] = 2,
                  ["prefab"] = "W_LuJY_Skill3_SF_003",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1505,
                  ["eventId"] = 3,
                  ["prefab"] = "W_LuJY_Skill3_SF_004",
                  ["autoMirror"] = false,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                          [1] = 0.9999998,
                          [2] = 1,
                          [3] = 0.9999998,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 4,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1228,
                  ["eventId"] = 5,
                  ["soundName"] = "skill3_1",
                  ["bankName"] = "",
              },

              [6] = 
              {
                  ["eventKey"] = 6,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 2457,
                  ["eventId"] = 6,
                  ["soundName"] = "skill2",
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