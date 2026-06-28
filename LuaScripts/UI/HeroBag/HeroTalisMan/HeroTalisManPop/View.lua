local M = class("TalisManmentPopView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroTalisMan/TalisManmentPop"
M.m_size_type = 2
local __TAB_BTN_NODE = {
	[1] = "talisman_text_001",
	[2] = "talisman_text_002",
	[3] = "talisman_text_003",
	[4] = "talisman_text_004",
}
function M:onEnter()
	self.grayImage = self:findImage("grayImage")
	self:refreshUI()
end


function M:refreshUI()
	self:InitText()
	self:UpdateInfo()
end

function M:InitText()
	local text = __TAB_BTN_NODE[self.m_model.pos] or "talisman_text_001"
	self:setTextByLanKey("common_title_text", text) -- 脚 腿 等等
	self:setTextByLanKey("cizhui_text", "talisman_text_009") --属性
	--self:setTextByLanKey("eqp_des_title_text1", "talisman_text_0010") --共鸣效果
	self:setTextByLanKey("eqp_des_title_text3", "talisman_text_0011") --符篆描述
	self:setTextByLanKey("buy_btn_text", "talisman_text_0012") --替换
end

function M:UpdateInfo()
	local data = self.m_model:getCurrentTalinsDataByPos(self.m_model.pos)
	local cfgdata = self.m_model:getTalisSuitConfigByCid(data and data.id or 1)
	local efeectNum = self.m_model:getHeroTalinsEfeectNum() --判断是两件事4 件

	if efeectNum >=2 and efeectNum<4 then
		self:setTextByLanKey("eqp_count_text_title","talisman_text_0023",Language:getTextByKey("talisman_text_0036"))
		self:setTextByLanKey("eqp_count_text2_title","talisman_text_0037")
		self:setTextByLanKey("eqp_count_text",cfgdata.addition2.tips or "")
		self:setTextByLanKey("eqp_count_text2",cfgdata.addition4.tips or "")
		self:setTextColor("eqp_count_text",Color( 64/255, 118/255, 17/255))
	elseif efeectNum >=4 then
		self:setTextByLanKey("eqp_count_text_title","talisman_text_0023",Language:getTextByKey("talisman_text_0036"))
		self:setTextByLanKey("eqp_count_text2_title","talisman_text_0023",Language:getTextByKey("talisman_text_0037"))
		self:setTextByLanKey("eqp_count_text", cfgdata.addition2.tips or "")
		self:setTextByLanKey("eqp_count_text2", cfgdata.addition4.tips or "")
		self:setTextColor("eqp_count_text",Color( 64/255, 118/255, 17/255))
		self:setTextColor("eqp_count_text2",Color( 64/255, 118/255, 17/255))
	else
		self:setTextByLanKey("eqp_count_text_title","talisman_text_0036")
		self:setTextByLanKey("eqp_count_text2_title","talisman_text_0037")
		self:setTextByLanKey("eqp_count_text", cfgdata.addition2.tips or "")
		self:setTextByLanKey("eqp_count_text2", cfgdata.addition4.tips or "")
	end
	--设置item 
	local item = self:findGameObject("ItemNode")
	local itemData = self.m_model:getTalisDataById(data.id)
	GameUtil:updateItemElement(item, itemData.reward or {170,data.id,1}, false, false)
	local cfgData = self.m_model:getTalisSuitConfigByCid(data.id or 1)
	--设置装备名字
	self:setTextByLanKey("eqp_name_text",cfgdata.name or "")
	-- 设置属性
	for i = 1,3 do
		local attrsData = data.attrs[tostring(i)]
		if attrsData then
			local reward_bar = self:findSlider("left_property_slider_"..i)
			local cur_value,max_value = self.m_model:getCurrentLimitbyId(cfgData.quality,self.m_model.pos,attrsData.team_id,attrsData.value[2])
			reward_bar.value = cur_value/max_value
			--设置属性
			local showArr = self.m_model:getCurrentAttrs({attrsData.value})
			local at_name = GameUtil:getAttrsName(showArr[1]).."："
			--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", at_name)
			-- 四舍五入保留小数点后一位
			local attr_value = showArr[2].cur_num or 0
			attr_value = math.floor(attr_value * 10 + 0.5)/10
			if GameUtil:newattrTransition2(showArr[1]) == true then
				self:setTextByLanKey("attr_count_text"..i, at_name..GameUtil:formatValueToString(attr_value).."%")
			else
				self:setTextByLanKey("attr_count_text"..i, at_name..GameUtil:formatValueToString(attr_value))
			end
			self:setTextColor("attr_count_text"..i,self.m_model:getCurrentPropertyTextColor(attrsData.value[2],self.m_model.pos,attrsData.value[1]))
		else
			self:setTextByLanKey("attr_count_text"..i, "")
			self:setObjectVisible("left_property_slider_"..i,false)
		end

	end

	--设置战力
	--local combat = self.m_model:getTalisComatByArr(data.attrs)
	local combat = self.m_model:getCurrentIntegral(self.m_model.pos,data.attrs)
	combat = math.floor(combat * 10 + 0.5)/10
	self:setTextByLanKey("zhanli_text",  Language:getTextByKey("talisman_text_0035"))
	self:setTextByLanKey("combat_text",  GameUtil:formatValueToString(combat))
	
	
	--共鸣效果
	local curNum,allNum = self.m_model:getHeroTalinsEfeectNum()
	self:setTextByLanKey("eqp_des_title_text1","talisman_text_0010",curNum,allNum)
	
	--设置那妞状态
	local talis_data = self.m_model:getTalisData()
	if #talis_data <=0 then
		local buy_img = self:findImage("buy_btn")
		buy_img.material = self.grayImage.material
	 	--local btn = self:findButton("buy_btn")
		--btn.enabled = false
	end
	if self.m_model.look_model == 3 then 
		self:setObjectVisible("buy_btn",false)
	end
end

function M:destroy()
	if self.m_item_detail_node then
		self.m_item_detail_node:destroy()
		self.m_item_detail_node = nil
	end
	M.super.destroy(self)
end

return M