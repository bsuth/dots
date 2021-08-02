import m from 'mithril';

const Bookmark = {
  view: vnode => m('div', vnode.attrs.title),
};

m.render(
  document.body,
  [
    {
      title: 'test',
      href: 'google.com',
    },
    {
      title: 'test2',
      href: 'google.com',
    },
  ].map(data => m(Bookmark, data))
);
