---@class PrivilegeView:OOPopBase
local M=class("PrivilegeView",LikeOO.OOPopBase)

M.m_uiName="Xiakedao/Privilege"
M.m_size_type=1
M.m_iphoneXAdapter=true

function M:onCreate()

end

function M:onEnter()

    self.m_gray_material = self:findText("material_node").material
    self.left_buy_btn_img = self:findImage("left_buy_btn")
    self.right_buy_btn_img = self:findImage("right_buy_btn")

    self:setTextByLanKey("close_title_text", "new_str_1114")
    self:setTextByLanKey("buyTip_text", "new_str_1129")

    local visitor_cfg=ConfigManager:getCfgByName("hero_isle_visitor")[self.m_model.season]
    if visitor_cfg==nil then
        visitor_cfg=ConfigManager:getCfgByName("hero_isle_visitor")[-1]
    end

    self:setTextByLanKey("discount_text", "secret_store_text6",visitor_cfg.discount*10)
    --self:setTextByLanKey("price_text", GameUtil:getMoneyTypeNum(cfg.price_first))
    --self:setTextByLanKey("price_text", "secret_store_text6",visitor_cfg.discount*10)
    LuaBehaviourUtil.setTextByLanKey(self.m_luaBehaviour, "price_text", GameUtil:getMoneyTypeNum(visitor_cfg.price))
    self:setObjectVisible("left_discount",visitor_cfg.discount<1)

    local privilege_cfg=ConfigManager:getCfgByName("hero_isle_privilege")[self.m_model.season]
    if privilege_cfg==nil then
        privilege_cfg=ConfigManager:getCfgByName("hero_isle_privilege")[-1]
    end

    self:setTextByLanKey("buyTip_right_text", "secret_store_text6",privilege_cfg.discount*10)
    LuaBehaviourUtil.setTextByLanKey(self.m_luaBehaviour, "price_right_text", GameUtil:getMoneyTypeNum(privilege_cfg.price))
    LuaBehaviourUtil.setTextByLanKey(self.m_luaBehaviour, "originalPrice_text", GameUtil:getMoneyTypeNum(privilege_cfg.price/privilege_cfg.discount))
    self:setObjectVisible("right_discount",privilege_cfg.discount<1)
    self:setObjectVisible("originalPrice",privilege_cfg.discount<1)

    self:setTextByLanKey("left_item_text",privilege_cfg.desc_left)
    self:setTextByLanKey("right_item_text",privilege_cfg.desc_right)
    --local text=self:setTextByLanKey("right_item_text",privilege_cfg.desc_right)
    --local str=text.text
    --str = string.gsub(str, "\n","\\n");
    --text.text=str

    local rewardNode=self:findGameObject("rewardNode")
    for i = 1, #privilege_cfg.reward do
        local itemNode = GameUtil:createItemElement(privilege_cfg.reward[i], true, true)
        itemNode.transform.localScale=Vector3(1.5,1.5,1.5)
        itemNode.transform:SetParent(rewardNode.transform, false)

        --local itemLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
        --if itemLuaBehaviour then
        --    if data == -1 or data > 0 and end_time > 0   then
        --        if index == 2 then
        --            LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", UserDataManager:subRewardReceived(2) == true)
        --        else
        --            LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", true)
        --        end
        --    else
        --        LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", false)
        --    end
        --end
    end
    self:refreshUI()
end

function M:refreshUI()
    self:refreshSP()
    self:refreshBuyBtnState()
end

function M:refreshSP()
    local cfg = UserDataManager.hero_data:getHeroConfigByCid(self.m_model.visitor)
    self:setTextByLanKey("class_name",cfg.class)
    self:setTextByLanKey("hero_name",cfg.name)

    local race = GlobalConfig.TYPE_HERO_RACE[cfg.race].big_race_icon --英雄种族icon
    self:setImg(race, ResourceUtil:getLanAtlas(), "hero_race")

    local FRAME_QUA = GlobalConfig.QUALITY_FRAME[cfg.max_evo]
    self:setImg(GameUtil:get_lineframename(cfg.Ex_hero,cfg.max_evo), "common_ui", "hero_evo")

    local icon=cfg.hero_spine
    --icon="hero_0309_SkeletonData"
    local play_img = self:findGameObject("hero_sk")
    if self.m_hero_spine == nil then
        self.m_hero_spine = GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. icon, "idle", 0, true)
    end
end

function M:refreshBuyBtnState()
    if self.m_model.privilege_bought==1 then
        self:setRightBtnGray()
    end
    if self.m_model.visitor_bought==1 then
        self:setLeftBtnGray()
    end
end

function M:setLeftBtnGray()
    self.left_buy_btn_img.material=self.m_gray_material
    self.left_buy_btn_img.color=Color(195/255,195/255,195/255)

end

function M:setRightBtnGray()
    self.right_buy_btn_img.material=self.m_gray_material
    self.right_buy_btn_img.color=Color(195/255,195/255,195/255)
end


function M:updateTime()
    if self.m_model.m_end_ts ~= nil then
        local time_end = self.m_model.m_end_ts - UserDataManager:getServerTime()
        self:setTextByLanKey("overtime_text","new_str_1130",GameUtil:formatTimeBySecond(time_end))
        --self:setText("countdown", GameUtil:formatTimeBySecond(time_end))
        if time_end <= 0 then
            self:updateMsg(99999)
        end
    end
end

return M