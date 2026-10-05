import { store } from '../events/store';
import {
  type AudioMeta,
  audioMetaAtom,
  audioPlayingAtom,
  audioVisibleAtom,
} from './atoms';
import { AudioPlayer } from './player';

export type PlayMusicPayload = AudioMeta & {
  url: string;
  pitch?: number;
  start?: number;
  end?: number;
};

export const player = new AudioPlayer();

player.onPlay(() => {
  store.set(audioPlayingAtom, true);
  store.set(audioVisibleAtom, true);
});

player.onStop(() => {
  store.set(audioPlayingAtom, false);
  store.set(audioVisibleAtom, false);
  store.set(audioMetaAtom, null);
});

export function playMusic(payload: PlayMusicPayload): void {
  if (!payload || typeof payload.url !== 'string') {
    return;
  }

  const { url, ...meta } = payload;
  player.play(url, meta);
  store.set(audioMetaAtom, meta);
}

export function stopMusic(): void {
  player.stop();
}

export function setMusicVolume(volume: number): void {
  if (Number.isFinite(volume)) {
    player.setVolume(Math.max(0, Math.min(1, volume)));
  }
}
