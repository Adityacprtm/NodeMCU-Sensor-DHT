local module = {}

module.SSID = "MyRasPiApp"
module.PWD = "pleasehelpme"

module.HOST = "192.168.100.1"
module.PORT_COAP = 5683

module.PATH_AUTH = "/device/request"
module.PORT_AUTH = 80
module.ALGORITHM = "AES-CBC"

module.ID = node.chipid()

module.DEVICE_ID = "117f96b137b87380deb99ecc74eb3003712dca8911fb726a061cde9ee38ec6b8"
module.PASSWORD = "7b855f1173489606dc8a4d9639356238b37f44ca847ec52b509e56399b57a4eb"

--module.KEY = "17922ef895d7f9eed51705fa618902d7"
--module.IV = "ccc1730477fee41329a875286abce3f0"

module.TOPIC = "home"

module.PIN = 4

return module
