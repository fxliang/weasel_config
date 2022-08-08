local unicode = require("unicode")()
local emoji2 = require("emoji2")()
local mydate = require("mydate")()
local english = require("english")()
local rmb = require("number")()
local basefunc = require("basefunctions")()

--must after function definitions
english_processor = english.processor
english_segmentor = english.segmentor
english_translator = english.translator
english_filter = english.filter
english_filter0 = english.filter0
Multiline_filter = basefunc.Multiline_filter

-- translators
date_translator = mydate.date_translator;
UnicodeTranslator  = unicode.UnicodeTranslator;
Emoji_Translator = emoji2.Emoji_Translator;
daxie_translator = rmb.daxie_translator;
