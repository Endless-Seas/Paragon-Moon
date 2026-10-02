/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
import { atom, createStore } from 'jotai';

import type { Config, UpdatePayload } from './types';

export const configAtom = atom<Config>({} as Config);
export const dataAtom = atom<Record<string, any>>({});
export const sharedAtom = atom<Record<string, any>>({});
export const suspendedAtom = atom<number | false>(Date.now());
export const suspendingAtom = atom(false);
export const debugAtom = atom({ debugLayout: false, kitchenSink: false });

export const backendStateAtom = atom((get) => ({
  config: get(configAtom),
  data: get(dataAtom),
  shared: get(sharedAtom),
  suspended: get(suspendedAtom),
  suspending: get(suspendingAtom),
}));

// Publish the complete update together, including the first render after reuse.
// Paragon merges each packet's dynamic data last, including partial updates.
export const updateAtom = atom(null, (get, set, payload: UpdatePayload) => {
  const nextConfig = { ...get(configAtom), ...payload.config };
  const previousSession = get(configAtom).window?.session;
  if (
    previousSession !== undefined &&
    nextConfig.window?.session !== previousSession
  ) {
    set(dataAtom, {});
    set(sharedAtom, {});
  }
  set(configAtom, nextConfig);
  set(dataAtom, {
    ...get(dataAtom),
    ...payload.static_data,
    ...payload.data,
  });
  if (payload.shared) {
    const shared = { ...get(sharedAtom) };
    for (const [key, value] of Object.entries(payload.shared)) {
      if (typeof value !== 'string') continue;
      try {
        shared[key] = value === '' ? undefined : JSON.parse(value);
      } catch {
        // Ignore one malformed value without discarding the rest of the update.
      }
    }
    set(sharedAtom, shared);
  }
  if (get(suspendedAtom) || nextConfig.window?.session !== previousSession) {
    set(suspendingAtom, false);
  }
  set(suspendedAtom, false);
});

export const resetAtom = atom(null, (get, set) => {
  set(dataAtom, {});
  set(sharedAtom, {});
  set(configAtom, { ...get(configAtom), title: '', status: 1 });
  set(suspendingAtom, false);
  set(suspendedAtom, Date.now());
});

export const store = createStore();
