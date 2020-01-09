local module = {}

module.SSID = "RaspiAP"
module.PWD = "pokemon48"

module.HOST = "172.16.100.1"
module.PORT_COAP = 5683

module.PATH_AUTH = "/things/request"
module.PORT_AUTH = 80

module.ID = node.chipid()

module.THINGS_ID = "a82fc1123492ce4259fc77e3133d2ca4d45236fc8a0cd5aabdf87454f516b1d9"
module.THINGS_PASSWORD = "63a783d373538cf0d2ecb926e6be550cb4204357322214ebb5a4a52c49acf747"

module.TOPIC = "home/garage"

module.PIN = 4

module.COUNT = 20

return module
