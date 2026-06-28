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
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 384,
                  ["eventId"] = 1,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "",
                  ["prefab"] = "W_SongS3_Attack_Fly_001",
                  ["speed"] = 30,
                  ["lifeTime"] = 5,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 1.25,
                      ["z"] = 0
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "head",
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
                          ["prefab"] = "W_SongS3_Attack_Hit_001",
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

              [2] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
                  ["soundName"] = "W_SongS_412_attack1",
                  ["bankName"] = "W_SongS_412",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 384,
                  ["eventId"] = 3,
                  ["soundName"] = "W_SongS_412_attack1_hit",
                  ["bankName"] = "W_SongS_412",
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
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 1945,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1,
                  ["soundName"] = "ShortVo_BiaoNan04_Dead_1",
                  ["bankName"] = "ShortVo_BiaoNan04",
              },

          },
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 238,
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
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 852,
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
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit3"] = 
{
     ["animName"] = "hit3",
     ["animLength"] = 681,
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
     ["animLength"] = 4265,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1536,
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

["skill0"] = 
{
     ["animName"] = "skill0",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 2115,
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
                  ["prefab"] = "W_SongS3_Skill1_SF_001",
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
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 256,
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
                          ["type"] = "rangeHit",
                          ["prefab"] = "W_SongS3_Skill1_Hit_001",
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
                          ["autoDestroy"] = 2.5,
                      },

                  },
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "W_SongS_412_skill1",
                  ["bankName"] = "W_SongS_412",
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
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1525,
                  ["eventId"] = 1,
                  ["prefab"] = "W_SongS3_Skill3_SF_001",
                  ["autoMirror"] = true,
                  ["mirrorPrefab"] = false,
                  ["parent"] = "Root",
                  ["isPutUpInParent"] = false,
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
                  ["isSkill"] = false,
                  ["autodestoryTime"] = 20,
              },

              [2] = 
              {
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
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

              [3] = 
              {
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 2027,
                  ["eventId"] = 3,
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
                          ["prefab"] = "W_SongS3_Attack_Hit_001",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 4,
                  ["soundName"] = "W_SongS_412_skill3",
                  ["bankName"] = "W_SongS_412",
              },

              [5] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 2027,
                  ["eventId"] = 5,
                  ["soundName"] = "W_SongS_412_skill3_hit",
                  ["bankName"] = "W_SongS_412",
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