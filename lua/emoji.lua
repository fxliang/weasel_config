require("emoji_datas")
-- key as input punct, input prefix and [key] to yield from _start to _end 
local ranges = {
	[""] = { _start = 1,    _end = 1879,       tip = "全部"},
	jt	 = { _start = 487,  _end = 524,        tip = "家庭"},
	dw   = { _start = 539,  _end = 662,        tip = "动物"},
	lx   = { _start = 824,  _end = 1041,       tip = "旅行"},
	che  = { _start = 890,  _end = 961,        tip = "车&交通"}, --
	hd   = { _start = 1042, _end = 1126,       tip = "活动"},
	fh   = { _start = 1388, _end = 1610,       tip = "符号"},
	fs   = { _start = 530,  _end = 538,        tip = "肤色发型"},
	qi   = { _start = 1611, _end = 1879,       tip = "旗帜"},
	wp   = { _start = 1127, _end = 1387,       tip = "物品"},
	sw   = { _start = 691,  _end = 823,        tip = "食物和饮料"},
	xz   = { _start = 1448, _end = 1460,       tip = "星座"},
	zw   = { _start = 673,  _end = 690,        tip = "植物"},
	xl   = { _start = 1,    _end = 166,        tip = "笑脸"},
	yd   = { _start = 1069, _end = 1095,       tip = "运动"},
	yx   = { _start = 1096, _end = 1119,       tip = "游戏"},
	jm   = { _start = 1525, _end = 1537,       tip = "键帽"},
	sb   = { _start = 167,  _end = 206,        tip = "手部动作"},
	rl   = { _start = 167,  _end = 529,        tip = "人类和身体"},
	rw   = { _start = 228,  _end = 486,        tip = "人物"},
	sgsc = { _start = 691,  _end = 726,        tip = "水果蔬菜"},
	ss   = { _start = 727,  _end = 760,        tip = "熟食"},
	jz   = { _start = 840,  _end = 889,        tip = "建筑场所"},
}
local ranges2 = {
	[""] = { _start = 1,    _end = 4526,       tip = "全部"},
	jt	 = { _start = 2620,  _end = 3153,        tip = "家庭"},
	qi   = { _start = 4253, _end = 4526,       tip = "旗帜"},
	dw   = { _start = 3168,  _end = 3320,        tip = "动物"},
	lx   = { _start = 3454,  _end = 3671,       tip = "旅行"},
	che  = { _start = 3520,  _end = 3591,        tip = "车&交通"}, --
	hd   = { _start = 3672, _end = 3756,       tip = "活动"},
	fh   = { _start = 4019, _end = 4252,       tip = "符号"},
	fs   = { _start = 3159,  _end = 3167,        tip = "肤色发型"},
	wp   = { _start = 3757, _end = 4017,       tip = "物品"},
	sw   = { _start = 3321,  _end = 3453,        tip = "食物和饮料"},
	xz   = { _start = 4078, _end = 4090,       tip = "星座"},
	zw   = { _start = 3293,  _end = 3356,        tip = "植物"},
	xl   = { _start = 1,    _end = 172,        tip = "笑脸"},
	yd   = { _start = 3699, _end = 3725,       tip = "运动"},
	yx   = { _start = 3726, _end = 3749,       tip = "游戏"},
	jm   = { _start = 4155, _end = 4179,       tip = "键帽"},
	sb   = { _start = 173,  _end = 450,        tip = "手部动作"},
	rl   = { _start = 173,  _end = 3158,        tip = "人类和身体"},
	rw   = { _start = 499,  _end = 2619,        tip = "人物"},
	sgsc = { _start = 3321,  _end = 3356,        tip = "水果蔬菜"},
	ss   = { _start = 3357,  _end = 3390,        tip = "熟食"},
	jz   = { _start = 3470,  _end = 3519,        tip = "建筑场所"},
}
-- punct start prefix
local prefix = "/em"
local prefix2 = "/aem"

-- calc prompt
local function prompt_str(input, limit, datas, subfix)
	local prompt = ""
	local cnt = 0
	for k, v in pairs(ranges) do
		local cmpl = ((prefix..k):match(input .. "(.+)$"))
		local cand = emoji_candidate_info[ranges[k]._start].cand
		prompt = cmpl and ("%s~%s%s"):format(prompt, cmpl, cand) or prompt
		cnt = cmpl and (cnt + 1) or cnt
		if cnt >= limit then break end
	end
	prompt = datas and "[" .. datas.tip .. subfix .. "] " .. prompt or prompt
	return prompt
end

-- calc prompt2
local function prompt_str2(input, limit, datas)
	local prompt = ""
	local cnt = 0
	for k, v in pairs(ranges) do
		local cmpl = ((prefix2..k):match(input .. "(.+)$"))
		local cand = aemoji_candidate_info[ranges2[k]._start].cand
		prompt = cmpl and ("%s~%s%s"):format(prompt, cmpl, cand) or prompt
		cnt = cmpl and (cnt + 1) or cnt
		if cnt >= limit then break end
	end
	prompt = datas and "[" .. datas.tip .. "] " .. prompt or prompt
	return prompt
end

-- not always work
local function AddSkinColor(emoji, skincode)
    local outemoji = ""
    local codes = {}
    for p, c in utf8.codes(emoji) do table.insert(codes, c) end
    if #codes == 1 then outemoji = emoji .. skincode
    elseif #codes == 3 and codes[2] == 8205 then 
        outemoji  = utf8.char(codes[1]) .. skincode .. utf8.char(codes[2]) .. utf8.char(codes[3])
    elseif #codes == 4 and codes[2] == 8205 then
        outemoji  = utf8.char(codes[1]) .. skincode .. utf8.char(codes[2]) .. utf8.char(codes[3]) .. utf8.char(codes[4])
    elseif #codes == 5 and codes[3] == 8205 then
        outemoji  = utf8.char(codes[1]) .. utf8.char(codes[2])  .. skincode .. utf8.char(codes[3]) .. utf8.char(codes[4]) .. utf8.char(codes[5])
	else
		outemoji = emoji .. skincode
    end
    return outemoji
end

-- translator
local function Emoji_Translator(input, seg, env)
	-- not start with prefix return 
	if (not input:match("^" .. prefix)) and (not input:match("^" .. prefix2)) then return end
	local segment = env.engine.context.composition:back()
	local page_size = env.engine.schema.page_size
	local fsprefix = ""
	local fssbufix = ""
	local datas = nil
	if input:match("^" .. prefix) then
		-- skin color subfix with start, prepare strings and datas
		-- jq,	  zq,    zd,    zs,    js
		-- 1f3fb, 1f3fc, 1f3fd, 1f3fe, 1f3ff
		if input:match(prefix .. "(%w+)jq$") then
			datas = ranges[ input:match(prefix .. "(%w+)jq$") ]
			fsprefix = utf8.char(0x1f3fb)
			fssbufix = "-较浅"
		elseif input:match(prefix .. "(%w+)zq$") then
			datas = ranges[ input:match(prefix .. "(%w+)zq$") ]
			fsprefix = utf8.char(0x1f3fc)
			fssbufix = "-中浅"
		elseif input:match(prefix .. "(%w+)zd$") then
			datas = ranges[ input:match(prefix .. "(%w+)zd$") ]
			fsprefix = utf8.char(0x1f3fd)
			fssbufix = "-中等"
		elseif input:match(prefix .. "(%w+)zs$") then
			datas = ranges[ input:match(prefix .. "(%w+)zs$") ]
			fsprefix = utf8.char(0x1f3fe)
			fssbufix = "-中深"
		elseif input:match(prefix .. "(%w+)js$") then
			datas = ranges[ input:match(prefix .. "(%w+)js$") ]
			fsprefix = utf8.char(0x1f3ff)
			fssbufix = "-较深"
		elseif input:match(prefix .. "(.*)$") then
			datas = ranges[ input:match(prefix .. "(.*)$") ]
		end
		-- skin color subfix with end
		-- prompt string
		segment.prompt = prompt_str(input, page_size, datas, fssbufix)
	elseif input:match("^" .. prefix2) then
		datas = ranges2[ input:match(prefix2 .. "(.*)$") ]
		-- prompt string
		segment.prompt = prompt_str2(input, page_size, datas)
	end
	-- not matched, return
	if not datas then return end
	-- yield candidates
	if input:match("^" .. prefix) then 
		for idx = datas._start, datas._end do
			local candtxt = AddSkinColor(emoji_candidate_info[idx].cand, fsprefix)
			yield(Candidate("emoji", seg._start, seg._end, candtxt, emoji_candidate_info[idx].comment))
		end
	elseif input:match("^" .. prefix2) then
		for idx = datas._start, datas._end do
			yield(Candidate("emoji", seg._start, seg._end, aemoji_candidate_info[idx].cand, aemoji_candidate_info[idx].comment))
		end
	end
end

local function Emoji_Tips()
	local tips = ""
	for k,v in pairs(ranges) do
		tips = tips .. (prefix .. k) .. "\t" .. v.tip .. "\r"
	end
	tips = string.sub(tips, 1, #tips - 1)
	return tips
end

return {func = Emoji_Translator, emoji_tips = Emoji_Tips}
