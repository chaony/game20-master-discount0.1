return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1296,
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

["debuff"] = 
{
     ["animName"] = "debuff",
     ["animLength"] = 2048,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 1501,
     ["isLoop"] = false,
     ["events"] = 
     {
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
     ["animLength"] = 614,
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
     ["animLength"] = 1536,
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
     ["animLength"] = 4061,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["jumpin2"] = 
{
     ["animName"] = "jumpin2",
     ["animLength"] = 1193,
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
     ["animLength"] = 2048,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1910,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 1843,
                  ["eventId"] = 0,
                  ["anim"] = "skill3_loop",
                  ["isLoop"] = false,
                  ["endAnim"] = "nil",
              },

              [2] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 614,
                  ["eventId"] = 0,
                  ["dispatchEventName"] = "skill3_addBuff",
              },

          },
     },
},

["skill3_end"] = 
{
     ["animName"] = "skill3_end",
     ["animLength"] = 1945,
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

["skill3_plus"] = 
{
     ["animName"] = "skill3_plus",
     ["animLength"] = 1910,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 1843,
                  ["eventId"] = 0,
                  ["anim"] = "skill3_loop",
                  ["isLoop"] = false,
                  ["endAnim"] = "nil",
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 614,
                  ["eventId"] = 2048,
                  ["dispatchEventName"] = "skill3_addBuff",
              },

          },
     },
},

["skill3_plus_end"] = 
{
     ["animName"] = "skill3_plus_end",
     ["animLength"] = 1945,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3_plus_loop"] = 
{
     ["animName"] = "skill3_plus_loop",
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