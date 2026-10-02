/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
import { globalEvents } from 'tgui-core/events';
import { acquireHotKey } from 'tgui-core/hotkeys';
import { KEY_BACKSPACE, KEY_F10, KEY_F11, KEY_F12 } from 'tgui-core/keycodes';

import { debugAtom, store } from '../events/store';

export function toggleKitchenSink() {
  store.set(debugAtom, (previous) => ({
    ...previous,
    kitchenSink: !previous.kitchenSink,
  }));
}

export function setupDebugEvents(
  dispatch: (type: string, payload: any, relayed: boolean) => void,
) {
  const devServer = require('tgui-dev-server/link/client.ts');
  acquireHotKey(KEY_F11);
  acquireHotKey(KEY_F12);
  acquireHotKey(KEY_F10);
  globalEvents.on('keydown', (key) => {
    if (key.code === KEY_F11) {
      store.set(debugAtom, (previous) => ({
        ...previous,
        debugLayout: !previous.debugLayout,
      }));
    }
    if (key.code === KEY_F12) toggleKitchenSink();
    if (key.code === KEY_F10) {
      window.open(`${location.href}?external`, '_blank');
    }
    if (key.ctrl && key.alt && key.code === KEY_BACKSPACE) {
      setTimeout(() => {
        throw new Error('TGUI debug error');
      });
    }
  });
  if (location.search === '?external') {
    devServer.subscribe(({ type, payload }) => {
      if (type === 'relay' && payload.windowId === Byond.windowId) {
        dispatch(payload.action.type, payload.action.payload, true);
      }
    });
  }
}

export function relayMessage(type: string, payload: any) {
  if (location.search !== '?external' && type === 'update') {
    const devServer = require('tgui-dev-server/link/client.ts');
    devServer.sendMessage({
      type: 'relay',
      payload: { windowId: Byond.windowId, action: { type, payload } },
    });
  }
}
