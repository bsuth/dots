export function traverseElement(element: Element, callback: (element: Element) => void) {
  callback(element);

  for (const child of element.children) {
    traverseElement(child, callback);
  }
}

export function isAncestorElement(child: Element, ancestor: Element) {
  if (child.parentNode === ancestor) {
    return true;
  } else if (child.parentNode instanceof Element) {
    return isAncestorElement(child.parentNode, ancestor);
  } else {
    return false;
  }
}

export function isVisibleElement(element: Element) {
  const isElementRendered = element.checkVisibility({
    checkOpacity: true,
    checkVisibilityCSS: true,
    contentVisibilityAuto: true,
  })

  if (!isElementRendered) {
    return false;
  }

  const { x, y, width, height } = element.getBoundingClientRect();

  return (
    x + width >= 0 &&
    x <= window.innerWidth &&
    y + height >= 0 &&
    y <= window.innerHeight
  );
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
