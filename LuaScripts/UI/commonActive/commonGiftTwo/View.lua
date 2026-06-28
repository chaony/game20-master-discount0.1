local M = class("commonGiftTwoView",LikeOO.OOPopBase)

M.m_uiName = "commonActive/commonGiftTwo"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    local attr_mode = 13
    if self.m_model.is_tokens == true then
        attr_mode = 20
    end
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
    --RedPointUtil:saveLocalRedPointFreshTime("GuJianQiTanGiftRedDot")
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self.m_gray_image = self:findImage("hui")
    self.m_scroll_stay_flag = true
    self:setSpine()
    self:setObjectVisible("help_btn",self.m_model.m_is_show_help_btn == 1)
    self:setObjectVisible("day_des_text",self.m_model.m_is_show_gift_tips == 1)
    self:refreshUI()
    RedPointUtil:saveLocalRedPointFreshTime("ChivalryCommonGiftTwoRedDot")
end

function M:refreshUI()
    self:updateLoopScroll()
    self:updateHeroSkinShop()
end

function M:setSpine()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    local reward_data = RewardUtil:getProcessRewardData(hero_skin_cfg.reward[1])
    local skin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({}, reward_data.item_cfg)

    GameUtil:updateSpineLoadSet(self:findGameObject("hero_spine"), "RoleSpine/".. skin_data_cfg.hero_spine, "idle", 0, true)
    if reward_data then
        self:setText("hero_name2", "")
        self:setTextByLanKey("hero_name", string.cutTextForString(Language:getTextByKey(reward_data.item_cfg.name)))
        local race =  GlobalConfig.TYPE_HERO_RACE[reward_data.item_cfg.race]
        self:setImg(race.race_icon, ResourceUtil:getLanAtlas(), "hero_race")
        self:setObjectVisible("hero_name_con", true)
    else
        self:setObjectVisible("hero_name_con", false)
    end
end
function M:updateHeroSkinShop()
    local hero_skin_cfg = self.m_model:getHeroSkinCfg()
    if hero_skin_cfg then
        self:setTextByLanKey("right_btn_text2", GameUtil:getMoneyTypeNum(hero_skin_cfg.price_old))
        self:setTextByLanKey("per_text", hero_skin_cfg.return_per)
        local buy_img = self:findImage("buy_skip_btn")
        local pre_img = self:findImage("pre_img")
        if self.m_model:checkHeroSkinTimesLimited() == false then
            self:setTextByLanKey("buy_skip_btn_text", "lantern_text_0014", GameUtil:switchMoneyType(hero_skin_cfg.price_new))
            buy_img.material = nil
            pre_img.material = nil
            self:setObjectVisible("buy_skip_btn_text", true)
            self:setObjectVisible("buy_skip_get_text", false)
        else
            buy_img.material = self.m_gray_image.material
            pre_img.material = self.m_gray_image.material
            self:setTextByLanKey("buy_skip_btn_text", "gf_str_0048")
            self:setObjectVisible("buy_skip_btn_text", false)
            self:setObjectVisible("buy_skip_get_text", true)
        end
    end
end


function M:updateLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:getGiftData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("btns_loopscroll")
        local params ={
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if cell_data then
                    self:updateMsg("buy_gift", cell_data)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, self.m_scroll_stay_flag)
        self.m_scroll_stay_flag = true
    end
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_text")

        local sort = cfg.price_type or 1
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", sort == 1)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_text", sort == 2 )
        if sort == 1 then -- 元宝
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cost_num_text", tostring(cfg.price))
        elseif sort == 2 then -- 充值金额
            if cfg.price == 0 then
                buy_btn_text.text = Language:getTextByKey("new_str_0278")
            else
                buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
            end
        else
            Logger.logError(sort, "ship_gift sort is error ")
        end


        local return_per_text = luaBehaviour:FindText("return_per_text")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "return_per_text", false )
        if return_per_text and cfg.return_per ~= ""  then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("reward_node")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil, 0.65)
        -- isCanBuy 展示上一礼包
        local bg_img = luaBehaviour:FindGameObject("cell_bg_image")
        if not (data.status == 1) then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
            GameUtil:updateResourcesImg(bg_img, "Texture/moon_shadow/a_yycs_yilinqulibaochendi")
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)
            GameUtil:updateResourcesImg(bg_img, "Texture/gujianqitan/a_gjqt_lbcd")
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            local residueCount = (cfg.time_limit - data.times)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end

        --置灰
        local buy_img = luaBehaviour:FindImage("bg_img")
        buy_img.material = data.status_paper == 0 and self.m_gray_image.material or nil

    end
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M