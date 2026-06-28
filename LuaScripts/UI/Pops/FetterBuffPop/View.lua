local M = class("FetterBuffPopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/FetterBuffPop"
M.m_size_type = 2

local FATTER_TAB = {
	{id = 1, lv = 1, desc = "fb_str_0025"},
	{id = 2, lv = 2, desc = "fb_str_0001"},
	{id = 3, lv = 3, desc = "fb_str_0002"},
	{id = 4, lv = 4, desc = "fb_str_0003"},
	{id = 5, lv = 5, desc = "fb_str_0004"},
	{id = 6, lv = 5, desc = "fb_str_0037"},
	{id = 7, lv = 5, desc = "fb_str_0038"},
	{id = 8, lv = 5, desc = "fb_str_0039"},
}

function M:onEnter()
	self:setObjectVisible("content_node", false)
	self:setTextByLanKey("yuan_title", "fb_str_0036")
	self:refreshUI()
	self.m_control:setOnceTimer(0.05, function ()
		self:setObjectVisible("content_node", true)
	end)
end

function M:refreshUI()
	--local color_un = Color.New(58/255, 72/255, 94/255)
	local color_un = GlobalConfig.COMMON_COLLOR.COMMON_25
	--local color_hv = Color.New(175/255, 108/255, 64/255)
	local color_hv = GlobalConfig.COMMON_COLLOR.COMMON_26
	for i = 1, 8 do
		local p_name = "count_"..i
		local p_obj = self:findGameObject(p_name)
		local luaBehaviour = UIUtil.findLuaBehaviour(p_obj)
		local count_text = luaBehaviour:FindText("count_text")
		local num_text = luaBehaviour:FindText("num_text")
		
		if self.m_model:checkIsInList(i) == true then
			num_text.color = color_hv
		else
			num_text.color = color_un
		end
		local data = self.m_model:getBuffNum(i)
		count_text.text = Language:getTextByKey(FATTER_TAB[i].desc)
		local num1 = data[1]
		local num2 = data[2]
		num_text.text = Language:getTextByKey("fb_str_0007", tostring(GameUtil:formatNum(num1))).."%    "..Language:getTextByKey("fb_str_0008", tostring(GameUtil:formatNum(num2))).."%"
		--num_text.text = Language:getTextByKey("fb_str_0007", num1).."%    "..Language:getTextByKey("fb_str_0008", num2).."%"
		--没有sp侠客，就不显示后三个
		if i >= 6 then
			self:setObjectVisible(p_name, false)
			--self:setObjectVisible(p_name, UserDataManager.hero_data:checkHaveSP())
		end
	end
	self:setObjectVisible("Image2", false)
	self:setObjectVisible("sp", false)
	--self:setObjectVisible("sp", UserDataManager.hero_data:checkHaveSP()) --没有sp侠客，就不显示sp对应描述
	self:setTextByLanKey("yin_title", "fb_str_0024")
	self:setTextByLanKey("yang_title", "fb_str_0026")
	for i = 1, 5 do
		local num_text = nil
		if i < 5 then
			local data = self.m_model:getBuffNum(i + 10, i <= 2)
			num_text = self:setTextByLanKey("yin_"..i, "fb_str_001"..i, tostring(GameUtil:formatNum(data[1])))
		else
			local data = ConfigManager:getBattleCommonValueById(79, 0)
			if next(data) ~= nil then
				local str_1 = tostring(GameUtil:formatNum(data[1]))
				local str_2 = tostring(GameUtil:formatNum(data[2]*100))
				local str = Language:getTextByKey("fb_str_0015", str_1,str_2)
				num_text = self:setTextByLanKey("yin_"..i, str)	
			else
				num_text = self:setTextByLanKey("yin_"..i, "fb_str_001"..i, tostring(GameUtil:formatNum(data[1])))	
			end
		end
		if self.m_model:checkIsDemonList(i + 10) == true then
			num_text.color = color_hv
		else
			num_text.color = color_un
		end
	end
end

return M