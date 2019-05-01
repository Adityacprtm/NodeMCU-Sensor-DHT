local module = {}
module.mytmr = tmr.create()

module.SSID = "ap-testing"
module.PWD = "attackme"

module.HOST = "192.168.137.1"
module.PORT_COAP = 5683
module.PORT_AUTH = 8080
module.PATH_AUTH = "/device/request"
module.ID = node.chipid()

module.DEVICE_ID = "anojuth6j6z"
module.PASSWORD = "juth6j70"

module.TOPIC = "home"

module.PIN = 2
return module