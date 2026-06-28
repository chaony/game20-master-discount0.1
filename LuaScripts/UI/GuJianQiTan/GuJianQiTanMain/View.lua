local M = class("GuJianQiTanMainView",LikeOO.OOPopBase)

M.m_uiName = "GuJianQiTan/GuJianQiTanMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
 	self.m_gray_material = self:findText("material_node").material
	self.maze_btn_img = self:findImage("maze_btn")
	self.maze_btn_text = self:findText("maze_btn_text")
	self.m_maze_open_time = self.m_model:getMazeOpenTime()
	local btn_data = BtnOpenUtil:getBtnCfg(280)
	self:setTextByLanKey("close_title_text", btn_data.name)
	self:setTextByLanKey("draw_btn_text", "gu_jian_qi_tan_str_001")
	self:setTextByLanKey("show_btn_text", "gu_jian_qi_tan_str_002")
	self:setTextByLanKey("maze_btn_text", "gu_jian_qi_tan_str_003")
	self:setTextByLanKey("shop_btn_text", "gu_jian_qi_tan_str_004")
	self:setTextByLanKey("rank_btn_text", "gu_jian_qi_tan_str_005")
	self:setTextByLanKey("date_btn_text", "gu_jian_qi_tan_str_006")
	self:setTextByLanKey("h5_btn_text", "gu_jian_qi_tan_str_034")
	self:setObjectVisible("h5_btn", false)
	--if SDKUtil.is_gmsdk then
	--	local application_Id = SDKUtil.sdk_params.applicationId
	--	self:setObjectVisible("h5_btn", application_Id == "com.hermes.wl" or application_Id == "com.hermes.wl.debug") --官包显示桃花幻梦活动入口(沙箱测试也显示)
	--end
	self:refreshUI()
end

function M:refreshUI()
	self:initTime()
	self:refreshRedPoint()
end


function M:refreshRedPoint()
	self:setObjectVisible("draw_btn_red_point_img", RedPointUtil:hasRedPointById(281))
	self:setObjectVisible("show_btn_red_point_img", false)
	self:setObjectVisible("maze_btn_red_point_img", false)
	self:setObjectVisible("shop_btn_red_point_img", RedPointUtil:hasRedPointById(284))
	self:setObjectVisible("rank_btn_red_point_img", false)
	self:setObjectVisible("date_btn_red_point_img", false)
	self:setObjectVisible("h5_btn_red_point_img", false)
end

--地宫时间标签
function M:initTime()
	local d_time = self.m_maze_open_time - UserDataManager:getServerTime()
	self:setObjectVisible("maze_time_node", d_time > 0)
end

function M:updateTime()
	local d_time = self.m_maze_open_time - UserDataManager:getServerTime()
	if d_time <= 0 then
		self:setObjectVisible("maze_time_node", false)
	else
		self:setTextByLanKey("maze_time_text", Language:getTextByKey("gu_jian_qi_tan_str_042", GameUtil:formatTimeBySecond2(d_time, 999)))
	end
	self:updateMazeBtn(d_time <= 0)
end

function M:updateMazeBtn(open_time_flag)
	if open_time_flag and self.m_model:isActivityShowDone() == true then
		self.maze_btn_img.material = nil
		self.maze_btn_text.material = nil

		self.m_control:removeTimer(self.m_control.m_timer_id)
	else
		self.maze_btn_img.material = self.m_gray_material
		self.maze_btn_text.material = self.m_gray_material
	end
end


return M