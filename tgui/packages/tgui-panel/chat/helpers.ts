import { storage } from 'common/storage';

import { store } from '../events/store';
import {
  allChatAtom,
  chatLoadedAtom,
  chatPagesAtom,
  chatPagesRecordAtom,
  currentPageAtom,
  currentPageIdAtom,
  mainPage,
  scrollTrackingAtom,
} from './atom';
import { MAX_PERSISTED_MESSAGES } from './constants';
import { canPageAcceptType, serializeMessage } from './model';
import { chatRenderer } from './renderer';
import type { Page } from './types';

function updateMessageCount(countByType: Record<string, number>): void {
  const pageById = store.get(chatPagesRecordAtom);
  const pageIds = store.get(chatPagesAtom);
  const currentPage = store.get(currentPageAtom);
  const scrollTracking = store.get(scrollTrackingAtom);
  const nextPageById = { ...pageById };

  for (const pageId of pageIds) {
    const page = pageById[pageId];
    if (!page) continue;

    let unreadCount = 0;
    for (const [type, count] of Object.entries(countByType)) {
      if (!canPageAcceptType(page, type)) continue;
      if (page === currentPage && scrollTracking) continue;
      if (page !== currentPage && canPageAcceptType(currentPage, type)) {
        continue;
      }
      unreadCount += count;
    }

    if (unreadCount > 0) {
      nextPageById[page.id] = {
        ...page,
        unreadCount: page.unreadCount + unreadCount,
      };
    }
  }

  store.set(chatPagesRecordAtom, nextPageById);
}

chatRenderer.events.on(
  'batchProcessed',
  (countByType: Record<string, number>) => {
    // Messages restored from storage must not create unread badges.
    if (store.get(chatLoadedAtom)) {
      updateMessageCount(countByType);
    }
  },
);

chatRenderer.events.on('scrollTrackingChanged', (scrollTracking: boolean) => {
  store.set(scrollTrackingAtom, scrollTracking);
  if (scrollTracking) {
    const currentPageId = store.get(currentPageIdAtom);
    const pageById = store.get(chatPagesRecordAtom);
    const page = pageById[currentPageId];
    if (page?.unreadCount) {
      store.set(chatPagesRecordAtom, {
        ...pageById,
        [currentPageId]: { ...page, unreadCount: 0 },
      });
    }
  }
});

export function importChatState(pageRecord: Record<string, Page>): void {
  if (!pageRecord || typeof pageRecord !== 'object') return;

  const ids = Object.keys(pageRecord);
  if (ids.length === 0) return;

  const merged: Record<string, Page> = {};
  for (const id of ids) {
    merged[id] = {
      ...mainPage,
      ...pageRecord[id],
      id,
      unreadCount: 0,
      acceptedTypes: {
        ...mainPage.acceptedTypes,
        ...(pageRecord[id]?.acceptedTypes || {}),
      },
    };
  }

  const orderedIds = Object.keys(merged);
  const first = orderedIds[0];
  store.set(currentPageIdAtom, first);
  store.set(chatPagesAtom, orderedIds);
  store.set(chatPagesRecordAtom, merged);
  chatRenderer.changePage(merged[first]);
}

export async function saveChatToStorage(): Promise<void> {
  const fromIndex = Math.max(
    0,
    chatRenderer.messages.length - MAX_PERSISTED_MESSAGES,
  );
  const messages = chatRenderer.messages
    .slice(fromIndex)
    .map((message) => serializeMessage(message));
  const allChat = store.get(allChatAtom);

  await Promise.all([
    storage.set('chat-state', allChat),
    storage.set('chat-messages', messages),
  ]);
}

export function clearChat(): void {
  chatRenderer.clearChat();
}

export function rebuildChat(): void {
  chatRenderer.rebuildChat();
}
