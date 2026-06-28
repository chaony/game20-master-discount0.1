return{
["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1364,
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
     ["animLength"] = 1774,
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

["hit1_end"] = 
{
     ["animName"] = "hit1_end",
     ["animLength"] = 443,
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
     ["animLength"] = 819,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 716,
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
     ["animLength"] = 1672,
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
     ["animLength"] = 2867,
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
     ["animLength"] = 750,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 784,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill2"] = 
{
     ["animName"] = "skill2",
     ["animLength"] = 2286,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1740,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventKey"] = 0,
                  ["eventName"] = "ChangeAnim",
                  ["triggerTime"] = 1638,
                  ["eventId"] = 0,
                  ["anim"] = "skill3_loop",
                  ["isLoop"] = false,
                  ["endAnim"] = "nil",
              },

              [2] = 
              {
                  ["eventKey"] = 2,
                  ["eventName"] = "Dispatch",
                  ["triggerTime"] = 665,
                  ["eventId"] = 2048,
                  ["dispatchEventName"] = "skill3_addBuff",
              },

          },
     },
},

["skill3_end"] = 
{
     ["animName"] = "skill3_end",
     ["animLength"] = 784,
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
                  ["eventKey"] = 1,
                  ["eventName"] = "Hook",
                  ["triggerTime"] = 0,
                  ["eventId"] = 1024,
                  ["origin"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["originParent"] = "Xiong",
                  ["destination"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["destinationParent"] = "Xiong",
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["playerType"] = "player",
                      ["camp"] = "curFriend",
                      ["posIndex"] = "all",
                      ["roleType"] = 0,
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "forceMax",
                      ["profession"] = "all",
                      ["area"] = "all",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 0,
                      ["areaRadius"] = 0,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["prefab"] = "W_ZhanZ_Skill1_Line_001",
                  ["hitEffect"] = "nil",
                  ["damageStart"] = 0,
                  ["damage"] = 0,
                  ["damageInterval"] = 0,
                  ["imprison"] = false,
                  ["fireTime"] = 0,
                  ["selfWaitTime"] = 1022976,
                  ["enemyWaitTime"] = 1022976,
                  ["selfBasePos"] = 0,
                  ["enemyBasePos"] = 0,
                  ["finishWaitTime"] = 1022976,
                  ["selfMoveTimer"] = 0,
                  ["enemyMoveTimer"] = 0,
                  ["selfDistance"] = 0,
                  ["enemyDistance"] = 0,
                  ["selfCurve"] = "nil",
                  ["enemyCurve"] = "nil",
                  ["bufid"] = "nil",
              },

          },
     },
},

}