local module = {}
local mytmr = tmr.create()
m = nil
token = nil
payload = nil

local function decryption(cipher)
    iv = encoder.fromHex(config.IV)
    key = encoder.fromHex(config.KEY)
    encryptedText = encoder.fromHex(cipher)
    decrypted = crypto.decrypt(config.ALGORITHM, key, encryptedText, iv)
    return string.sub(decrypted, 0, -9)
end

local function set_get_dht()
    status, temp, humi, temp_dec, humi_dec = dht.read(config.PIN)
    if status == dht.OK then
        -- print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        ok, payload = pcall(sjson.encode, {
            protocol="mqtt",
            timestamp=tmr.now(),
            topic=config.TOPIC,
            humidity={
                value=humi,
                unit="%"
            },
            temperature={
                value=temp,
                unit="celcius"
            }
        })
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

local function mqtt_start()
    m = mqtt.Client(config.ID, 120, token, nil)
    m:on("offline", function(client) print ("offline") end)
    m:connect(config.HOST, config.PORT_MQTT, 0, function(client)
        print ("connected")
        mytimer = tmr.create()
        mytimer:register(30000, tmr.ALARM_AUTO, function()
            set_get_dht()
            client:publish(config.ID..'/'..config.TOPIC,payload,1,0, function(client) print("Message published") end)
        end)
        mytimer:interval(10000)
        mytimer:start()
    end, function(client, reason)
        print("failed reason: " .. reason)
    end)
end

local function get_token()
    http.post('http://'..config.HOST..':'..config.PORT_AUTH..config.PATH_AUTH,
        'Content-Type: application/json\r\n',
        '{"device_id":"'..config.DEVICE_ID..'","device_password":"'..config.PASSWORD..'"}',
        function(code, data)
            if (code == 200) then
                print(code, data)
                token = decryption(data)
                print(token)
                mqtt_start()
            elseif (code == 401) then
                print(code, data)
                print("Wait 20 sec")
                mytmr:alarm(20000, tmr.ALARM_SINGLE, function() get_token() end)
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
