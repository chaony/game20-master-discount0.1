------------------- LODUtil

local M = {}

function M:init()
    --cpu   手机处理器
    --ram   内存
    self.cpu =  "xxxx";
    -- self.cpu = SDKUtil.sdk_params.cpu_name or "xxxx";
    self.cpu = string.lower(self.cpu);
    -- self.ram = SDKUtil.sdk_params.memory or 2000;
    self.ram = 2000;
    local cpus = string.split(self.cpu,"-")
    if string.find(cpus[1],"hardware") then
        local cpus_lod = string.split(cpus[1],":")
        self.cpu_type = string.trim(cpus_lod[2])
    else
        self.cpu_type = string.trim(cpus[1])
    end
    self.cpu_score = ConfigManager:getCfgByName("cpu_score")
    self.cpu_score_num = self:cpuScore(self.cpu_type) * 0.5;
    self.ram_score_num = self:ramScore(self.ram) * 0.5;
    local total_num = self.cpu_score_num + self.ram_score_num;
    --分3个档次 0(最低)， 1(中等)， 2(高配)
    self.lodLevel = 1
    local value = UserDataManager.local_data:getLocalDataByKey("picture_quality",-1);
    self.init_lodlevel = UserDataManager.local_data:getLocalDataByKey("init_picture_quality",0);
    if value >= 0 then
        --说明本地没有记录LOD值
        if value >= 3 then
            value = 1;
        end
        self.lodLevel = value;
    else
        self:getLodLevel(total_num);
    end
    self.lodLevel_original = self.lodLevel
    self.scaleWidth = 0;
    self.scaleHeight = 0;

    local hfr = UserDataManager.local_data:getLocalDataByKey("hfr",1)
    if hfr == 1 then
        CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(60);
    else
        CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(30);
    end
    
    --抗锯齿
    local antiAliasing = UserDataManager.local_data:getLocalDataByKey("phone_antiAliasing",0)
    CS.wt.framework.AssetLoaderHelper.Inst:SetQuailty(antiAliasing);
    
    self:initLODLevel()

    UserDataManager.local_data:setLocalDataByKey("gameFPS",1)

    Logger.log( "<color=#ff9900>".." 手机处理器 cpu ~~~ "..tostring(self.cpu).."</color>");
    Logger.log( "<color=#ff9900>".." 内存 ram ~~~ "..tostring(self.ram) .. " ; self.lodLevel = " .. tostring(self.lodLevel).."</color>");
end

--初始化LOD等级
function M:initLODLevel()
    --是否显示效果
    local effectShow = UserDataManager.local_data:getLocalDataByKey("effectShow",1)
    CS.wt.framework.AssetLoaderHelper.Inst:ShowEffect(effectShow==1);
    local is_auto_setting = UserDataManager.local_data:getLocalDataByKey("is_auto_setting",-1)
    if is_auto_setting == 1 then
        --自定义等级
        --设置描边  0:关闭  1:开启
        local stroke = UserDataManager.local_data:getLocalDataByKey("stroke",1)
        --设置阴影  0:关闭  1:开启
        -- 200 初始渲染 描边 阴影  
        -- 150 初始渲染 描边 圆圈
        -- 100 初始渲染 圆圈	
        local shadow = UserDataManager.local_data:getLocalDataByKey("shadow",1)
        if stroke == 1 then
            if shadow == 1 then
                CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(2);
            else
                CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(1);
            end
        else
            CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(0);
        end

        if shadow == 1 then
            CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(2);
        else
            if stroke == 1 then
                CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(1);
            else
                CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(0);
            end
        end

        --设置高帧率(60帧)  
        -- 0:关闭  1:开启
        local hfr = UserDataManager.local_data:getLocalDataByKey("hfr",1)
        if hfr == 1 then
            CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(60);
        else
            CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(30);
        end

        --设置分辨率 0,1,2
        local power = UserDataManager.local_data:getLocalDataByKey("power",1)
        self:setPower(power)
        --CS.wt.framework.AssetLoaderHelper.Inst:SetScreenSize(power);

        --设置场景质量 0,1,2
        local sceneLod = UserDataManager.local_data:getLocalDataByKey("sceneLod",1)
        CS.wt.framework.AssetLoaderHelper.Inst:SetSceneLOD(sceneLod);

        self.sceneLod = sceneLod;
        
        --设置特效质量 0,1,2
        local effectLod = UserDataManager.local_data:getLocalDataByKey("effectLod",1)
        CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(effectLod);
    else
        self:setLodLevel(self.lodLevel);
    end
    UserDataManager.local_data:setLocalDataByKey("picture_quality",self.lodLevel)
    self.m_isShowUiFx = self.lodLevel ~= 0
end

--记录当前的lod等级
function M:recordLodLevel()
    self.lodLevel_original = self.lodLevel
end

--设置分辨率 0,1,2
function M:setPower(value)
    if value == 0 then
        self:setRealPower(1024,576)
    elseif value == 1 then
        self:setRealPower(1280,720)
    elseif value == 2 then
        self:setRealPower(1536,864)
    end
end


--设备宽高 de_width， de_height
function M:setRealPower( de_width, de_height )
    local width = CS.UnityEngine.Screen.currentResolution.width;
    local height = CS.UnityEngine.Screen.currentResolution.height;
    local designWidth = de_width;
    local designHeight = de_height;
    local s1 = designWidth / designHeight;
    local s2 = width / height;
    if s1 < s2 then
        designWidth = math.floor(designHeight * s2);
    elseif s1 > s2 then
        designHeight = math.floor(designWidth / s2);
    end
    CS.UnityEngine.Screen.SetResolution(designWidth,designHeight,true);
end


--强制修改lod等级
function M:setLodLevel(level, force)
    self.lodLevel = level
    CS.wt.framework.AssetLoaderHelper.Inst:SetLodLevel(self.lodLevel);
    --特效质量
    CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(self.lodLevel);
    --场景质量
    CS.wt.framework.AssetLoaderHelper.Inst:SetSceneLOD(self.lodLevel);
    
    self.sceneLod = self.lodLevel;
    --分辨率
    self:setPower(self.lodLevel)
    --ShaderLod等级 描边 阴影
    CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(self.lodLevel);
    
    self.m_isShowUiFx = self.lodLevel ~= 0
end

function M:setShaderLOD(level)
    CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(level);
end

--还原lod设置
function M:resetLodLevel()
    local curStroke = UserDataManager.local_data:getLocalDataByKey("stroke",1)
    local curShadow =  UserDataManager.local_data:getLocalDataByKey("shadow",0)
    if  curShadow == 1 and curStroke == 1 then
        CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(2);
    elseif curStroke == 1 then
        CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(1);
    else
        CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(0);
    end

    local curEffect = UserDataManager.local_data:getLocalDataByKey("effectLod",self.lodLevel_original)
    if  CS.wt.framework.AssetLoaderHelper.Inst:GetEffectLODLevel() ~= curEffect then
        CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(curEffect);
    end
    end

function M:getCpuName()
    return self.cpu;
end


function M:getRam()
    return self.ram;
end


function M:getString()
    return self.cpu_type.." - "..self.cpu_score_num.." - "..self.ram.." - "..self.ram_score_num;
end


function M:getLodLevel( score )
    local sdk_gpm = 1
    if SDKUtil.is_gmsdk then
        SDKUtil:callCSFuncByName(
            "getGraphicLevel", 
            {},
            function(rst)
                local level = rst.level
                -- 0 1 2 3 4 5 6 7
                if level >= 4 then
                    sdk_gpm = 2
                else
                    sdk_gpm = 1
                end
                Logger.logAlways(" 字节返回 LOD 等级 "..sdk_gpm )
                self.init_lodlevel = sdk_gpm;
                self.lodLevel = sdk_gpm;
                UserDataManager.local_data:setLocalDataByKey("init_picture_quality",self.init_lodlevel);
                self:initLODLevel();
            end)
    end
end


function M:getSceneLod()
    return self.sceneLod;
end


--获取lod字符串
function M:getLodKey()
    if CS.wt.framework.AssetLoaderHelper.Inst.isUseBundle then
        if self.lodLevel == 0 then
            return "_lod0";
        elseif self.lodLevel == 1 then
            return "_lod1";
        else
            return "";
        end
        return "";
    end
    return "";
end

function M:isShowUiFx()
    return self.m_isShowUiFx
end

--cpu分数
function M:cpuScore( cpu )
    local item = self.cpu_score[tostring(cpu)]
    if item ~= nil then
        return tonumber(item.score)
    else
        return 5;
    end
end


--内存分数
function M:ramScore( ram )
    if GameUtil:getpPlatform() == "Android" then
        if ram < 4096 then
            return 0;
        end
        if ram < 6144 then
            return 50;
        end
        return 100;
    elseif GameUtil:getpPlatform() == "Ios" then
        if ram < 2048 then
            return 0;
        end
        if ram < 3072 then
            return 50;
        end
        return 100;
    end
    return 100;
end

return M
