return{
["attack1_1"] = 
{
     ["animName"] = "attack1_1",
     ["animLength"] = 1228,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 266,
                  ["eventId"] = 1,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "TongRenPS_Attack_Fly_01",
                  ["speed"] = 15,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 0.5,
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
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "TongRenPS_Attack_Hit_01",
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
                              ["y"] = 270,
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
                  ["eventId"] = 0,
                  ["soundName"] = "M_TongRenPS_9202_attack1",
                  ["bankName"] = "M_TongRenPS_9202",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 266,
                  ["eventId"] = 3,
                  ["soundName"] = "M_TongRenPS_9202_attack1_hit",
                  ["bankName"] = "M_TongRenPS_9202",
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 204,
                  ["eventId"] = 4,
                  ["soundName"] = "ShortVo_BiaoNan01_Attack_H1",
                  ["bankName"] = "ShortVo_BiaoNan01",
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
     ["animLength"] = 2729,
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
                  ["soundName"] = "ShortVo_BiaoNan01_Dead_02",
                  ["bankName"] = "ShortVo_BiaoNan01",
              },

          },
     },
},

["hit1"] = 
{
     ["animName"] = "hit1",
     ["animLength"] = 648,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 272,
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
     ["animLength"] = 750,
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

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 614,
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
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 921,
                  ["eventId"] = 1,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "skill1_hit",
                  ["prefab"] = "TongRenPS_Skill1_Fly_01",
                  ["speed"] = 15,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 0.5,
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
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "TongRenPS_Skill1_Hit_01",
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
                              ["y"] = 270,
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
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 819,
                  ["eventId"] = 3,
                  ["soundName"] = "ShortVo_BiaoNan01_Attack_L1",
                  ["bankName"] = "ShortVo_BiaoNan01",
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
                  ["eventName"] = "PlayEffect",
                  ["triggerTime"] = 716,
                  ["eventId"] = 1,
                  ["prefab"] = "TongRenPS_Skill2_SF_01",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 307,
                  ["eventId"] = 2,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 716,
                  ["eventId"] = 3,
                  ["soundName"] = "ShortVo_BiaoNan01_Attack_H1",
                  ["bankName"] = "ShortVo_BiaoNan01",
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1193,
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
                  ["prefab"] = "TongRenPS_Skill3_SF_01",
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
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 0,
                  ["eventId"] = 2,
                  ["soundName"] = "",
                  ["bankName"] = "",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 1351,
                  ["eventId"] = 3,
                  ["soundName"] = "M_TongRenPS_9202_skill3_hit",
                  ["bankName"] = "M_TongRenPS_9202",
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 102,
                  ["eventId"] = 4,
                  ["soundName"] = "ShortVo_BiaoNan03_Attack_H1_2",
                  ["bankName"] = "ShortVo_BiaoNan03",
              },

          },
     },
},

["skill3_end"] = 
{
     ["animName"] = "skill3_end",
     ["animLength"] = 955,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_loop"] = 
{
     ["animName"] = "skill3_loop",
     ["animLength"] = 1024,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["attack1_2"] = 
{
     ["animName"] = "attack1_2",
     ["animLength"] = 1228,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "ShootEffect",
                  ["triggerTime"] = 276,
                  ["eventId"] = 1,
                  ["effectId"] = 0,
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "TongRenPS_Skill3_Fly_01",
                  ["speed"] = 15,
                  ["lifeTime"] = 0,
                  ["firePoint"] = 
                  {
                      ["x"] = 0.5,
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
                  ["prefabList"] = 
                  {
                      ["0"] = {
                          ["type"] = "injureHit",
                          ["prefab"] = "TongRenPS_Skill3_Hit_01",
                          ["parent"] = "Root",
                          ["position"] = 
                          {
                              ["x"] = 0,
                              ["y"] = 0.1,
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
                  ["soundName"] = "M_TongRenPS_9202_attack1",
                  ["bankName"] = "M_TongRenPS_9202",
              },

              [3] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 266,
                  ["eventId"] = 3,
                  ["soundName"] = "M_TongRenPS_9202_attack1_hit",
                  ["bankName"] = "M_TongRenPS_9202",
              },

              [4] = 
              {
                  ["eventName"] = "PlaySound",
                  ["triggerTime"] = 204,
                  ["eventId"] = 4,
                  ["soundName"] = "ShortVo_BiaoNan01_Attack_H1",
                  ["bankName"] = "ShortVo_BiaoNan01",
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