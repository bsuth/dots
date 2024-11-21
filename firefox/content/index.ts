import { KEY_SEQUENCE_TIMEOUT_MS } from './constants';
import {
  cycleHighlightedScrollContainers,
  scrollDownFast,
  scrollDownSlow,
  scrollToTop,
  scrollToBottom,
  scrollUpFast,
  scrollUpSlow,
} from "./scroll";
import { state } from './state';
import { type Keybindings } from './types';

// -----------------------------------------------------------------------------
// Keybindings
// -----------------------------------------------------------------------------

export const DEFAULT_KEYBINDINGS: Keybindings = {
  H: () => history.back(),
  L: () => history.forward(),
  j: scrollDownSlow,
  k: scrollUpSlow,
  d: scrollDownFast,
  u: scrollUpFast,
  gg: scrollToTop,
  G: scrollToBottom,
  s: () => cycleHighlightedScrollContainers(1),
  S: () => cycleHighlightedScrollContainers(-1),
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
