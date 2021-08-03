import './styles.scss';
import { render } from 'react-dom';
import { BrowserRouter } from 'react-router-dom';
import { Navbar } from './components/Navbar';

render(
  <BrowserRouter children={[<Navbar />]} />,
  document.getElementById('root'),
);
