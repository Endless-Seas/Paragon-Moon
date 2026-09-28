import { playMusic, stopMusic } from '../audio/handlers';
import { chatMessage } from '../chat/handlers';
import { pingReply, pingSoft } from '../ping/handlers';
import {
  handleTelemetryData,
  telemetryRequest,
  testTelemetryCommand,
} from '../telemetry/handlers';
import { handlePanelAsset } from './handlers/assets';
import { handleRoundRestart } from './handlers/roundrestart';

/** Messages consumed by the chat panel. Keep names aligned with DM topics. */
export const listeners = {
  'asset/stylesheet': (payload: unknown) =>
    handlePanelAsset('asset/stylesheet', payload),
  'asset/mappings': (payload: unknown) =>
    handlePanelAsset('asset/mappings', payload),
  'audio/playMusic': playMusic,
  'audio/stopMusic': stopMusic,
  'chat/message': chatMessage,
  'ping/reply': pingReply,
  'ping/soft': pingSoft,
  roundrestart: handleRoundRestart,
  'telemetry/request': telemetryRequest,
  testTelemetryCommand,
  // The old backend middleware delivered this as `backend/update`; the
  // transport itself sends `update`. Supporting both makes reconnects during
  // a rolling bundle update harmless.
  update: handleTelemetryData,
  'backend/update': handleTelemetryData,
} as const;
