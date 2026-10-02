/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useAtomValue } from 'jotai';

import { debugAtom, store } from '../events/store';

export function useDebug() {
  return useAtomValue(debugAtom, { store });
}
