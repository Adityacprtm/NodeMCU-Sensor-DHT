local module = {}

module.SSID = "RaspiAP"
module.PWD = "pokemon48"

module.HOST = "172.16.100.1"
module.PORT_MQTT = 1883

module.PATH_AUTH = "/things/request"
module.PORT_AUTH = 80

module.ID = node.chipid()

module.THINGS_ID = "b77f0cd1c54ffd485ae11c0113b99fafb87676607d9cc79eb758768fa8878bda"
module.THINGS_PASSWORD = "ba2afcf008ddf67202e43544e9e89101fe97b94768383c6dfb4791e67eec4e76"

module.TOPIC = "home"

module.PIN = 4

module.COUNT = 100

return module
