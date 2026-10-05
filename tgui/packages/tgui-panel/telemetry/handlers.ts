import { storage } from 'common/storage';

import { MAX_CONNECTIONS_STORED } from './constants';
import { type ConnectionRecord, connectionsMatch } from './helpers';

type Telemetry = {
  connections: ConnectionRecord[];
};

let telemetry: Telemetry | null = null;
let deferredRequest: { limits?: { connections?: number } } | null = null;

export function telemetryRequest(
  payload: { limits?: { connections?: number } } = {},
): void {
  if (!telemetry) {
    deferredRequest = payload;
    return;
  }

  const limit = payload.limits?.connections;
  const connections =
    typeof limit === 'number'
      ? telemetry.connections.slice(0, Math.max(0, limit))
      : telemetry.connections;
  Byond.sendMessage('telemetry', { connections });
}

export function testTelemetryCommand(): void {
  setTimeout(() => {
    if (!telemetry) {
      Byond.sendMessage('ready');
    }
  }, 500);
}

export async function handleTelemetryData(payload: any): Promise<void> {
  const client = payload?.config?.client;
  if (!client) {
    return;
  }

  if (!telemetry) {
    const stored = await storage.get('telemetry');
    telemetry = {
      connections: Array.isArray(stored?.connections)
        ? stored.connections.slice(0, MAX_CONNECTIONS_STORED)
        : [],
    };
  }

  if (!telemetry.connections.some((entry) => connectionsMatch(entry, client))) {
    telemetry.connections.unshift(client);
    telemetry.connections = telemetry.connections.slice(
      0,
      MAX_CONNECTIONS_STORED,
    );
    await storage.set('telemetry', telemetry);
  }

  if (deferredRequest) {
    const request = deferredRequest;
    deferredRequest = null;
    telemetryRequest(request);
  }
}
