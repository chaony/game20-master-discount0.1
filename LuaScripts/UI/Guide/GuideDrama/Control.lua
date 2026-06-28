local M = class("GuideDramaControl", LikeOO.OOControlBase)

function M:onEnter()
	self.m_guide_file_name = "UI.Guide.GuideDrama.Guide"
	if not self.m_model:getCurDialog() then
		self:updateMsg(99999)
	else
		--self:setTimer(0.1,self.talkUpdate)
		self.m_model:sendPointLog(1)
	end
end

function M:startGuide()
	
end

--开始执行 剧情事件
function M:runStoryEvent( data )
	--self.m_view:showCGChangeTu("changtu1", 20)
	--事件类型
	--1=立绘对话，
	--2=特写图片+立绘对话，
	--3=滤镜特效
	--4=图片互动
	--事件类型
	if data.type ~= nil and data.type ~= "" then
			--特写图片
		if data.type == 2 then
			--特写图片
			local param_str = data.param;
			local param = string.split(param_str, ',')
			if next(param) ~= nil then
				--type,imgName,width,height
				local imgSrc = param[1];
				local imgIndex =tonumber(param[2]);
				local imgHasFloor = param[3];
				local imgWidth = param[4];
				local imgHeight = param[5];
				self.m_view:showSpecialImg(imgIndex, imgSrc, imgHasFloor, imgWidth, imgHeight);
			end
		elseif data.type == 3 then
			--滤镜特效
			--滤镜特效枚举
			local param_str = data.param;
			local param = string.split(param_str, ',')
			if next(param) ~= nil then
				self.m_view:showScreenEffect(tonumber(param))
			end
		elseif data.type == 4 then
			--图片互动
			local param_str = data.param;
			local param = string.split(param_str, ',')
			if next(param) ~= nil then
				--spine动画名称 
				local spineName = param[1]
				--有无对话框 1=有，0=无
				local hasDialog = param[2]
				self.m_view:showMoveSpine(spineName, hasDialog)
			end
		elseif data.type == 5 then
			--黑屏 + 白字
			local param = data.param
			if type(param) == "string" then
				param = string.split(param, ",")
			end
			if next(param) ~= nil then
				local black_screen_time = (tonumber(param[1]) or 2000)/1000
				local word_talk = param[2]
				local word_time = (tonumber(param[3]) or 3000)/1000
				--显示黑屏
				self.m_view:showBlackScreen()
				self:setOnceTimer(black_screen_time, function()
					self.m_view:setColorA(self.m_view.m_black_screen, 0)
					self:updateMsg("next_btn")
				end)
				--显示文字
				if word_talk == "0" then
					word_talk = "";
				end
				self.m_view:setTextByLanKey("white_text", GameUtil:replacePlayerName(word_talk))
				self:setOnceTimer(word_time, function()
					--self.m_view:setColorA(self.m_view.m_white_text,0)
					self.m_view:setTextByLanKey("white_text", "")
				end)
			end
		elseif data.type == 6 then
			local param_str = data.param
			if param_str and param_str ~= "" then
				local obj =ResourceUtil:LoadUIGameObject("Guide/"..param_str,Vector3(0,0,0),self.m_view.m_rootView);
				self:setOnceTimer(3,function()
					U3DUtil:Destroy(obj);
					self:updateMsg("next_btn")
				end)
			end
		elseif data.type == 7 then --只展示图片的会话
			local img_key
			if next(data.param) then
				img_key = data.param[1]
			end
			self.m_view:displayImgDialog(img_key)
		elseif data.type == 8 then --播漫画
			if self.m_model.m_dialog_index > 1  then
				local last_dialog = self.m_model:getLastDialog()
				if last_dialog and last_dialog.dialogue_cfg then
					local last_img = last_dialog.dialogue_cfg.bgpic
					self.m_view:playLastImgAnimation(last_img)
				end
			end
		end
	end
	
	--气泡逻辑
	local pop_param = nil;
	local pos_type = 0
	if data.face_left ~= nil and next(data.face_left) ~= nil  then
		pop_param = data.face_left;
		pos_type = 1;
		--清除气泡
		Logger.log(pop_param, "左气泡 ~~~~~~~ 气泡参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:showPopHandler(pos_type, pop_param)
	end
	
	if data.face_center ~= nil and next(data.face_center) ~= nil then
		pop_param = data.face_center;
		pos_type = 2;
		--清除气泡
		Logger.log(pop_param, "中气泡 ~~~~~~~ 气泡参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:showPopHandler(pos_type, pop_param)
	end
	
	if data.face_right ~= nil and next(data.face_right) ~= nil then
		pop_param = data.face_right;
		pos_type = 3;
		--清除气泡
		Logger.log(pop_param, "右气泡 ~~~~~~~ 气泡参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:showPopHandler(pos_type, pop_param)
	end
	
	local move_param = nil;
	local playerId = nil
	--移动逻辑
	if data.move_left ~= nil and next(data.move_left) ~= nil then
		move_param = data.move_left;
		pos_type = 1;
		playerId = data.role_left
		Logger.log(move_param, "左移动 ~~~~~~~~ 移动参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:moveHandler(pos_type, move_param, playerId)
	end
	
	if data.move_center ~= nil and next(data.move_center) ~= nil then
		move_param = data.move_center;
		pos_type = 2;
		playerId = data.role_center
		Logger.log(move_param, "中间移动 ~~~~~~~~ 移动参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:moveHandler(pos_type, move_param, playerId)
	end
	
	if data.move_right ~= nil and next(data.move_right) ~= nil then
		move_param = data.move_right;
		pos_type = 3;
		playerId = data.role_right
		Logger.log(move_param, "右移动 ~~~~~~~~ 移动参数 ~~~~~~~~~~~~~~~~~~~ " )
		self:moveHandler(pos_type, move_param, playerId)
	end


	--CG长图配置
	local pop_param = nil;
	local pos_type = 0
	Logger.log(data.long_cg, "CG长图参数 ~~~~~~~ ~~~~~~~~~~~~~~~~~~~ " )
	if data.long_cg ~= nil and data.long_cg ~= "" then
		local param_str = data.long_cg;
		local param = string.split(param_str, ',')
		local imgName = param[1];
		local moveTime = tonumber(param[2])/1000;
		local restart = false;
		if self.curImgName == nil then
			self.curImgName = imgName;
			restart = true;
		else
			if self.curImgName ~= imgName then
				self.curImgName = imgName;
				restart = true;
			else
				restart = false;
			end
		end
		self.m_view:showCGChangeTu(self.curImgName,moveTime,restart)
	else
		self.m_view:setColorA(self.m_view.m_changtu,0)
	end
end


function M:moveHandler( pos_type,move_param, playerId)
	if move_param ~= nil and next(move_param) ~= nil then
		local moveType = move_param[1];
		local targetIndex = move_param[2];
		local moveTime = tonumber(move_param[3] or 0)/1000;
		local fadeTime = moveTime;
		--type, moveType, moveTime, fadeTime, taragetPosIndex, playerId
		self.m_view:DoTweenHandler(pos_type, moveType ,moveTime,fadeTime, targetIndex, playerId);
	end
end

function M:showPopHandler( pos_type, pop_param )
	if pop_param ~= nil then
		--气泡id
		local faceID = pop_param[1]
		--x偏移量
		local x_offset = pop_param[2]
		--y偏移量
		local y_offset = pop_param[3]
		--显示气泡
		self.m_view:showPop(pos_type, faceID, x_offset, y_offset)
	end
end


function M:onHandle(msg, data)
	if msg == 99999 then
		self:closeView()
	elseif msg == "skip_btn" then
		self.m_model:sendPointLog(3)
		self:checkSelectDrama()
	elseif msg == "speak_end" then
		self.m_model:setTalking(false)
	elseif msg == "next_btn" then
		if not self.m_model:getTalking() then
			if self.m_model:nextDialog() then
				self.m_view:refreshUI()
			else
				self:checkSelectDrama()
			end
		else
			self.m_view:setDramaText()
		end
	elseif msg == "select_drama_Item" then
		if data.cell_data.can_choise then
			self.m_select_choise_data = {id = data.cell_data.id, index = data.index}
			self:closeView()
		else
			self.m_select_choise_data = {id = 0, index = data.index}
			self:closeView()
			if data.cell_data.no_choise_tips == nil or data.cell_data.no_choise_tips == 0 then
				GameUtil:lookInfoTips(static_rootControl, {msg = "new_str_0594", delay_close = 2})
			else
				--GameUtil:lookInfoTips(self, {msg = data.cell_data.no_choise_tips, delay_close = 2})
				if LikeOO.Map2DControl.curMap2D ~= nil then
					LikeOO.Map2DControl.curMap2D:playPlot(data.cell_data.no_choise_tips, "no_choise_plot", nil)
				end
			end
		end
	elseif msg == "refresh_choise" then
		self.m_model.waitForChoise = false
		self.m_model:setChoise(data)
		self:checkSelectDrama()
	--elseif msg == "select_drama_node" then
	--	self:closeView()
	elseif msg == "move_spine_btn" then
		--点击图片互动
		self.m_view:clickMoveSpine()
	elseif msg == "check_guide" then
		self.m_guide:checkGuide()
	elseif msg == "auto_btn" then
		self.m_model:setAutoState()
		self.m_view:refreshAutoImg()
		self.m_view:checkAuto()
	elseif msg == "kv_img" then
		self.m_view:closeKVImag()
	end
end

function M:talkUpdate()
	self.m_view:updateDramaWord()
end

function M:checkSelectDrama()
	if self.m_model.waitForChoise == false then
		if #self.m_model:getSelectDramaData() > 0 then -- 是否有选择剧情对话
			self.m_view:updateSelectDramaLoopScroll()
			if not self.m_model.is_guide then
				self.m_guide:checkGuide()
			end
		else
			self:closeView()
		end
	else
		local callback = self.m_model.m_params.callback
		if type(callback) == "function" then
			callback(self.m_select_choise_data)
		end
	end
end

function M:destroy()
	self.m_view:stopAllVoice()
	local callback = self.m_model.m_params.callback
	if type(callback) == "function" then
		callback(self.m_select_choise_data)
	end
	self.m_model:sendPointLog(2)
	if self.m_model.m_is_delay_close then
		self.m_view:lockTouch()
		self:setOnceTimer(0.8, function()
			self.m_view:unlockTouch()
			M.super.destroy(self)
		end)
	else
		M.super.destroy(self)
	end
end

return M;