--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("SGTAdvertiser", "enUS", true)
if not L then return end 

L["Advertiser"] = "Advertiser"
L["SGTAdvertiserDescription"] = "Make a macro with 'SGT' as name, set the delay, and SGT will give you a button to send the macro to trade chat when it's time to spam.\nYou can drag the button with the right mouse button."
L["Error_NoMacro"] = "No valid \"SGT\" macro was found. Please create a macro called \"SGT\", give it a name, and a text. Then reload and SGT should pick up the macro";
L["Error_NoTradeChannel"] = "SGT advertiser: No 'Trade' Channel found on /2. Please make your your /2 is on index 2 :)";
L["Enabled"] = "Enabled";
L["ButtonSize"] = "Button size";
L["delaySec"] = "Delay in seconds";
L["Error_version_core"] = "SGT Core version is below the required version, please update SGT Core.\nSGT Advertiser will not load until you have updated!"
L["SearchMacro"] = "Search Macro";
