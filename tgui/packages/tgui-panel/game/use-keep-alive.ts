import { useAtomValue, useSetAtom } from 'jotai';
import { useEffect } from 'react';

import { lastPingedAtAtom } from '../ping/atoms';
import { sendPing } from '../ping/helpers';
import { connectionLostAtAtom } from './atoms';

/** Starts the bounded ping queue and keeps the disconnect clock subscribed. */
export function useKeepAlive(): void {
  useAtomValue(connectionLostAtAtom);
  const setLastPingedAt = useSetAtom(lastPingedAtAtom);

  useEffect(() => {
    setLastPingedAt(null);
    sendPing();
  }, [setLastPingedAt]);
}
