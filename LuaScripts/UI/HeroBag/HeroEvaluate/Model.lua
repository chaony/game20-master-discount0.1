---@class HeroEvaluateModel:OODataBase
local M = class("HeroEvaluateModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	--self:getData("hero_evaluate_index")
	self.hero_oid = self.m_params.hero_id

	self:getData("hero_evaluate_index",{hero_id = self.hero_oid},nil,GlobalConfig.POST)
end

M.dataTime = 22

function M:onEnter()

	self.m_tab_index = self.m_params.tab_index or 1
	self.hero_id = self.m_params.hero_id or 1
	
	self.max_comment_id = self.m_data.max_comment_id or 1 --最大评论id
	self.score_count = self.m_data.score_count or 1 --总评分人数
	self.hero_score = self.m_data.hero_score or 1 --平均分
	self.last_eva_ts = self.m_data.last_eva_ts or 0
	
	self.m_hotlist_data =  {} --热门评论
	self.m_newlist_data =  {} --最新评论
	self:updateEvaluateData()
end

function M:setTabIndex(index)
	self.m_tab_index = index
end
function M:updateEvaluateData( ... )
	
	for k,v in pairs(self.m_data.top_comments) do
		table.insert(self.m_hotlist_data,v)
	end
	local function sortFunc(id_one, id_two)
        return id_one.like_count > id_two.like_count
    end
    table.sort(self.m_hotlist_data, sortFunc)
    
    for k,v in pairs(self.m_data.newest_comments) do
    	table.insert(self.m_newlist_data,v)
		
	end
	local function sortFunc(id_one, id_two)
           return id_one.cmt_id > id_two.cmt_id
    	end
    table.sort(self.m_newlist_data, sortFunc)
end

function M:getEvaluateData( ... )
	if self.m_tab_index == 1 then
		return self.m_hotlist_data
	elseif self.m_tab_index ==2 then
		return self.m_newlist_data
	end
end

function M:setEvaluatehero_score( data )
	self.hero_score = data.hero_score
	self.score_count = data.score_count
end
function M:setEvaluatelast_eva_ts( data )
	self.last_eva_ts = data.last_eva_ts
	
end

--替换评论
function M:setEvaluateData(data)
	self.m_hotlist_data = data.top_comments
		local function sortFunc(id_one, id_two)
           return id_one.like_count > id_two.like_count
    	end
    table.sort(self.m_hotlist_data, sortFunc)

	for k,v in pairs(self.m_newlist_data) do
		if v.cmt_id == data.comments[1].cmt_id  then
			self.m_newlist_data [k] = data.comments[1] 
		end
	end
	
	
end

--添加评论
function M:addEvaluateData(data)  
	if data.comments ~= nil then
		table.insert(self.m_newlist_data,data.comments[1])
		local function sortFunc(id_one, id_two)
		  return id_one.cmt_id > id_two.cmt_id
		end
		table.sort(self.m_newlist_data, sortFunc)

	end
	
end

return M
