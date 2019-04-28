local mytimer = tmr.create()

function setupWifi()
    station_cfg={}
    station_cfg.ssid="testing"
    station_cfg.pwd="attackme"
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    wifi.sta.connect()
end

function getToken()
    http.post('http://192.168.137.1:8080/device/request',
        'Content-Type: application/json\r\n',
        '{"device_id": "anojuth6j6z","password": "juth6j70"}',
        function(code, data)
            if (code < 0) then
                print("HTTP request failed")
            else
                print(code, data)
            end
        end)
end

function getAndSetDht()
    pin = 4
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    print(status)
    print(dht.OK)

    if status == dht.OK then
        -- Integer firmware using this example
        print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
            math.floor(temp),
            temp_dec,
            math.floor(humi),
            humi_dec
        ))
        -- Float firmware using this example
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

function handle_mqtt_error(client, reason)
    tmr.create():alarm(10000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function do_mqtt_connect()
    m = mqtt.Client("clientid", 120, data, NULL)
    m:connect("192.168.137.1", 1883, function(client)
        print("connected")
        client:publish("topic", "hello", 0, 0, function(client) print("sent") end)
    end,handle_mqtt_error)
end

mytimer:alarm(5000, tmr.ALARM_AUTO, function()
    setupWifi()
    if wifi.sta.getip() == nil then
        print("IP unavailable, Waiting...")
    else
        mytimer:stop()
        print("ESP8266 mode is: " .. wifi.getmode())
        print("The module MAC address is: " .. wifi.ap.getmac())
        print("Config done, IP is "..wifi.sta.getip())

    end
end)
