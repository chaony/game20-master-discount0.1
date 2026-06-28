--鬼谷 skill3被动
--开局将我方后排血量最多的队友和敌人后排血量最少的敌人互换位置
---@class W_GuiG_skill2_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_GuiG_skill2_1_View", SkillFeatures_View)

function M:init( player, skill, model )
    M.super.init(self, player, skill, model );
    self:addEventListener_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_Line, {self,self.MV_W_GuiG_skill2_1_Line});
    self:addEventListener_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_PlayerEffect, {self,self.MV_W_GuiG_skill2_1_PlayerEffect});
    self:addEventListener_Local(Battle.SkillEventType.MV_W_GuiG_skill2_1_DestroyLineEffect, {self,self.MV_W_GuiG_skill2_1_DestroyLineEffect});
end

function M:MV_W_GuiG_skill2_1_DestroyLineEffect( eventName, data )
    self:destroyLineEffect()
end

--鬼谷连线
function M:MV_W_GuiG_skill2_1_Line( eventName, data )
    self:line();
end

--鬼谷播放特效
function M:MV_W_GuiG_skill2_1_PlayerEffect( eventName, data )
    self:PlayerEffectOnPoint(data.pos, data.effectName);
end


function M:PlayerEffectOnPoint(pos, effectName)
    if pos ~= nil then
        local effectData = {}
        effectData["prefab"] = effectName
        effectData["autodestoryTime"] = 3
        effectData["isPutUpInParent"] = false
        effectData["parent"] = "nil"
        effectData["directionType"] = "body"
        effectData["scaleType"] = "world"
        effectData["positionType"] = "worldFix"

        local prefabTrans = {}
        prefabTrans["useUserSet"] = true

        prefabTrans["position"] = {
            [1] = GlobalTools:FixToCommon(pos.x),
            [2] = GlobalTools:FixToCommon(pos.y),
            [3] = GlobalTools:FixToCommon(pos.z),
        }
        prefabTrans["rotation"] = {
            [1] = 0,
            [2] = 180,
            [3] = 0,
        }
        prefabTrans["scale"] = {
            [1] = 1,
            [2] = 1,
            [3] = 1,
        }
        effectData["prefabTrans"] = prefabTrans

        local effectItem = self.player:playEffect(effectData,self.player, self.player)
        return effectItem
    end
end


function M:line()
    if IsNull(self.player.luaViewHelper) == false then
        local prefabName = "W_GuiG3_Skill2_Line_001"
        prefabName = string.gsub(prefabName, self.player.default_plyType, self.player.plyType)
        self.lineEffect = self.player.luaViewHelper.m_ui:CreatePlayerLine( self.player.prefabRoot, prefabName)
        --C#组件
        self.luaViewHelper = self.lineEffect.m_owner;
        self.helperArr = LuaCSharpArr.New(12)
        local CSharpAccess = self.helperArr:GetCSharpAccess()
        if not IsNull(self.luaViewHelper) then
            self.luaViewHelper:PinTable(CSharpAccess)
            self:refreshLine()
        end
    end
end


function M:refreshLine()
    if self.lineEffect ~= nil then
        if self.model.enemyPos_target ~= nil then
            local enemy_view = self:getPlayerView(self.model.enemyPos_target)
            if enemy_view ~= nil and enemy_view.head ~= nil then
                self.helperArr[1] = enemy_view.head.position.x
                self.helperArr[2] = enemy_view.head.position.y + 0.5
                self.helperArr[3] = enemy_view.head.position.z
            end
        end
        if self.model.friendPos_target ~= nil then
            local friend_view = self:getPlayerView(self.model.friendPos_target)
            if friend_view ~= nil and friend_view.head ~= nil then
                self.helperArr[4] = friend_view.head.position.x
                self.helperArr[5] = friend_view.head.position.y + 0.5
                self.helperArr[6] = friend_view.head.position.z
            end
        end
    end
end

--更新调用
function M:update(dt)
    M.super.update(dt);
    self:refreshLine()
end

--销毁 线特效
function M:destroyLineEffect()
    if self.lineEffect ~= nil then
        self.lineEffect:Destroy();
        self.lineEffect = nil;
    end
end

--技能销毁调用
function M:destroy()
    self:destroyLineEffect()
end


return M