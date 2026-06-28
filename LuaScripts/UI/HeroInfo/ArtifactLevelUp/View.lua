local M = class("ArtifactLevelUpView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/ArtifactLevelUp"

local tab_exp = {RewardUtil.REWARD_TYPE_KEYS.HERO_EXP, 0, 0} --英雄经验

function M:onEnter()
    self:setTextByLanKey("artifact_text", self.m_model.m_art_cfg.name) --
    self:setTextByLanKey("common_title_text", "神兵强化")
    self:refreshUI()
end

function M:refreshUI()
    local cur_star = self:findGameObject("cur_star")
    local last_star = self:findGameObject("last_star")
    self:updateStar(cur_star, self.m_model.m_art_data.lv)
    self:updateStar(last_star, self.m_model.m_art_data.lv+1)
    self:setImg(self.m_model.m_art_cfg.icon, "item_icon", "artifact_img")
    self:setTextByLanKey("art_name", self.m_model.m_art_cfg.name)
    local attrs = self.m_model:getAttrs()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = attrs,
            loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self:updateCell(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(attrs)
    end
    local cost_1, cost_2 = self.m_model:getCostMoney()
    self:setImg(cost_1.icon_name, cost_1.atlas_name, "cond_img")	--金币
    self:setImg(cost_2.icon_name, cost_2.atlas_name, "debris_img")	--特殊
    self:setText("cond_num_text", GameUtil:formatValueToString(cost_1.user_num).."/"..GameUtil:formatValueToString(cost_1.data_num))
	self:setText("debris_num_text", GameUtil:formatValueToString(cost_2.user_num).."/"..GameUtil:formatValueToString(cost_2.data_num))
    local lock_lv, str = self.m_model:getNextLockDes()
    if lock_lv > 0 then
        self:setText("levelup_lock_text", "强化至"..lock_lv.."星解锁")
        self:setText("lock_desc_text", Language:getTextByKey(str))
        self:setObjectVisible("levelup_lock_text", true)
        self:setObjectVisible("lock_desc_text", true)
    else
        self:setObjectVisible("levelup_lock_text", false)
        self:setObjectVisible("lock_desc_text", false)  
    end
end

function M:updateCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local title_name = luaBehaviour:FindGameObject("title_name")
    local cur_num = luaBehaviour:FindGameObject("cur_num")
    local next_num = luaBehaviour:FindGameObject("next_num")
    local jiantou = luaBehaviour:FindGameObject("jiantou")
    --title_name:SetActive(false)
    cur_num:SetActive(false)
    next_num:SetActive(false)
    local text_title = title_name:GetComponent("Text")
    local text_c_num = cur_num:GetComponent("Text")
    local text_n_num = next_num:GetComponent("Text")
    local atr_key = GameUtil:getAttrsKey(data.n_attr[1])
    local name = GameUtil:getAttrsName(atr_key)
    text_title.text = name
    cur_num:SetActive(true)
    next_num:SetActive(true)
    if data.c_attr then
        if GameUtil:attrTransition(atr_key) == true then
            text_c_num.text = (data.c_attr[2] * 100).."%"
        else
            text_c_num.text = data.c_attr[2]  
        end
    else
        text_c_num.text = "0"
    end
    if GameUtil:attrTransition(atr_key) == true then
        text_n_num.text = (data.n_attr[2] * 100).."%"
    else
        text_n_num.text = data.n_attr[2]
    end
end

function M:updateStar(obj, lv)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local star_tab = {}
    for i = 1 , 5 do
        local star = luaBehaviour:FindGameObject("star_"..i)
        star:SetActive(false)
        star_tab[i] = star
    end
    local n_lv = lv > 5 and 5 or lv
    if n_lv > 0 then
        for i = 1, n_lv do
            star_tab[i]:SetActive(true)
        end
    end
end


return M