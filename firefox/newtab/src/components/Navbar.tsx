import { Link } from 'react-router-dom';
import styles from './Navbar.scss';

const NavItems = [
  {
    title: 'Bookmarks',
    href: '/bookmarks',
  },
];

export const Navbar = () => (
  <div className={styles.navbar}>
    {NavItems.map(navItem => (
      <Link to={navItem.href}>{navItem.title}</Link>
    ))}
  </div>
);
