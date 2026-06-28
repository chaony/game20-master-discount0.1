---@class AdditionSupportSystemControl:OOControlBase
---@field m_model AdditionSupportSystemModel
---@field m_view  AdditionSupportSystemView
local M = class("AdditionSupportSystemControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        --覆盖gameinfo那边数据，实时更新，在布阵里头用
        --UserDataManager.help_heros=self.m_model.m_data
        self:closeView()
    elseif msg == "update_hero" then
        local params={
            race=self.m_model.m_race_id,
            pos=self.m_model.m_curOpPos,
            h_oid=data.selected_oid
        }
        local calback=function(data)
            --self.m_view:updateCurOp(data.hero_on)
            self.m_model:getNetData("hero_help_index",nil,function(data)
                self.m_model:updateData(data)
                self.m_view:refreshUI()
            end)

        end
        self.m_model:getNetData("hero_help_help",params,calback)
    elseif msg == "tab_btn" then
        self.m_model:switchTag(data.index)
        self.m_view:switchTagView()
    elseif msg == "guide_btn" then
        --快速导航
        self:openView("WorldMap.WorldMapGuide", { pop_from_func_id = -1 })
    elseif msg == "explain_btn" then
        local help_base_cfg=ConfigManager:getCfgByName("hero_help_base")
        self:openView("Pops.CommonHelpPop", { title = Language:getTextByKey("supportSys_str_0004"), content = Language:getTextByKey(help_base_cfg.desc) })
    elseif msg == "support_num_text" then
        if self.m_model.unlockNum+1<=self.m_model.unlcokMaxNum then
            local hero_help_pos_cfg=ConfigManager:getCfgByName("hero_help_pos")
            local stage=hero_help_pos_cfg[self.m_model.unlockNum+1]
            --local stage=2701
            local chapter,section_frac=math.modf(stage/100)
            local section=math.floor(section_frac*100)
            GameUtil:lookInfoTips(self, {click_transform =self.m_view.support_num_text_trans,
                                         msg =Language:getTextByKey("supportSys_str_0006",chapter,section)})
        end

    end
end



function M:destroy()
    M.super.destroy(self)
end


return M
