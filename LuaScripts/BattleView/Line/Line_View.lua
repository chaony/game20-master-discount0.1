--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-04-30 14:31:55
]]
---@class Line_View : ViewBase @
---@field super ViewBase @ViewBase
local M = class("Line_View",Battle.ViewBase)

function M:init( model, player, effectPlayer)
    self.m_model = model;
    self.player = player
    self.effectPlayer = self.player;
    
    if effectPlayer ~= nil then
        self.effectPlayer = effectPlayer;
    end
    
    self.data = self.m_model:get_data();
    local target_model = self.m_model:get_target();
    
    --开始点
    local orgin_fix_pos = self.m_model:get_origin();
    self.origin = Vector3(0,0,0);
    self.origin.x = GlobalTools:ToFloat(orgin_fix_pos.x);
    self.origin.y = GlobalTools:ToFloat(orgin_fix_pos.y);
    self.origin.z = GlobalTools:ToFloat(orgin_fix_pos.z);
    
    --结束点
    local destination_fix_pos = self.m_model:get_destination();
    self.destination = Vector3(0,0,0);
    self.destination.x = GlobalTools:ToFloat(destination_fix_pos.x);
    self.destination.y = GlobalTools:ToFloat(destination_fix_pos.y);
    self.destination.z = GlobalTools:ToFloat(destination_fix_pos.z);
    
    local prefab = self.data["prefab"]
    if self.player ~= nil then
        prefab = self.player:getNameByPlyType(prefab)
    end
    self.hitEffect = self.data["hitEffect"]

    --连接资源名称
    self.originParentName = self.data["originParent"]
    if self.player.tranformHelper ~= nil then
        self.originParent = self.player.tranformHelper:FindObj(self.player.tran, self.originParentName)
    end

    if target_model ~= nil then
        self.target = self.player.plyMgr:GetPlayerViewByModel(target_model);
        --结束资源名称
        self.destinationParentName = self.data["destinationParent"]
        if self.target ~= nil and IsNull(self.target.tranformHelper) == false then
            self.destinationParent = self.target.tranformHelper:FindObj(self.target.tran, self.destinationParentName)
        end
    end
    
    --创建了一条线
    if prefab ~= nil and self.player.luaViewHelper ~= nil then
       self.player_line = self.player.luaViewHelper.m_ui:CreatePlayerLine( self.effectPlayer.prefabRoot, prefab )
    end

    if IsNull(self.player_line) == false then
        --C#组件
        self.luaViewHelper = self.player_line.m_owner;
        self.helperArr = LuaCSharpArr.New(12)
        local CSharpAccess = self.helperArr:GetCSharpAccess()
        if IsNull(self.luaViewHelper) == false then
            self.luaViewHelper:PinTable(CSharpAccess)
        end
    end
    
    --当前结束位置 type == 1
    self.curEndPos = Vector3(0,0,0);
    --自己开始移动位置 type == 2
    self.selfStartMovePos = Vector3(0,0,0);
    --自己移动位置 type == 3
    self.selfMovePos = Vector3(0,0,0);
    --敌人开始移动位置 type == 4
    self.enemyStartMovePos = Vector3(0,0,0);
    --敌人移动位置 type == 5
    self.enemyMovePos = Vector3(0,0,0);
    --根位置
    self.sourcePosition = Vector3(0,0,0)
    --结束位置
    self.endPosition = Vector3(0,0,0)
    
    --同步线的位置
    self:addEventListener_Local(Battle.EventType.MV_LineModelSyncPosition, {self,self.MV_LineModelSyncPosition})
    --同步更新函数
    self:addEventListener_Local(Battle.EventType.MV_LineModelSyncUpdate, {self,self.MV_LineModelSyncUpdate})
    --线销毁
    self:addEventListener_Local(Battle.EventType.MV_LineModelDestroy, {self,self.MV_LineModelDestroy})
end

--线销毁
function M:MV_LineModelDestroy(eventName, data)
    self:destroy();
end


--同步线的更新函数
function M:MV_LineModelSyncUpdate(eventName, data)
    --更新Source位置
    self:update();
end

--同步位置信息
function M:MV_LineModelSyncPosition( eventName, data )
    if data.pos ~= nil then
        local pos_x = GlobalTools:ToFloat(data.pos.x);
        local pos_y = GlobalTools:ToFloat(data.pos.y);
        local pos_z = GlobalTools:ToFloat(data.pos.z);
        if data.type == 1 then
            self.curEndPos.x = pos_x;
            self.curEndPos.y = pos_y;
            self.curEndPos.z = pos_z;
        elseif data.type == 2 then
            self.selfStartMovePos.x = pos_x;
            self.selfStartMovePos.y = pos_y;
            self.selfStartMovePos.z = pos_z;
        elseif data.type == 3 then
            self.selfMovePos.x = pos_x;
            self.selfMovePos.y = pos_y;
            self.selfMovePos.z = pos_z;
        elseif data.type == 4 then
            self.enemyStartMovePos.x = pos_x;
            self.enemyStartMovePos.y = pos_y;
            self.enemyStartMovePos.z = pos_z;
        elseif data.type == 5 then
            self.enemyMovePos.x = pos_x;
            self.enemyMovePos.y = pos_y;
            self.enemyMovePos.z = pos_z;
        elseif data.type == 6 then
            self.sourcePosition.x = pos_x;
            self.sourcePosition.y = pos_y;
            self.sourcePosition.z = pos_z;
        elseif data.type == 7 then
            self.endPosition.x = pos_x;
            self.endPosition.y = pos_y;
            self.endPosition.z = pos_z;
        end
    end
end


--获取根位置
function M:getSourcePos()
    if not IsNull(self.originParent) then
        return self.originParent.transform.position
    end
    return nil
end

--获取结束位置
function M:getEndPos()
    if not IsNull(self.destinationParent) then
        return self.destinationParent.transform.position
    end
    return nil;
end


function M:fireEnd()
    if self.hitEffect ~= nil and self.hitEffect ~= "nil" and self.hitEffect ~= "" then
        local effectData = {}
        effectData["prefab"] = self.hitEffect
        if self.target.spine ~= nil then
            effectData["parent"] = self.target.spine.name
        end
        self.target:playInjureEffect(effectData, self.target,  self.player);
    end
end


--攻击
function M:update()
    if self.curEndPos ~= nil and self.sourcePosition ~= nil and self.helperArr ~= nil then
        local view_curEndPos = self:getEndPos();
        if view_curEndPos ~= nil then
            self.helperArr[1] = view_curEndPos.x;
            self.helperArr[2] = view_curEndPos.y;
            self.helperArr[3] = view_curEndPos.z;
        else
            self.helperArr[1] = self.curEndPos.x;
            self.helperArr[2] = self.curEndPos.y;
            self.helperArr[3] = self.curEndPos.z;
        end

        local view_sourcePos = self:getSourcePos();
        if view_sourcePos ~= nil then
            self.helperArr[4] = view_sourcePos.x;
            self.helperArr[5] = view_sourcePos.y;
            self.helperArr[6] = view_sourcePos.z;
        else
            self.helperArr[4] = self.sourcePosition.x;
            self.helperArr[5] = self.sourcePosition.y;
            self.helperArr[6] = self.sourcePosition.z;    
        end
    end
end

--销毁连线
function M:destroy()
    if self.player_line ~= nil then
        self.player_line:Destroy();
        self.player_line = nil;
    end
end

return M