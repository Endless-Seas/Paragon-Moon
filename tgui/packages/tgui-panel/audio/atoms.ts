import { atom } from 'jotai';

export type AudioMeta = {
  album?: string;
  artist?: string;
  duration?: string;
  link?: string;
  title?: string;
  upload_date?: string;
};

export const audioPlayingAtom = atom(false);
export const audioVisibleAtom = atom(false);
export const audioMetaAtom = atom<AudioMeta | null>(null);

export const audioAtom = atom((get) => ({
  playing: get(audioPlayingAtom),
  visible: get(audioVisibleAtom),
  meta: get(audioMetaAtom),
}));
