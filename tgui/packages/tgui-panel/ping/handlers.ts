import { store } from '../events/store';
import { lastPingedAtAtom } from './atoms';
import { pings, pingSuccess, sendPing } from './helpers';

type SoftPingPayload = {
  afk?: boolean;
};

/** Handles the periodic server-side ping. */
export function pingSoft(payload: SoftPingPayload = {}): void {
  store.set(lastPingedAtAtom, Date.now());
  if (!payload.afk) {
    sendPing();
  }
}

type ReplyPingPayload = {
  index: number;
};

export function pingReply(payload: ReplyPingPayload): void {
  if (!Number.isInteger(payload?.index)) {
    return;
  }

  const ping = pings[payload.index];
  if (!ping) {
    return;
  }

  pings[payload.index] = null;
  pingSuccess((Date.now() - ping.sentAt) * 0.5);
}
