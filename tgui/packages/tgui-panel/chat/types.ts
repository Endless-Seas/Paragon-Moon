export type Page = {
  isMain: boolean;
  id: string;
  name: string;
  acceptedTypes: Record<string, boolean>;
  unreadCount: number;
  hideUnreadCount: boolean;
  createdAt: number;
};

export type SerializedMessage = {
  type: string;
  createdAt: number;
  text?: string;
  html?: string;
  times?: number;
  node?: HTMLElement | 'pruned';
  avoidHighlighting?: boolean;
};

export type StoredChatSettings = {
  version: number;
  scrollTracking: boolean;
  currentPageId: string;
  pages: string[];
  pageById: Record<string, Page>;
};

export type ChatPages = {
  chatPages: Record<string, Page>;
};
