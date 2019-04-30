local module = {}

local function wifi_wait_ip()
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    config.mytmr:stop()
    -- tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    app.start()
  end
end

local function wifi_start()
    station_cfg={}
    station_cfg.ssid=config.SSID
    station_cfg.pwd=config.PWD
    wifi.setmode(wifi.STATION);
    wifi.sta.config(station_cfg)
    wifi.sta.connect()
    print("Connecting...")
    --config.SSID = nil  -- can save memory
    --tmr.alarm(1, 2500, 1, wifi_wait_ip)
    config.mytmr:alarm(2500, tmr.ALARM_AUTO, function() wifi_wait_ip() end)
end

function module.start()
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION);
  wifi.sta.getap(wifi_start)
end

return module
