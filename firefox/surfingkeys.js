// -----------------------------------------------------------------------------
// Settings
// -----------------------------------------------------------------------------

settings.tabsThreshold = 0;
settings.omnibarMaxResults = 8;

// -----------------------------------------------------------------------------
// Mappings
// -----------------------------------------------------------------------------

map('<Ctrl-[>', '<Esc>');
map('H', 'S');
map('L', 'D');

// -----------------------------------------------------------------------------
// Theme
// -----------------------------------------------------------------------------

function compileTheme(theme) {
  return typeof theme !== 'object'
    ? theme.replaceAll(';', ' !important;')
    : Object.values(theme)
        .map(subtheme => compileTheme(subtheme))
        .join(' ');
}

settings.theme = compileTheme({
  palette: `
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
  `,

  surfingkeys: {
    main: `
      .sk_theme {
          color: var(--onedark-white);
          background: var(--onedark-black);
          font-size: 14px;
          font-family: Input Sans Condensed, Charcoal, sans-serif;
      }
      .sk_theme .separator {
          color: #fff;
      }
      .sk_theme tbody {
          color: #fff;
      }
      .sk_theme input {
          color: var(--onedark-white);
      }
      .sk_theme .url {
          color: var(--onedark-blue);
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
    `,
    omnibar: `
      #sk_omnibar {
        width: 70%;
        padding: 16px;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
      }
      #sk_omnibarSearchArea, #sk_omnibarSearchResult {
        margin: 0;
      }
      #sk_omnibarSearchArea {
        border-bottom-width: 2px;
        border-bottom-color: var(--onedark-white);
      }
      #sk_omnibarSearchArea .prompt, #sk_omnibarSearchArea .resultPage {
        display: none;
      }
      #sk_omnibarSearchArea input {
        margin-bottom: 8px;
        padding: 0;
      }
      #sk_omnibarSearchResult ul {
        margin: 0;
      }
      #sk_omnibarSearchResult .omnibar_folder {
        color: var(--onedark-green);
      }
      #sk_omnibarSearchResult .omnibar_timestamp {
        display: none;
      }
      #sk_omnibarSearchResult .title {
        margin-left: -16px;
      }
      #sk_omnibarSearchResult .url {
        font-size: 10px;
      }
      #sk_omnibar #sk_omnibarSearchResult ul li {
        margin-top: 8px;
        padding: 0;
        background: none;
      }
      #sk_omnibar #sk_omnibarSearchResult ul li.focused {
        background: #abb2bf20;
      }
    `,
  },

  ace: {
    editor: `
      #sk_editor {
          color: var(--onedark-white);
          background-color: var(--onedark-black);
      }
      .ace_gutter, .ace_gutter-active-line {
          color: var(--onedark-black);
          background-color: var(--onedark-white);
      }
    `,
    cursor: `
      .ace_animate-blinking .ace_cursor {
          animation: none;
          border-color: var(--onedark-white);
      }
      .normal-mode .ace_animate-blinking .ace_cursor {
          background-color: #abb2bf88;
      }
      .ace_hidden-cursors .ace_cursor {
          border-color: var(--onedark-white);
      }
    `,
    selection: `
      .ace_selection {
          background-color: var(--onedark-white);
          opacity: 0.2;
      }
      .ace_selected-word {
          border: none;
          background: none;
      }
    `,
  },
});
