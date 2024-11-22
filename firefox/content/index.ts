import { KEY_SEQUENCE_TIMEOUT_MS, SCROLL_SPEED_FAST, SCROLL_SPEED_SLOW } from './constants';
import { cycleActiveScrollElement } from "./cycleActiveScrollElement";
import { state } from './state';
import { type Keybindings } from './types';

// -----------------------------------------------------------------------------
// Keybindings
// -----------------------------------------------------------------------------

export const DEFAULT_KEYBINDINGS: Keybindings = {
  H: () => history.back(),
  L: () => history.forward(),
  j: () => state.activeScrollElement.scrollBy({ top: SCROLL_SPEED_SLOW, behavior: 'instant' }),
  k: () => state.activeScrollElement.scrollBy({ top: -SCROLL_SPEED_SLOW, behavior: 'instant' }),
  d: () => state.activeScrollElement.scrollBy({ top: SCROLL_SPEED_FAST, behavior: 'instant' }),
  u: () => state.activeScrollElement.scrollBy({ top: -SCROLL_SPEED_FAST, behavior: 'instant' }),
  gg: () => state.activeScrollElement.scrollTo({ top: 0, behavior: 'instant' }),
  G: () => state.activeScrollElement.scrollTo({ top: state.activeScrollElement.scrollHeight, behavior: 'instant' }),
  s: () => cycleActiveScrollElement(1),
  S: () => cycleActiveScrollElement(-1),
}

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

state.activeKeybindings = DEFAULT_KEYBINDINGS;

window.addEventListener('keydown', event => {
  if (document.activeElement instanceof HTMLInputElement) {
    return; // do not block <input>
  }

  if (document.activeElement instanceof HTMLTextAreaElement) {
    return; // do not block <textarea>
  }

  const activeKeySequence = state.pendingKeySequence + event.key;

  state.pendingKeySequence = '';
  clearTimeout(state.pendingKeySequenceTimeout);

  if (activeKeySequence in state.activeKeybindings) {
    state.activeKeybindings[activeKeySequence]();
    event.stopPropagation();
    return;
  }

  for (const keySequence in state.activeKeybindings) {
    if (keySequence.startsWith(activeKeySequence)) {
      state.pendingKeySequence = activeKeySequence;
      state.pendingKeySequenceTimeout = setTimeout(
        () => { state.pendingKeySequence = ''; },
        KEY_SEQUENCE_TIMEOUT_MS
      );
      event.stopPropagation();
      return;
    }
  }
}, { capture: true });
