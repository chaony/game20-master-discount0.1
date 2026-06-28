--- 秘籍合成概率
local M = class("MysicCompositeProbabilityPopNode",LikeOO.OOUIbase)

M.m_uiName = "SutraDepository/MysicCompositeProbabilityPop"
--M.m_sortOrder = 19999

function M:onCreate()
	self.m_transfer = "scale"
	self.m_content = self:findGameObject("content_node")
	self.m_content:SetActive(false)
end

function M:setParent(parent)
	if static_root_node then
		self.m_rootView.transform:SetParent(static_root_node.transform, false)
	end
end

function M:onButtonClick(obj, name, data)
	if name == "close_btn" then
		self:destroy()
	end
end

function M:onEnter()
	local all_list = self.m_params.max_rate_mystic_list or {}
	local max_rate = 0
	for k,v in pairs(all_list) do
		if v > max_rate then
			max_rate = v
		end
	end
	local new_list = {}
	for k,v in pairs(all_list) do
		if v == max_rate then
			new_list[k] = v
		end
	end
	self.max_rate_mystic_list = new_list
	self.mystic_rate_list = self.m_params.mystic_rate_list or {}
	self.m_call_func = self.m_params.call_func
	self.m_next_quality = self.m_params.next_quality
	self.m_type_3 = self.m_params.type_3
	self:setTextByLanKey("composite_title_text", "mystic_str_0070")
	local rate_batter = 0
	for i, rate in pairs(self.max_rate_mystic_list) do
		rate_batter = rate_batter + rate
	end
	local rate = string.format("%.2f", rate_batter*100)
	self:setTextByLanKey("composite_text1",  Language:getTextByKey("mystic_str_0071", rate))
	local other_rate = math.max(0,100 - rate)
	local color_name =  "new_str_0335"
	if GlobalConfig.QUALITY_COMMON_SETTING[self.m_next_quality] then
		color_name = GlobalConfig.QUALITY_COMMON_SETTING[self.m_next_quality].name
	else
		color_name = GlobalConfig.QUALITY_COMMON_SETTING[12].name	
	end
	
	self:setTextByLanKey("composite_text2", Language:getTextByKey("mystic_str_0072", other_rate, Language:getTextByKey(color_name)))
	self:setObjectVisible("composite_text2",other_rate~=0)
	
	self:updateRightScroll()
	self:refreshUI()
end


function M:updateRightScroll()
	local rewardList = {}
	for id, v in pairs(self.max_rate_mystic_list) do
		local cfg = self:getMysticData(id)
		local reward_data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(id), cfg.quality,
															 mystic_num = 1})
		table.insert(rewardList, reward_data)
	end
	self.m_gift_tab = {}
	local data = rewardList
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			--one_line_count = 4,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self.m_gift_tab[index] = cell_obj
				self:updateLoopScroll(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg(click_name, cell_data)
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data, true)
	end
end

-- 根据数据创建通用道具节点
function M:updateLoopScroll(index, obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local itemNode = luaBehaviour:FindGameObject("ItemNode")
	local itemNodeLuaBehaviour = UIUtil.findLuaBehaviour(itemNode)
	--itemNodeLuaBehaviour:RegistButtonClick(function (obj, name)
	--	if name == "ItemNode" then
	--	end
	--end)
	GameUtil:updateItemElementByData(itemNode, cell_data, true, false)
	LuaBehaviourUtil.setObjectVisible(itemNodeLuaBehaviour,"count_text",false)
	local item_name = luaBehaviour:FindText("item_name")
	item_name.text = Language:getTextByKey(cell_data.item_cfg.name)
end


function M:refreshUI()
	self.m_content:SetActive(true)
end

-- 通过秘籍配置id获取秘籍详情
function M:getMysticData(m_oid)
	local cfg = UserDataManager.mystic_data:getMysticConfigByCid(tonumber(m_oid))
	return cfg
end


function M:destroy()
	if self.m_call_func then
		self.m_call_func()
	end
	M.super.destroy(self)
end

return M