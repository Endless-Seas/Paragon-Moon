/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
import { setupDrag } from '../drag';
import { focusMap } from '../focus';
import { resumeRenderer, suspendRenderer } from '../renderer';
import { cancelTransfers } from './act';
import {
  configAtom,
  resetAtom,
  store,
  suspendedAtom,
  suspendingAtom,
  updateAtom,
} from './store';
import type { UpdatePayload } from './types';

let suspendInterval: ReturnType<typeof setInterval> | undefined;

export function update(payload: UpdatePayload) {
  const previous = store.get(configAtom);
  const wasSuspended = store.get(suspendedAtom);
  if (
    payload.config?.window &&
    payload.config.window.session !== previous.window?.session
  ) {
    clearInterval(suspendInterval);
    suspendInterval = undefined;
    cancelTransfers();
  }
  store.set(updateAtom, payload);
  const config = store.get(configAtom);
  if (previous.window?.fancy !== config.window?.fancy) {
    Byond.winset(Byond.windowId, {
      titlebar: !config.window?.fancy,
      'can-resize': !config.window?.fancy,
    });
  }
  if (wasSuspended) {
    resumeRenderer();
    setupDrag();
    setTimeout(() => {
      if (store.get(suspendedAtom)) return;
      Byond.winset(Byond.windowId, { 'is-visible': true });
      Byond.sendMessage('visible');
    });
  }
}

export function suspend() {
  cancelTransfers();
  clearInterval(suspendInterval);
  suspendInterval = undefined;
  suspendRenderer();
  store.set(resetAtom);
  Byond.winset(Byond.windowId, { 'is-visible': false });
  setTimeout(focusMap);
}

export function suspendStart() {
  if (suspendInterval) return;
  cancelTransfers();
  store.set(suspendingAtom, true);
  const session = store.get(configAtom).window?.session;
  const send = () =>
    Byond.sendMessage({ type: 'suspend', windowSession: session });
  send();
  suspendInterval = setInterval(send, 2000);
}
