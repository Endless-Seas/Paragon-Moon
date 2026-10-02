import { atom } from 'jotai';

export type PingState = {
  roundtrip: number | undefined;
  roundtripAvg: number | undefined;
  failCount: number;
  networkQuality: number;
};

export const lastPingedAtAtom = atom<number | null>(null);
export const pingAtom = atom<PingState>({
  roundtrip: undefined,
  roundtripAvg: undefined,
  failCount: 0,
  networkQuality: 0,
});
