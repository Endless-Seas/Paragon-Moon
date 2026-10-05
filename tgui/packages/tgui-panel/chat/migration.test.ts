import { describe, expect, it } from 'bun:test';

import { mainPage } from './atom';
import { normalizeChatSettings } from './migration';

describe('panel chat state migration', () => {
  it('repairs legacy main ids, page order, filters, and unread state', () => {
    const legacyMainId = 'legacy-main-id';
    const input = {
      version: 5,
      scrollTracking: false,
      currentPageId: legacyMainId,
      pages: [legacyMainId, 'custom', legacyMainId, 'missing', 42],
      pageById: {
        [legacyMainId]: {
          ...mainPage,
          id: legacyMainId,
          isMain: true,
          name: 'Old Main',
          acceptedTypes: {},
          unreadCount: 12,
        },
        main: {
          ...mainPage,
          unreadCount: 4,
        },
        custom: {
          ...mainPage,
          id: 'custom',
          isMain: false,
          name: 'Custom',
          acceptedTypes: { ooc: true },
          unreadCount: 9,
        },
        malformed: null,
      },
    };

    const result = normalizeChatSettings(input);

    expect(result.dirty).toBe(true);
    expect(result.settings.pages).toEqual(['main', 'custom']);
    expect(result.settings.currentPageId).toBe('main');
    expect(result.settings.pageById.main).toMatchObject({
      id: 'main',
      isMain: true,
      unreadCount: 0,
    });
    expect(result.settings.pageById.custom).toMatchObject({
      id: 'custom',
      unreadCount: 0,
      acceptedTypes: { ooc: true },
    });
    expect(result.settings.pageById.custom.acceptedTypes.system).toBe(true);
  });

  it('falls back to a canonical default for an incompatible saved version', () => {
    const result = normalizeChatSettings({ version: 4, pages: [] });

    expect(result.dirty).toBe(true);
    expect(result.settings).toMatchObject({
      version: 5,
      currentPageId: 'main',
      pages: ['main'],
      scrollTracking: true,
    });
    expect(result.settings.pageById.main).toEqual(mainPage);
  });
});
