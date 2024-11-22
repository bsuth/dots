import { type Keybindings } from "./types";

export interface State {
  activeKeybindings: Keybindings;
  activeScrollElement: Element;
  pendingKeySequence: string;
  pendingKeySequenceTimeout: number;
}

export const state: State = {
  activeKeybindings: {},
  activeScrollElement: document.documentElement,
  pendingKeySequence: '',
  pendingKeySequenceTimeout: -1,
};
