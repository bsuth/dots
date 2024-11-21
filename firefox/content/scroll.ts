import {
  SCROLL_HIGHLIGHT_COLOR,
  SCROLL_HIGHLIGHT_TIMEOUT,
  SCROLL_SPEED_FAST,
  SCROLL_SPEED_SLOW,
} from './constants';
import { traverseElement, isVisibleElement, isScrollableElement } from './element';
import { state } from './state';

// -----------------------------------------------------------------------------
// Setup
// -----------------------------------------------------------------------------

// TODO
let activeScrollHighlightTimeout = -1;

// TODO
const activeScrollHighlightElement = document.createElement('div');
activeScrollHighlightElement.style.zIndex = '2147483647';
activeScrollHighlightElement.style.position = 'fixed';
activeScrollHighlightElement.style.boxSizing = 'border-box';
activeScrollHighlightElement.style.background = `${SCROLL_HIGHLIGHT_COLOR}22`;
activeScrollHighlightElement.style.border = `4px solid ${SCROLL_HIGHLIGHT_COLOR}FF`;
document.body.append(activeScrollHighlightElement);

// -----------------------------------------------------------------------------
// Api
// -----------------------------------------------------------------------------

export function scrollDownFast() {
  state.activeScrollElement.scrollBy({
    top: SCROLL_SPEED_FAST,
    behavior: 'instant',
  });
}

export function scrollDownSlow() {
  state.activeScrollElement.scrollBy({
    top: SCROLL_SPEED_SLOW,
    behavior: 'instant',
  });
}

export function scrollUpFast() {
  state.activeScrollElement.scrollBy({
    top: -SCROLL_SPEED_FAST,
    behavior: 'instant',
  });
}

export function scrollUpSlow() {
  state.activeScrollElement.scrollBy({
    top: -SCROLL_SPEED_SLOW,
    behavior: 'instant',
  });
}

export function scrollToTop() {
  state.activeScrollElement.scrollTo({
    top: 0,
    behavior: 'instant',
  });
}

export function scrollToBottom() {
  state.activeScrollElement.scrollTo({
    top: state.activeScrollElement.scrollHeight,
    behavior: 'instant',
  });
}

export function cycleHighlightedScrollContainers(increment: number) {
  const scrollElements: Element[] = [];
  let activeScrollElementIndex = 0;

  traverseElement(document.documentElement, child => {
    if (child === state.activeScrollElement) {
      activeScrollElementIndex = scrollElements.length;
      scrollElements.push(child);
    } else if (isScrollableElement(child) && isVisibleElement(child)) {
      scrollElements.push(child);
    }
  });

  if (scrollElements.length === 0) {
    return; // nothing to do
  }

  const newActiveScrollElementIndex = (activeScrollElementIndex + increment + scrollElements.length) % scrollElements.length;
  const newActiveScrollElement = scrollElements[newActiveScrollElementIndex];
  state.activeScrollElement = newActiveScrollElement;

  const { x, y, width, height } = newActiveScrollElement.getBoundingClientRect();
  activeScrollHighlightElement.style.display = 'block';
  activeScrollHighlightElement.style.left = `${x}px`;
  activeScrollHighlightElement.style.top = `${y}px`;
  activeScrollHighlightElement.style.width = `${width}px`;
  activeScrollHighlightElement.style.height = `${height}px`;

  clearTimeout(activeScrollHighlightTimeout);
  activeScrollHighlightTimeout = setTimeout(
    () => { activeScrollHighlightElement.style.display = 'none'; },
    SCROLL_HIGHLIGHT_TIMEOUT,
  );
}
