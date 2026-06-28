return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1057,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 460,
                  ["eventId"] = 1,
                  ["prefab"] = "P_Cat_Attack_SF_001",
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
                  ["eventKey"] = 2,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 512,
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
                          ["prefab"] = "P_Cat_Attack_Hit_001",
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
                  ["triggerTime"] = 307,
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

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 1910,
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
                  ["soundName"] = "P_Cat_101_skill3_1",
                  ["bankName"] = "P_Cat_101",
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

["idle01"] = 
{
     ["animName"] = "idle01",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["idle_circlewalk"] = 
{
     ["animName"] = "idle_circlewalk",
     ["animLength"] = 819,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["idle_hunt"] = 
{
     ["animName"] = "idle_hunt",
     ["animLength"] = 2662,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["idle_walk"] = 
{
     ["animName"] = "idle_walk",
     ["animLength"] = 955,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["idle_walk2"] = 
{
     ["animName"] = "idle_walk2",
     ["animLength"] = 1501,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 545,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1262,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 307,
                  ["eventId"] = 1,
                  ["prefab"] = "P_Cat_Skill3A_SF_001",
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
                  ["eventKey"] = 2,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 307,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "P_Cat_XieZhan_Fly_001",
                  ["speed"] = 20,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1.2,
                      ["z"] = 0
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "nil",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["prefabList"] = {},
                  ["EditorBuffName"] = "nil",
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

["skill4"] = 
{
     ["animName"] = "skill4",
     ["animLength"] = 819,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill4_1"] = 
{
     ["animName"] = "skill4_1",
     ["animLength"] = 819,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["stay_dahaqian"] = 
{
     ["animName"] = "stay_dahaqian",
     ["animLength"] = 2560,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["stay_down"] = 
{
     ["animName"] = "stay_down",
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["stay_down_end"] = 
{
     ["animName"] = "stay_down_end",
     ["animLength"] = 2150,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["stay_down_loop"] = 
{
     ["animName"] = "stay_down_loop",
     ["animLength"] = 1024,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["stay_sit"] = 
{
     ["animName"] = "stay_sit",
     ["animLength"] = 2150,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["touch_ask"] = 
{
     ["animName"] = "touch_ask",
     ["animLength"] = 4198,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["touch_lay"] = 
{
     ["animName"] = "touch_lay",
     ["animLength"] = 5460,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["touch_yawn"] = 
{
     ["animName"] = "touch_yawn",
     ["animLength"] = 3584,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["xiezhanattack1"] = 
{
     ["animName"] = "xiezhanattack1",
     ["animLength"] = 1057,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 460,
                  ["eventId"] = 1,
                  ["prefab"] = "P_Cat_Attack_SF_001",
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
                  ["eventKey"] = 2,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 512,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["hitAudio"] = "nil",
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "P_Cat_Attack_Hit_001",
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
                  ["triggerTime"] = 307,
                  ["eventId"] = 3,
                  ["soundName"] = "P_Cat_101_attack1",
                  ["bankName"] = "P_Cat_101",
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 512,
                  ["eventId"] = 4,
                  ["soundName"] = "P_Cat_101_attack1_hit",
                  ["bankName"] = "P_Cat_101",
              },

          },
     },
},

["xiezhanskill1"] = 
{
     ["animName"] = "xiezhanskill1",
     ["animLength"] = 1262,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 307,
                  ["eventId"] = 1,
                  ["prefab"] = "P_Cat_XieZhan_SF_001",
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
                  ["eventKey"] = 2,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 307,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "P_Cat_XieZhan_Fly_001",
                  ["speed"] = 20,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1.2,
                      ["z"] = 0
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "nil",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["prefabList"] = {},
                  ["EditorBuffName"] = "nil",
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

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 307,
                  ["eventId"] = 4,
                  ["soundName"] = "P_Cat_101_skill3_1",
                  ["bankName"] = "P_Cat_101",
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