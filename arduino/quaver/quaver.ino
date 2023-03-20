#include "Kaleidoscope.h"

KEYMAPS(
  [0] = KEYMAP_STACKED(
    ___, ___, ___, ___, ___,
    ___, Key_S, Key_D, Key_F, ___,
    ___, ___, ___, ___, ___, ___,
    Key_Esc, ___, ___, ___, Key_Space, ___,

    ___, ___, ___, ___, ___,
    ___, Key_J, Key_K, Key_L, ___,
    ___, ___, ___, ___, ___, ___,
    ___, Key_Space, ___, ___, ___, ___
  )
)

void setup() {
  Kaleidoscope.setup();
}

void loop() {
  Kaleidoscope.loop();
}
