import { atom } from 'jotai';

import { lastPingedAtAtom } from '../ping/atoms';
import { CONNECTION_LOST_AFTER } from './constants';

export const roundRestartedAtAtom = atom<number | null>(null);

const nowAtom = atom(0);
nowAtom.onMount = (set) => {
  set(Date.now());
  const id = setInterval(() => set(Date.now()), 1000);
  return () => clearInterval(id);
};

/** The deadline at which a missing ping becomes a visible disconnect. */
export const connectionLostAtAtom = atom<number | null>((get) => {
  const lastPingedAt = get(lastPingedAtAtom);
  if (!lastPingedAt) {
    return null;
  }

  const deadline = lastPingedAt + CONNECTION_LOST_AFTER;
  return get(nowAtom) >= deadline ? deadline : null;
});

export const gameAtom = atom((get) => ({
  roundRestartedAt: get(roundRestartedAtAtom),
  connectionLostAt: get(connectionLostAtAtom),
}));
