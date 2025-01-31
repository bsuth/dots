export interface State {
  activeScrollElement: Element;
  disableKeybindings: boolean;
  pendingKeySequence: string;
  pendingKeySequenceTimeout: number;
}

export const state: State = {
  activeScrollElement: document.documentElement,
  disableKeybindings: false,
  pendingKeySequence: '',
  pendingKeySequenceTimeout: -1,
};
