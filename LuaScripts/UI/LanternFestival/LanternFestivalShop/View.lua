local M = class("LanternFestivalShopView",LikeOO.OOPopBase)

M.m_uiName = "LanternFestival/LanternFestivalShop"
M.m_size_type = 1
M.m_iphoneXAdapter = true


function M:onEnter()
    self.m_gray_image = self:findImage("gray_img")
    self:setSpine()
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "lantern_festival_text_0005")
  
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    self:createLoopScroll()
    self:updateLeftSkipShop()
end

function M:updateLeftSkipShop()
    if self.m_model.m_clothes_cfg then
        self:setTextByLanKey("old_price", GameUtil:getMoneyTypeNum(self.m_model.m_clothes_cfg.price_old))
        self:setTextByLanKey("per_text", self.m_model.m_clothes_cfg.return_per)
        local buy_img = self:findImage("buy_skip_btn")
        local pre_img = self:findImage("pre_img")
        if self.m_model:getClothesGift() == true then
            self:setTextByLanKey("buy_skip_btn_text", "lantern_text_0014", GameUtil:switchMoneyType(self.m_model.m_clothes_cfg.price_new))    
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


function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_ladderGiftData()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            one_line_count = 3,
            loop_scroll_object = loopscroll,
            update_cell =function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                self:updateCell(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if self.m_model.m_end_ts > 0 and self.m_model:checkActiveIsEnd() == false then
                    self:updateMsg(99999)
                    return
                end
                local cfg = cell_data.xlsxData
                if cfg.price == 0 then
                    self:updateMsg("get_free_ladder_gift", {vsn = self.m_model.m_gifts_data.version, id = cfg.id, open_id = 275} )
                else
                    self:updateMsg("buy", cell_data.xlsxData.charge_id)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.xlsxData
    if luaBehaviour then
        local name_text = luaBehaviour:FindText("cell_title_text")
        name_text.text = Language:getTextByKey(cfg.gift_name)
        local buy_btn_text = luaBehaviour:FindText("buy_btn_text")
        if cfg.price == 0 then
            buy_btn_text.text = Language:getTextByKey("new_str_0278")
        else
            buy_btn_text.text = GameUtil:getMoneyTypeNum(cfg.price)
        end
        local return_per_text = luaBehaviour:FindText("return_per_text")
        if return_per_text then
            return_per_text.text = GameUtil:formatNum(cfg.return_per * 100) .. "%"
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", true)
        local parent = luaBehaviour:FindGameObject("itemParent")
        UIUtil.destroyAllChild(parent.transform)
        local rewards = GameUtil:createGiftRewards(parent.transform, cfg.reward, true, true, nil)
        -- isCanBuy 展示上一礼包
        if not data.isCanBuy then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_limit_text", false)
            for k,v in pairs(rewards) do
                local reward_luaBehaviour = UIUtil.findLuaBehaviour(v)
                if reward_luaBehaviour then
                    LuaBehaviourUtil.setObjectVisible(reward_luaBehaviour, "duigoudi_img", true)
                end
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "sellout_text", false)
        end
        if cfg.time_limit == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0105")
        else
            local residueCount = (cfg.time_limit-data.buyCount)
            residueCount = data.isCanBuy and residueCount or 0
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "buy_limit_text", "gf_str_0050", residueCount)
        end
    end
end

function M:setSpine()
    local icon, item_data = self.m_model:getShowSkip()
    if self.cacheSpineName and self.cacheSpineName ~= icon then
        self.cacheSpineName = icon
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
    else
        self.cacheSpineName = icon
        local play_img = self:findGameObject("hero_spine")
        GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true) 
    end
    if item_data then
        self:setText("hero_name2", string.cutTextForString(Language:getTextByKey(item_data.item_cfg.skin_name)))
        local race = self.m_model:getRaceByCId(item_data.item_cfg.hero)
        self:setImg(race.race_icon, ResourceUtil:getLanAtlas(), "hero_race")
        self:setObjectVisible("hero_name_con", true)
    else
        self:setObjectVisible("hero_name_con", false)
    end
end

function M:updateActivityTimer()
	local end_ts = self.m_model:getEndTs()
	local down_time = end_ts - UserDataManager:getServerTime()
	if down_time >= 0 then
		local text = GameUtil:formatTimeBySecond(down_time, 999)
		self:setTextByLanKey("text_timer", text)
    elseif down_time == 0 then
        self:updateMsg("refresh_data")
	end
end

return M