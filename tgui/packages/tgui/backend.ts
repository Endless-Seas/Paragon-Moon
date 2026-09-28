/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */
import { useAtomValue } from 'jotai';
import { type SetStateAction, useCallback } from 'react';

import { sendAct } from './events/act';
import {
  backendStateAtom,
  configAtom,
  sharedAtom,
  store,
} from './events/store';

/** Snapshot access for class components and non-React event handlers. */
export function getBackend<TData = Record<string, any>>() {
  const state = store.get(backendStateAtom);
  const act = (action: string, payload: object = {}) =>
    sendAct(action, payload, state.config.window?.session);
  return { ...state, data: state.data as TData, act };
}

export function useBackend<TData = Record<string, any>>() {
  const state = useAtomValue(backendStateAtom, { store });
  const session = state.config.window?.session;
  const act = useCallback(
    (action: string, payload: object = {}) => sendAct(action, payload, session),
    [session],
  );
  return { ...state, data: state.data as TData, act };
}

type StateWithSetter<T> = [T, (nextState: SetStateAction<T>) => void];

/** Window-local state, forgotten when a pooled window is suspended. */
export function useLocalState<T>(
  key: string,
  initialState: T,
): StateWithSetter<T> {
  const shared = useAtomValue(sharedAtom, { store });
  const session = store.get(configAtom).window?.session;
  return [
    key in shared ? shared[key] : initialState,
    (nextState) => {
      if (store.get(configAtom).window?.session !== session) return;
      store.set(sharedAtom, (previous) => {
        const current = key in previous ? previous[key] : initialState;
        return {
          ...previous,
          [key]:
            typeof nextState === 'function'
              ? (nextState as (value: T) => T)(current)
              : nextState,
        };
      });
    },
  ];
}

/** State shared by the server with other authorized viewers of this UI. */
export function useSharedState<T>(
  key: string,
  initialState: T,
): StateWithSetter<T> {
  const shared = useAtomValue(sharedAtom, { store });
  const session = store.get(configAtom).window?.session;
  return [
    key in shared ? shared[key] : initialState,
    (nextState) => {
      const { config, suspended, suspending } = store.get(backendStateAtom);
      if (suspended || suspending || config.window?.session !== session) return;
      const current = store.get(sharedAtom);
      const value = key in current ? current[key] : initialState;
      Byond.sendMessage({
        type: 'setSharedState',
        windowSession: config.window.session,
        key,
        value:
          JSON.stringify(
            typeof nextState === 'function'
              ? (nextState as (value: T) => T)(value)
              : nextState,
          ) || '',
      });
    },
  ];
}
