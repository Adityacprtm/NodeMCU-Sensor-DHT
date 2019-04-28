station_cfg={}
station_cfg.ssid="testing1"
station_cfg.pwd="attackme"
wifi.sta.config(station_cfg)
wifi.sta.connect()

local token = nil
local data_dht = nil
local m = nil

function get_token()
    http.post('http://192.168.137.1:8080/device/request',
        'Content-Type: application/json\r\n',
        '{"device_id":"2akjutj5nw3", "password":"jutj5nw5"}',
        function(code, data)
            if (code == 200) then
                print(code, data)
                token = data
            else if (code == 401)
                print(code, data)
                get_token()
            else
                print("HTTP request failed")
            end
        end)
end

function set_get_dht()
    pin = 4
    status, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then   
        print("DHT Temperature:"..temp_dec..";".."Humidity:"..humi_dec)
        data_dht = '{"Temperature":'..temp_dec..',"Humidity":'..humi_dec..'}'
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

function mqtt_pub()
    m:connect("192.168.137.1", "1883",0, function(client) print('Connected to broker')
        m:publish("topic", data_dht, 0, 0, function(client) print("sent") end)
    end)
end

function exec_loop()
    if wifi.sta.getip() == nil then
        print(wifi.sta.status())
        print("IP unavailable, Waiting...")
    else
        print("ESP8266 mode is: " .. wifi.getmode())
        print("The module MAC address is: " .. wifi.ap.getmac())
        print("Config done, IP is "..wifi.sta.getip())
        if token == nil then
            get_token()
            print(token)
        else
            set_get_dht()
            m = mqtt.Client("clientid", 120, token, NULL)
            mqtt_pub()
            tmr.create():stop() 
        end
    end
end

tmr.create():alarm(10000, tmr.ALARM_AUTO, function() exec_loop() end)