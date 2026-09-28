import { createUuid } from 'tgui-core/uuid';

import { MESSAGE_TYPE_INTERNAL, MESSAGE_TYPES } from './constants';
import type { Page, SerializedMessage } from './types';

export function canPageAcceptType(
  page: Page | undefined,
  type: string,
): boolean {
  return Boolean(
    page &&
      (type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type]),
  );
}

export function createPage(overrides: Partial<Page> = {}): Page {
  const acceptedTypes: Record<string, boolean> = {};
  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = Boolean(typeDef.important);
  }

  return {
    isMain: false,
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes,
    unreadCount: 0,
    hideUnreadCount: false,
    createdAt: Date.now(),
    ...overrides,
  };
}

/** The stable id lets old random main-page ids be normalized on load. */
export function createMainPage(): Page {
  const acceptedTypes: Record<string, boolean> = {};
  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }

  return createPage({
    id: 'main',
    isMain: true,
    name: 'Main',
    acceptedTypes,
  });
}

export function createMessage(
  payload: Omit<SerializedMessage, 'createdAt'> & Partial<SerializedMessage>,
): SerializedMessage {
  return {
    createdAt: Date.now(),
    ...payload,
  };
}

export function serializeMessage(
  message: SerializedMessage,
): SerializedMessage {
  return {
    type: message.type,
    text: message.text,
    html: message.html,
    times: message.times,
    createdAt: message.createdAt,
  };
}

export function isSameMessage(
  a: SerializedMessage,
  b: SerializedMessage,
): boolean {
  return (
    (typeof a.text === 'string' && a.text === b.text) ||
    (typeof a.html === 'string' && a.html === b.html)
  );
}
