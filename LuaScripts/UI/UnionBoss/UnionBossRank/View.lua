local M = class("UnionBossRankView",LikeOO.OOPopBase)

M.m_uiName = "UnionBoss/UnionBossRankPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true
local rank_tab = {"ui_one","ui_two","ui_three",}
function M:onEnter()
	self:setTextByLanKey("sec_title_text", "world_boss_str_0024")
	self:setTextByLanKey("fresh_btn_text", "world_boss_str_0015")
	self:setTextByLanKey("reward_text", "new_str_0224")
	self:setTextByLanKey("mine_score_text", "new_str_0077")
	self:setTextByLanKey("no_text", "world_boss_str_0025")
	self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
	self:setTextByLanKey("score_label_text", "world_boss_str_0026")
	self:setTextByLanKey("dan_label_text", "world_boss_str_0027")
	self.self_rank_node = self:findGameObject("self_rank_node")
	self.no_panel = self:findGameObject("no_panel")
	self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_day == 1 then
		self:setTextByLanKey("change_btn_text", "world_boss_str_0013")
	else
		self:setTextByLanKey("change_btn_text", "world_boss_str_0014")
	end
	local user = UserDataManager.user_data.user_status
	local luaBehaviour = self.self_rank_node:GetComponent("LuaBehaviour")
	local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	GameUtil:setUserAvatar(headNode, user, nil, nil, {show_flag = true, scale = 1})
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "arena_str_0010")
	local self_rank = self.m_model:getSelfRankData()
	local battle_text = luaBehaviour:FindText("battle_text")
	battle_text.text = string.format(Language:getTextByKey("world_boss_str_0010"), self_rank.score)
	local dan_data = self.m_model:getDanData(self_rank.rank)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "dan_text", dan_data.division_name)
	local tank_img = luaBehaviour:FindGameObject("tank_img")
	local rank_text = luaBehaviour:FindGameObject("rank_text")
	local dan_img = luaBehaviour:FindGameObject("dan_img")
	dan_img:SetActive(self_rank.rank > 0)
	if self_rank.rank > 0 and dan_data.division == 1 then
		LuaBehaviourUtil.setText(luaBehaviour,"rank_text", tostring(self_rank.rank))
		-- if self_rank.rank <= 3 then
			-- rank_text:SetActive(false)
			-- tank_img:SetActive(true)
		-- 	LuaBehaviourUtil.setImg(luaBehaviour,"tank_img", rank_tab[self_rank.rank], "rank_ui")
		-- else
			-- rank_text:SetActive(true)
			-- tank_img:SetActive(false)
		-- 	LuaBehaviourUtil.setText(luaBehaviour,"rank_text", tostring(self_rank.rank))
		-- end
	else
		rank_text:SetActive(false)
		-- tank_img:SetActive(false)
	end
	self:updateLoopScroll()
end

function M:updateLoopScroll()
	local data = self.m_model:getRankData()
	self.no_panel:SetActive(#data <= 0)
	if self.m_loop_scroll_view == nil then
		local list_scroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local user = data.user or {}
    local rank = data.rank or 0
    local name = user.name
    local tank_img = luaBehaviour:FindImage("tank_img")
    local rank_text = luaBehaviour:FindText("rank_text")
    if rank > 3 then
    	tank_img.gameObject:SetActive(false)
    	rank_text.text = rank
    else
    	tank_img.gameObject:SetActive(true)
    	LuaBehaviourUtil.setImg(luaBehaviour,"tank_img", rank_tab[rank], "rank_ui")
    end
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "new_str_0141")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end

    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
	GameUtil:setUserAvatar(headNode, user, nil, nil, {show_flag = true, scale = 1})

	local score_text = luaBehaviour:FindText("score_text")
	score_text.text =  cell_data.score

	local dan_data = self.m_model:getDanData(rank)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "dan_text", dan_data.division_name)
end
return M