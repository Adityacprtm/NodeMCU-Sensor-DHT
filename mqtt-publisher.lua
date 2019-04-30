-- WIFI Config
station_cfg={}
station_cfg.ssid="ap-testing"
station_cfg.pwd="attackme"
wifi.sta.config(station_cfg)
wifi.sta.connect()

-- Initial var
local mytmr = tmr.create()
local token = nil
local data_dht = nil
local m = nil

-- Func mqtt conn pubs
function mqtt_pub()
    m = mqtt.Client("clientid", 120, token, nil)
    m:connect("192.168.137.1", "1883",0, function(client)
        print('Connected to broker')
        client:publish("topic", data_dht, 1, 0, function(client) print("sent") end)
    end)
end

-- Func set-get data temp and humi from dht sensor
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

-- func get token from server auth
function get_token()
    http.post('http://192.168.137.1:8080/device/request',
        'Content-Type: application/json\r\n',
        '{"device_id":"anojuth6j6z","password":"juth6j70"}',
        function(code, data)
            if (code == 200) then
                print(code, data)
                token = data
            elseif (code == 401) then
                print(code, data)
                print("Wait 30 sec")
                tmr.create():alarm(20000, tmr.ALARM_SINGLE, function() get_token() end)
            else
                print("HTTP request failed")
            end
        end)
end

-- func loop
function exec_loop()
    if wifi.sta.getip() == nil then
        print("IP unavailable, Connecting...")
    else
        print("Connected to WIFI!")
        print("IP Address: "..wifi.sta.getip())
        if token == nil then
            get_token()
        else
            set_get_dht()
            mqtt_pub()
            mytmr:stop()
        end
    end
end

mytmr:alarm(20000, tmr.ALARM_AUTO, function() exec_loop() end)
