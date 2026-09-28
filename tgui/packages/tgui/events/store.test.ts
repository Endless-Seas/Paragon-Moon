import { afterEach, describe, expect, it } from 'bun:test';
import { createStore } from 'jotai';
import { createElement } from 'react';
import { flushSync } from 'react-dom';
import { createRoot } from 'react-dom/client';

import { getBackend, useLocalState } from '../backend';
import {
  backendStateAtom,
  resetAtom,
  sharedAtom,
  store,
  updateAtom,
} from './store';
import type { Config } from './types';

const windowConfig = (session: number) => ({ session }) as Config['window'];

afterEach(() => store.set(resetAtom));

describe('Paragon backend contracts', () => {
  it('publishes complete first data and preserves per-packet merge precedence', () => {
    const local = createStore();
    const observed: unknown[] = [];
    const unsubscribe = local.sub(backendStateAtom, () => {
      observed.push(local.get(backendStateAtom));
    });
    local.set(updateAtom, {
      config: { window: windowConfig(1) },
      static_data: { collision: 'static', retained: 'static' },
      data: { collision: 'dynamic', partial: 1 },
    });
    expect(observed).toHaveLength(1);
    expect(local.get(backendStateAtom).suspended).toBe(false);
    expect(local.get(backendStateAtom).data.collision).toBe('dynamic');
    local.set(updateAtom, { data: { partial: 2 } });
    expect(local.get(backendStateAtom).data).toEqual({
      collision: 'dynamic',
      retained: 'static',
      partial: 2,
    });
    // A later static-only packet overwrites an earlier dynamic value, as before.
    local.set(updateAtom, { static_data: { collision: 'later static' } });
    expect(local.get(backendStateAtom).data.collision).toBe('later static');
    unsubscribe();
  });

  it('decodes shared values and clears all object state on suspension or owner change', () => {
    const local = createStore();
    local.set(updateAtom, {
      config: { window: windowConfig(1) },
      data: { secret: 'old object' },
      shared: { draft: '"text"', malformed: '{broken', empty: '' },
    });
    expect(local.get(sharedAtom)).toEqual({ draft: 'text', empty: undefined });
    local.set(resetAtom);
    expect(local.get(backendStateAtom).data).toEqual({});
    expect(local.get(sharedAtom)).toEqual({});
    local.set(updateAtom, { data: { old: true } });
    local.set(updateAtom, {
      config: { window: windowConfig(2) },
      data: { current: true },
    });
    expect(local.get(backendStateAtom).data).toEqual({ current: true });
    expect(local.get(sharedAtom)).toEqual({});
  });

  it('evaluates consecutive local functional setters against the latest state', () => {
    let state: ReturnType<typeof useLocalState<number>>;
    function Fixture() {
      state = useLocalState('counter', 0);
      return null;
    }
    const host = document.createElement('div');
    const root = createRoot(host);
    try {
      flushSync(() => root.render(createElement(Fixture)));
      flushSync(() => {
        state[1]((value) => value + 1);
        state[1]((value) => value + 1);
      });
      expect(store.get(sharedAtom).counter).toBe(2);
      flushSync(() => store.set(resetAtom));
      expect(store.get(sharedAtom)).toEqual({});
    } finally {
      flushSync(() => root.unmount());
    }
  });

  it('does not let an old render send actions to the next pooled-window owner', () => {
    const globals = globalThis as typeof globalThis & { Byond: typeof Byond };
    const previousByond = globals.Byond;
    const sent: unknown[] = [];
    globals.Byond = {
      windowId: 'test-window',
      sendMessage: (message) => sent.push(message),
    } as any;
    try {
      store.set(updateAtom, { config: { window: windowConfig(1) } });
      const old = getBackend();
      store.set(updateAtom, { config: { window: windowConfig(2) } });
      old.act('submit', { private: 'old object' });
      expect(sent).toEqual([]);
      getBackend().act('submit', { current: true });
      expect(sent).toEqual([
        { type: 'act/submit', payload: { current: true }, windowSession: 2 },
      ]);
    } finally {
      globals.Byond = previousByond;
    }
  });
});
