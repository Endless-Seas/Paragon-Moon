import { describe, expect, it } from 'bun:test';

import { defaultSettings } from './atoms';
import { normalizeHighlightState, normalizeSettings } from './migration';

describe('panel settings migration', () => {
  it('preserves Paragon defaults while clamping persisted volume', () => {
    const settings = normalizeSettings({
      adminMusicVolume: 3,
      fontFamily: 'Verdana',
      fontSize: 21,
      lineHeight: 1.4,
      theme: 'light',
      view: { visible: true },
    });

    expect(settings).toMatchObject({
      adminMusicVolume: 1,
      fontFamily: 'Verdana',
      fontSize: 21,
      lineHeight: 1.4,
      theme: 'dark',
      initialized: true,
    });
    expect(settings.view).toEqual(defaultSettings.view);
  });

  it('repairs malformed highlight settings with a usable default entry', () => {
    const highlights = normalizeHighlightState({
      highlightSettings: ['missing', 'missing'],
      highlightSettingById: {
        missing: { highlightText: 42, highlightColor: null },
      },
    });

    expect(highlights.highlightSettings).toEqual(['default', 'missing']);
    expect(highlights.highlightSettingById.missing).toMatchObject({
      id: 'missing',
      highlightText: '',
      highlightColor: '#ffdd44',
      highlightWholeMessage: true,
    });
    expect(highlights.highlightSettingById.default).toBeDefined();
  });
});
