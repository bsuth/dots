#include "Kaleidoscope.h"
#include "Kaleidoscope-Qukeys.h"

#define Key_Exclamation LSHIFT(Key_1)
#define Key_At          LSHIFT(Key_2)
#define Key_Hash        LSHIFT(Key_3)
#define Key_Dollar      LSHIFT(Key_4)
#define Key_Percent     LSHIFT(Key_5)
#define Key_Caret       LSHIFT(Key_6)
#define Key_And         LSHIFT(Key_7)
#define Key_Star        LSHIFT(Key_8)

#define Key_LeftBrace   LSHIFT(Key_LeftBracket)
#define Key_RightBrace  LSHIFT(Key_RightBracket)
#define Key_GreaterThan LSHIFT(Key_Comma)
#define Key_LessThan    LSHIFT(Key_Period)
#define Key_Underscore  LSHIFT(Key_Minus)
#define Key_DoubleQuote LSHIFT(Key_Quote)
#define Key_Tilde       LSHIFT(Key_Backtick)
#define Key_Plus        LSHIFT(Key_Equals)

enum {
  QWERTY,
  NUMBERS,
  SYMBOLS,
  ARROWS,
};

KEYMAPS(
  [QWERTY] = KEYMAP_STACKED(
    Key_Q, Key_W, Key_E, Key_R, Key_T,
    Key_A, Key_S, Key_D, Key_F, Key_G,
    Key_Z, Key_X, Key_C, Key_V, Key_B, ___,
    Key_Esc, Key_CapsLock, ___, Key_Tab, Key_Enter, ___,

    Key_Y, Key_U, Key_I, Key_O, Key_P,
    Key_H, Key_J, Key_K, Key_L, Key_Semicolon,
    ___, Key_N, Key_M, Key_Comma, Key_Period, Key_Slash,
    ___, Key_Space, Key_Backspace, ___, Key_CapsLock, ___
  ),

  [NUMBERS] = KEYMAP_STACKED(
    Key_Exclamation, Key_At, Key_Hash, Key_Dollar, Key_Percent,
    Key_1, Key_2, Key_3, Key_4, Key_5,
    Key_F1, Key_F2, Key_F3, Key_F4, Key_F5, Key_F11,
    ___, ___, ___, ___, ___, ___,

    Key_Caret, Key_And, Key_Star, ___, ___,
    Key_6, Key_7, Key_8, Key_9, Key_0,
    Key_F12, Key_F6, Key_F7, Key_F8, Key_F9, Key_F10,
    ___, ___, ___, ___, ___, ___
  ),

  [SYMBOLS] = KEYMAP_STACKED(
    ___, Key_DoubleQuote, Key_Quote, Key_Backtick, ___,
    Key_LeftBracket, Key_RightBracket, Key_LeftBrace, Key_RightBrace, ___,
    ___, ___, Key_Backslash, Key_Pipe, ___, ___,
    ___, ___, ___, ___, ___, ___,

    ___, Key_Equals, Key_Minus, Key_Underscore, ___,
    ___, Key_LeftParen, Key_RightParen, Key_LessThan, Key_GreaterThan,
    ___, ___, Key_Tilde, Key_Plus, ___, ___,
    ___, Key_Esc, ___, ___, ___, ___
  ),

  [ARROWS] = KEYMAP_STACKED(
    ___, ___, ___, ___, ___,
    ___, ___, ___, ___, ___,
    ___, ___, ___, ___, ___, ___,
    ___, ___, ___, ___, ___, ___,

    ___, ___, ___, ___, ___,
    Key_LeftArrow, Key_DownArrow, Key_UpArrow, Key_RightArrow, ___,
    ___, ___, ___, ___, ___, ___,
    ___, ___, ___, ___, ___, ___
  )
)

KALEIDOSCOPE_INIT_PLUGINS(Qukeys);
void setup() {
  QUKEYS(
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 0), Key_LeftAlt),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 1), Key_LeftGui),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 2), Key_LeftControl),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 3), Key_LeftShift),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 4), ShiftToLayer(ARROWS)),

    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 7), Key_Esc),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 8), Key_RightShift),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 9), Key_RightControl),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 10), Key_RightGui),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(1, 11), Key_RightAlt),

    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(3, 3), ShiftToLayer(NUMBERS)),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(3, 4), ShiftToLayer(SYMBOLS)),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(3, 7), ShiftToLayer(SYMBOLS)),
    kaleidoscope::plugin::Qukey(QWERTY, KeyAddr(3, 8), ShiftToLayer(NUMBERS))
  )
  Kaleidoscope.setup();
}

void loop() {
  Kaleidoscope.loop();
}
