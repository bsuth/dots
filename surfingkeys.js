// an example to create a new mapping `ctrl-y`
mapkey("<ctrl-y>", "Show me the money", function () {
  Front.showPopup(
    "a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close)."
  );
});

unmap("<ctrl-e>");

map("<Ctrl-[>", "<Esc>");

// set theme
settings.theme = `
/* -------------------------------------------------------------------------- */
/* OneDark                                                                    */
/* -------------------------------------------------------------------------- */

:root {
  --onedark-black: #282c34;
  --onedark-red: #e06c75;
  --onedark-green: #98c379;
  --onedark-yellow: #e5c07b;
  --onedark-blue: #61afef;
  --onedark-purple: #c678dd;
  --onedark-cyan: #56b6c2;
  --onedark-white: #abb2bf;
}

/* -------------------------------------------------------------------------- */
/* Surfing Keys UI                                                            */
/* -------------------------------------------------------------------------- */

.sk_theme {
    color: #abb2bf;
    background: var(--onedark-black);
    font-size: 10pt;
    font-family: Input Sans Condensed, Charcoal, sans-serif;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 20pt;
}

/* -------------------------------------------------------------------------- */
/* Ace Editor                                                                 */
/* -------------------------------------------------------------------------- */

/**
 * Editor
 */

#sk_editor {
    color: var(--onedark-white) !important;
    background-color: var(--onedark-black) !important;
}

.ace_gutter, .ace_gutter-active-line {
    color: var(--onedark-black) !important;
    background-color: var(--onedark-white) !important;
}

/**
 * Cursor
 */

.ace_animate-blinking .ace_cursor {
    animation: none !important;
    border-color: var(--onedark-white) !important;
}

.normal-mode .ace_animate-blinking .ace_cursor {
    background-color: #abb2bf88 !important;
}

.ace_hidden-cursors .ace_cursor {
    border-color: var(--onedark-white) !important;
}

/**
 * Selections
 */

.ace_selection {
    background-color: var(--onedark-white) !important;
    opacity: 0.2 !important;
}

.ace_selected-word {
    border: none !important;
    background: none !important;
}

`;
