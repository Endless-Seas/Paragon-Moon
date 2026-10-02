/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import './styles/main.scss';

import { perf } from 'common/perf';
import { captureExternalLinks } from 'tgui/links';
import { render } from 'tgui/renderer';
import { EventBus } from 'tgui-core/eventbus';
import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotReloading } from 'tgui-dev-server/link/client';

import { App } from './app';
import { listeners } from './events/listeners';
import { setupPanelFocusHacks } from './panelFocus';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

const bus = new EventBus(listeners);

function installPanelStackAugmentor(): void {
  const previous = (window as any).__augmentStack__;
  (window as any).__augmentStack__ = (stack: string, error?: Error) => {
    const base =
      typeof previous === 'function' ? previous(stack, error) : stack;
    return `${base}\nTGUI panel window: ${Byond.windowId}`;
  };
}

function setupApp() {
  // Delay setup until the browser output has a document.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp, { once: true });
    return;
  }

  setupGlobalEvents({
    ignoreWindowFocus: true,
  });

  setupPanelFocusHacks();
  captureExternalLinks();
  installPanelStackAugmentor();

  render(<App />);

  // Dispatch incoming messages to panel-owned event handlers. No Redux root
  // store is created for this window.
  Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));

  // Unhide the panel.
  Byond.winset('outputwindow.legacy_output_selector', {
    left: 'output_browser',
  });

  // Resize the panel to match the non-browser output.
  Byond.winget('legacy_output_selector').then((output: { size: string }) => {
    Byond.winset('browseroutput', {
      size: output.size,
    });
  });

  if (import.meta.webpackHot) {
    setupHotReloading();
    import.meta.webpackHot.accept(['./app', './Panel'], () => render(<App />));
  }
}

setupApp();
