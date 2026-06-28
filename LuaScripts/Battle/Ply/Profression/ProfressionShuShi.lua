--- 术士
--- 每次释放必杀后，永久增加3%内伤。
--- 每次释放必杀后，永久增加5%内伤
--- 每次释放必杀后，永久增加5%内伤，且同时获得一个护盾，免疫一次技能伤害。
---@class ProfressionShuShi : Profression
---@field super Profression
local M = class("ProfressionShuShi", Profression)

function M:init(player,data)
    M.super.init(self,player,data)
    --永久增加3%内伤
    self.addmagicdamage = self:getParam(1);
    --护盾免疫buf
    self.sheildBuf = self:getParam(2);
    --最大叠加次数
    self.maxCount = self:getParam(3);
    
    self.curCount = 0
    self.hasSheildBuf = false;

    --Logger.logError(" 初始化术士技能 ")
    --Logger.logError(" self.addmagicdamage "..tostring(self.addmagicdamage) )
    --Logger.logError(" self.sheildBuf "..tostring(self.sheildBuf))
    --Logger.logError(" self.maxCount "..tostring(self.maxCount))
end

--游戏开始
function M:gameStart()
    self.curCount = self.maxCount
    --是否含有护盾
    self.hasSheildBuf = false;
end

--增加属性
function M:addProperty()
    if self.curCount > 0 then
        local rate = self.addmagicdamage
        local cur_magicdamage = self.player.data.magicdamage:getValue();
        local next_magicdamage = GlobalTools:Mul(cur_magicdamage, rate)
        --Logger.logError(" 增加 内伤增伤 ~~~~~~~~~~~~~~ "..next_magicdamage )
        --内伤增伤
        self.player.data.magicdamage:addToAddList(next_magicdamage)
        --获得一个护盾，免疫一次技能伤害
        if self.sheildBuf ~= nil then
            --加入护盾
            self.hasSheildBuf = true;
            --Logger.logError(" 增加护盾buf ~~~~~~~~~~~~~~ ")
            self.player.bufMgr:addBufById( self.sheildBuf, self.player)
        end
        self.curCount = self.curCount - 1;
    end
end


function M:BeHitOver()
    --是否含有护盾
    if self.hasSheildBuf then
        --免疫一次伤害
        if self.sheildBuf ~= nil then
            --Logger.logError(" 移除护盾buf  ~~~~~~~~~~~~~~ ")
            self.player.bufMgr:removeBufById( self.sheildBuf, true)
        end
    end
end

--大招结束之后
function M:skill3Over()
    self:addProperty();
end

return M;