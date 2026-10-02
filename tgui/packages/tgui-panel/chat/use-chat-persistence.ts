import { storage } from 'common/storage';
import DOMPurify from 'dompurify';
import { useAtom, useAtomValue, useSetAtom } from 'jotai';
import { useEffect } from 'react';

import { settingsLoadedAtom } from '../settings/atoms';
import {
  allChatAtom,
  chatLoadedAtom,
  chatPagesAtom,
  chatPagesRecordAtom,
  currentPageIdAtom,
  scrollTrackingAtom,
  versionAtom,
} from './atom';
import { MAX_PERSISTED_MESSAGES, MESSAGE_SAVE_INTERVAL } from './constants';
import { saveChatToStorage } from './helpers';
import { normalizeChatSettings } from './migration';
import { createMessage } from './model';
import { chatRenderer } from './renderer';
import type { SerializedMessage, StoredChatSettings } from './types';

const FORBID_TAGS = ['a', 'iframe', 'link', 'video'];

export function useChatPersistence(): void {
  const [loaded, setLoaded] = useAtom(chatLoadedAtom);
  const settingsLoaded = useAtomValue(settingsLoadedAtom);
  const allChat = useAtomValue(allChatAtom);
  const version = useAtomValue(versionAtom);
  const setChatPages = useSetAtom(chatPagesAtom);
  const setCurrentPageId = useSetAtom(currentPageIdAtom);
  const setPagesRecord = useSetAtom(chatPagesRecordAtom);
  const setScrollTracking = useSetAtom(scrollTrackingAtom);

  useEffect(() => {
    if (loaded || !settingsLoaded) return;

    let cancelled = false;
    async function initialize(): Promise<void> {
      const [rawState, rawMessages] = await Promise.all([
        storage.get('chat-state'),
        storage.get('chat-messages'),
      ]);

      if (cancelled) return;
      restoreMessages(rawMessages);

      const normalized = normalizeChatSettings(rawState);
      if (normalized.dirty) {
        await storage.set('chat-state', normalized.settings);
      }
      if (cancelled) return;

      const state = normalized.settings;
      // `normalizeChatSettings` already falls back to version 5 defaults.
      if (state.version === version) {
        setScrollTracking(state.scrollTracking);
        setChatPages(state.pages);
        setCurrentPageId(state.currentPageId);
        setPagesRecord(state.pageById);
        chatRenderer.changePage(state.pageById[state.currentPageId]);
      }

      chatRenderer.onStateLoaded();
      // Flush restored messages while the unread-count listener still knows
      // they came from storage, then expose the live chat state.
      setLoaded(true);
    }

    initialize().catch((error) => {
      console.error('Failed to initialize chat persistence:', error);
      if (!cancelled) {
        chatRenderer.onStateLoaded();
        setLoaded(true);
      }
    });

    return () => {
      cancelled = true;
    };
  }, [
    loaded,
    settingsLoaded,
    version,
    setChatPages,
    setCurrentPageId,
    setLoaded,
    setPagesRecord,
    setScrollTracking,
  ]);

  useEffect(() => {
    if (!loaded) return;
    const interval = setInterval(() => {
      void saveChatToStorage();
    }, MESSAGE_SAVE_INTERVAL);
    return () => clearInterval(interval);
  }, [loaded]);

  useEffect(() => {
    if (!loaded) return;
    const timeout = setTimeout(() => {
      const pageById = Object.fromEntries(
        Object.entries(allChat.pageById).map(([id, page]) => [
          id,
          { ...page, unreadCount: 0 },
        ]),
      );
      void storage.set('chat-state', { ...allChat, pageById });
    }, 750);
    return () => clearTimeout(timeout);
  }, [allChat, loaded]);
}

export function sanitizePersistedMessages(
  rawMessages: unknown,
): SerializedMessage[] {
  if (!Array.isArray(rawMessages)) return [];

  const messages = rawMessages
    .filter((message): message is Record<string, any> => {
      return Boolean(message && typeof message === 'object');
    })
    .map((message): SerializedMessage => {
      const sanitized: SerializedMessage = {
        type: typeof message.type === 'string' ? message.type : 'unknown',
        createdAt:
          typeof message.createdAt === 'number'
            ? message.createdAt
            : Date.now(),
      };

      if (typeof message.text === 'string') {
        sanitized.text = message.text;
      }
      if (typeof message.html === 'string') {
        sanitized.html = DOMPurify.sanitize(message.html, {
          FORBID_TAGS,
        });
      }
      if (typeof message.times === 'number' && Number.isFinite(message.times)) {
        sanitized.times = message.times;
      }
      if (message.avoidHighlighting === true) {
        sanitized.avoidHighlighting = true;
      }

      return sanitized;
    });

  return messages.slice(-MAX_PERSISTED_MESSAGES);
}

function restoreMessages(rawMessages: unknown): void {
  const messages = sanitizePersistedMessages(rawMessages);

  if (messages.length === 0) return;

  chatRenderer.processBatch(
    [...messages, createMessage({ type: 'internal/reconnected' })],
    { prepend: true },
  );
}

export type { StoredChatSettings };
