import { KEY_SEQUENCE_TIMEOUT_MS, SCROLL_SPEED_FAST, SCROLL_SPEED_SLOW } from './constants';
import { cycleActiveScrollElement } from "./cycleActiveScrollElement";
import { find } from './find';
import { state } from './state';

export const keybindings = {
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
  f: () => find(),
}

window.addEventListener('keydown', event => {
  if (state.disableKeybindings) {
    return;
  }

  if (document.activeElement instanceof HTMLInputElement) {
    return; // do not block <input>
  }

  if (document.activeElement instanceof HTMLTextAreaElement) {
    return; // do not block <textarea>
  }

  const activeKeySequence = state.pendingKeySequence + (event.key.match(/^[a-zA-Z0-9]$/) ? event.key : '');

  state.pendingKeySequence = '';
  clearTimeout(state.pendingKeySequenceTimeout);

  if (activeKeySequence in keybindings) {
    keybindings[activeKeySequence]();
    event.stopPropagation();
    return;
  }

  for (const keySequence in keybindings) {
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
