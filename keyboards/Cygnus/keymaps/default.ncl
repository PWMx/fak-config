# Miryoku Layout for Cygnus 36keys
# See https://github.com/manna-harbour/miryoku
# Home-row pinkies is AltGr suitable for EurKey
# Inner thumbs combo is Win

let { tap, hold, td, combo, encoder, .. } = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

let virtual_keys' = [
  combo.make 50 [32, 33], # Inner thumbs
] in

let key_count = 36 + std.array.length virtual_keys' in

let kc = tap.reg.kc in
let ks = tap.reg.ks in
let md = hold.reg.mod in
let tm = tap.reg.mod in
let me = tap.custom.media in
let ms = tap.custom.mouse in
let MO = hold.reg.layer in

let ki = {
  hp = { decision = 'hold, trigger_on = 'press },
  tp = { decision = 'tap, trigger_on = 'press },
  hr = { decision = 'hold, trigger_on = 'release },
  tr = { decision = 'tap, trigger_on = 'release },
  xx = { decision = 'none },
} in

let layouts = {
  QWERTY =     "QWERTYUIOPASDFGHJKL;ZXCVBNM,./",
  DVORAK =     "',.PYFGCRLAOEUIDHTNS;QJKXBMWVZ",
  COLEMAK =    "QWFPGJLUY;ARSTDHNEIOZXCVBKM,./",
  COLEMAK_DH = "QWFPBJLUY'ARSTGMNEIOZXCDVKH,./",
} in

let make_hrm = fun key_idx =>
  let htb_hrm_base = fun eager => {
    timeout_ms = 200,
    quick_tap_ms = 150,
    quick_tap_interrupt_ms = 500,
    global_quick_tap_ms = 80,
    eager_decision = eager,
  } in

  let htb_hrm_left = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tr, ki.tr, ki.tr, ki.tr, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,  
                    ki.hp, ki.hp, ki.hp,    ki.hp, ki.hp, ki.hp,
    ]
  } in

  let htb_hrm_right = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tr, ki.tr, ki.tr, ki.tr,
      ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
                    ki.hp, ki.hp, ki.hp,    ki.hp, ki.hp, ki.hp,
    ]
  } in

  let hrm_mods = 
    let m = [md.ralt, md.lalt, md.lctl, md.lsft] in
    m @ std.array.reverse m
  in

  let hrm_key_indices = [10, 11, 12, 13, 16, 17, 18, 19] in

  if std.array.elem key_idx hrm_key_indices then
    let mod_idx = util.array.index_of key_idx hrm_key_indices in
    let side = if mod_idx < (std.array.length hrm_mods / 2) then 'left else 'right in
    let mod = std.array.at mod_idx hrm_mods in

    mod & hold.reg.behavior (
      (if side == 'left then htb_hrm_left else htb_hrm_right)
      (if mod == md.lalt then 'none else 'hold)
    )
  else
    {}
in

let XXXX = tap.none & hold.none in

let L' = fun layer => 
  let filler = std.array.replicate (key_count - std.array.length layer) XXXX in
  layer @ filler
in

let layer_media =
  let MNP = td.make 200 [ me.NEXT, me.PREV ] in
  L' [
    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       XXXX,    me.PREV, me.VOLD, me.VOLU, me.NEXT,
    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
                      XXXX,    XXXX,    XXXX,       MNP,     me.PLAY, me.MUTE,
  ]
in

let htb_media = {
  timeout_ms = 250,
  timeout_decision = 'tap,
  global_quick_tap_ms = 80,
  key_interrupts = layer_media
    |> std.array.map (fun kc => if kc == XXXX then ki.tp else ki.hr)
} in

let alphas = fun layout => layout
  |> std.string.characters
  |> util.array.enumerate
  |> std.array.map (fun { index, value } => kc."%{value}"
      & (if index == 0 then
          MO 2 & hold.reg.behavior htb_media
        else 
          make_hrm index)
    )
in

let cu = {
  REDO = md.lctl & kc.Y,
  PSTE = md.lctl & kc.V,
  COPY = md.lctl & kc.C,
  CUT  = md.lctl & kc.X,
  UNDO = md.lctl & kc.Z,
  WH_L = md.lsft & ms.WH_U,
  WH_R = md.lsft & ms.WH_D,
  BOOT = tap.custom.fak.BOOT,
} in

let thumb = fun i =>
  let htb_generic = {
    timeout_ms = 200,
    quick_tap_ms = 150,
    key_interrupts = std.array.replicate key_count ki.hr,
  } in
  [
    kc.ESC & MO 1 & hold.reg.behavior htb_generic,
    kc.SPC & MO 2 & hold.reg.behavior htb_generic,
    kc.TAB & MO 3 & hold.reg.behavior htb_generic,
    kc.ENT & MO 4 & hold.reg.behavior htb_generic,
    kc.BSPC & MO 5 & hold.reg.behavior htb_generic,
    kc.DEL & MO 6 & hold.reg.behavior htb_generic,
  ]
  |> std.array.at i
in

let keymap = {
  virtual_keys = virtual_keys',
  layers = [
    let base = fun key_idx => (alphas layouts.COLEMAK_DH) |> std.array.at key_idx in
    [
      base 0,  base 1,  base 2,  base 3,  base 4,     base 5,  base 6,  base 7,  base 8,  base 9,
      base 10, base 11, base 12, base 13, base 14,    base 15, base 16, base 17, base 18, base 19,
      base 20, base 21, base 22, base 23, base 24,    base 25, base 26, base 27, base 28, base 29,
                        thumb 0, thumb 1, thumb 2,    thumb 3, thumb 4, thumb 5,
      # Combo inner thumbs
      md.lgui,
    ],
    
    # Media layer from up
    layer_media,
    
    # Navigation layer
    L' [
      XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       cu.REDO, cu.PSTE, cu.COPY, cu.CUT,  cu.UNDO,
      XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       kc.CAPS, kc.LEFT, kc.DOWN, kc.UP,   kc.RGHT,
      XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       kc.INS,  kc.HOME, kc.PGDN, kc.PGUP, kc.END,
                        XXXX,    XXXX,    XXXX,       XXXX,    XXXX,    XXXX,
    ],

    # Mouse layer
    L' [
      XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       cu.REDO, cu.PSTE, cu.COPY, cu.CUT,  cu.UNDO,
      XXXX,    XXXX,    XXXX,    XXXX,    XXXX,       XXXX,    ms.LEFT, ms.UP,   ms.DOWN, ms.RGHT,
      cu.BOOT, XXXX,    XXXX,    XXXX,    XXXX,       XXXX,    cu.WH_L, ms.WH_U, ms.WH_D, cu.WH_R,
                        XXXX,    XXXX,    XXXX,       ms.BTN1, ms.BTN2, ms.BTN3,
    ],

    # Symbol layer
    L' [
      ks.LCBR, ks.AMPR, ks.ASTR, ks.LPRN, ks.RCBR,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      ks.COLN, ks.DLR,  ks.PERC, ks.CIRC, ks.PLUS,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      ks.TILD, ks.EXLM, ks.AT,   ks.HASH, ks.PIPE,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
                        ks.LPRN, ks.RPRN, ks.UNDS,    XXXX,    XXXX,    XXXX,
    ],

    # Numeric layer
    L' [
      kc.LBRC, kc.N7,   kc.N8,   kc.N9,    kc.RBRC,   XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      kc.SCLN, kc.N4,   kc.N5,   kc.N6,    kc.EQL,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      kc.GRV,  kc.N1,   kc.N2,   kc.N3,    kc.BSLS,   XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
                        kc.".",  kc.N0,    kc.MINS,   XXXX,    XXXX,    XXXX,
    ], 

    # Function layer
    L' [
      kc.F12,  kc.F7,   kc.F8,   kc.F9,   kc.PSCR,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      kc.F11,  kc.F4,   kc.F5,   kc.F6,   kc.SCRL,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
      kc.F10,  kc.F1,   kc.F2,   kc.F3,   kc.PAUS,    XXXX,    XXXX,    XXXX,    XXXX,    XXXX,
                        md.rgui, XXXX,    XXXX,       XXXX,    XXXX,    XXXX,
    ],    
  ]
} in

keymap
