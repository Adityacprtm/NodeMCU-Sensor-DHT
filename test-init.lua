-- Constants
station_cfg={}
station_cfg.ssid="ap-testing"
station_cfg.pwd="attackme"

-- File that is executed after connection
CMDFILE = "test-mqtt.lua"

-- Some control variables
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 200    -- Maximum number of WIFI Testings while waiting for connection

-- Change the code of this function that it calls your code.
function launch()
    print("Connected to WIFI!")
    print("IP Address: " .. wifi.sta.getip())

    -- Call our command file every minute.
    tmr.create():alarm(10000, tmr.ALARM_AUTO, function() dofile(CMDFILE) end )
end

function checkWIFI()
    if ( wifiTrys > NUMWIFITRYS ) then
        print("Sorry. Not able to connect")
    else
        if ( wifi.sta.getip() ~= nil )then
            -- lauch()        -- Cannot call directly the function from here the timer... NodeMcu crashes...
            tmr.create():alarm( 1000 , tmr.ALARM_AUTO , launch )
        else
            -- Reset alarm again
            tmr.create():alarm( 2500 , tmr.ALARM_AUTO , checkWIFI)
            print("Checking WIFI..." .. wifiTrys)
            wifiTrys = wifiTrys + 1
        end
    end
end

print("-- Starting up! ")

-- Lets see if we are already connected by getting the IP
if ( wifi.sta.getip() == nil ) then
    -- We aren't connected, so let's connect
    print("Configuring WIFI....")
    wifi.setmode( wifi.STATION )
    wifi.sta.config(station_cfg)
    print("Waiting for connection")
    tmr.create():alarm( 2000 , tmr.ALARM_AUTO , checkWIFI )  -- Call checkWIFI 2.5S in the future.
else
    -- We are connected, so just run the launch code.
    launch()
end
-- Drop through here to let NodeMcu run
