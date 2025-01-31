export function isAncestorElement(child: Element, ancestor: Element) {
  if (child.parentNode === ancestor) {
    return true;
  } else if (child.parentNode instanceof Element) {
    return isAncestorElement(child.parentNode, ancestor);
  } else {
    return false;
  }
}

export function isInteractiveElement(element: Element) {
  if (element instanceof HTMLAnchorElement) {
    return true;
  }

  if (element instanceof HTMLButtonElement) {
    return true;
  }

  if (element instanceof HTMLInputElement) {
    return true;
  }

  if (element instanceof HTMLTextAreaElement) {
    return true;
  }

  if (element instanceof HTMLSelectElement) {
    return true;
  }

  return false;
}

export function isScrollableElement(element: Element) {
  if (element.clientHeight === element.scrollHeight) {
    return false;
  }

  const overflowY = getComputedStyle(element).overflowY;

  if (element === document.documentElement) {
    // The root element still acts as a scroll container when the overflow is
    // set to 'visible'.
    return overflowY !== 'hidden' && overflowY !== 'clip';
  } else {
    return overflowY !== 'visible' && overflowY !== 'hidden' && overflowY !== 'clip';
  }
}

export function isVisibleElement(element: Element) {
  const isElementRendered = element.checkVisibility({
    checkOpacity: true,
    checkVisibilityCSS: true,
    contentVisibilityAuto: true,
  })

  // NOTE: The `Element.checkVisibility` spec states:
  //
  // "If `this` does not have an associated box, return false."
  //
  // Since elements with `display: contents` do not define a box on their own,
  // we should only use `Element.checkVisibility` for elements that do _not_
  // specify `display: contents`.
  //
  // See: https://drafts.csswg.org/cssom-view/#dom-element-checkvisibility
  if (!isElementRendered && getComputedStyle(element).display !== 'contents') {
    return false;
  }

  const { x, y, width, height } = element.getBoundingClientRect();

  // TODO: consider overflow

  return (
    x + width >= 0 &&
    x <= window.innerWidth &&
    y + height >= 0 &&
    y <= window.innerHeight
  );
}

export function traverseElement(element: Element, callback: (element: Element) => boolean | void) {
  if (callback(element) === false) {
    return;
  }

  for (const child of element.children) {
    traverseElement(child, callback);
  }
}
