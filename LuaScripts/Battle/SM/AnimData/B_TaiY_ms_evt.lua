return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1705,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 614,
                  ["eventId"] = 1,
                  ["prefab"] = "B_TaiY_Attack_SF_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = -0.5000001,
                          [2] = 2.2,
                          [3] = 4.000002,
                      },
                      ["rotation"] = 
                      {
                          [1] = 356.4381,
                          [2] = 36.2627,
                          [3] = 19.55169,
                      },
                      ["scale"] = 
                      {
                          [1] = 1.2,
                          [2] = 1.2,
                          [3] = 1.2,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 5,
              },

              [2] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 695,
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
                          ["prefab"] = "B_TaiY_Attack_Hit_001",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

          },
     },
},

["debuff"] = 
{
     ["animName"] = "debuff",
     ["animLength"] = 4777,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["debuff1"] = 
{
     ["animName"] = "debuff1",
     ["animLength"] = 4777,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 5120,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1"] = 
{
     ["animName"] = "hit1",
     ["animLength"] = 1296,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 5120,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill0"] = 
{
     ["animName"] = "skill0",
     ["animLength"] = 5699,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 614,
                  ["eventId"] = 1,
                  ["prefab"] = "B_TaiY_Skill0_SF_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 4.300015,
                          [2] = 5.8,
                          [3] = -5.600012,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 90,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = -1.4,
                          [2] = 1.4,
                          [3] = 1.4,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 5,
              },

              [2] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 3072,
                  ["eventId"] = 2,
                  ["prefab"] = "B_TaiY_Skill0_SF_002",
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
                      ["useUserSet"] = true,
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

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 3430,
                  ["eventId"] = 3,
                  ["prefab"] = "B_TaiY_Skill0_SF_003",
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
                      ["useUserSet"] = true,
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
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 4096,
                  ["eventId"] = 4,
                  ["prefab"] = "B_TaiY_Skill0_SF_004",
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
                      ["useUserSet"] = true,
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

              [5] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 3072,
                  ["eventId"] = 5,
                  ["prefab"] = "B_TaiY_Skill0_Hit_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 1.000001,
                          [2] = 4.263256E-14,
                          [3] = 2.000001,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 300,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = -1.3,
                          [2] = 1.6,
                          [3] = 1.3,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 3,
              },

              [6] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 3430,
                  ["eventId"] = 6,
                  ["prefab"] = "B_TaiY_Skill0_Hit_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 1.3,
                          [2] = 4.263256E-14,
                          [3] = 2.500001,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 325,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = -1.5,
                          [2] = 1.6,
                          [3] = 1.5,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 3,
              },

              [7] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 4096,
                  ["eventId"] = 7,
                  ["prefab"] = "B_TaiY_Skill0_Hit_002",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 0.2499998,
                          [2] = 4.263256E-14,
                          [3] = 2.000001,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 280,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = -1.6,
                          [2] = 1.6,
                          [3] = 1.6,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 3,
              },

              [8] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 8,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [9] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 2560,
                  ["eventId"] = 9,
                  ["soundName"] = "skill0_1",
                  ["bankName"] = "",
              },

          },
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 3072,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1,
                  ["prefab"] = "B_TaiY_Skill1_SF_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 2.800004,
                          [2] = 4,
                          [3] = 2.600003,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 270,
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
                  ["autodestoryTime"] = 0.5,
              },

              [2] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1126,
                  ["eventId"] = 2,
                  ["prefab"] = "B_TaiY_Skill1_SF_002",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 3.700004,
                          [2] = 2.2,
                          [3] = 4.000004,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 250,
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
                  ["autodestoryTime"] = 0.8,
              },

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1075,
                  ["eventId"] = 3,
                  ["prefab"] = "B_TaiY_Skill1_SF_003",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 3.500004,
                          [2] = 1.705303E-13,
                          [3] = -40,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 90,
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
                  ["autodestoryTime"] = 90,
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 4,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [5] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 5,
                  ["soundName"] = "skill1_1",
                  ["bankName"] = "",
              },

              [6] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1536,
                  ["eventId"] = 6,
                  ["soundName"] = "skill1_2",
                  ["bankName"] = "",
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2593,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 921,
                  ["eventId"] = 1,
                  ["prefab"] = "B_TaiY_Skill02_SF_001",
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
                      ["useUserSet"] = true,
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
                  ["autodestoryTime"] = 3,
              },

              [2] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["hitAudio"] = "",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "B_TaiY_Attack_Hit_001",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 512,
                  ["eventId"] = 4,
                  ["soundName"] = "skill2_1",
                  ["bankName"] = "",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 4096,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 3993,
                  ["eventId"] = 1,
                  ["prefab"] = "B_TaiY_Skill3_SF_001",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 4.83,
                          [2] = 0,
                          [3] = -6.340003,
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
                  ["autodestoryTime"] = 1,
              },

              [2] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 614,
                  ["eventId"] = 2,
                  ["prefab"] = "B_TaiY_Skill3_SF_002",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = -1.136868E-13,
                          [2] = 8,
                          [3] = -6.340009,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = 1.8,
                          [2] = 1.8,
                          [3] = 1.8,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 1,
              },

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1689,
                  ["eventId"] = 3,
                  ["prefab"] = "B_TaiY_Skill3_SF_003",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 3.800005,
                          [2] = -1.136868E-13,
                          [3] = -5.850005,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = 1.6,
                          [2] = 1.6,
                          [3] = 1.6,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 1.5,
              },

              [4] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 2560,
                  ["eventId"] = 4,
                  ["prefab"] = "B_TaiY_Skill3_SF_004",
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
                      ["useUserSet"] = true,
                      ["position"] = 
                      {
                          [1] = 3.800006,
                          [2] = -1.421085E-13,
                          [3] = -5.850006,
                      },
                      ["rotation"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                      ["scale"] = 
                      {
                          [1] = 2,
                          [2] = 2,
                          [3] = 2,
                      },
                  },
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 3,
              },

              [5] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 2560,
                  ["eventId"] = 5,
                  ["effectId"] = 0,
                  ["hitAudio"] = "skill3_hit",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "B_TaiY_Skill3_Hit_001",
                          ["parent"] = "Root",
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

              [6] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 6,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [7] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 2560,
                  ["eventId"] = 7,
                  ["soundName"] = "skill3_1",
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