return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1091,
     ["isLoop"] = false,
     ["events"] = 
     {
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
     ["animLength"] = 1843,
     ["isLoop"] = false,
     ["events"] = 
     {
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
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 1126,
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

["hit2_spine"] = 
{
     ["animName"] = "hit2_spine",
     ["animLength"] = 340,
     ["isLoop"] = true,
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
     ["animLength"] = 4368,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1638,
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
     ["animLength"] = 1945,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 819,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 716,
                  ["eventId"] = 0,
                  ["active"] = true,
                  ["activeNode"] = "W_CiH",
                  ["hpBarActive"] = true,
              },

              [2] = 
              {
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 768,
                  ["eventId"] = 0,
                  ["dispatchEventName"] = "skill2_move",
              },

              [3] = 
              {
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 819,
                  ["eventId"] = 0,
                  ["anim"] = "skill2_1",
                  ["isLoop"] = false,
                  ["endAnim"] = "nil",
              },

              [4] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 716,
                  ["eventId"] = 4096,
                  ["active"] = false,
                  ["activeNode"] = "W_CiH_Weapon",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill2_1"] = 
{
     ["animName"] = "skill2_1",
     ["animLength"] = 1126,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["eventId"] = 0,
                  ["active"] = false,
                  ["activeNode"] = "W_CiH",
                  ["hpBarActive"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 133,
                  ["eventId"] = 0,
                  ["dispatchEventName"] = "skill2_fire",
              },

              [3] = 
              {
                  ["eventName"] = "PlayActive",
                  ["triggerTime"] = 0,
                  ["eventId"] = 3072,
                  ["active"] = false,
                  ["activeNode"] = "W_CiH_Weapon",
                  ["hpBarActive"] = false,
              },

          },
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 2900,
     ["isLoop"] = false,
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