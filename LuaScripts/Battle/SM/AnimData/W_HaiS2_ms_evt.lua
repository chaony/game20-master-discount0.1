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
                  ["triggerTime"] = 512,
                  ["eventId"] = 1,
                  ["prefab"] = "W_HaiS2_Attack_SF_001",
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
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 588,
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
                          ["prefab"] = "W_HaiS2_Attack_Hit_001",
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
                  ["triggerTime"] = 204,
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
     ["animLength"] = 2593,
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
                  ["soundName"] = "ShortVo_Boy_Dead",
                  ["bankName"] = "ShortVo_Boy",
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
     ["animLength"] = 443,
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
     ["animLength"] = 716,
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
     ["animLength"] = 1193,
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
     ["animLength"] = 4505,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1364,
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
     ["animLength"] = 3584,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1699,
                  ["eventId"] = 1,
                  ["prefab"] = "W_HaiS2_Skill1_SF_001",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 3481,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 204,
                  ["eventId"] = 1,
                  ["prefab"] = "W_HaiS2_Skill2_SF_001",
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
                  ["triggerTime"] = 1658,
                  ["eventId"] = 2,
                  ["prefab"] = "W_HaiS2_Skill2_SF_002",
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
                  ["triggerTime"] = 1740,
                  ["eventId"] = 3,
                  ["prefab"] = "W_HaiS2_Skill2_SF_003",
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
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 1730,
                  ["eventId"] = 4,
                  ["effectId"] = 0,
                  ["hitAudio"] = "skill2_hit",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_HaiS2_Skill2_Hit_001",
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

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 5,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 4880,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 2099,
                  ["eventId"] = 1,
                  ["prefab"] = "W_HaiS2_Skill3_SF_001",
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
                  ["triggerTime"] = 1177,
                  ["eventId"] = 2,
                  ["prefab"] = "W_HaiS2_Skill3_SF_002",
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
                  ["triggerTime"] = 2816,
                  ["eventId"] = 3,
                  ["prefab"] = "W_HaiS2_Skill3_SF_003",
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
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 2867,
                  ["eventId"] = 4,
                  ["prefab"] = "W_HaiS2_Skill3_SF_004",
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

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 2918,
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
                          ["prefab"] = "W_HaiS2_Skill3_Hit_001",
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

              [6] = 
              {
                  ["eventKey"] = 6,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 6,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [7] = 
              {
                  ["eventKey"] = 7,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1597,
                  ["eventId"] = 7,
                  ["soundName"] = "skill3_1",
                  ["bankName"] = "",
              },

              [8] = 
              {
                  ["eventKey"] = 8,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1740,
                  ["eventId"] = 8,
                  ["soundName"] = "skill3_2",
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