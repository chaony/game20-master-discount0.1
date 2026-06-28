local M = class("LoginServerModel", LikeOO.OODataBase)

M.testTable = {}

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.server_url = UserDataManager.server_data:getServerInfo()
	self.server_url = self.server_url or {
		{name = "开发服务器", 	server_list = {"http://49.233.43.174/underworld"}},
		{name = "测试服务器", 	server_list = {"http://49.233.43.174/underworld_stg_horizontal"}},
		{name = "腾讯测试服务器", 	server_list = {"http://49.233.43.174/underworld_stg_portrait"}},
		{name = "审核服务器", 	server_list = {"http://49.233.46.162/underworld_edition"}},
		{name = "正式服务器", 	server_list = {"http://152.136.205.84/underworld_release"}},
		{name = "策划服1", 		server_list = {"http://10.89.128.133:8080/underworld_planning1"}},
		{name = "策划服2", 		server_list = {"http://10.89.128.133:8080/underworld_planning2"}},
		{name = "策划服3", 		server_list = {"http://10.89.128.133:8080/underworld_planning3"}},
		{name = "策划服4", 		server_list = {"http://10.89.128.133:8080/underworld_planning4"}},
		{name = "策划服5", 		server_list = {"http://10.89.128.133:8080/underworld_planning5"}},
		{name = "腾讯内测", 	    server_list = {"https://dhjh.kingsoft.com/underworld_prod"}},
		{name = "版署审核横版服务器", 	server_list = {"http://49.233.46.162/underworld_edition_horizontal"}},
	}
end

return M