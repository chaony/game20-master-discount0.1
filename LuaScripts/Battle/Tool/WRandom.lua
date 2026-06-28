--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 09:44:39
]]

---@class WRandom伪随机
WRandom = {}

--Bit.bxor 异或 相同的为0 不同的为 1
--Bit.band      有0就为0 全是1 才为1
--根据随机种子设定好了数据序列
--设定随机种子

--是否使用梅森算法
WRandom.useMeiShen = false;
WRandom.common_index = 100;
WRandom.seed = 100;
--是否使用真随机
WRandom.useRealRandom = false;
function WRandom:setSeed( seed, seedTeam, useRealRandom )
    WRandom.seed = seed or 100;
    WRandom.seedTeam = seedTeam or -1
    WRandom.useRealRandom = useRealRandom or false;
    WRandom:initRandomPool(seedTeam);
    if WRandom.useMeiShen == true then
        WRandom:meiShen_setSeed( seed )
    end
end

--左闭右开
function WRandom:randomNum( min, max, isCommon )
    if WRandom.useRealRandom == true then
        return GlobalTools:ToFix( math.random( min, max ) )
    else
        if min == max then
            return min
        end
        min = min or 0;
        max = max or 0;
        if WRandom.useMeiShen == false then
            if isCommon == nil then
                return GlobalTools:ToFix( min + WRandom:common_random() % (max - min) )
            else
                return min + WRandom:common_random() % (max - min)
            end
        else
            if isCommon == nil then
                return GlobalTools:ToFix( min + WRandom:meiShen_random() % (max - min) )
            else
                return min + WRandom:meiShen_random() % (max - min)
            end
        end
    end
end


function WRandom:initRandomPool(seedTeam)
    if seedTeam > 0 then
        local random_seed = ConfigManager:getCfgByName("random_seed");
        WRandom.random_pool = random_seed[seedTeam];
        WRandom.common_index = WRandom.seed % #WRandom.random_pool;
        --Logger.logError("Init Random "..WRandom.common_index.." F "..SceneManager:getCurSceneModel():get_loopTimeNormal())
    else
        WRandom.random_pool = require("Battle.Data.battleRandom");
        WRandom.common_index = WRandom.seed % #WRandom.random_pool;
    end
end

function WRandom:common_random()
    if WRandom.common_index > #WRandom.random_pool then
        WRandom.common_index = 1;
    end
    local number =  WRandom.random_pool[WRandom.common_index]
    WRandom.common_index = WRandom.common_index + 1;
    return number or 0;
end

--[[
    @desc: 梅森螺旋算法 ---------------------------------------------------------
    author:{author}
    time:2020-05-07 19:36:06
    @return:
]]

--固定数
WRandom.FixNum = 1812433253
WRandom.N = 624
WRandom.M = 397
WRandom.MT = nil
WRandom.index = 0
WRandom.isInit = false


--梅森螺旋算法生成随机数
function WRandom:meiShen_generate( )
    for i = 1, WRandom.N,1 do
        -- 2^31 = 0x80000000
        -- 2^31-1 = 0x7fffffff
        local sourceNum = WRandom.MT[i-1] 
        local sourceNum_band = Bit.band(sourceNum,0x80000000)
        local nextNum = WRandom.MT[i]
        local nextNum_mo = WRandom.MT[i % WRandom.N]
        local nextNum_mo_band = Bit.band(nextNum_mo,0x7fffffff) 
        local y = sourceNum_band + nextNum_mo_band
        WRandom.MT[i-1] = Bit.bxor(  WRandom.MT[(i + WRandom.M) % WRandom.N], Bit.rshift(y,1))
        if Bit.band(y,1) >= 1 then
            WRandom.MT[i-1] = Bit.bxor(WRandom.MT[i-1], 2567483615);
        end
    end
end

--梅森螺旋算法生成随机数
function WRandom:meiShen_setSeed( seed )
    if seed == nil then
        seed = 100;
    end
    WRandom.MT = {}
    WRandom.index = 0
    WRandom.isInit = true

    --将数组第一个数给了种子
    WRandom.MT[0] = seed
    --对数组的其他元素进行实例化
    for i = 1, WRandom.N,1 do
        --基础数
        local sourceNum = WRandom.MT[i-1]
        --基础数,向右移动 30 位
        local sourceNum_right_30 = Bit.rshift(sourceNum,30)
        --使用基础数 和 右移动数 进行异或操作 相同的为0 不同的为 1 
        local targetNum = Bit.bxor( sourceNum, sourceNum_right_30 )
        --算出来的目标数 * 常数 1812433253
        local t = WRandom.FixNum * targetNum
        --取最后的32位赋给MT[i]
        WRandom.MT[i] = Bit.band(t,0xffffffff) 
    end
end

--梅森螺旋算法 随机
function WRandom:meiShen_random()
    if WRandom.isInit == false then
        local seed = 500
        WRandom:meiShen_setSeed(seed)
    end
    if WRandom.index == 0 then
        WRandom:meiShen_generate()
    end
    
    local result = WRandom.MT[ WRandom.index ]
    result = Bit.bxor(result, Bit.rshift(result,11) )
    result = Bit.bxor(result, Bit.band( Bit.lshift(result,7), 2636928640 ) )
    result = Bit.bxor(result, Bit.band( Bit.lshift(result,15), 4022730752 ) )
    result = Bit.bxor(result, Bit.rshift(result,18) )
    WRandom.index = (WRandom.index + 1) % WRandom.N
    return result
end


return WRandom