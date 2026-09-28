import { Provider } from 'jotai';

import { store } from './events/store';
import { Panel } from './Panel';

/** Keeps all panel state in the panel bundle instead of the application store. */
export function App() {
  return (
    <Provider store={store}>
      <Panel />
    </Provider>
  );
}
