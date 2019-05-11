local module = {}
local mytmr = tmr.create()

local function wifi_wait_ip()
    if wifi.sta.getip() == nil then
        print("IP unavailable, Waiting...")
    else
        mytmr:stop()
        print("\n====================================")
        print("ESP8266 mode is: " .. wifi.getmode())
        print("MAC address is: " .. wifi.ap.getmac())
        print("IP is "..wifi.sta.getip())
        print("====================================")
        app.start()
    end
end

local function wifi_start()
    wifi.setmode(wifi.STATION);
    wifi.sta.config({ssid=config.SSID, pwd=config.PWD})
    wifi.sta.connect()
    print("Connecting to "..config.SSID.."...")
    --tmr.alarm(1, 2500, 1, wifi_wait_ip)
    mytmr:alarm(2500, tmr.ALARM_AUTO, function() wifi_wait_ip() end)
end

function module.start()
    print("Configuring Wifi ...")
    wifi.setmode(wifi.STATION);
    wifi.sta.getap(wifi_start)
end

return module