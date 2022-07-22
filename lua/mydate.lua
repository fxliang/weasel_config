require("wnl")
local function mydate()
	-- 计算目标时间的相关信息,输出字符串列表
	function CalcDate(t) 
		local tb = {'星期日','星期一','星期二','星期三','星期四','星期五','星期六'}
		local wkn = os.date("*t", t).wday
		local dateformated = {
			date = os.date("*t", t).year .. '年' .. os.date("*t", t).month .. '月' .. os.date("*t",t).day .. '日',
			dateweekday = os.date("*t",t).year .. '年' .. os.date("*t",t).month .. '月' .. os.date("*t", t).day .. '日' .. tb[wkn],
			lunarday = Lunar(os.date("*t",t).year, os.date("*t",t).month,os.date("*t", t).day),
			weekday = tb[wkn],
			time = os.date("%H:%M"),
			timec = os.date("%H时%M分"),
			timewithdate = os.date("%Y年%m月%d日%H时%M分")
		}
		return dateformated
	end

	function GetNearWeekDayN(n, subfix)
		local cy = tonumber(os.date("%Y", os.time()))
		local cm = tonumber(os.date("%m", os.time()))
		local cd = tonumber(os.date("%d", os.time()))
		local cw = (tonumber(os.date("%w", os.time())) == 0) and 7 or tonumber(os.date("%w", os.time()))
		local offset = (subfix=='z' and (n - cw)) or ((subfix=='x') and ((cw == 0 and 1) or (7-cw+n))) or ((cw == 0 and ( n - 14)) or (n-cw-7))
		return  CalcDate(os.time({year = cy, month = cm, day = cd + offset}))
	end

	function date_translator(input, seg)
		local tb = {'星期日','星期一','星期二','星期三','星期四','星期五','星期六'}
		local t = os.time()
		local res = CalcDate(t)
		if (input == "/date") then
			yield(Candidate("date", seg.start, seg._end, res.date, ""))
			yield(Candidate("date", seg.start, seg._end, res.dateweekday, ""))
			yield(Candidate("weekday", seg.start, seg._end, res.weekday, "" ))
			yield(Candidate("date", seg.start, seg._end, res.lunarday.sz, ""))
			yield(Candidate("date", seg.start, seg._end, res.lunarday.gz, ""))
		elseif (input == "/time") then
			yield(Candidate("time", seg.start, seg._end, res.time, ""))
			yield(Candidate("time", seg.start, seg._end, res.timec, ""))
			yield(Candidate("time", seg.start, seg._end, res.timewithdate, ""))
		elseif string.match(input, "/%d%d%d%d%d%d[0123]%d$") then
			local of = 1
			local yr=string.sub(input, of+1, of+4)
			local mon=string.sub(input, of+5, of+6)
			local day=string.sub(input, of+7, of+8)
			t = os.time({year=yr, month=mon, day=day})
			local res = CalcDate(t)
			yield(Candidate("weekday", seg.start, seg._end, res.date, "日期" ))
			yield(Candidate("weekday", seg.start, seg._end, res.dateweekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.weekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.sz, ""))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.gz, ""))
		elseif string.match(input, "/%d%d%d%d%d%d[0123]%dg$") then
			local date = require("date")
			local of = 1
			local yr  =tonumber(string.sub(input, of+1, of+4))
			local mon =tonumber(string.sub(input, of+5, of+6))
			local day =tonumber(string.sub(input, of+7, of+8))
			local dc = date(false)
			local y,m,d = dc:getdate()
			local d = date.diff(date(yr, mon, day), date(y,m,d))
			local gapstr =   tostring(math.floor(d:spandays()))
			local cmt = "距离今天的日期间隔"
			yield(Candidate("gap", seg.start, seg._end, gapstr, cmt ))

		elseif string.match(input, "/%d%d%d%d%d%d[0123]%d[hq]%d+[^0-9]$") then
			local of = 1
			local yr=string.sub(input, of+1, of+4)
			local mon=string.sub(input, of+5, of+6)
			local day=string.sub(input, of+7, of+8)
			local offset = tonumber(string.sub(input, of+10, string.len(input)-1))
			local subfix = ''
			if string.match(input, "/%d%d%d%d%d%d[0123]%dh%d+d$") then
				t = os.time({year=yr, month=mon, day=day+offset})
				subfix = CalcDate(os.time({year=yr, month = mon, day = day})).date .. '后第' .. offset .. '天'
			else
				t = os.time({year=yr, month=mon, day=day-offset})
				subfix = CalcDate(os.time({year=yr, month = mon, day = day})).date .. '前第' .. offset .. '天'
			end
			local res = CalcDate(t)
			yield(Candidate("weekday", seg.start, seg._end, res.date, subfix ))
			yield(Candidate("weekday", seg.start, seg._end, res.dateweekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.weekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.sz, ""))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.gz, ""))
		elseif string.match(input, '/%d+[hq]') then
			local cy = tonumber(os.date("%Y", unixTime))
			local cm = tonumber(os.date("%m", unixTime))
			local cd = tonumber(os.date("%d", unixTime))
			local str = string.sub(input, 2, string.len(input)-1)
			local subfix = (string.match(input, 'h$') and '天后') or '天前'
			t = (string.match(input, 'h$') and os.time({year=cy, month=cm, day=cd+tonumber(str)})) or os.time({year=cy, month=cm, day=cd-tonumber(str)})
			res = CalcDate(t)
			yield(Candidate("dateoffset", seg.start, seg._end, res.date, str..subfix ))
			yield(Candidate("dateoffset", seg.start, seg._end, res.dateweekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.weekday, "" ))
			yield(Candidate("dateoffset", seg.start, seg._end, res.lunarday.sz, ""))
			yield(Candidate("dateoffset", seg.start, seg._end, res.lunarday.gz, ""))
		elseif string.match(input, '/[1-7][xsz]') then
			local tb2 = {'一','二','三','四','五','六', '日'}
			local wd = tonumber(string.sub(input, 2, string.len(input)-1))
			local le = string.match(input, '[sxz]')
			local prefix = (le=='s' and '上周') or ((le=='x' and '下周') or '这周')
			local res = GetNearWeekDayN(wd, le)
			yield(Candidate("weekday", seg.start, seg._end, res.date, prefix..tb2[wd] ))
			yield(Candidate("weekday", seg.start, seg._end, res.dateweekday, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.sz, "" ))
			yield(Candidate("weekday", seg.start, seg._end, res.lunarday.gz, "" ))
		end
	end

end

return mydate
