import type { BooleanLike } from 'tgui-core/react';

export type Config = {
  title: string;
  status: number;
  interface: { name: string; layout: string };
  refreshing: BooleanLike;
  window: {
    key: string;
    size: [number, number];
    fancy: BooleanLike;
    locked: BooleanLike;
    theme: string;
    scale: BooleanLike;
    session: number;
  };
  client: { ckey: string; address: string; computer_id: string };
  user: { name: string; observer: number };
  mapInfo?: { maxx: number; maxy: number };
  mapZLevel?: number;
};

export type UpdatePayload = {
  config?: Partial<Config>;
  data?: Record<string, any>;
  static_data?: Record<string, any>;
  shared?: Record<string, string>;
};
