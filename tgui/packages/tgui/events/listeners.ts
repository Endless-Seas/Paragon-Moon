import { handleAssetMessage } from '../assets';
import { relayMessage } from '../debug/events';
import {
  acknowledgePayloadChunk,
  oversizePayloadResponse,
  rejectPayload,
} from './act';
import { suspend, update } from './window';

const handlers = {
  update,
  suspend,
  ping: () => Byond.sendMessage('ping/reply'),
  oversizePayloadResponse,
  acknowledgePayloadChunk,
  rejectPayload,
};

export function dispatchMessage(type: string, payload: any, relayed = false) {
  if (process.env.NODE_ENV !== 'production' && !relayed) {
    relayMessage(type, payload);
  }
  if (handleAssetMessage(type, payload)) return;
  handlers[type]?.(payload);
}
