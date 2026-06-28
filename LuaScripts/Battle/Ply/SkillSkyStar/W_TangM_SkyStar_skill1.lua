---
--- 蛊神决：
--- 改：敌方侠客每受到一次中毒效果，唐门的攻速提高5点，伤害提升2%(最多叠加10层)
---
local M = class("W_TangM_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --增加攻速1
    self.addSpeedValue = self:getParam(1)
    --最大叠加层数
    self.maxSpeedFloor = self:getParam(2)
    --伤害提升2%
    self.damageBuf = self:getParam(3)

    self.checkCurTime = 0
    self.checkTime = 0;
end

-- 游戏开始时
function M:gameStart()
    --2秒检测一次
    self.checkTime = GlobalTools.base2;
    self.checkCurTime = self.checkTime
    self.curFloor = 0
end

-- 计算
function M:update( time )
    if self.checkCurTime > 0 then
        self.checkCurTime = self.checkCurTime - time;
        if self.checkCurTime <= 0 then
            if self.curFloor <= self.maxSpeedFloor then
                local enemys = self.player.plyMgr:getPlayers(-self.player.camp)
                for i = 1, enemys.Count do
                    local enemy = enemys:get(i - 1)
                    local buff = enemy.bufMgr:findBufByTag("zhongdu")
                    for i, v in ipairs(buff) do
                        --增加攻速
                        self.player.data.haste:addToAddList(self.addSpeedValue)
                        --增加伤害
                        self.player.bufMgr:addBufById(self.damageBuf, self.player)
                        self.curFloor = self.curFloor + 1;
                    end
                end
                self.checkCurTime = self.checkTime;
            end
        end
    end
end


return M;