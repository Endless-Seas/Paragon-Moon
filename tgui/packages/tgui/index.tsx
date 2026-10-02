/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { perf } from 'common/perf';
import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotKeys } from 'tgui-core/hotkeys';
import { setupHotReloading } from 'tgui-dev-server/link/client';

import { App } from './App';
import { setupDebugEvents } from './debug/events';
import { dispatchMessage } from './events/listeners';
import { captureExternalLinks } from './links';
import { render } from './renderer';
import { createStackAugmentor } from './stack';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  window.__augmentStack__ = createStackAugmentor();

  setupGlobalEvents();
  setupHotKeys({
    keyUpVerb: 'KeyUp',
    keyDownVerb: 'KeyDown',
    // In the future you could send a winget here to get mousepos/size from the map here if it's necessary
    verbParamsFn: (verb, key) => `${verb} "${key}" 0 0 0 0`,
  });
  captureExternalLinks();

  Byond.subscribe(dispatchMessage);
  render(<App />);

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setupDebugEvents(dispatchMessage);
    setupHotReloading();
    import.meta.webpackHot.accept(
      ['./debug', './layouts', './routes', './App'],
      () => {
        render(<App />);
      },
    );
  }
}

setupApp();
