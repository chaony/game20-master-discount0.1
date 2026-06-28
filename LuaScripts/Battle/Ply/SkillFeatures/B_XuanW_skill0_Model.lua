--玄武boss skill0
--玄武之躯
--每损失一定血量，会叠加一层强化buf，每层buf会提升防御力和攻击，buf叠加至10、20、50层时，boss都会陷入8秒的虚弱状态
--此时boss的防御力会大幅降低，虚弱状态结束时，boss会获得额外的强化效果
--10层时获得一层相当于200%的自身防御的护盾
--20层时自身将受到物理伤害减少50%
--50层时将受到物理伤害的80%放回给攻击者
---@class B_XuanW_skill0_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_XuanW_skill0_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.ont_count = self:getParam(1) --第一层buf触发层数
    self.bufID_1 = self:getParam(2)  -- 第一层buf
    self.two_count = self:getParam(3)--第二层buf触发层数
    self.bufID_2 = self:getParam(4)  -- 第二层buf
    self.three_count = self:getParam(5) --第三层的层数
    self.bufID_3 = self:getParam(6)  --第三层buf
    
    --所有参与运算的
    --时间 比例 攻击力 血量 都需要转化成定点数
    self.atk_thorns = self:getParam(7) --反伤比例
    self.feebleness_time = self:getParam(8) --虚弱时间
    self.feebleness_buf = self:getParam(9) --虚弱buf
   
    self.maxnum = GlobalTools.base0;
    self.lastNum = GlobalTools.base0;
    -- self.hp = self:getParam(1)
    -- self.atk = self:getParam(2)
    -- self.def = self:getParam(3)
    -- self.bufID_10 = self:getParam(4)
    -- self.bufID_20 = self:getParam(5)
    -- self.killer_atk = self:getParam(6)
    -- self.interval = self:getParam(7)
    -- self.bufID = self:getParam(8)

    self.lat_atk_sum = nil
    self.lat_def_sum = nil
    self.start = false
    self.buf_table = {}
    self.skill_enter = false
    self.lastNum = 0
    table.insert(self.buf_table, 
    {
        count = self.ont_count,
        time = GlobalTools.base0,
        isBuf = false,
        buffId = self.bufID_1,
    })

    table.insert(self.buf_table, 
    {
        count = self.two_count,
        time = GlobalTools.base0,
        isBuf = false,
        buffId = self.bufID_2,
    })

    table.insert(self.buf_table, 
    {
        count = self.three_count,
        time = GlobalTools.base0,
        isBuf = false,
        buffId = self.bufID_3,
    })

    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
    EventDispatcher:registerEvent("bossMaxnum", {self,self.bossMaxnumHandler})
end



function M:bossMaxnumHandler(eventName, data)
    --最大数量
    self.maxnum = data["maxnum"]
    --增加攻击力
    self.addAtk = data["addAtk"]

    for k,v in ipairs(self.buf_table) do
        if self.maxnum >= v.count and v.isBuf == false then
            self:change_count(v)
        end
    end
    --当前的 层数 减去上一次的层数
    local num = self.maxnum - self.lastNum
    if num > 0  then
        local add_atk_fix = GlobalTools:Mul(GlobalTools:ToFix(num), GlobalTools:ToFix(self.addAtk))
        self.player.data.atk:addToAddList(add_atk_fix)
    end
    self.lastNum = self.maxnum
end

function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    local dmgType = data["damageType"]
    if victim ~= nil and victim:equal(self.player) then
        if ply ~= nil and dmgType == 2 and self.buf_table[3].isBuf == true and self.buf_table[3].time <= GlobalTools.base0 then
            local attackData = BattleTool:getBaseAttackData()
            attackData["damage"] = GlobalTools:Mul( dmg , self.atk_thorns )
            attackData["player"] = self.player
            attackData["damageFront"] = GlobalTools.base1;
            attackData["damageLast"] = GlobalTools.base1;
            attackData["angerAir"] = GlobalTools.base0;
            attackData["type"] = 0
            attackData["injureBuf"] = 0
            attackData["damageType"] = 1
            --local wantdata = {}
            --wantdata["damage"] = attackData["damage"]
            --wantdata["suck_value"]  = 0  
            ply:injure( attackData) 
        end

    end
end

function M:update(dt,unsdt)
     M.super.update(self,dt,unsdt)

    if self.skill_enter then
        for k,v in ipairs(self.buf_table) do
            if v.time > 0 then
                v.time = v.time - dt
                if v.time <= 0 then
                    self:change_buf(v)
                end
            end
        end
    end
end

function M:canUse()
    return self.start
end


function M:change_count(bufValue)
    if self:checkLoop() == false then
        if self.player.curSkillConfig ~= nil and self.player.curSkillConfig.anim_name ~= "skill3" then
            self.player.aiEngine.skillConfig = self.skill
            self.player.aiEngine:changeState("attack")
        else
            self.start = true
        end
    end
    bufValue.isBuf = true
    bufValue.time = self.feebleness_time
end

function M:change_buf(bufValue)

    if self:checkLoop() == false then
        self.player.animator:changeState("skill0_end")
        self.start = false
        self.skill_enter = false
        --临时发送销毁特效
        self:dispatchEvent_Local(Battle.EventType.MV_SkillFeaturesModelDestroyEffect)
    end

    if bufValue.buff ~= nil then
        self.player.bufMgr:addBufById(bufValue.buff, self.player)
    end
end

function M:skillStart()
    M.super.skillStart(self)
    --加上虚弱buf
    self.player.bufMgr:addBufById(self.feebleness_buf, self.player)
    self.skill_enter = true
end

function M:checkLoop()
    for k,v in ipairs(self.buf_table) do
        if v.time > 0 then
            return true
        end
    end
    return false
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("bossMaxnum", {self,self.bossMaxnumHandler})
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end

return M