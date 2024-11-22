import { SCROLL_HIGHLIGHT_COLOR, SCROLL_HIGHLIGHT_TIMEOUT } from './constants';
import { isScrollableElement, isVisibleElement, traverseElement } from './element';
import { state } from './state';

// -----------------------------------------------------------------------------
// State
// -----------------------------------------------------------------------------

let highlightTimeout = -1;

const highlightElement = document.createElement('div');
highlightElement.style.zIndex = '2147483647';
highlightElement.style.position = 'fixed';
highlightElement.style.boxSizing = 'border-box';
highlightElement.style.background = `${SCROLL_HIGHLIGHT_COLOR}22`;
highlightElement.style.border = `4px solid ${SCROLL_HIGHLIGHT_COLOR}FF`;
document.body.append(highlightElement);

// -----------------------------------------------------------------------------
// cycleActiveScrollElement
// -----------------------------------------------------------------------------

export function cycleActiveScrollElement(increment: number) {
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
  highlightElement.style.display = 'block';
  highlightElement.style.left = `${x}px`;
  highlightElement.style.top = `${y}px`;
  highlightElement.style.width = `${width}px`;
  highlightElement.style.height = `${height}px`;

  clearTimeout(highlightTimeout);
  highlightTimeout = setTimeout(
    () => { highlightElement.style.display = 'none'; },
    SCROLL_HIGHLIGHT_TIMEOUT,
  );
}