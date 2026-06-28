return{
["idle"] = 
{
     ["animName"] = "idle",
     ["animLength"] = 1705,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["attack1"] = 
{
     ["animName"] = "attack1",
     ["animLength"] = 1467,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Shoot",
                  ["triggerTime"] = 906,
                  ["effectId"] = 0,
                  ["bulletType"] = "Bullet",
                  ["linePrefab"] = "fx_GongJianShou_attack_01",
                  ["lineBuffId"] = "",
                  ["lineTime"] = 0,
                  ["circleStayTime"] = 0,
                  ["backPuncture"] = false,
                  ["backdamagePercent"] = 0,
                  ["delayTime"] = 0,
                  ["delayBoomTime"] = 0,
                  ["frontdamagePercent"] = 1024,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "myenemy",
                      ["posIndex"] = "all",
                      ["priority"] = true,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
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
                  ["isEnemy"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["targetNoRepeat"] = false,
                  ["bombName"] = "nil",
                  ["bombParent"] = "head",
                  ["prefabName"] = "M_CaoM2_Attack_Hit_001",
                  ["bulletAudio"] = "attack1_hit",
                  ["prefab"] = "M_CaoM2_Attack_Fly_001",
                  ["speed"] = 20480,
                  ["noAttack"] = false,
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["parent"] = "shootpoint",
                  ["firePoint"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1432,
                      ["z"] = 819
                  },
                  ["isForward"] = false,
                  ["isY"] = false,
                  ["checkRange"] = 0,
                  ["acceleration"] = 0,
                  ["vSpeed"] = 0,
                  ["gravity"] = 0,
                  ["power"] = 0,
                  ["lifeTime"] = 5120,
                  ["movePath"] = 
                  {
                      ["move"] = false,

                  },
                  ["puncturedmg"] = false,
                  ["damageReduce"] = 0,
                  ["punctureTime"] = 0,
                  ["isCircle"] = false,
                  ["TrackParam"] = "not",
                  ["trackCount"] = 0,
                  ["notFaceToTarget"] = false,
                  ["isSideBomb"] = false,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["isDeadbuff"] = false,
                  ["buffId"] = "nil",
                  ["EditorBuffName"] = "",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["isSpecial"] = false,
                  ["SpecialParam"] = "not",
                  ["specialAudio"] = "",
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
                  ["Effect"] = 
                  {
                  },
              },

          },
     },
},

["die"] = 
{
     ["animName"] = "die",
     ["animLength"] = 1057,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1"] = 
{
     ["animName"] = "hit1_1",
     ["animLength"] = 204,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1end"] = 
{
     ["animName"] = "hit1_1end",
     ["animLength"] = 340,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit1_1loop"] = 
{
     ["animName"] = "hit1_1loop",
     ["animLength"] = 33,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_1"] = 
{
     ["animName"] = "hit2_1",
     ["animLength"] = 512,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_2"] = 
{
     ["animName"] = "hit2_2",
     ["animLength"] = 852,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_fly"] = 
{
     ["animName"] = "hit2_fly",
     ["animLength"] = 409,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyend"] = 
{
     ["animName"] = "hit2_flyend",
     ["animLength"] = 512,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit2_flyloop"] = 
{
     ["animName"] = "hit2_flyloop",
     ["animLength"] = 33,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["hit2_spin"] = 
{
     ["animName"] = "hit2_spin",
     ["animLength"] = 272,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["hit3"] = 
{
     ["animName"] = "hit3",
     ["animLength"] = 545,
     ["isLoop"] = false,
     ["events"] = 
     {
     },
},

["skill3"] = 
{
     ["animName"] = "skill3",
     ["animLength"] = 1876,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "SkillCondition",
                  ["triggerTime"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "all",
                      ["camp"] = "enemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "sector",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 61440,
                      ["areaRadius"] = 7168,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["noControl"] = false,
                  ["mustEnough"] = false,
              },

              [2] = 
              {
                  ["eventName"] = "Hit",
                  ["triggerTime"] = 1228,
                  ["effectId"] = 0,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "myenemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
                      ["profession"] = "all",
                      ["area"] = "all",
                      ["areaWidth"] = 0,
                      ["areaHeight"] = 0,
                      ["areaAngle"] = 61440,
                      ["areaRadius"] = 7168,
                      ["forceSelect"] = false,
                      ["selectLast"] = false,
                      ["isFixPoint"] = false,
                      ["useSelf"] = false,
                      ["fixpoint"] = "enemyBackCenter"
                  },
                  ["damageDelay"] = 0,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = true,
                      ["aoeType"] = "Sector",
                      ["useSceneDir"] = false,
                      ["aoeSectorRadius"] = 3072,
                      ["aoeSectorAngle"] = 368640,
                      ["aoeRectX"] = 0,
                      ["aoeRectY"] = 0,
                      ["aoeOffset"] = 
                      {
                          [1] = 0,
                          [2] = 0,
                          [3] = 0,
                      },
                  },
                  ["targetNoRepeat"] = false,
                  ["prefabName"] = "",
                  ["hitAudio"] = "",
                  ["is_foot"] = false,
                  ["frontdamagePercent"] = 1843,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["power"] = 0,
                  ["noAttack"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["Isattack"] = true,
                  ["cameraShake"] = 
                  {
                      ["shake"] = false,
                      ["curve_id"] = 0
                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["buffId"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
              },

          },
     },
},

["run"] = 
{
     ["animName"] = "run",
     ["animLength"] = 681,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["debuff1"] = 
{
     ["animName"] = "debuff1",
     ["animLength"] = 1364,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["battle_idle"] = 
{
     ["animName"] = "battle_idle",
     ["animLength"] = 1705,
     ["isLoop"] = true,
     ["events"] = 
     {
     },
},

["skill1"] = 
{
     ["animName"] = "skill1",
     ["animLength"] = 1536,
     ["isLoop"] = false,
     ["events"] = 
     {
          ["level1"] = 
          {
              [1] = 
              {
                  ["eventName"] = "Shoot",
                  ["triggerTime"] = 952,
                  ["effectId"] = 0,
                  ["bulletType"] = "Bullet",
                  ["linePrefab"] = "",
                  ["lineBuffId"] = "nil",
                  ["lineTime"] = 0,
                  ["circleStayTime"] = 0,
                  ["backPuncture"] = false,
                  ["backdamagePercent"] = 0,
                  ["delayTime"] = 0,
                  ["delayBoomTime"] = 0,
                  ["frontdamagePercent"] = 1536,
                  ["lastdamagePercent"] = 1024,
                  ["angerAirPercent"] = 1024,
                  ["count"] = 
                  {
                      ["count"] = "one",
                      ["camp"] = "myenemy",
                      ["posIndex"] = "all",
                      ["priority"] = false,
                      ["ignoreSummon"] = false,
                      ["targetNoRepeat"] = false,
                      ["campRace"] = "not",
                      ["gender"] = "all",
                      ["pos"] = "not",
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
                  ["isEnemy"] = false,
                  ["mustHit"] = false,
                  ["mustCrit"] = false,
                  ["targetNoRepeat"] = false,
                  ["bombName"] = "nil",
                  ["bombParent"] = "head",
                  ["prefabName"] = "M_CaoM2_Skill1_Hit_001",
                  ["bulletAudio"] = "nil",
                  ["prefab"] = "M_CaoM2_Skill1_Fly_001",
                  ["speed"] = 20480,
                  ["noAttack"] = false,
                  ["targetOffset"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 0,
                      ["z"] = 0
                  },
                  ["parent"] = "head",
                  ["firePoint"] = 
                  {
                      ["x"] = 0,
                      ["y"] = 1511,
                      ["z"] = 813
                  },
                  ["isForward"] = false,
                  ["isY"] = false,
                  ["checkRange"] = 0,
                  ["acceleration"] = 0,
                  ["vSpeed"] = 0,
                  ["gravity"] = 0,
                  ["power"] = 0,
                  ["lifeTime"] = 2048,
                  ["movePath"] = 
                  {
                      ["move"] = false,

                  },
                  ["puncturedmg"] = false,
                  ["damageReduce"] = 0,
                  ["punctureTime"] = 0,
                  ["isCircle"] = false,
                  ["TrackParam"] = "not",
                  ["trackCount"] = 0,
                  ["notFaceToTarget"] = false,
                  ["isSideBomb"] = false,
                  ["aoeType"] = 
                  {
                      ["openAoe"] = false,

                  },
                  ["injureMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["curveMove"] = 
                  {
                      ["move"] = false,

                  },
                  ["isDeadbuff"] = false,
                  ["buffId"] = "nil",
                  ["EditorBuffName"] = "nil",
                  ["buffType"] = 
                  {
                      ["openBuff"] = false,

                  },
                  ["isSpecial"] = false,
                  ["SpecialParam"] = "not",
                  ["specialAudio"] = "nil",
                  ["areaCheck"] = 
                  {
                      ["openAreaCheck"] = false,

                  },
                  ["useSelf"] = false,
                  ["Effect"] = 
                  {
                  },
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