---@class ArenaAdvanceView:OOPopBase
---@field m_model ArenaAdvanceModel
local M=class("ArenaAdvanceView",LikeOO.OOPopBase)


M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "Arena/ArenaPeak/ArenaAdvancePop"

function M:onEnter()
    local lan_index=self.m_model.match_type+59
    local lan_key="arena_str_00"..lan_index
    self:setTextByLanKey("main_node_tips_text",lan_key)
    self:setTextByLanKey("later_btn_text","arena_str_0043")
    self:setTextByLanKey("advance_btn_text","wlsh_text_0014")
    self:setTextByLanKey("abadon_btn_text","arena_str_0044")

    self:setTextByLanKey("banXuan_text","arena_str_0045")
    self:setTextByLanKey("new_limit_text","arena_str_0046")

    --人，黄，玄，地，天12345
    self.race_icon={
        [1]={name_icon="ljsz_zfls_name1",badge_icon="ljsz_zfls_badge_ren"},
        [2]={name_icon="ljsz_zfls_name2",badge_icon="ljsz_zfls_badge_huang"},
        [3]={name_icon="ljsz_zfls_name3",badge_icon="ljsz_zfls_badge_xuan"},
        [4]={name_icon="ljsz_zfls_name4",badge_icon="ljsz_zfls_badge_di"},
        [5]={name_icon="ljsz_zfls_name5",badge_icon="ljsz_zfls_badge_tian"},
    }

    --晋升效果类型
    self.PROMOTION_EFFECT_TYPE={
        daoju=1,
        liansaiguize=2,
        ban=3,
        multeam=4
    }

    if self.m_model.promote_flag==2 then --晋级
        self:setObjectVisible("main_node",true)
        self:initMainNode(self.m_model.match_type+1)
    elseif self.m_model.promote_flag==4 then--失败晋级
        self:setObjectVisible("failure_node",true)
        self:setObjectVisible("common_node",true)
        local str=Language:getTextByKey("arena_str_0065",self.m_model.next_match_name)
        --self:setTextByLanKey("tips_text","arena_str_0065",self.m_model.next_match_name)
        self:setText("failure_node_tips_text",str)
        self:initDuanWei(self.m_model.match_type)
        self.m_control:setOnceTimer(3, function()
            self.m_control:updateMsg(99999)
        end)

    --处理自动晋级的播放动画
    elseif self.m_model.promote_flag==1 then
        self:promote(self.m_model.match_type)
        self.m_control:setOnceTimer(3, function()
            self.m_control:updateMsg(99999)
        end)
    end
end


function M:refreshUI()

end


--放弃晋级保留段位
function M:retain()
    self:setObjectVisible("main_node",false)
    self:setObjectVisible("forfeit_success_node",true)
    self:setObjectVisible("title_img_retain1",true)
    self:initDuanWei(self.m_model.match_type)
    self:setObjectVisible("common_node",true)
end

--晋级
function M:promote(match_type)
    self:setObjectVisible("main_node",false)
    self:setObjectVisible("forfeit_success_node",true)
    self:setObjectVisible("title_img_success",true)
    self:setObjectVisible("common_node",true)
    self:initDuanWei(match_type)
end

function M:initMainNode(next_match_type)
    local icon_str=self.race_icon[next_match_type]
    self:setImg(icon_str.name_icon, ResourceUtil:getLanAtlas(),"main_race_name_icon")
    self:setImg(icon_str.badge_icon,"arena_ui","main_badge_icon")

    self:setObjectVisible("banXuan",self.m_model.ban_num>0)
    self:setObjectVisible("multiTeam_battle",self.m_model.team_num>0)

    self:initPromoteEffectItem(self.PROMOTION_EFFECT_TYPE.daoju,"fulu")
    self:initPromoteEffectItem(self.PROMOTION_EFFECT_TYPE.liansaiguize,"new_limit")
    self:initPromoteEffectItem(self.PROMOTION_EFFECT_TYPE.ban,"banXuan")
    self:initPromoteEffectItem(self.PROMOTION_EFFECT_TYPE.multeam,"multiTeam_battle")

end


function M:initPromoteEffectItem(type,item_obj_name)
    local is_contain,effect_name,id,item_type=self:isContainEffectType(type)
    self:setObjectVisible(item_obj_name,is_contain)

    if is_contain then
        local item_trans=self:findGameObject(item_obj_name).transform
        UIUtil.setText(item_trans,effect_name,"text")

        if type==self.PROMOTION_EFFECT_TYPE.liansaiguize then
            local rule_cfg=ConfigManager:getCfgByName("rise_arena_week_rule")
            local icon_name=rule_cfg[self.m_model.match_type][id].rule_icon
            UIUtil.setImg(item_trans,icon_name,"arena_ui","new_limit_icon")
        elseif type==self.PROMOTION_EFFECT_TYPE.daoju then
            local data={item_type,id,1}
            local trans=UIUtil.findTrans(item_trans,"ItemNode")
            GameUtil:updateItemElement(trans,data,false)
        elseif type==self.PROMOTION_EFFECT_TYPE.multeam then
            local icon_name="arenaAdvance_"..id
            UIUtil.setImg(item_trans,icon_name,"arena_ui","icon")
        end
    end
end

--function M:isContainEffectType(type)
--    local promote_effects=self.m_model.promote_effects
--    for i, effect in pairs(promote_effects) do
--        if effect[3]==type then
--            local effect_name=Language:getTextByKey(effect[1])
--            local id=effect[2]
--            if _type==1 then
--                id=effect[4]
--                return true,effect_name,id,effect[3]
--            end
--            return true,effect_name,id
--        end
--    end
--    return false
--end

function M:isContainEffectType(type)
    local promote_effects=self.m_model.promote_effects
    for i, effect in pairs(promote_effects) do
        local _type=effect[2]
        if _type==type then
            local effect_name=Language:getTextByKey(effect[1])
            local id=effect[3]
            if _type==1 then
                id=effect[4]
                return true,effect_name,id,effect[3]
            end
            return true,effect_name,id
        end
    end
    return false
end

function M:initDuanWei(match_type)
    local icon_str=self.race_icon[match_type]
    self:setImg(icon_str.name_icon, ResourceUtil:getLanAtlas(),"race_name_icon")
    self:setImg(icon_str.badge_icon,"arena_ui","badge_icon")
    self:setObjectVisible("UI_Arena_duawei0"..match_type,true)
    self.m_control:setOnceTimer(0.7, function()
        local badge_icon_img=self:findImage("badge_icon")
        badge_icon_img.enabled=true
    end)
end

return M