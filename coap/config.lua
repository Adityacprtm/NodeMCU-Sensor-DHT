local module = {}

module.SSID = "RaspiAP"
module.PWD = "pokemon48"

module.HOST = "192.168.100.1"
module.PORT_COAP = 5683

module.PATH_AUTH = "/things/request"
module.PORT_AUTH = 80

module.ID = node.chipid()

module.DEVICE_ID = "117f96b137b87380deb99ecc74eb3003712dca8911fb726a061cde9ee38ec6b8"
module.PASSWORD = "7b855f1173489606dc8a4d9639356238b37f44ca847ec52b509e56399b57a4eb"

module.TOPIC = "home"

module.PIN = 4

module.COUNT = 10

return module
