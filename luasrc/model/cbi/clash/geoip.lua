
local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local DISP = require "luci.dispatcher"
local UTIL = require "luci.util"
local uci = require("luci.model.uci").cursor()
local clash = "clash"
local http = luci.http

font_green = [[<font color="green">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]


k = Map(clash)
k.reset = false
k.submit = false
s =k:section(TypedSection, "clash", translate("Local Update GeoIP"))
s.anonymous = true
s.addremove=false
o = s:option(FileUpload, "",translate("Update GEOIP Database"))
o.description = translate("NB: Upload GEOIP Database file Country.mmdb")
.."<br />"
..translate("https://github.com/Dreamacro/maxmind-geoip/releases")
.."<br />"
..translate("https://static.clash.to/GeoIP2/GeoIP2-Country.tar.gz")
.."<br />"
..translate("https://geolite.clash.dev/Country.mmdb")

o.title = translate("Update GEOIP Database")
o.template = "clash/clash_upload"
um = s:option(DummyValue, "", nil)
um.template = "clash/clash_dvalue"

local dir, fd
dir = "/etc/clash/"
http.setfilehandler(
	function(meta, chunk, eof)
		if not fd then
			if not meta then return end

			if	meta and chunk then fd = nixio.open(dir .. meta.file, "w") end

			if not fd then
				um.value = translate("upload file error.")
				return
			end
		end
		if chunk and fd then
			fd:write(chunk)
		end
		if eof and fd then
			fd:close()
			fd = nil
			um.value = translate("File saved to") .. ' "/etc/clash/"'
			SYS.call("chmod + x /etc/clash/Country.mmdb")
			if luci.sys.call("pidof clash >/dev/null") == 0 then
			SYS.call("/etc/init.d/clash restart >/dev/null 2>&1 &")
			end
		end
	end
)

if luci.http.formvalue("upload") then
	local f = luci.http.formvalue("ulfile")
	if #f <= 0 then
		um.value = translate("No specify upload file.")
	end
end




m = Map("clash")
s = m:section(TypedSection, "clash" , translate("Online Update GeoIP"))
m.pageaction = false
s.anonymous = true
s.addremove=false

o = s:option(Flag, "auto_update_geoip", translate("Auto Update"))
o.description = translate("Auto Update GeoIP Database")

o = s:option(ListValue, "auto_update_geoip_time", translate("Update time (every day)"))
for t = 0,23 do
o:value(t, t..":00")
end
o.default=0
o.description = translate("GeoIP Update Time")

o = s:option(ListValue, "geo_update_week", translate("Update Time (Day/Weeks of Month)"))
o:value("1", translate("Every First Day"))
o:value("7", translate("Every First Week"))
o:value("14", translate("Every Second Weeks"))
o:value("21", translate("Every Third Weeks"))
o:value("28", translate("Every Fouth Weeks"))
o.default=1


o = s:option(Value, "license_key")
o.title = translate("LICENSE KEY")
o.description = translate("MaxMind LICENSE KEY")
o.rmempty = true

o=s:option(Button,"update_geoip")
o.inputtitle = translate("Save & Apply")
o.title = translate("Save & Apply")
o.inputstyle = "reload"
o.write = function()
  m.uci:commit("clash")
end

o = s:option(Button,"download")
o.title = translate("Download")
o.template = "clash/geoip"


return m, k

