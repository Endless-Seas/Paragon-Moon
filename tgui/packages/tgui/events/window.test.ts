import { expect, it, spyOn } from 'bun:test';

import { resetAtom, store, suspendingAtom, updateAtom } from './store';
import type { Config } from './types';
import { suspendStart, update } from './window';

it('keeps retrying a dropped close across ordinary updates, but stops on window reuse', () => {
  const globals = globalThis as typeof globalThis & { Byond: typeof Byond };
  const previousByond = globals.Byond;
  const sent: unknown[] = [];
  let retry: (() => void) | undefined;
  const schedule = spyOn(globalThis, 'setInterval').mockImplementation(((
    callback: () => void,
  ) => {
    retry = callback;
    return 123;
  }) as unknown as typeof setInterval);
  const cancel = spyOn(globalThis, 'clearInterval').mockImplementation(() => {
    retry = undefined;
  });
  globals.Byond = {
    sendMessage: (message) => sent.push(message),
    winset: () => {},
  } as any;
  const config = (session: number) => ({
    window: { session } as Config['window'],
  });
  try {
    store.set(updateAtom, { config: config(1) });
    suspendStart();
    update({ config: config(1), data: { changed: true } });
    expect(store.get(suspendingAtom)).toBe(true);
    expect(retry).toBeDefined();
    retry!();
    expect(sent).toEqual([
      { type: 'suspend', windowSession: 1 },
      { type: 'suspend', windowSession: 1 },
    ]);
    update({ config: config(2) });
    expect(retry).toBeUndefined();
    expect(store.get(suspendingAtom)).toBe(false);
  } finally {
    update({ config: config(3) });
    store.set(resetAtom);
    schedule.mockRestore();
    cancel.mockRestore();
    globals.Byond = previousByond;
  }
});
