return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1024,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 409,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "attack1_hit",
                  ["prefab"] = "W_HongY_Attack_Fly_001",
                  ["speed"] = 30,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 0.8,
                      ["z"] = 0
                  },
                  ["isForward"] = true,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "nil",
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
                          ["prefab"] = "W_HongY_Attack_Hit_001",
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

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 409,
                  ["eventId"] = 0,
                  ["prefab"] = "W_HongY_Attack_SF_001",
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
                          [1] = 1,
                          [2] = 1,
                          [3] = 1,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "ShortVo_BiaoNv02_Dead_01",
                  ["bankName"] = "ShortVo_BiaoNv02",
              },

          },
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

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 512,
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
     ["animLength"] = 681,
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
     ["animLength"] = 512,
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
     ["animLength"] = 3720,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1501,
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
     ["animLength"] = 2457,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 1126,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "skill1_hit",
                  ["prefab"] = "W_HongY_Skill1_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 0.8,
                      ["z"] = 0
                  },
                  ["isForward"] = true,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "nil",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "bombHit",
                          ["prefab"] = "W_HongY_Skill1_Hit_001",
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

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1126,
                  ["eventId"] = 0,
                  ["prefab"] = "W_HongY_Skill1_SF_001",
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
                          [1] = 1,
                          [2] = 1,
                          [3] = 1,
                      },
                  },
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 3,
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 1262,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "skill2_1",
                  ["bankName"] = "",
              },

              [2] = 
              {
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 460,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "skill2_2",
                  ["prefab"] = "W_HongY_Skill2_Fly_001",
                  ["speed"] = 30,
                  ["lifeTime"] = 2,
                  ["firePoint"] = 
                  {
                      ["x"] = -1,
                      ["y"] = 1.7,
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
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_HongY_Skill2_Hit_001",
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
                  ["EditorBuffName"] = "nil",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 3822,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["prefab"] = "W_HongY_Skill3_SF_001",
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

              [2] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["soundName"] = "skill3_1",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
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
                  ["triggerTime"] = 819,
                  ["eventId"] = 0,
                  ["soundName"] = "skill3_2",
                  ["bankName"] = "",
              },

              [5] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 2560,
                  ["eventId"] = 0,
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
                          ["type"] = "rangeHit",
                          ["prefab"] = "W_HongY_Skill3_Hit_001",
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

          },
     },
},

["reload"] = 
{
     ["animName"] = "reload",
     ["animLength"] = 409,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["reload_end"] = 
{
     ["animName"] = "reload_end",
     ["animLength"] = 614,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["reload_loop"] = 
{
     ["animName"] = "reload_loop",
     ["animLength"] = 1024,
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