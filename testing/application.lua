local module = {}
local mytmr = tmr.create()
token = nil
rtctime.set(1574509386, 0)

local function get_token()
    -- counter = 1
    -- maxCounter = config.COUNT

    -- mytimer = tmr.create()
    -- mytimer:register(10000, tmr.ALARM_AUTO, function(t)
    --     if counter <= maxCounter then
    reqSec, reqUsec = rtctime.get() -- req token
    http.post(
        "http://" .. config.HOST .. ":" .. config.PORT_AUTH .. config.PATH_AUTH,
        "Content-Type: application/json\r\n",
        '{"things_id":"' .. config.THINGS_ID .. '","things_password":"' .. config.THINGS_PASSWORD .. '"}',
        function(code, data)
            print(code)
            if (code == 200) then
                -- t = sjson.decode(data)
                -- token = t.token
                print(code, data)
                reqSec2, reqUsec2 = rtctime.get()
                print("req time (sec):\t" .. (reqUsec2 + ((reqSec2 - reqSec) * 1000000) - reqUsec) / 1000000)
            elseif (code == 401) then
                -- print("Wait 20 sec")
                -- mytmr:alarm(20000, tmr.ALARM_SINGLE, function()
                --     get_token()
                -- end)
                print(code, data)
            else
                print("HTTP request failed")
            end
        end
    )
    --     else
    --         print(maxCounter .. " request successfully")
    --         t:unregister()
    --     end
    --     counter = counter + 1

    -- end)
    -- mytimer:interval(3000)
    -- mytimer:start()
end

function module.start()
    get_token()
end

return module
