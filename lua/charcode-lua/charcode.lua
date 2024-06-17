local char, byte, gmatch, sub, upper = string.char, string.byte, string.gmatch, string.sub, string.upper
local next, pairs, ipairs, type, assert = next, pairs, ipairs, type, assert
local floor = math.floor
local stdin, stdout, stderr, open, close, read, write = io.stdin, io.stdout, io.stderr, io.open, io.close, io.read,
io.write
local table_insert, table_concat = table.insert, table.concat
local unpack = table.unpack or unpack
local utf8 = require('utf8')

-- maybe it should be modified :)
package.path = package.path .. ';?.lua'

-- convert utf-8 string to unicode array
local function utf8_string_to_unicode_array(ustring)
  local arr = {}
  if not ustring then return arr end
  for _, cp in utf8.codes(ustring) do
    table_insert(arr, cp)
  end
  return arr
end

-- check if a char is cjk character
local function is_extended_cjk(ch)
  if not ch then return false end
  return ((ch >= 0x3400 and ch <= 0x4DBF) or  -- CJK Unified Ideographs Extension A
  (ch >= 0x20000 and ch <= 0x2A6DF) or    -- CJK Unified Ideographs Extension B
  (ch >= 0x2A700 and ch <= 0x2B73F) or    -- CJK Unified Ideographs Extension C
  (ch >= 0x2B740 and ch <= 0x2B81F) or    -- CJK Unified Ideographs Extension D
  (ch >= 0x2B820 and ch <= 0x2CEAF) or    -- CJK Unified Ideographs Extension E
  (ch >= 0x2CEB0 and ch <= 0x2EBEF) or    -- CJK Unified Ideographs Extension F
  (ch >= 0x30000 and ch <= 0x3134F) or    -- CJK Unified Ideographs Extension G
  (ch >= 0x31350 and ch <= 0x323AF) or    -- CJK Unified Ideographs Extension H
  (ch >= 0x2EBF0 and ch <= 0x2EE5D) or    -- CJK Unified Ideographs Extension I
  (ch >= 0x3300 and ch <= 0x33FF) or      -- CJK Compatibility
  (ch >= 0xFE30 and ch <= 0xFE4F) or      -- CJK Compatibility Forms
  (ch >= 0xF900 and ch <= 0xFAFF) or      -- CJK Compatibility Ideographs
  (ch >= 0x2F800 and ch <= 0x2FA1F))      -- CJK Compatibility Ideographs Supplement
end

-- if str contains extended cjk
local function contains_extended_cjk(str)
  local cpArray = utf8_string_to_unicode_array(str)
  for i = 1, #str do
    if is_extended_cjk(cpArray[i]) then return true end
  end
  return false
end

-- logic in librime/src/rime/gear/charset_filter.cc, CharsetFilter::FilterText
local function CharsetFilterFilter_FilterText(text)
  return not contains_extended_cjk(text)
end

-- normalize charset names
local function normalize_charset_name(charset)
  local correct_charset = (type(charset) == 'string') and charset:gsub("-", "_"):upper() or charset
  local charset_names = {
    ["GSM"] = "GSM0338",
    -- cstools:cstocs
    ["UTF8"] = "UTF_8",
    ["GBK"] = "CP936",
    ["GB2312"] = "GB2312",
    ["BIG5"] = "CP950",
    ["IL1"] = "8859_1",
    ["IL2"] = "8859_2",
    ["PC1"] = "CP850",
    ["PC2"] = "CP852",
    ["1250"] = "CP1250",
    ["1252"] = "CP1252",
    ["MACCE"] = "MAC_CENTEURO",
    -- konwert
    ["ISO1"] = "8859_1",
    ["ISO2"] = "8859_2",
    ["ISO3"] = "8859_3",
    ["ISO4"] = "8859_4",
    ["ISO5"] = "8859_5",
    ["ISO6"] = "8859_6",
    ["ISO7"] = "8859_7",
    ["ISO8"] = "8859_8",
    ["ISO9"] = "8859_9",
    ["ISO10"] = "8859_10",
    ["ISO11"] = "8859_11",
    ["ISO12"] = "8859_12",
    ["ISO13"] = "8859_13",
    ["ISO14"] = "8859_14",
    ["ISO15"] = "8859_15",
    ["ISO16"] = "8859_16",
    ["ISOLATIN1"] = "8859_1",
    ["ISOLATIN2"] = "8859_2",
    ["ISOLATIN3"] = "8859_3",
    ["ISOLATIN4"] = "8859_4",
    ["ISOLATIN5"] = "8859_5",
    ["ISOLATIN6"] = "8859_6",
    ["ISOLATIN7"] = "8859_7",
    ["ISOLATIN8"] = "8859_8",
    ["ISOLATIN9"] = "8859_9",
    ["DOSGREEK"] = "CP737",
    ["DOSBALTIC"] = "CP775",
    ["DOSLATIN1"] = "CP850",
    ["DOSLATIN2"] = "CP852",
    ["DOSCYR"] = "CP855",
    ["DOSTUR"] = "CP857",
    ["DOSICELAND"] = "CP861",
    ["DOSHEBREW"] = "CP862",
    ["DOSCANADAFR"] = "CP863",
    ["DOSARABIC"] = "CP864",
    ["DOSNORDIC"] = "CP865",
    ["DOSRUSSIAN"] = "CP866",
    ["DOSGREEK2"] = "CP869",
    ["DOSTHAI"] = "CP874",
    ["WINLATIN2"] = "CP1250",
    ["WINLATIN1"] = "CP1252",
    ["WINCYR"] = "CP1251",
    ["WINGREEK"] = "CP1253",
    ["WINTUR"] = "CP1254",
    ["WINHEBREW"] = "CP1255",
    ["WINARABIC"] = "CP1256",
    ["WINBALTIC"] = "CP1257",
    ["WINVIET"] = "CP1258",
    ["KOI8R"] = "KOI8_R",
    ["KOI8U"] = "KOI8_U",
    ["HTMLENT"] = "SGML",
    -- iconv
    ["437"] = "CP427",
    ["850"] = "CP850",
    ["852"] = "CP852",
    ["855"] = "CP855",
    ["857"] = "CP857",
    ["860"] = "CP860",
    ["861"] = "CP861",
    ["862"] = "CP862",
    ["863"] = "CP863",
    ["864"] = "CP864",
    ["865"] = "CP865",
    ["866"] = "CP866",
    ["869"] = "CP869",
    ["874"] = "CP874",
    ["ISO8859_1"] = "8859_1",
    ["ISO8859_2"] = "8859_2",
    ["ISO8859_3"] = "8859_3",
    ["ISO8859_4"] = "8859_4",
    ["ISO8859_5"] = "8859_5",
    ["ISO8859_6"] = "8859_6",
    ["ISO8859_7"] = "8859_7",
    ["ISO8859_8"] = "8859_8",
    ["ISO8859_9"] = "8859_9",
    ["ISO8859_10"] = "8859_10",
    ["ISO8859_11"] = "8859_11",
    ["ISO8859_12"] = "8859_12",
    ["ISO8859_13"] = "8859_13",
    ["ISO8859_14"] = "8859_14",
    ["ISO8859_15"] = "8859_15",
    ["ISO8859_16"] = "8859_16",
    ["ISO_8859_1"] = "8859_1",
    ["ISO_8859_2"] = "8859_2",
    ["ISO_8859_3"] = "8859_3",
    ["ISO_8859_4"] = "8859_4",
    ["ISO_8859_5"] = "8859_5",
    ["ISO_8859_6"] = "8859_6",
    ["ISO_8859_7"] = "8859_7",
    ["ISO_8859_8"] = "8859_8",
    ["ISO_8859_9"] = "8859_9",
    ["ISO_8859_10"] = "8859_10",
    ["ISO_8859_11"] = "8859_11",
    ["ISO_8859_12"] = "8859_12",
    ["ISO_8859_13"] = "8859_13",
    ["ISO_8859_14"] = "8859_14",
    ["ISO_8859_15"] = "8859_15",
    ["ISO_8859_16"] = "8859_16",
    ["LATIN1"] = "8859_1",
    ["LATIN2"] = "8859_2",
    ["LATIN3"] = "8859_3",
    ["LATIN4"] = "8859_4",
    ["LATIN5"] = "8859_5",
    ["LATIN6"] = "8859_6",
    ["LATIN7"] = "8859_7",
    ["LATIN8"] = "8859_8",
    ["LATIN9"] = "8859_9",
    ["LATIN10"] = "8859_10",
    ["L1"] = "8859_1",
    ["L2"] = "8859_2",
    ["L3"] = "8859_3",
    ["L4"] = "8859_4",
    ["L5"] = "8859_5",
    ["L6"] = "8859_6",
    ["L7"] = "8859_7",
    ["L8"] = "8859_8",
    ["L9"] = "8859_9",
    ["L10"] = "8859_10",
    ["WINDOWS_874"] = "CP874",
    ["WINDOWS_1250"] = "CP1250",
    ["WINDOWS_1251"] = "CP1251",
    ["WINDOWS_1252"] = "CP1252",
    ["WINDOWS_1253"] = "CP1253",
    ["WINDOWS_1254"] = "CP1254",
    ["WINDOWS_1255"] = "CP1255",
    ["WINDOWS_1256"] = "CP1256",
    ["WINDOWS_1257"] = "CP1257",
    ["WINDOWS_1258"] = "CP1258",
    -- mime
    ["US_ASCII"] = "ASCII",
  }
  return charset_names[correct_charset] or correct_charset
end
--check if unicode char ch is emoji
local function is_emoji(ch)
  if not ch then return false end
  --emoji data from http://www.unicode.org/Public/emoji/12.0/emoji-data.txt
  return ((ch == 0x0023) or
  (ch == 0x002A) or
  (ch >= 0x0030 and ch <= 0x0039) or
  (ch == 0x00A9) or
  (ch == 0x00AE) or
  (ch == 0x203C) or
  (ch == 0x2049) or
  (ch == 0x2122) or
  (ch == 0x2139) or
  (ch >= 0x2194 and ch <= 0x2199) or
  (ch >= 0x21A9 and ch <= 0x21AA) or
  (ch >= 0x231A and ch <= 0x231B) or
  (ch == 0x2328) or
  (ch == 0x23CF) or
  (ch >= 0x23E9 and ch <= 0x23F3) or
  (ch >= 0x23F8 and ch <= 0x23FA) or
  (ch == 0x24C2) or
  (ch >= 0x25AA and ch <= 0x25AB) or
  (ch == 0x25B6) or
  (ch == 0x25C0) or
  (ch >= 0x25FB and ch <= 0x25FE) or
  (ch >= 0x2600 and ch <= 0x2604) or
  (ch == 0x260E) or
  (ch == 0x2611) or
  (ch >= 0x2614 and ch <= 0x2615) or
  (ch == 0x2618) or
  (ch == 0x261D) or
  (ch == 0x2620) or
  (ch >= 0x2622 and ch <= 0x2623) or
  (ch == 0x2626) or
  (ch == 0x262A) or
  (ch >= 0x262E and ch <= 0x262F) or
  (ch >= 0x2638 and ch <= 0x263A) or
  (ch == 0x2640) or
  (ch == 0x2642) or
  (ch >= 0x2648 and ch <= 0x2653) or
  (ch >= 0x265F and ch <= 0x2660) or
  (ch == 0x2663) or
  (ch >= 0x2665 and ch <= 0x2666) or
  (ch == 0x2668) or
  (ch == 0x267B) or
  (ch >= 0x267E and ch <= 0x267F) or
  (ch >= 0x2692 and ch <= 0x2697) or
  (ch == 0x2699) or
  (ch >= 0x269B and ch <= 0x269C) or
  (ch >= 0x26A0 and ch <= 0x26A1) or
  (ch >= 0x26AA and ch <= 0x26AB) or
  (ch >= 0x26B0 and ch <= 0x26B1) or
  (ch >= 0x26BD and ch <= 0x26BE) or
  (ch >= 0x26C4 and ch <= 0x26C5) or
  (ch == 0x26C8) or
  (ch == 0x26CE) or
  (ch == 0x26CF) or
  (ch == 0x26D1) or
  (ch >= 0x26D3 and ch <= 0x26D4) or
  (ch >= 0x26E9 and ch <= 0x26EA) or
  (ch >= 0x26F0 and ch <= 0x26F5) or
  (ch >= 0x26F7 and ch <= 0x26FA) or
  (ch == 0x26FD) or
  (ch == 0x2702) or
  (ch == 0x2705) or
  (ch >= 0x2708 and ch <= 0x2709) or
  (ch >= 0x270A and ch <= 0x270B) or
  (ch >= 0x270C and ch <= 0x270D) or
  (ch == 0x270F) or
  (ch == 0x2712) or
  (ch == 0x2714) or
  (ch == 0x2716) or
  (ch == 0x271D) or
  (ch == 0x2721) or
  (ch == 0x2728) or
  (ch >= 0x2733 and ch <= 0x2734) or
  (ch == 0x2744) or
  (ch == 0x2747) or
  (ch == 0x274C) or
  (ch == 0x274E) or
  (ch >= 0x2753 and ch <= 0x2755) or
  (ch == 0x2757) or
  (ch >= 0x2763 and ch <= 0x2764) or
  (ch >= 0x2795 and ch <= 0x2797) or
  (ch == 0x27A1) or
  (ch == 0x27B0) or
  (ch == 0x27BF) or
  (ch >= 0x2934 and ch <= 0x2935) or
  (ch >= 0x2B05 and ch <= 0x2B07) or
  (ch >= 0x2B1B and ch <= 0x2B1C) or
  (ch == 0x2B50) or
  (ch == 0x2B55) or
  (ch == 0x3030) or
  (ch == 0x303D) or
  (ch == 0x3297) or
  (ch == 0x3299) or
  (ch == 0x1F004) or
  (ch == 0x1F0CF) or
  (ch >= 0x1F170 and ch <= 0x1F171) or
  (ch == 0x1F17E) or
  (ch == 0x1F17F) or
  (ch == 0x1F18E) or
  (ch >= 0x1F191 and ch <= 0x1F19A) or
  (ch >= 0x1F1E6 and ch <= 0x1F1FF) or
  (ch >= 0x1F201 and ch <= 0x1F202) or
  (ch == 0x1F21A) or
  (ch == 0x1F22F) or
  (ch >= 0x1F232 and ch <= 0x1F23A) or
  (ch >= 0x1F250 and ch <= 0x1F251) or
  (ch >= 0x1F300 and ch <= 0x1F320) or
  (ch == 0x1F321) or
  (ch >= 0x1F324 and ch <= 0x1F32C) or
  (ch >= 0x1F32D and ch <= 0x1F32F) or
  (ch >= 0x1F330 and ch <= 0x1F335) or
  (ch == 0x1F336) or
  (ch >= 0x1F337 and ch <= 0x1F37C) or
  (ch == 0x1F37D) or
  (ch >= 0x1F37E and ch <= 0x1F37F) or
  (ch >= 0x1F380 and ch <= 0x1F393) or
  (ch >= 0x1F396 and ch <= 0x1F397) or
  (ch >= 0x1F399 and ch <= 0x1F39B) or
  (ch >= 0x1F39E and ch <= 0x1F39F) or
  (ch >= 0x1F3A0 and ch <= 0x1F3C4) or
  (ch == 0x1F3C5) or
  (ch >= 0x1F3C6 and ch <= 0x1F3CA) or
  (ch >= 0x1F3CB and ch <= 0x1F3CE) or
  (ch >= 0x1F3CF and ch <= 0x1F3D3) or
  (ch >= 0x1F3D4 and ch <= 0x1F3DF) or
  (ch >= 0x1F3E0 and ch <= 0x1F3F0) or
  (ch >= 0x1F3F3 and ch <= 0x1F3F5) or
  (ch == 0x1F3F7) or
  (ch >= 0x1F3F8 and ch <= 0x1F3FF) or
  (ch >= 0x1F400 and ch <= 0x1F43E) or
  (ch == 0x1F43F) or
  (ch == 0x1F440) or
  (ch == 0x1F441) or
  (ch >= 0x1F442 and ch <= 0x1F4F7) or
  (ch == 0x1F4F8) or
  (ch >= 0x1F4F9 and ch <= 0x1F4FC) or
  (ch == 0x1F4FD) or
  (ch == 0x1F4FF) or
  (ch >= 0x1F500 and ch <= 0x1F53D) or
  (ch >= 0x1F549 and ch <= 0x1F54A) or
  (ch >= 0x1F54B and ch <= 0x1F54E) or
  (ch >= 0x1F550 and ch <= 0x1F567) or
  (ch >= 0x1F56F and ch <= 0x1F570) or
  (ch >= 0x1F573 and ch <= 0x1F579) or
  (ch == 0x1F57A) or
  (ch == 0x1F587) or
  (ch >= 0x1F58A and ch <= 0x1F58D) or
  (ch == 0x1F590) or
  (ch >= 0x1F595 and ch <= 0x1F596) or
  (ch == 0x1F5A4) or
  (ch == 0x1F5A5) or
  (ch == 0x1F5A8) or
  (ch >= 0x1F5B1 and ch <= 0x1F5B2) or
  (ch == 0x1F5BC) or
  (ch >= 0x1F5C2 and ch <= 0x1F5C4) or
  (ch >= 0x1F5D1 and ch <= 0x1F5D3) or
  (ch >= 0x1F5DC and ch <= 0x1F5DE) or
  (ch == 0x1F5E1) or
  (ch == 0x1F5E3) or
  (ch == 0x1F5E8) or
  (ch == 0x1F5EF) or
  (ch == 0x1F5F3) or
  (ch == 0x1F5FA) or
  (ch >= 0x1F5FB and ch <= 0x1F5FF) or
  (ch == 0x1F600) or
  (ch >= 0x1F601 and ch <= 0x1F610) or
  (ch == 0x1F611) or
  (ch >= 0x1F612 and ch <= 0x1F614) or
  (ch == 0x1F615) or
  (ch == 0x1F616) or
  (ch == 0x1F617) or
  (ch == 0x1F618) or
  (ch == 0x1F619) or
  (ch == 0x1F61A) or
  (ch == 0x1F61B) or
  (ch >= 0x1F61C and ch <= 0x1F61E) or
  (ch == 0x1F61F) or
  (ch >= 0x1F620 and ch <= 0x1F625) or
  (ch >= 0x1F626 and ch <= 0x1F627) or
  (ch >= 0x1F628 and ch <= 0x1F62B) or
  (ch == 0x1F62C) or
  (ch == 0x1F62D) or
  (ch >= 0x1F62E and ch <= 0x1F62F) or
  (ch >= 0x1F630 and ch <= 0x1F633) or
  (ch == 0x1F634) or
  (ch >= 0x1F635 and ch <= 0x1F640) or
  (ch >= 0x1F641 and ch <= 0x1F642) or
  (ch >= 0x1F643 and ch <= 0x1F644) or
  (ch >= 0x1F645 and ch <= 0x1F64F) or
  (ch >= 0x1F680 and ch <= 0x1F6C5) or
  (ch >= 0x1F6CB and ch <= 0x1F6CF) or
  (ch == 0x1F6D0) or
  (ch >= 0x1F6D1 and ch <= 0x1F6D2) or
  (ch == 0x1F6D5) or
  (ch >= 0x1F6E0 and ch <= 0x1F6E5) or
  (ch == 0x1F6E9) or
  (ch >= 0x1F6EB and ch <= 0x1F6EC) or
  (ch == 0x1F6F0) or
  (ch == 0x1F6F3) or
  (ch >= 0x1F6F4 and ch <= 0x1F6F6) or
  (ch >= 0x1F6F7 and ch <= 0x1F6F8) or
  (ch == 0x1F6F9) or
  (ch == 0x1F6FA) or
  (ch >= 0x1F7E0 and ch <= 0x1F7EB) or
  (ch >= 0x1F90D and ch <= 0x1F90F) or
  (ch >= 0x1F910 and ch <= 0x1F918) or
  (ch >= 0x1F919 and ch <= 0x1F91E) or
  (ch == 0x1F91F) or
  (ch >= 0x1F920 and ch <= 0x1F927) or
  (ch >= 0x1F928 and ch <= 0x1F92F) or
  (ch == 0x1F930) or
  (ch >= 0x1F931 and ch <= 0x1F932) or
  (ch >= 0x1F933 and ch <= 0x1F93A) or
  (ch >= 0x1F93C and ch <= 0x1F93E) or
  (ch == 0x1F93F) or
  (ch >= 0x1F940 and ch <= 0x1F945) or
  (ch >= 0x1F947 and ch <= 0x1F94B) or
  (ch == 0x1F94C) or
  (ch >= 0x1F94D and ch <= 0x1F94F) or
  (ch >= 0x1F950 and ch <= 0x1F95E) or
  (ch >= 0x1F95F and ch <= 0x1F96B) or
  (ch >= 0x1F96C and ch <= 0x1F970) or
  (ch == 0x1F971) or
  (ch >= 0x1F973 and ch <= 0x1F976) or
  (ch == 0x1F97A) or
  (ch == 0x1F97B) or
  (ch >= 0x1F97C and ch <= 0x1F97F) or
  (ch >= 0x1F980 and ch <= 0x1F984) or
  (ch >= 0x1F985 and ch <= 0x1F991) or
  (ch >= 0x1F992 and ch <= 0x1F997) or
  (ch >= 0x1F998 and ch <= 0x1F9A2) or
  (ch >= 0x1F9A5 and ch <= 0x1F9AA) or
  (ch >= 0x1F9AE and ch <= 0x1F9AF) or
  (ch >= 0x1F9B0 and ch <= 0x1F9B9) or
  (ch >= 0x1F9BA and ch <= 0x1F9BF) or
  (ch == 0x1F9C0) or
  (ch >= 0x1F9C1 and ch <= 0x1F9C2) or
  (ch >= 0x1F9C3 and ch <= 0x1F9CA) or
  (ch >= 0x1F9CD and ch <= 0x1F9CF) or
  (ch >= 0x1F9D0 and ch <= 0x1F9E6) or
  (ch >= 0x1F9E7 and ch <= 0x1F9FF) or
  (ch >= 0x1FA70 and ch <= 0x1FA73) or
  (ch >= 0x1FA78 and ch <= 0x1FA7A) or
  (ch >= 0x1FA80 and ch <= 0x1FA82) or
  (ch >= 0x1FA90 and ch <= 0x1FA95) or
  (ch >= 0x231A and ch <= 0x231B) or
  (ch >= 0x23E9 and ch <= 0x23EC) or
  (ch == 0x23F0) or
  (ch == 0x23F3) or
  (ch >= 0x25FD and ch <= 0x25FE) or
  (ch >= 0x2614 and ch <= 0x2615) or
  (ch >= 0x2648 and ch <= 0x2653) or
  (ch == 0x267F) or
  (ch == 0x2693) or
  (ch == 0x26A1) or
  (ch >= 0x26AA and ch <= 0x26AB) or
  (ch >= 0x26BD and ch <= 0x26BE) or
  (ch >= 0x26C4 and ch <= 0x26C5) or
  (ch == 0x26CE) or
  (ch == 0x26D4) or
  (ch == 0x26EA) or
  (ch >= 0x26F2 and ch <= 0x26F3) or
  (ch == 0x26F5) or
  (ch == 0x26FA) or
  (ch == 0x26FD) or
  (ch == 0x2705) or
  (ch >= 0x270A and ch <= 0x270B) or
  (ch == 0x2728) or
  (ch == 0x274C) or
  (ch == 0x274E) or
  (ch >= 0x2753 and ch <= 0x2755) or
  (ch == 0x2757) or
  (ch >= 0x2795 and ch <= 0x2797) or
  (ch == 0x27B0) or
  (ch == 0x27BF) or
  (ch >= 0x2B1B and ch <= 0x2B1C) or
  (ch == 0x2B50) or
  (ch == 0x2B55) or
  (ch == 0x1F004) or
  (ch == 0x1F0CF) or
  (ch == 0x1F18E) or
  (ch >= 0x1F191 and ch <= 0x1F19A) or
  (ch >= 0x1F1E6 and ch <= 0x1F1FF) or
  (ch == 0x1F201) or
  (ch == 0x1F21A) or
  (ch == 0x1F22F) or
  (ch >= 0x1F232 and ch <= 0x1F236) or
  (ch >= 0x1F238 and ch <= 0x1F23A) or
  (ch >= 0x1F250 and ch <= 0x1F251) or
  (ch >= 0x1F300 and ch <= 0x1F320) or
  (ch >= 0x1F32D and ch <= 0x1F32F) or
  (ch >= 0x1F330 and ch <= 0x1F335) or
  (ch >= 0x1F337 and ch <= 0x1F37C) or
  (ch >= 0x1F37E and ch <= 0x1F37F) or
  (ch >= 0x1F380 and ch <= 0x1F393) or
  (ch >= 0x1F3A0 and ch <= 0x1F3C4) or
  (ch == 0x1F3C5) or
  (ch >= 0x1F3C6 and ch <= 0x1F3CA) or
  (ch >= 0x1F3CF and ch <= 0x1F3D3) or
  (ch >= 0x1F3E0 and ch <= 0x1F3F0) or
  (ch == 0x1F3F4) or
  (ch >= 0x1F3F8 and ch <= 0x1F3FF) or
  (ch >= 0x1F400 and ch <= 0x1F43E) or
  (ch == 0x1F440) or
  (ch >= 0x1F442 and ch <= 0x1F4F7) or
  (ch == 0x1F4F8) or
  (ch >= 0x1F4F9 and ch <= 0x1F4FC) or
  (ch == 0x1F4FF) or
  (ch >= 0x1F500 and ch <= 0x1F53D) or
  (ch >= 0x1F54B and ch <= 0x1F54E) or
  (ch >= 0x1F550 and ch <= 0x1F567) or
  (ch == 0x1F57A) or
  (ch >= 0x1F595 and ch <= 0x1F596) or
  (ch == 0x1F5A4) or
  (ch >= 0x1F5FB and ch <= 0x1F5FF) or
  (ch == 0x1F600) or
  (ch >= 0x1F601 and ch <= 0x1F610) or
  (ch == 0x1F611) or
  (ch >= 0x1F612 and ch <= 0x1F614) or
  (ch == 0x1F615) or
  (ch == 0x1F616) or
  (ch == 0x1F617) or
  (ch == 0x1F618) or
  (ch == 0x1F619) or
  (ch == 0x1F61A) or
  (ch == 0x1F61B) or
  (ch >= 0x1F61C and ch <= 0x1F61E) or
  (ch == 0x1F61F) or
  (ch >= 0x1F620 and ch <= 0x1F625) or
  (ch >= 0x1F626 and ch <= 0x1F627) or
  (ch >= 0x1F628 and ch <= 0x1F62B) or
  (ch == 0x1F62C) or
  (ch == 0x1F62D) or
  (ch >= 0x1F62E and ch <= 0x1F62F) or
  (ch >= 0x1F630 and ch <= 0x1F633) or
  (ch == 0x1F634) or
  (ch >= 0x1F635 and ch <= 0x1F640) or
  (ch >= 0x1F641 and ch <= 0x1F642) or
  (ch >= 0x1F643 and ch <= 0x1F644) or
  (ch >= 0x1F645 and ch <= 0x1F64F) or
  (ch >= 0x1F680 and ch <= 0x1F6C5) or
  (ch == 0x1F6CC) or
  (ch == 0x1F6D0) or
  (ch >= 0x1F6D1 and ch <= 0x1F6D2) or
  (ch == 0x1F6D5) or
  (ch >= 0x1F6EB and ch <= 0x1F6EC) or
  (ch >= 0x1F6F4 and ch <= 0x1F6F6) or
  (ch >= 0x1F6F7 and ch <= 0x1F6F8) or
  (ch == 0x1F6F9) or
  (ch == 0x1F6FA) or
  (ch >= 0x1F7E0 and ch <= 0x1F7EB) or
  (ch >= 0x1F90D and ch <= 0x1F90F) or
  (ch >= 0x1F910 and ch <= 0x1F918) or
  (ch >= 0x1F919 and ch <= 0x1F91E) or
  (ch == 0x1F91F) or
  (ch >= 0x1F920 and ch <= 0x1F927) or
  (ch >= 0x1F928 and ch <= 0x1F92F) or
  (ch == 0x1F930) or
  (ch >= 0x1F931 and ch <= 0x1F932) or
  (ch >= 0x1F933 and ch <= 0x1F93A) or
  (ch >= 0x1F93C and ch <= 0x1F93E) or
  (ch == 0x1F93F) or
  (ch >= 0x1F940 and ch <= 0x1F945) or
  (ch >= 0x1F947 and ch <= 0x1F94B) or
  (ch == 0x1F94C) or
  (ch >= 0x1F94D and ch <= 0x1F94F) or
  (ch >= 0x1F950 and ch <= 0x1F95E) or
  (ch >= 0x1F95F and ch <= 0x1F96B) or
  (ch >= 0x1F96C and ch <= 0x1F970) or
  (ch == 0x1F971) or
  (ch >= 0x1F973 and ch <= 0x1F976) or
  (ch == 0x1F97A) or
  (ch == 0x1F97B) or
  (ch >= 0x1F97C and ch <= 0x1F97F) or
  (ch >= 0x1F980 and ch <= 0x1F984) or
  (ch >= 0x1F985 and ch <= 0x1F991) or
  (ch >= 0x1F992 and ch <= 0x1F997) or
  (ch >= 0x1F998 and ch <= 0x1F9A2) or
  (ch >= 0x1F9A5 and ch <= 0x1F9AA) or
  (ch >= 0x1F9AE and ch <= 0x1F9AF) or
  (ch >= 0x1F9B0 and ch <= 0x1F9B9) or
  (ch >= 0x1F9BA and ch <= 0x1F9BF) or
  (ch == 0x1F9C0) or
  (ch >= 0x1F9C1 and ch <= 0x1F9C2) or
  (ch >= 0x1F9C3 and ch <= 0x1F9CA) or
  (ch >= 0x1F9CD and ch <= 0x1F9CF) or
  (ch >= 0x1F9D0 and ch <= 0x1F9E6) or
  (ch >= 0x1F9E7 and ch <= 0x1F9FF) or
  (ch >= 0x1FA70 and ch <= 0x1FA73) or
  (ch >= 0x1FA78 and ch <= 0x1FA7A) or
  (ch >= 0x1FA80 and ch <= 0x1FA82) or
  (ch >= 0x1FA90 and ch <= 0x1FA95) or
  (ch >= 0x1F3FB and ch <= 0x1F3FF) or
  (ch == 0x261D) or
  (ch == 0x26F9) or
  (ch >= 0x270A and ch <= 0x270B) or
  (ch >= 0x270C and ch <= 0x270D) or
  (ch == 0x1F385) or
  (ch >= 0x1F3C2 and ch <= 0x1F3C4) or
  (ch == 0x1F3C7) or
  (ch == 0x1F3CA) or
  (ch >= 0x1F3CB and ch <= 0x1F3CC) or
  (ch >= 0x1F442 and ch <= 0x1F443) or
  (ch >= 0x1F446 and ch <= 0x1F450) or
  (ch >= 0x1F466 and ch <= 0x1F478) or
  (ch == 0x1F47C) or
  (ch >= 0x1F481 and ch <= 0x1F483) or
  (ch >= 0x1F485 and ch <= 0x1F487) or
  (ch == 0x1F48F) or
  (ch == 0x1F491) or
  (ch == 0x1F4AA) or
  (ch >= 0x1F574 and ch <= 0x1F575) or
  (ch == 0x1F57A) or
  (ch == 0x1F590) or
  (ch >= 0x1F595 and ch <= 0x1F596) or
  (ch >= 0x1F645 and ch <= 0x1F647) or
  (ch >= 0x1F64B and ch <= 0x1F64F) or
  (ch == 0x1F6A3) or
  (ch >= 0x1F6B4 and ch <= 0x1F6B6) or
  (ch == 0x1F6C0) or
  (ch == 0x1F6CC) or
  (ch == 0x1F90F) or
  (ch == 0x1F918) or
  (ch >= 0x1F919 and ch <= 0x1F91E) or
  (ch == 0x1F91F) or
  (ch == 0x1F926) or
  (ch == 0x1F930) or
  (ch >= 0x1F931 and ch <= 0x1F932) or
  (ch >= 0x1F933 and ch <= 0x1F939) or
  (ch >= 0x1F93C and ch <= 0x1F93E) or
  (ch >= 0x1F9B5 and ch <= 0x1F9B6) or
  (ch >= 0x1F9B8 and ch <= 0x1F9B9) or
  (ch == 0x1F9BB) or
  (ch >= 0x1F9CD and ch <= 0x1F9CF) or
  (ch >= 0x1F9D1 and ch <= 0x1F9DD) or
  (ch == 0x0023) or
  (ch == 0x002A) or
  (ch >= 0x0030 and ch <= 0x0039) or
  (ch == 0x200D) or
  (ch == 0x20E3) or
  (ch == 0xFE0F) or
  (ch >= 0x1F1E6 and ch <= 0x1F1FF) or
  (ch >= 0x1F3FB and ch <= 0x1F3FF) or
  (ch >= 0x1F9B0 and ch <= 0x1F9B3) or
  (ch >= 0xE0020 and ch <= 0xE007F) or
  (ch == 0x00A9) or
  (ch == 0x00AE) or
  (ch == 0x203C) or
  (ch == 0x2049) or
  (ch == 0x2122) or
  (ch == 0x2139) or
  (ch >= 0x2194 and ch <= 0x2199) or
  (ch >= 0x21A9 and ch <= 0x21AA) or
  (ch >= 0x231A and ch <= 0x231B) or
  (ch == 0x2328) or
  (ch == 0x2388) or
  (ch == 0x23CF) or
  (ch >= 0x23E9 and ch <= 0x23F3) or
  (ch >= 0x23F8 and ch <= 0x23FA) or
  (ch == 0x24C2) or
  (ch >= 0x25AA and ch <= 0x25AB) or
  (ch == 0x25B6) or
  (ch == 0x25C0) or
  (ch >= 0x25FB and ch <= 0x25FE) or
  (ch >= 0x2600 and ch <= 0x2605) or
  (ch >= 0x2607 and ch <= 0x2612) or
  (ch >= 0x2614 and ch <= 0x2615) or
  (ch >= 0x2616 and ch <= 0x2617) or
  (ch == 0x2618) or
  (ch == 0x2619) or
  (ch >= 0x261A and ch <= 0x266F) or
  (ch >= 0x2670 and ch <= 0x2671) or
  (ch >= 0x2672 and ch <= 0x267D) or
  (ch >= 0x267E and ch <= 0x267F) or
  (ch >= 0x2680 and ch <= 0x2685) or
  (ch >= 0x2690 and ch <= 0x2691) or
  (ch >= 0x2692 and ch <= 0x269C) or
  (ch == 0x269D) or
  (ch >= 0x269E and ch <= 0x269F) or
  (ch >= 0x26A0 and ch <= 0x26A1) or
  (ch >= 0x26A2 and ch <= 0x26B1) or
  (ch == 0x26B2) or
  (ch >= 0x26B3 and ch <= 0x26BC) or
  (ch >= 0x26BD and ch <= 0x26BF) or
  (ch >= 0x26C0 and ch <= 0x26C3) or
  (ch >= 0x26C4 and ch <= 0x26CD) or
  (ch == 0x26CE) or
  (ch >= 0x26CF and ch <= 0x26E1) or
  (ch == 0x26E2) or
  (ch == 0x26E3) or
  (ch >= 0x26E4 and ch <= 0x26E7) or
  (ch >= 0x26E8 and ch <= 0x26FF) or
  (ch == 0x2700) or
  (ch >= 0x2701 and ch <= 0x2704) or
  (ch == 0x2705) or
  (ch >= 0x2708 and ch <= 0x2709) or
  (ch >= 0x270A and ch <= 0x270B) or
  (ch >= 0x270C and ch <= 0x2712) or
  (ch == 0x2714) or
  (ch == 0x2716) or
  (ch == 0x271D) or
  (ch == 0x2721) or
  (ch == 0x2728) or
  (ch >= 0x2733 and ch <= 0x2734) or
  (ch == 0x2744) or
  (ch == 0x2747) or
  (ch == 0x274C) or
  (ch == 0x274E) or
  (ch >= 0x2753 and ch <= 0x2755) or
  (ch == 0x2757) or
  (ch >= 0x2763 and ch <= 0x2767) or
  (ch >= 0x2795 and ch <= 0x2797) or
  (ch == 0x27A1) or
  (ch == 0x27B0) or
  (ch == 0x27BF) or
  (ch >= 0x2934 and ch <= 0x2935) or
  (ch >= 0x2B05 and ch <= 0x2B07) or
  (ch >= 0x2B1B and ch <= 0x2B1C) or
  (ch == 0x2B50) or
  (ch == 0x2B55) or
  (ch == 0x3030) or
  (ch == 0x303D) or
  (ch == 0x3297) or
  (ch == 0x3299) or
  (ch >= 0x1F000 and ch <= 0x1F02B) or
  (ch >= 0x1F02C and ch <= 0x1F02F) or
  (ch >= 0x1F030 and ch <= 0x1F093) or
  (ch >= 0x1F094 and ch <= 0x1F09F) or
  (ch >= 0x1F0A0 and ch <= 0x1F0AE) or
  (ch >= 0x1F0AF and ch <= 0x1F0B0) or
  (ch >= 0x1F0B1 and ch <= 0x1F0BE) or
  (ch == 0x1F0BF) or
  (ch == 0x1F0C0) or
  (ch >= 0x1F0C1 and ch <= 0x1F0CF) or
  (ch == 0x1F0D0) or
  (ch >= 0x1F0D1 and ch <= 0x1F0DF) or
  (ch >= 0x1F0E0 and ch <= 0x1F0F5) or
  (ch >= 0x1F0F6 and ch <= 0x1F0FF) or
  (ch >= 0x1F10D and ch <= 0x1F10F) or
  (ch == 0x1F12F) or
  (ch == 0x1F16C) or
  (ch >= 0x1F16D and ch <= 0x1F16F) or
  (ch >= 0x1F170 and ch <= 0x1F171) or
  (ch == 0x1F17E) or
  (ch == 0x1F17F) or
  (ch == 0x1F18E) or
  (ch >= 0x1F191 and ch <= 0x1F19A) or
  (ch >= 0x1F1AD and ch <= 0x1F1E5) or
  (ch >= 0x1F201 and ch <= 0x1F202) or
  (ch >= 0x1F203 and ch <= 0x1F20F) or
  (ch == 0x1F21A) or
  (ch == 0x1F22F) or
  (ch >= 0x1F232 and ch <= 0x1F23A) or
  (ch >= 0x1F23C and ch <= 0x1F23F) or
  (ch >= 0x1F249 and ch <= 0x1F24F) or
  (ch >= 0x1F250 and ch <= 0x1F251) or
  (ch >= 0x1F252 and ch <= 0x1F25F) or
  (ch >= 0x1F260 and ch <= 0x1F265) or
  (ch >= 0x1F266 and ch <= 0x1F2FF) or
  (ch >= 0x1F300 and ch <= 0x1F320) or
  (ch >= 0x1F321 and ch <= 0x1F32C) or
  (ch >= 0x1F32D and ch <= 0x1F32F) or
  (ch >= 0x1F330 and ch <= 0x1F335) or
  (ch == 0x1F336) or
  (ch >= 0x1F337 and ch <= 0x1F37C) or
  (ch == 0x1F37D) or
  (ch >= 0x1F37E and ch <= 0x1F37F) or
  (ch >= 0x1F380 and ch <= 0x1F393) or
  (ch >= 0x1F394 and ch <= 0x1F39F) or
  (ch >= 0x1F3A0 and ch <= 0x1F3C4) or
  (ch == 0x1F3C5) or
  (ch >= 0x1F3C6 and ch <= 0x1F3CA) or
  (ch >= 0x1F3CB and ch <= 0x1F3CE) or
  (ch >= 0x1F3CF and ch <= 0x1F3D3) or
  (ch >= 0x1F3D4 and ch <= 0x1F3DF) or
  (ch >= 0x1F3E0 and ch <= 0x1F3F0) or
  (ch >= 0x1F3F1 and ch <= 0x1F3F7) or
  (ch >= 0x1F3F8 and ch <= 0x1F3FA) or
  (ch >= 0x1F400 and ch <= 0x1F43E) or
  (ch == 0x1F43F) or
  (ch == 0x1F440) or
  (ch == 0x1F441) or
  (ch >= 0x1F442 and ch <= 0x1F4F7) or
  (ch == 0x1F4F8) or
  (ch >= 0x1F4F9 and ch <= 0x1F4FC) or
  (ch >= 0x1F4FD and ch <= 0x1F4FE) or
  (ch == 0x1F4FF) or
  (ch >= 0x1F500 and ch <= 0x1F53D) or
  (ch >= 0x1F546 and ch <= 0x1F54A) or
  (ch >= 0x1F54B and ch <= 0x1F54F) or
  (ch >= 0x1F550 and ch <= 0x1F567) or
  (ch >= 0x1F568 and ch <= 0x1F579) or
  (ch == 0x1F57A) or
  (ch >= 0x1F57B and ch <= 0x1F5A3) or
  (ch == 0x1F5A4) or
  (ch >= 0x1F5A5 and ch <= 0x1F5FA) or
  (ch >= 0x1F5FB and ch <= 0x1F5FF) or
  (ch == 0x1F600) or
  (ch >= 0x1F601 and ch <= 0x1F610) or
  (ch == 0x1F611) or
  (ch >= 0x1F612 and ch <= 0x1F614) or
  (ch == 0x1F615) or
  (ch == 0x1F616) or
  (ch == 0x1F617) or
  (ch == 0x1F618) or
  (ch == 0x1F619) or
  (ch == 0x1F61A) or
  (ch == 0x1F61B) or
  (ch >= 0x1F61C and ch <= 0x1F61E) or
  (ch == 0x1F61F) or
  (ch >= 0x1F620 and ch <= 0x1F625) or
  (ch >= 0x1F626 and ch <= 0x1F627) or
  (ch >= 0x1F628 and ch <= 0x1F62B) or
  (ch == 0x1F62C) or
  (ch == 0x1F62D) or
  (ch >= 0x1F62E and ch <= 0x1F62F) or
  (ch >= 0x1F630 and ch <= 0x1F633) or
  (ch == 0x1F634) or
  (ch >= 0x1F635 and ch <= 0x1F640) or
  (ch >= 0x1F641 and ch <= 0x1F642) or
  (ch >= 0x1F643 and ch <= 0x1F644) or
  (ch >= 0x1F645 and ch <= 0x1F64F) or
  (ch >= 0x1F680 and ch <= 0x1F6C5) or
  (ch >= 0x1F6C6 and ch <= 0x1F6CF) or
  (ch == 0x1F6D0) or
  (ch >= 0x1F6D1 and ch <= 0x1F6D2) or
  (ch >= 0x1F6D3 and ch <= 0x1F6D4) or
  (ch == 0x1F6D5) or
  (ch >= 0x1F6D6 and ch <= 0x1F6DF) or
  (ch >= 0x1F6E0 and ch <= 0x1F6EC) or
  (ch >= 0x1F6ED and ch <= 0x1F6EF) or
  (ch >= 0x1F6F0 and ch <= 0x1F6F3) or
  (ch >= 0x1F6F4 and ch <= 0x1F6F6) or
  (ch >= 0x1F6F7 and ch <= 0x1F6F8) or
  (ch == 0x1F6F9) or
  (ch == 0x1F6FA) or
  (ch >= 0x1F6FB and ch <= 0x1F6FF) or
  (ch >= 0x1F774 and ch <= 0x1F77F) or
  (ch >= 0x1F7D5 and ch <= 0x1F7D8) or
  (ch >= 0x1F7D9 and ch <= 0x1F7DF) or
  (ch >= 0x1F7E0 and ch <= 0x1F7EB) or
  (ch >= 0x1F7EC and ch <= 0x1F7FF) or
  (ch >= 0x1F80C and ch <= 0x1F80F) or
  (ch >= 0x1F848 and ch <= 0x1F84F) or
  (ch >= 0x1F85A and ch <= 0x1F85F) or
  (ch >= 0x1F888 and ch <= 0x1F88F) or
  (ch >= 0x1F8AE and ch <= 0x1F8FF) or
  (ch == 0x1F90C) or
  (ch >= 0x1F90D and ch <= 0x1F90F) or
  (ch >= 0x1F910 and ch <= 0x1F918) or
  (ch >= 0x1F919 and ch <= 0x1F91E) or
  (ch == 0x1F91F) or
  (ch >= 0x1F920 and ch <= 0x1F927) or
  (ch >= 0x1F928 and ch <= 0x1F92F) or
  (ch == 0x1F930) or
  (ch >= 0x1F931 and ch <= 0x1F932) or
  (ch >= 0x1F933 and ch <= 0x1F93A) or
  (ch >= 0x1F93C and ch <= 0x1F93E) or
  (ch == 0x1F93F) or
  (ch >= 0x1F940 and ch <= 0x1F945) or
  (ch >= 0x1F947 and ch <= 0x1F94B) or
  (ch == 0x1F94C) or
  (ch >= 0x1F94D and ch <= 0x1F94F) or
  (ch >= 0x1F950 and ch <= 0x1F95E) or
  (ch >= 0x1F95F and ch <= 0x1F96B) or
  (ch >= 0x1F96C and ch <= 0x1F970) or
  (ch == 0x1F971) or
  (ch == 0x1F972) or
  (ch >= 0x1F973 and ch <= 0x1F976) or
  (ch >= 0x1F977 and ch <= 0x1F979) or
  (ch == 0x1F97A) or
  (ch == 0x1F97B) or
  (ch >= 0x1F97C and ch <= 0x1F97F) or
  (ch >= 0x1F980 and ch <= 0x1F984) or
  (ch >= 0x1F985 and ch <= 0x1F991) or
  (ch >= 0x1F992 and ch <= 0x1F997) or
  (ch >= 0x1F998 and ch <= 0x1F9A2) or
  (ch >= 0x1F9A3 and ch <= 0x1F9A4) or
  (ch >= 0x1F9A5 and ch <= 0x1F9AA) or
  (ch >= 0x1F9AB and ch <= 0x1F9AD) or
  (ch >= 0x1F9AE and ch <= 0x1F9AF) or
  (ch >= 0x1F9B0 and ch <= 0x1F9B9) or
  (ch >= 0x1F9BA and ch <= 0x1F9BF) or
  (ch == 0x1F9C0) or
  (ch >= 0x1F9C1 and ch <= 0x1F9C2) or
  (ch >= 0x1F9C3 and ch <= 0x1F9CA) or
  (ch >= 0x1F9CB and ch <= 0x1F9CC) or
  (ch >= 0x1F9CD and ch <= 0x1F9CF) or
  (ch >= 0x1F9D0 and ch <= 0x1F9E6) or
  (ch >= 0x1F9E7 and ch <= 0x1F9FF) or
  (ch >= 0x1FA00 and ch <= 0x1FA53) or
  (ch >= 0x1FA54 and ch <= 0x1FA5F) or
  (ch >= 0x1FA60 and ch <= 0x1FA6D) or
  (ch >= 0x1FA6E and ch <= 0x1FA6F) or
  (ch >= 0x1FA70 and ch <= 0x1FA73) or
  (ch >= 0x1FA74 and ch <= 0x1FA77) or
  (ch >= 0x1FA78 and ch <= 0x1FA7A) or
  (ch >= 0x1FA7B and ch <= 0x1FA7F) or
  (ch >= 0x1FA80 and ch <= 0x1FA82) or
  (ch >= 0x1FA83 and ch <= 0x1FA8F) or
  (ch >= 0x1FA90 and ch <= 0x1FA95) or
  (ch >= 0x1FA96 and ch <= 0x1FFFD))
end

-- check if text is all emoji
local function is_all_emoji(text)
  if not text or #text == 0 then return false end
  local cpArray = utf8_string_to_unicode_array(text)

  for i = 1, #text do
    if not is_emoji(cpArray[i]) then return false end
  end
  return true
end

-- reverse look up key by value from map
local function reverseLookup(map, value)
  for key, val in pairs(map) do
    if val == value then
      return key
    end
  end
  return nil
end

-- convert string from native string to utf-8 string
local function native_string_to_utf8(nstr, charset)
  local module_name_for_mapping_to_unicode = "%s_to_UNICODE"
  local charset_map_table = (type(charset) == 'string' and module_name_for_mapping_to_unicode:format(normalize_charset_name(charset)))
  local map = require(charset_map_table)
  local ostr = ''
  local i = 1
  if type(nstr) == 'string' then
    repeat
      local uch = ''
      if nstr:byte(i) < 0x81 then
        uch = nstr:byte(i)
        i = i + 1
      else
        uch = nstr:byte(i) * 256 + nstr:byte(i+1)
        i = i + 2
      end
      ostr = ostr .. utf8.char(map[uch])
    until i > #nstr
  elseif type(nstr) == 'table' then
    repeat
      local uch = ''
      if nstr[i] < 0x81 then
        uch = nstr[i]
        i = i + 1
      else
        uch = nstr[i] * 256 + nstr[i+1]
        i = i + 2
      end
      ostr = ostr .. utf8.char(map[uch])
    until i > #nstr
  end
  return ostr
end

-- convert string to native string from utf-8 string
local function native_string_from_utf8(ustr, charset)
  local unicode_array = utf8_string_to_unicode_array(ustr)
  local module_name_for_mapping_to_unicode = "%s_to_UNICODE"
  local charset_map_table = (type(charset) == 'string' and module_name_for_mapping_to_unicode:format(normalize_charset_name(charset)))
  local map = require(charset_map_table)
  local res = {}
  for i = 1, #unicode_array do
    local native_code = reverseLookup(map, unicode_array[i])
    if native_code then
      if native_code < 0x80 then
        table.insert(res, native_code)
      else
        table.insert(res, native_code >> 8)
        table.insert(res, native_code & 0xff)
      end
    end
  end
  return string.char(unpack(res))
end

local function check_dict_for_value(dict, target_value)
  for key, value in pairs(dict) do
    if value == target_value then
      return true
    end
  end
  return false
end

-- check if text is in charset
local function is_all_in_charset(text, charset, is_emoji_enbaled)
  if not (type(text) == 'string') then return false end
  if not (type(charset) == 'string') then return false end
  if not is_emoji_enbaled then is_emoji_enbaled = false end
  if charset:upper() == 'UTF8' or charset:upper() == 'UTF-8' then return true end
  local module_name_for_mapping_to_unicode = "%s_to_UNICODE"
  local charset_map_table = (type(charset) == 'string' and module_name_for_mapping_to_unicode:format(normalize_charset_name(charset)))
  -- avoid module not exists problem
  local ok, map = pcall(require, charset_map_table)
  -- invalide charset error, return true
  if not ok then return true end

	if charset:upper() == 'GB2312' then
		map = require("GB2312_to_UNICODE")
	end
  local cpArray = utf8_string_to_unicode_array(text)
  for  i = 1, #cpArray do
    if (is_emoji_enbaled and is_emoji(cpArray[i])) then
      do break end    -- simulate continue
    end
    if not check_dict_for_value(map, cpArray[i]) then return false end
  end
  return true
end

-- check if text is in charsets
local function is_all_in_charsets(text, charsets, is_emoji_enbaled)
  if not (type(text) == 'string') then return false end
  if not (type(charsets) == 'string') then return false end
  -- emoji default off
  if not is_emoji_enbaled then is_emoji_enbaled = false end
  local charsets_arr = {}
  local deli = '+'
  charsets:gsub("[^".. deli .."]+", function(part)
    table.insert(charsets_arr, part)
  end)
  local res = false
  if #charsets_arr > 0 then
    for i = 1, #charsets_arr do
      res = res or is_all_in_charset(text, charsets_arr[i], is_emoji_enbaled)
      if res == true and i < #charsets_arr then return true end
    end
  end
  return res
end

-- FilterText, check if text all in charsets
local function FilterText(text, charsets, is_emoji_enbaled)
  if not charsets or #charsets == 0 then return CharsetFilterFilter_FilterText(text) end
  if not charsets:upper() == 'CJK' then return CharsetFilterFilter_FilterText(text) end
  if is_emoji_enbaled and is_all_emoji(text) then return true end
  return is_all_in_charsets(text, charsets, is_emoji_enbaled)
end

--------------------------------------------------------------------------------------------
--[[
--  README
--  conv_from_utf is for making native string from utf-8, with charset defined
--  conv_to_utf   is for making utf8 string from native string, with charset defined
--  FilterText    is for checking if text all in charsets defined, '+' to make more than one charset
--  charsets supported list in normalize_charset_name function, charset_names, case insensitive
--  GBK alias to CP936, BIG5 alias to CP950, UTF8 alias to UTF_8
--]]
--------------------------------------------------------------------------------------------
return {
  FilterText = FilterText,
  conv_to_utf = native_string_to_utf8,
  conv_from_utf = native_string_from_utf8
}
