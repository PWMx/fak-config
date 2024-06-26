# Cygnus 36keys
# See https://github.com/juhakaup/keyboards/tree/main/Cygnus%20v1.0

let { ColToRowKey, PeripheralSideKey, .. } = import "fak/keyboard.ncl" in
let { CH552T, .. } = import "fak/mcus.ncl" in

# LHS
let side_central = {
  mcu = CH552T,
  matrix = {
    cols = [10, 17, 16, 15, 14],
    rows = [35, 34, 33, 11]
  },
  split.channel = CH552T.features.uart_30_31,
} in

# RHS
let side_periph = {
  mcu = CH552T,
  matrix = {
    cols = [10, 17, 16, 15, 14],
    rows = [35, 34, 33, 11]
  },
  split.channel = CH552T.features.uart_30_31,
  keys =
    let M = ColToRowKey in
    [
      M 4 0, M 3 0, M 2 0, M 1 0, M 0 0,
      M 4 1, M 3 1, M 2 1, M 1 1, M 0 1,
      M 4 2, M 3 2, M 2 2, M 1 2, M 0 2,
      M 4 3, M 3 3, M 2 3,
    ]
} in

side_central & {
  usb_dev = {
    vendor_id = 65261, # 0xFEED
    product_id = 48879, # 0xBEEF
    product_ver = 256, # 0x0100
  },
  split.peripheral = side_periph,
  keys =
    let M = ColToRowKey in
    let S = PeripheralSideKey in
    [
      M 0 0, M 1 0, M 2 0, M 3 0, M 4 0,      S 0,  S 1,  S 2,  S 3,  S 4,
      M 0 1, M 1 1, M 2 1, M 3 1, M 4 1,      S 5,  S 6,  S 7,  S 8,  S 9,
      M 0 2, M 1 2, M 2 2, M 3 2, M 4 2,      S 10, S 11, S 12, S 13, S 14,
                    M 2 3, M 3 3, M 4 3,      S 15, S 16, S 17
    ]
}
