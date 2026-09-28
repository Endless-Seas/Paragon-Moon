import { scale } from 'tgui-core/math';

import { store } from '../events/store';
import { lastPingedAtAtom, pingAtom } from './atoms';
import {
  PING_QUEUE_SIZE,
  PING_ROUNDTRIP_BEST,
  PING_ROUNDTRIP_WORST,
  PING_TIMEOUT,
} from './constants';

type Ping = {
  index: number;
  sentAt: number;
} | null;

let nextIndex = 0;
export const pings: Ping[] = [];

/** Sends a bounded ping queue and retires timed-out entries. */
export function sendPing(): void {
  const now = Date.now();
  for (let i = 0; i < PING_QUEUE_SIZE; i++) {
    const ping = pings[i];
    if (ping && now - ping.sentAt > PING_TIMEOUT) {
      pings[i] = null;
      pingFail();
    }
  }

  const ping = { index: nextIndex, sentAt: now };
  pings[nextIndex] = ping;
  Byond.sendMessage('ping', { index: nextIndex });
  nextIndex = (nextIndex + 1) % PING_QUEUE_SIZE;
}

export function pingSuccess(roundtrip: number): void {
  const state = store.get(pingAtom);
  const previous = state.roundtripAvg ?? roundtrip;
  const roundtripAvg = Math.round(previous * 0.4 + roundtrip * 0.6);
  const networkQuality = Math.max(
    0,
    Math.min(
      1,
      1 - scale(roundtripAvg, PING_ROUNDTRIP_BEST, PING_ROUNDTRIP_WORST),
    ),
  );

  store.set(pingAtom, {
    roundtrip,
    roundtripAvg,
    failCount: 0,
    networkQuality,
  });
  store.set(lastPingedAtAtom, Date.now());
}

export function pingFail(): void {
  const state = store.get(pingAtom);
  const failCount = state.failCount || 0;
  const networkQuality = Math.max(
    0,
    state.networkQuality - failCount / PING_QUEUE_SIZE,
  );
  const nextState: typeof state = {
    ...state,
    failCount: failCount + 1,
    networkQuality,
  };

  if (failCount >= PING_QUEUE_SIZE) {
    nextState.roundtrip = undefined;
    nextState.roundtripAvg = undefined;
  }

  store.set(pingAtom, nextState);
}
