--玄武boss skill2
--卸甲 进入防御状态，期间自己无法攻击，并在身体周围形成一层护盾，护盾可抵御200%boss攻击力的伤害
--若防御姿态结束时boss的护盾未被打破，则护盾会爆炸，对周围造成伤害
---@class B_XuanW_skill2_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_XuanW_skill2_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.dis = self:getParam(1)
    self.atk = self:getParam(2)
    EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end
 
function M:spawn()
    M.super.spawn(self)
end


--技能释放
function M:skillStart()
    --self:setMaterial(1)
end

--技能结束
function M:skillEnd()
    --self:setMaterial(0)
    -- if self.effect ~= nil then
    --     ResourceUtil:ReturnItem(self.player.footEffect)
    -- end
end

function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"] 
    if isStart == false and buf ~= nil then
        local skillConfig = self.player.curSkillConfig
        if buf.value > GlobalTools.base0 and skillConfig ~= nil and skillConfig.anim_name == "skill2" then
            TimeTools:delayTime( GlobalTools.base0_5,
                function()
                    local attackData = BattleTool:getBaseAttackData()
                    attackData["damage"] = self.player.data.atk:getValue()
                    attackData["player"] = self.player
                    attackData["damageFront"] = self.atk
                    attackData["damageLast"] = GlobalTools.base1 --1
                    attackData["angerAir"] = GlobalTools.base0 --0
                    attackData["type"] = 0
                    attackData["injureBuf"] = 0
                    attackData["damageType"] = 1
                    attackData["skillConfig"] = self.skill
                    --local wantdata = {}
                    --wantdata["damage"] = attackData["damage"]
                    --wantdata["suck_value"]  = 0   
                    local enemys = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
                    for i = enemys.Count, 1, -1 do
                        local enemy_player = enemys:get(i-1)
                        local distance = GlobalTools:Distance(self.player.position, enemy_player.position)
                        if distance <= GlobalTools:ToFix2(self.dis)  then
                            enemy_player:injure(attackData)
                        end
                    end  
            end)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
end






return M