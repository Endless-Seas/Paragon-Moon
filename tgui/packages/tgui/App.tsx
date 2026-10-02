import { useBackend } from './backend';
import { IconProvider } from './Icons';

export function App() {
  const { config, suspended } = useBackend();
  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent();

  if (suspended) return null;

  return (
    <>
      <Component key={config.window?.session} />
      <IconProvider />
    </>
  );
}
