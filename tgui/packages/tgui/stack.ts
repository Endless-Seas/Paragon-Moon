import { getBackend } from './backend';
import { createLogger } from './logging';

const logger = createLogger('stack');

export function createStackAugmentor() {
  return (stack: string, error?: Error) => {
    logger.log('FatalError:', error || new Error(stack));
    const { config } = getBackend();
    return `${stack}\nUser Agent: ${navigator.userAgent}\nState: ${JSON.stringify(
      {
        ckey: config.client?.ckey,
        interface: config.interface,
        window: config.window,
      },
    )}`;
  };
}
