--添加材质求buf 比如无敌金光
---@class BufWorkAddMaterial_View : BufWork_View @
---@field super BufWork_View @BufWork_View
local M = class("BufWorkAddMaterial_View", BufWork_View)

function M:init( buf, model )
    M.super.init(self, buf, model)
    self.type = self.playerBuf_model:checkParam("type", 1);
    self.materName, self.matType = self:selectType()
    self.changeId = 0;
    if IsNull(self.playerBuf.player.luaViewHelper) == false then
        if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD and self.playerBuf.player.camp == -1 then
            return;
        end
        self.changeId = self.playerBuf.player.luaViewHelper:AddMaterial(self.materName,self.matType);
    end
end

function M:stop()
    M.super.stop(self)
    if IsNull(self.playerBuf.player.luaViewHelper) == false then
        if SceneManager.curScene.mode == Battle.BattleGlobalConfig.BATTLE_MODE.DRAGONSWORD and self.playerBuf.player.camp == -1 then
            return;
        end
        self.playerBuf.player.luaViewHelper:ResetMaterial(self.changeId);
    end
end


function M:selectType( )
    local mater_name = "nil"
    local matType = 1
    if self.type == 1 then --嵩山冰冻材质
        mater_name = "IceMat"
    elseif self.type == 2 then --少林skill1 材质 （黄色）
        mater_name = "ShaoL_Skill1"
    elseif self.type == 3 then --天策skill3 材质（红色）
        mater_name = "TianC_Skill3"
    elseif self.type == 4 then --合欢skill3 己方材质 （蓝色）
        mater_name = "CopyFiles_w_heh_skill3_born1"
        matType = 3
    elseif self.type == 5 then --合欢skill3 敌人材质（红色）
        mater_name = "CopyFiles_w_heh_skill3_born2"
        matType= 3
    elseif self.type == 6 then --风之痕skill2 己方材质（透明蓝）
        mater_name = "Fx_FengZH_Skill2_Buff_001"
        matType= 3
    end
    return mater_name,matType
end

return M