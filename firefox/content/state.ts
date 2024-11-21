import { type Keybindings } from "./types";

export interface State {
  // TODO
  activeKeybindings: Keybindings;

  // TODO
  activeScrollElement: Element;

  // TODO
  pendingKeySequence: string;

  // TOSO
  pendingKeySequenceTimeout: number;
}

export const state: State = {
  activeKeybindings: {},
  activeScrollElement: document.documentElement,
  pendingKeySequence: '',
  pendingKeySequenceTimeout: -1,
};
