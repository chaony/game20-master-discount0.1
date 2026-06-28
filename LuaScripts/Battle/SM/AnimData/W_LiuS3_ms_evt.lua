return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1193,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 563,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LiuS3_Attack_SF_001",
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
                  ["autodestoryTime"] = 1.5,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 563,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "W_LiuS3_Attack_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 1.1,
                      ["z"] = -0.5
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
                          ["prefab"] = "W_LiuS3_Attack_Hit_001",
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
                          ["autoDestroy"] = 1.5,
                      },

                  },
                  ["EditorBuffName"] = "nil",
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "W_LiuS_103_attack1",
                  ["bankName"] = "W_LiuS_103",
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 563,
                  ["eventId"] = 4,
                  ["soundName"] = "W_LiuS_103_attack1_hit",
                  ["bankName"] = "W_LiuS_103",
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
     ["animLength"] = 1536,
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
                  ["soundName"] = "ShortVo_BiaoNan03_Dead_01",
                  ["bankName"] = "ShortVo_BiaoNan03",
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

["hit1_end"] = 
{
     ["animName"] = "hit1_end",
     ["animLength"] = 409,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_loop"] = 
{
     ["animName"] = "hit1_loop",
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

["hit2_fiyend"] = 
{
     ["animName"] = "hit2_fiyend",
     ["animLength"] = 409,
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
     ["animLength"] = 1024,
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
     ["animLength"] = 3003,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1024,
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
     ["animLength"] = 1364,
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
                  ["prefab"] = "W_LiuS3_Skill1_SF_001",
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
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 1.5,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
                  ["soundName"] = "W_LiuS_103_skill1",
                  ["bankName"] = "W_LiuS_103",
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 409,
                  ["eventId"] = 3,
                  ["soundName"] = "W_LiuS_103_skill1_debuff",
                  ["bankName"] = "W_LiuS_103",
              },

          },
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2560,
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
                  ["prefab"] = "W_LiuS3_Skill2_SF_001",
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
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 1.5,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 573,
                  ["eventId"] = 2,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "W_LiuS3_Attack_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 2,
                      ["y"] = 0.9,
                      ["z"] = -0.5
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
                          ["prefab"] = "W_LiuS3_Skill2_Hit_002",
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
                              ["y"] = -90,
                              ["z"] = 0
                          },
                          ["scale"] = 
                          {
                              ["x"] = 1,
                              ["y"] = 1,
                              ["z"] = 1
                          },
                          ["autoDestroy"] = 1.5,
                      },

                  },
                  ["EditorBuffName"] = "nil",
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 839,
                  ["eventId"] = 3,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "W_LiuS3_Attack_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 2,
                      ["y"] = 0.9,
                      ["z"] = -0.5
                  },
                  ["isForward"] = false,
                  ["rotate"] = false,
                  ["isY"] = false,
                  ["parent"] = "body",
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 1
                  },
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "W_LiuS3_Skill2_Hit_002",
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
                              ["y"] = -90,
                              ["z"] = 0
                          },
                          ["scale"] = 
                          {
                              ["x"] = 1,
                              ["y"] = 1,
                              ["z"] = 1
                          },
                          ["autoDestroy"] = 1.5,
                      },

                  },
                  ["EditorBuffName"] = "nil",
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 1198,
                  ["eventId"] = 4,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "W_LiuS3_Skill2_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 2,
                      ["y"] = 1,
                      ["z"] = -0.5
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
                          ["prefab"] = "W_LiuS3_Skill2_Hit_001",
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
                              ["y"] = -90,
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

              [5] = 
              {
                  ["eventKey"] = 5,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 5,
                  ["soundName"] = "W_LiuS_103_skill2_1",
                  ["bankName"] = "W_LiuS_103",
              },

              [6] = 
              {
                  ["eventKey"] = 6,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1433,
                  ["eventId"] = 6,
                  ["soundName"] = "W_LiuS_103_skill2_2",
                  ["bankName"] = "W_LiuS_103",
              },

              [7] = 
              {
                  ["eventKey"] = 7,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 614,
                  ["eventId"] = 7,
                  ["soundName"] = "W_LiuS_103_skill2_hit",
                  ["bankName"] = "W_LiuS_103",
              },

              [8] = 
              {
                  ["eventKey"] = 8,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1003,
                  ["eventId"] = 8,
                  ["soundName"] = "W_LiuS_103_skill2_hit",
                  ["bankName"] = "W_LiuS_103",
              },

              [9] = 
              {
                  ["eventKey"] = 9,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1536,
                  ["eventId"] = 9,
                  ["soundName"] = "W_LiuS_103_skill2_hit",
                  ["bankName"] = "W_LiuS_103",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 3003,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 1,
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 1,
                  ["prefab"] = "W_LiuS3_Skill3_SF_001",
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
                  ["isSkill"] = true,
                  ["autodestoryTime"] = 5,
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "HitEffect",
                  ["triggerTime"] = 614,
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
                          ["prefab"] = "W_LiuS3_Skill3_Hit_001",
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
                          ["autoDestroy"] = 1.5,
                      },

                  },
              },

              [3] = 
              {
                  ["eventKey"] = 3,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3,
                  ["soundName"] = "W_LiuS_103_skill3_cast",
                  ["bankName"] = "W_LiuS_103",
              },

              [4] = 
              {
                  ["eventKey"] = 4,
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1024,
                  ["eventId"] = 4,
                  ["soundName"] = "W_LiuS_103_skill3_fall",
                  ["bankName"] = "W_LiuS_103",
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
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 563,
                  ["eventId"] = 0,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "attack1_hit",
                  ["prefab"] = "W_LiuS3_Attack_Fly_001",
                  ["speed"] = 25,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 1,
                      ["y"] = 1.1,
                      ["z"] = -0.5
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
                          ["prefab"] = "W_LiuS3_Attack_Hit_001",
                          ["parent"] = "Xiong",
                          ["position"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0,
                              ["z"] = 0
                          },
                          ["eulerAngle"] = 
                          {
                              ["x"] = 180,
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

}