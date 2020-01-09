local module = {}
local mytmr = tmr.create()
m = nil
token = nil
payload = nil

local function set_get_dht()
    status, temp, humi, temp_dec, humi_dec = dht.read(config.PIN)
    if status == dht.OK then
        -- print("DHT Temperature:"..temp..";".."Humidity:"..humi)
        ok, payload =
            pcall(
            sjson.encode,
            {
                protocol = "mqtt",
                timestamp = tmr.now(),
                topic = config.TOPIC,
                humidity = {value = humi, unit = "%"},
                temperature = {value = temp, unit = "celcius"}
            }
        )
        if ok then
            -- print(payload)
        else
            print("failed to encode!")
        end
    elseif status == dht.ERROR_CHECKSUM then
        print("DHT Checksum error.")
    elseif status == dht.ERROR_TIMEOUT then
        print("DHT timed out.")
    end
end

local function mqtt_start()
    counter = 1
    maxCounter = config.COUNT

    mytimer = tmr.create()
    mytimer:register(
        10000,
        tmr.ALARM_AUTO,
        function(t)
            if counter <= maxCounter then
                -- print("mqtt connecting ...")
                -- conSec, conUsec = rtctime.get()
                conPubSec, conPubUsec = rtctime.get()
                -- m = mqtt.Client(config.ID, 120, token, nil) -- with auth
                m = mqtt.Client(config.ID, 120) -- without auth
                m:connect(
                    config.HOST,
                    config.PORT_MQTT,
                    false,
                    function(client)
                    end,
                    function(client, reason)
                        print("failed reason: " .. reason)
                    end
                )
                m:on(
                    "connect",
                    function(client)
                        -- print("mqtt connected")
                        -- conSec2, conUsec2 = rtctime.get()
                        -- print(counter .. "\tconn time (sec):\t" ..
                        --     (conUsec2 + ((conSec2 - conSec) * 1000000) - conUsec) /
                        --     1000000)

                        set_get_dht()
                        -- print("publishing message")
                        -- pubSec, pubUsec = rtctime.get()
                        client:publish(
                            config.ID .. "/" .. config.TOPIC,
                            payload,
                            1,
                            0,
                            function(client)
                            end
                        )
                        client:on(
                            "puback",
                            function(client, topic, message)
                                -- print("Message published")
                                conPubSec2, conPubUsec2 = rtctime.get()
                                print(
                                    counter ..
                                        "\tpubs time (sec):\t" ..
                                            (conPubUsec2 + ((conPubSec2 - conPubSec) * 1000000) - conPubUsec) / 1000000
                                )
                                m:close()
                            end
                        )
                    end
                )
            else
                print(maxCounter .. " messages successfully published")
                t:unregister()
            end
            counter = counter + 1
        end
    )
    mytimer:interval(2000)
    mytimer:start()
end

local function get_token()
    reqSec, reqUsec = rtctime.get() -- req token
    http.post(
        "http://" .. config.HOST .. ":" .. config.PORT_AUTH .. config.PATH_AUTH,
        "Content-Type: application/json\r\n",
        '{"things_id":"' .. config.THINGS_ID .. '","things_password":"' .. config.THINGS_PASSWORD .. '"}',
        function(code, data)
            if (code == 200) then
                -- print(code, data)
                -- print(token)
                t = sjson.decode(data)
                token = t.token
                reqSec2, reqUsec2 = rtctime.get()
                print("\treq time (sec):\t" .. (reqUsec2 + ((reqSec2 - reqSec) * 1000000) - reqUsec) / 1000000)
                mqtt_start()
            elseif (code == 401) then
                print(code, data)
                print("Wait 20 sec")
                mytmr:alarm(
                    20000,
                    tmr.ALARM_SINGLE,
                    function()
                        get_token()
                    end
                )
            else
                print("HTTP request failed")
            end
        end
    )
end

function module.start()
    -- if (token == nil) then
    -- get_token()
    -- else
    mqtt_start()
    -- end
end

return module
