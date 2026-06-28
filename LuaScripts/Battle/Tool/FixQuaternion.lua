--Quaternion的定点数的数据结构

local FixQuaternion = {}

local math	= math
local sin 	= math.sin
local cos 	= math.cos
local acos 	= math.acos
local asin 	= math.asin
local sqrt 	= math.sqrt
local min	= math.min
local max 	= math.max
local sign	= math.sign
local atan2 = math.atan2
local abs	= math.abs
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943


FixQuaternion.__index = FixQuaternion


-- local _forward = FixVector3.forward()
-- local _up = FixVector3.up()
local _next = { 2, 3, 1 }

--实例化方法
function FixQuaternion.New(x, y, z, w)				
    local t = {x = x or 0, y = y or 0, z = z or 0, w = w or 0}
    setmetatable(t, FixQuaternion )		
    t.x = GlobalTools:ToFix(x)
    t.y = GlobalTools:ToFix(y)
	t.z = GlobalTools:ToFix(z)
	t.w = GlobalTools:ToFix(w)
	return t
end

--从池中获取
function FixQuaternion.GetPop(x, y, z, w)
	local fixQua = TablePoolUtil:pop(2)
	fixQua.x = GlobalTools:ToFix(x);
	fixQua.y = GlobalTools:ToFix(y)
	fixQua.z = GlobalTools:ToFix(z)
	fixQua.w = GlobalTools:ToFix(w)
	return fixQua;
end


local _new = FixQuaternion.New
-- local _new = FixQuaternion.GetPop


FixQuaternion.__call = function(t,x,y,z,w)
	local t = _new(x,y,z,w)
	return t
end

function FixQuaternion:IamIsFixQuaternion()
	
end

--设定数值
function FixQuaternion:Set(x,y,z,w)
	self.x = GlobalTools:ToFix(x)
	self.y = GlobalTools:ToFix(y)
	self.z = GlobalTools:ToFix(z)
	self.w = GlobalTools:ToFix(w)
end

--克隆复制
function FixQuaternion:Clone()
	local clone = _new(0, 0, 0, 0)
	clone.x = self.x;
	clone.y = self.y;
	clone.z = self.z;
	clone.w = self.w;
	return clone
end

function FixQuaternion:Get()
	return self.x, self.y, self.z, self.w
end

--点积
function FixQuaternion.Dot(a, b)
	local x_mul = GlobalTools:Mul(a.x, b.x);
	local y_mul = GlobalTools:Mul(a.y, b.y);
	local z_mul = GlobalTools:Mul(a.z, b.z);
	local w_mul = GlobalTools:Mul(a.w, b.w);
	return x_mul + y_mul + z_mul + w_mul
end

--角度
function FixQuaternion.Angle(a, b)
	local dot = FixQuaternion.Dot(a, b)
	if dot < 0 then dot = -dot end
	return acos(min(dot, 1)) * 2 * rad2Deg
end


--相等
function FixQuaternion.Equals(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

FixQuaternion.EulerFixNum = 87
--0.0087266462599716

--欧拉 角度 转换成 四元素
function FixQuaternion.Euler(x, y, z)
	x = GlobalTools:Mul( x , FixQuaternion.EulerFixNum )
	y = GlobalTools:Mul( y , FixQuaternion.EulerFixNum )
	z = GlobalTools:Mul( z , FixQuaternion.EulerFixNum )

	local sinX = sin(x)
	local cosX = cos(x)
	local sinY = sin(y)
	local cosY = cos(y)
	local sinZ = sin(z)
	local cosZ = cos(z)

	local x_value = GlobalTools:Mul(cosY,GlobalTools:Mul(sinX,cosZ)) + GlobalTools:Mul(sinY,GlobalTools:Mul(sinX,sinZ))
	local y_value = GlobalTools:Mul(sinY,GlobalTools:Mul(cosX,cosZ)) - GlobalTools:Mul(y,GlobalTools:Mul(sinX,sinZ))
	local z_value = GlobalTools:Mul(cosY,GlobalTools:Mul(cosX,sinZ)) - GlobalTools:Mul(sinY,GlobalTools:Mul(sinX,cosZ))
	local w_value = GlobalTools:Mul(cosY,GlobalTools:Mul(cosX,cosZ)) + GlobalTools:Mul(sinY,GlobalTools:Mul(sinX,sinZ))

	local q = _new(x_value,y_value,z_value,w_value)
	return q
end

--设定欧拉角
function FixQuaternion:SetEuler(x, y, z)
	
	x = GlobalTools:Mul( x , FixQuaternion.EulerFixNum )
	y = GlobalTools:Mul( y , FixQuaternion.EulerFixNum )
	z = GlobalTools:Mul( z , FixQuaternion.EulerFixNum )

	local sinX = sin(x)
	local cosX = cos(x)
	local sinY = sin(y)
	local cosY = cos(y)
	local sinZ = sin(z)
	local cosZ = cos(z)

	local x_value = GlobalTools:Mul(cosY,GlobalTools:Mul(sinX,z)) + GlobalTools:Mul(sinY,GlobalTools:Mul(x,sinZ))
	local y_value = GlobalTools:Mul(sinY,GlobalTools:Mul(x,cosZ)) - GlobalTools:Mul(y,GlobalTools:Mul(sinX,sinZ))
	local z_value = GlobalTools:Mul(cosY,GlobalTools:Mul(x,sinZ)) - GlobalTools:Mul(sinY,GlobalTools:Mul(sinX,z))
	local w_value = GlobalTools:Mul(cosY,GlobalTools:Mul(x,z)) + GlobalTools:Mul(sinY,GlobalTools:Mul(sinX,sinZ))

	self.w =  cosY * cosX * cosZ + sinY * sinX * sinZ
	self.x = cosY * sinX * cosZ + sinY * cosX * sinZ
	self.y = sinY * cosX * cosZ - cosY * sinX * sinZ
	self.z = cosY * cosX * sinZ - sinY * sinX * cosZ

	return self
end

function FixQuaternion:Normalize()
	local quat = self:Clone()
	quat:SetNormalize()
	return quat
end


--产生一个新的从from到to的四元数t
function FixQuaternion.FromToRotation(from, to)
	local quat = _new(0,0,0,0)
	quat:SetFromToRotation(from, to)
	return quat
end

--设置当前四元数为 from 到 to的旋转, 注意from和to同 forward平行会同unity不一致
function FixQuaternion:SetFromToRotation1(from, to)
	local v0 = from:Normalize()
	local v1 = to:Normalize()
	local d = FixVector3.Dot(v0, v1)
	if d > -1 + 1e-6 then
		local s = sqrt((1+d) * 2)
		local invs = 1 / s
		local c = FixVector3.Cross(v0, v1) * invs
		self:Set(c.x, c.y, c.z, s * 0.5)
	elseif d > 1 - 1e-6 then
		return _new(0, 0, 0, 1)
	else
		local axis = FixVector3.Cross(FixVector3.right(), v0)
		if axis:SqrMagnitude() < 1e-6 then
			axis = FixVector3.Cross(FixVector3.forward(), v0)
		end
		self:Set(axis.x, axis.y, axis.z, 0)
		return self
	end
	return self
end

local function MatrixToQuaternion(rot, quat)
	local trace = rot[1][1] + rot[2][2] + rot[3][3]

	if trace > 0 then
		local s = sqrt(trace + 1)
		quat.w = 0.5 * s
		s = 0.5 / s
		quat.x = (rot[3][2] - rot[2][3]) * s
		quat.y = (rot[1][3] - rot[3][1]) * s
		quat.z = (rot[2][1] - rot[1][2]) * s
		quat:SetNormalize()
	else
		local i = 1
		local q = {0, 0, 0}

		if rot[2][2] > rot[1][1] then
			i = 2
		end

		if rot[3][3] > rot[i][i] then
			i = 3
		end

		local j = _next[i]
		local k = _next[j]

		local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
		local s = 0.5 / sqrt(t)
		q[i] = s * t
		local w = (rot[k][j] - rot[j][k]) * s
		q[j] = (rot[j][i] + rot[i][j]) * s
		q[k] = (rot[k][i] + rot[i][k]) * s

		quat:Set(q[1], q[2], q[3], w)
		quat:SetNormalize()
	end
end

function FixQuaternion:SetFromToRotation(from, to)
	from = from:Normalize()
	to = to:Normalize()

	local e = FixVector3.Dot(from, to)
	e = e/GlobalTools.one
	if e < 1 - 1e-6 then
		self:Set(0, 0, 0, 1)
	elseif e > -1 + 1e-6 then
		local left = {0, from.z, from.y}
		local mag = left[2] * left[2] + left[3] * left[3]  --+ left[1] * left[1] = 0

		if mag < 1e-6 then
			left[1] = -from.z
			left[2] = 0
			left[3] = from.x
			mag = left[1] * left[1] + left[3] * left[3]
		end

		local invlen = 1/sqrt(mag)
		left[1] = left[1] * invlen
		left[2] = left[2] * invlen
		left[3] = left[3] * invlen

		local up = {0, 0, 0}
		up[1] = left[2] * from.z - left[3] * from.y
		up[2] = left[3] * from.x - left[1] * from.z
		up[3] = left[1] * from.y - left[2] * from.x


		local fxx = -from.x * from.x
		local fyy = -from.y * from.y
		local fzz = -from.z * from.z

		local fxy = -from.x * from.y
		local fxz = -from.x * from.z
		local fyz = -from.y * from.z

		local uxx = up[1] * up[1]
		local uyy = up[2] * up[2]
		local uzz = up[3] * up[3]
		local uxy = up[1] * up[2]
		local uxz = up[1] * up[3]
		local uyz = up[2] * up[3]

		local lxx = -left[1] * left[1]
		local lyy = -left[2] * left[2]
		local lzz = -left[3] * left[3]
		local lxy = -left[1] * left[2]
		local lxz = -left[1] * left[3]
		local lyz = -left[2] * left[3]

		local rot =
		{
			{fxx + uxx + lxx, fxy + uxy + lxy, fxz + uxz + lxz},
			{fxy + uxy + lxy, fyy + uyy + lyy, fyz + uyz + lyz},
			{fxz + uxz + lxz, fyz + uyz + lyz, fzz + uzz + lzz},
		}

		MatrixToQuaternion(rot, self)
	else
		local v = FixVector3.Cross(from, to)
		if v:SqrMagnitude() < 1e-6 then
			v = FixVector3.Cross(FixVector3.right(), to)
		end
		local h = (1 - e) / FixVector3.Dot(v, v)

		local hx = h * v.x
		local hz = h * v.z
		local hxy = hx * v.y
		local hxz = hx * v.z
		local hyz = hz * v.y

		local rot =
		{
			{e + hx*v.x, 	hxy - v.z, 		hxz + v.y},
			{hxy + v.z,  	e + h*v.y*v.y, 	hyz-v.x},
			{hxz - v.y,  	hyz + v.x,    	e + hz*v.z},
		}

		MatrixToQuaternion(rot, self)
	end
end

function FixQuaternion:Inverse()
	local quat = FixQuaternion.New()

	quat.x = -self.x
	quat.y = -self.y
	quat.z = -self.z
	quat.w = self.w

	return quat
end


function FixQuaternion:SetIdentity()
	self.x = 0
	self.y = 0
	self.z = 0
	self.w = 1
end


local function Approximately(f0, f1)
	return abs(f0 - f1) < 1e-6
end

function FixQuaternion:ToAngleAxis()
	local angle = 2 * acos(self.w)

	if Approximately(angle, 0) then
		return angle * rad2Deg, FixVector3.New(1, 0, 0)
	end

	local div = 1 / sqrt(1 - sqrt(self.w))
	return angle * rad2Deg, FixVector3.New(self.x * div, self.y * div, self.z * div)
end


function FixQuaternion:Forward()
	return self:MulVec3(FixVector3.forward())
end

function FixQuaternion.MulVec3(self,point)
	
	local vec = FixVector3(0,0,0)
	
	local num 	= GlobalTools:Mul( self.x , GlobalTools:ToFix(2) )
	local num2 	= GlobalTools:Mul( self.y , GlobalTools:ToFix(2) )
	local num3 	= GlobalTools:Mul( self.z , GlobalTools:ToFix(2) )
	local num4 	= GlobalTools:Mul( self.x , num )
	local num5 	= GlobalTools:Mul( self.y , num2 )
	local num6 	= GlobalTools:Mul( self.z , num3 )
	local num7 	= GlobalTools:Mul( self.x , num2 )
	local num8 	= GlobalTools:Mul( self.x , num3 )
	local num9 	= GlobalTools:Mul( self.y , num3 )
	local num10 = GlobalTools:Mul( self.w , num )
	local num11 = GlobalTools:Mul( self.w , num2 )
	local num12 = GlobalTools:Mul( self.w , num3 )
	
	vec.x = GlobalTools:Mul((GlobalTools:ToFix(1) - (num5 + num6)),point.x) + GlobalTools:Mul((num7 - num12), point.y) + GlobalTools:Mul((num8 + num11),point.z)
	vec.y = GlobalTools:Mul((num7 + num12),point.x) + GlobalTools:Mul((GlobalTools:ToFix(1) - (num4 + num6)),point.y) + GlobalTools:Mul((num9 - num10),point.z)
	vec.z = GlobalTools:Mul((num8 - num11),point.x) + GlobalTools:Mul((num9 + num10),point.y) + GlobalTools:Mul((GlobalTools:ToFix(1) - (num4 + num5)),point.z)
	
	return vec
end

function FixQuaternion:toQuaternion()
	local x_float = GlobalTools:ToFloat(self.x)
	local y_float = GlobalTools:ToFloat(self.y)
	local z_float = GlobalTools:ToFloat(self.z)
	local w_float = GlobalTools:ToFloat(self.w)
	return Quaternion(x_float, y_float, z_float, w_float )
end

setmetatable(FixQuaternion, FixQuaternion)
return FixQuaternion