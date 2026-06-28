--角色的专属装备
--衡山 战斗中 没击杀一个敌人，衡山便获得一层强化效果，该效果最多叠加3层，且会一直持续到战斗结束，
--1层时 衡山获得20%的攻击力提升 2层时 衡山额外获得30%的攻速提升 3层时 衡山额外获得20%的暴击率提升
---@class W_HShan_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_HShan_Trait0", PlayerTrait)

M.critrate = 0
M.buf_table = {}
M.bufID_1 = 0
M.bufID_2 = 0
M.bufID_3 = 0

M.maxnum = 0

M.count = 0

function M:init()
    M.super.init(self)
    self.maxnum = self:getValue(1)
    self.bufID_1 = self:getValue(2)  
    self.bufID_2 = self:getValue(3)
    self.bufID_3 = self:getValue(4)
    self.count = 0
    table.insert(self.buf_table, 
    {
        count = 1,
        isBuf = false,
        buffId = self.bufID_1,
    })

    table.insert(self.buf_table, 
    {
        count = 2,
        isBuf = false,
        buffId = self.bufID_2,
    })

    table.insert(self.buf_table, 
    {
        count = 3,
        isBuf = false,
        buffId = self.bufID_3,
    })
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("PlayerDead", {self,self.playerDeadHandler})
end


function M:playerDeadHandler(eventName, data)
	local ply = data["data"]
	if ply ~= nil and ply:equal(self.player) == false then
	    if ply.killer ~= nil and ply.killer:equal(self.player) then
	    	self.count = self.count + 1
	    	if self.count >= self.maxnum then
	    		self.count = self.maxnum
	    	end
	    	for k,v in ipairs(self.buf_table) do
		        if self.count == v.count and v.isBuf == false then
		        	self:change_count(v)
		        end
    		end
	    end
	end
    
end

function M:change_count(bufValue)

    if bufValue.buffId ~= nil then
    	bufValue.isBuf = true
        self.player.bufMgr:addBufById(bufValue.buffId, self.player)
    end
    
end


function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.playerDeadHandler})
    
    M.super.destroy(self)
end

return M