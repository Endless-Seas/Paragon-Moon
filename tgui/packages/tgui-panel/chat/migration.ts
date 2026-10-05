import { mainPage } from './atom';
import type { Page, StoredChatSettings } from './types';

function isRecord(value: unknown): value is Record<string, any> {
  return Boolean(value && typeof value === 'object' && !Array.isArray(value));
}

function normalizePage(raw: unknown, key: string): Page | null {
  if (!isRecord(raw)) {
    return null;
  }

  const requestedId = typeof raw.id === 'string' ? raw.id : key;
  const id =
    raw.isMain || requestedId === mainPage.id || key === mainPage.id
      ? mainPage.id
      : requestedId;
  if (!id) {
    return null;
  }

  const acceptedTypes = isRecord(raw.acceptedTypes)
    ? { ...raw.acceptedTypes }
    : {};
  for (const [type, enabled] of Object.entries(mainPage.acceptedTypes)) {
    if (acceptedTypes[type] === undefined) {
      acceptedTypes[type] = enabled;
    }
  }

  return {
    ...mainPage,
    ...raw,
    id,
    isMain: id === mainPage.id,
    name:
      typeof raw.name === 'string'
        ? raw.name
        : id === mainPage.id
          ? 'Main'
          : 'New Tab',
    acceptedTypes,
    unreadCount: 0,
    hideUnreadCount: Boolean(raw.hideUnreadCount),
    createdAt: typeof raw.createdAt === 'number' ? raw.createdAt : Date.now(),
  };
}

function defaultChatSettings(): StoredChatSettings {
  return {
    version: 5,
    scrollTracking: true,
    currentPageId: mainPage.id,
    pages: [mainPage.id],
    pageById: { [mainPage.id]: mainPage },
  };
}

/** Repairs old random main ids, duplicate pages, missing filters and order. */
export function normalizeChatSettings(input: unknown): {
  settings: StoredChatSettings;
  dirty: boolean;
} {
  if (!isRecord(input) || input.version !== 5) {
    return { settings: defaultChatSettings(), dirty: Boolean(input) };
  }

  let dirty = false;
  const rawRecord = isRecord(input.pageById) ? input.pageById : {};
  const idRemap: Record<string, string> = {};
  const pageById: Record<string, Page> = {};

  for (const [key, rawPage] of Object.entries(rawRecord)) {
    const page = normalizePage(rawPage, key);
    if (!page) {
      dirty = true;
      continue;
    }

    if (page.id !== key) {
      idRemap[key] = page.id;
      dirty = true;
    }

    const existing = pageById[page.id];
    if (existing) {
      // Prefer a canonical `main` entry over an old random main id.
      if (page.id === mainPage.id && key === mainPage.id) {
        pageById[page.id] = page;
      }
      dirty = true;
      continue;
    }
    pageById[page.id] = page;
  }

  if (!pageById[mainPage.id]) {
    pageById[mainPage.id] = mainPage;
    dirty = true;
  }

  const rawPages = Array.isArray(input.pages) ? input.pages : [];
  const pages: string[] = [];
  const seen = new Set<string>();
  for (const rawId of rawPages) {
    if (typeof rawId !== 'string') {
      dirty = true;
      continue;
    }
    const id = idRemap[rawId] ?? rawId;
    if (!pageById[id] || seen.has(id)) {
      dirty = true;
      continue;
    }
    seen.add(id);
    pages.push(id);
  }
  for (const id of Object.keys(pageById)) {
    if (!seen.has(id)) {
      pages.push(id);
      dirty = true;
    }
  }

  const finalPages = pages.length ? pages : [mainPage.id];
  if (!pages.length) {
    dirty = true;
  }

  const requestedCurrent =
    typeof input.currentPageId === 'string' ? input.currentPageId : '';
  const currentPageId = pageById[idRemap[requestedCurrent] ?? requestedCurrent]
    ? (idRemap[requestedCurrent] ?? requestedCurrent)
    : finalPages[0];
  if (currentPageId !== requestedCurrent) {
    dirty = true;
  }

  const scrollTracking =
    typeof input.scrollTracking === 'boolean' ? input.scrollTracking : true;
  if (scrollTracking !== input.scrollTracking) {
    dirty = true;
  }

  return {
    settings: {
      version: 5,
      scrollTracking,
      currentPageId,
      pages: finalPages,
      pageById,
    },
    dirty,
  };
}
