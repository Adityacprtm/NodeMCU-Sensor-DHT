local module = {}
local m = nil
local token = nil
local payload = nil

local function set_get_dht()
    pin = config.PIN
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        data_dht = {protocol="mqtt",timestamp=tmr.now(),topic=config.TOPIC,humidity={value=humi,unit="persen"},temperature={value=temp,unit="celcius"}}
        ok, payload = pcall(sjson.encode, data_dht)
        if ok then
            print(payload)
        else
            print("failed to encode!")
        end
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

local function handle_mqtt_error(client, reason)
    config.mytmr:alarm(10 * 1000, tmr.ALARM_SINGLE, mqtt_start())
end

local function mqtt_start()
    m = mqtt.Client("clientid", 120, "token", nil)
    m:connect(config.HOST, config.PORT_MQTT, 0, function(client) 
        print ("connected") 
        set_get_dht()
        config.mytmr:alarm(5000, tmr.ALARM_AUTO, function() 
            client:publish(config.TOPIC, payload, 1, 0, function(client) 
                print("sent")
            end) 
        end)
    end, handle_mqtt_error())
    m:close()
end

local function get_token()
    http.post('http://'..config.HOST..':'..config.PORT_AUTH..config.PATH_AUTH,
        'Content-Type: application/json\r\n',
        '{"device_id":"'..config.DEVICE_ID..'","password":"'..config.PASSWORD..'"}',
        function(code, data)
            if (code == 200) then
                print(code, data)
                token = data
                mqtt_start()
            elseif (code == 401) then
                print(code, data)
                print("Wait 30 sec")
                config.mytmr:alarm(20000, tmr.ALARM_SINGLE, function() get_token() end)
            else
                print("HTTP request failed")
            end
        end)
end

function module.start()
    if (token == nil) then
        get_token()
    else
        mqtt_start()
    end
end

return module
