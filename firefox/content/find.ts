import {
  INTERACTIVE_ACTIVE_HIGHLIGHT_BACKGROUND,
  INTERACTIVE_HIGHLIGHT_BACKGROUND,
} from './constants';
import { isInteractiveElement, isVisibleElement, traverseElement } from './element';
import { state } from './state';

interface InteractiveTarget {
  element: HTMLElement;
  highlightElement: HTMLElement;
  text: string;
  lowerText: string;
}

let highlightContainer: HTMLElement | undefined;

let activeInteractiveTargetIndex = 0;
let interactiveTargets: InteractiveTarget[] = [];
let interactiveTargetFilter = '';
let filteredInteractiveTargets: InteractiveTarget[] = [];

const keybindings = {
  Escape: cleanup,
  Enter: submit,
  Tab: (event: MouseEvent) => cycle(event.shiftKey ? -1 : 1),
};

function cleanup() {
  state.disableKeybindings = false;
  window.removeEventListener('keydown', onKeyDown, { capture: true });

  if (highlightContainer) {
    document.body.removeChild(highlightContainer);
    highlightContainer = undefined;
  }

  activeInteractiveTargetIndex = 0;
  interactiveTargets = [];
  interactiveTargetFilter = '';
  filteredInteractiveTargets = [];
}

function cycle(increment: number) {
  activeInteractiveTargetIndex = (activeInteractiveTargetIndex + increment) % filteredInteractiveTargets.length;
  highlight();
}

function filter() {
  const tokens = interactiveTargetFilter.split(/\s+/).map(token => [token, !!token.match(/[A-Z]/)] as const);

  filteredInteractiveTargets = [];

  for (const interactiveTarget of interactiveTargets) {
    if (tokens.every(([token, isCaseSensitive]) => (isCaseSensitive ? interactiveTarget.text : interactiveTarget.lowerText).includes(token))) {
      filteredInteractiveTargets.push(interactiveTarget);
      interactiveTarget.highlightElement.style.display = 'block';
    } else {
      interactiveTarget.highlightElement.style.display = 'none';
    }
  }
}

function highlight() {
  for (const interactiveTarget of filteredInteractiveTargets) {
    interactiveTarget.highlightElement.style.background = INTERACTIVE_HIGHLIGHT_BACKGROUND;
  }

  const activeInteractiveTarget = filteredInteractiveTargets[activeInteractiveTargetIndex];

  if (activeInteractiveTarget === undefined) {
    return;
  }

  activeInteractiveTarget.highlightElement.style.background = INTERACTIVE_ACTIVE_HIGHLIGHT_BACKGROUND
}

function submit() {
  const activeInteractiveTarget = filteredInteractiveTargets[activeInteractiveTargetIndex];

  if (activeInteractiveTarget instanceof HTMLInputElement) {
    activeInteractiveTarget.focus();
  } else if (activeInteractiveTarget instanceof HTMLTextAreaElement) {
    activeInteractiveTarget.focus();
  } else if (activeInteractiveTarget instanceof HTMLSelectElement) {
    activeInteractiveTarget.focus();
  } else if (activeInteractiveTarget instanceof HTMLElement) {
    activeInteractiveTarget.click();
  }

  cleanup();
}

function onKeyDown (event: KeyboardEvent) {
  if (event.key in keybindings) {
    event.preventDefault();
    keybindings[event.key](event);
  } else if (event.key === 'Backspace') {
    event.preventDefault();

    activeInteractiveTargetIndex = 0;
    interactiveTargetFilter = interactiveTargetFilter.substring(0, interactiveTargetFilter.length - 1);

    filter();
    highlight();
  } else if (event.key.length === 1) {
    event.preventDefault();

    activeInteractiveTargetIndex = 0;
    interactiveTargetFilter += event.key

    filter();
    highlight();
  }
}

export function find() {
  const interactiveElements: Element[] = [];

  traverseElement(document.documentElement, child => {
    if (!isVisibleElement(child)) {
      return false;
    } else if (isInteractiveElement(child)) {
      interactiveElements.push(child);
    }
  });

  if (interactiveElements.length === 0) {
    return; // nothing to do
  }

  highlightContainer = document.createElement('div');
  highlightContainer.style.boxSizing = 'border-box';
  highlightContainer.style.zIndex = '2147483647';
  highlightContainer.style.position = 'fixed';
  highlightContainer.style.inset = '0px';
  highlightContainer.style.pointerEvents = 'none';
  document.body.append(highlightContainer);

  for (const interactiveElement of interactiveElements) {
    if (!(interactiveElement instanceof HTMLElement)) {
      continue;
    }

    const rect = interactiveElement.getBoundingClientRect();
    const text = interactiveElement.innerText || '*';

    const highlightElement = document.createElement('div');
    highlightContainer.style.boxSizing = 'border-box';
    highlightElement.style.position = 'absolute';
    highlightElement.style.left = `${rect.x}px`;
    highlightElement.style.top = `${rect.y}px`;
    highlightElement.style.width = `${rect.width}px`;
    highlightElement.style.height = `${rect.height}px`;
    highlightContainer.append(highlightElement);

    interactiveTargets.push({
      element: interactiveElement,
      highlightElement,
      text,
      lowerText: text.toLowerCase(),
    });
  }

  filter();
  highlight();

  state.disableKeybindings = true;
  window.addEventListener('keydown', onKeyDown, { capture: true });
}
