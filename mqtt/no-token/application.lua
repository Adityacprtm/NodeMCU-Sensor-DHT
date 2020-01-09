local module = {}
local mytmr = tmr.create()
local m = nil
local payload = nil
rtctime.set(1561601630, 0)

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

    m = mqtt.Client(config.ID, 120)

    -- print("mqtt connecting ...")
    conSec, conUsec = rtctime.get()
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
            conSec2, conUsec2 = rtctime.get()
            print("\tconn time (sec):\t" .. (conUsec2 + ((conSec2 - conSec) * 1000000) - conUsec) / 1000000)
            mytimer = tmr.create()
            mytimer:register(
                10000,
                tmr.ALARM_AUTO,
                function(t)
                    if counter <= maxCounter then
                        set_get_dht()
                        -- print("publishing message")
                        pubSec, pubUsec = rtctime.get()
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
                                pubSec2, pubUsec2 = rtctime.get()
                                print(
                                    counter ..
                                        "\tpubs time (sec):\t" ..
                                            (pubUsec2 + ((pubSec2 - pubSec) * 1000000) - pubUsec) / 1000000
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
            mytimer:interval(3000)
            mytimer:start()
        end
    )

    m:on(
        "offline",
        function(client)
            print("offline")
        end
    )
end

function module.start()
    mqtt_start()
end

return module
