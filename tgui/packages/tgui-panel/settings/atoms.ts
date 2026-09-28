import { atom } from 'jotai';

import { FONTS, SETTINGS_TABS } from './constants';
import type { HighlightSetting, HighlightState, SettingsState } from './types';

export const defaultSettings: SettingsState = {
  adminMusicVolume: 0.5,
  fontFamily: FONTS[0],
  fontSize: 19,
  initialized: false,
  lineHeight: 1.2,
  statFontSize: 12,
  statLinked: true,
  statTabsStyle: 'default',
  theme: 'dark',
  version: 1,
  view: {
    visible: false,
    activeTab: SETTINGS_TABS[0].id,
  },
};

export const defaultHighlightSetting: HighlightSetting = {
  id: 'default',
  highlightText: '',
  highlightColor: '#ffdd44',
  highlightWholeMessage: true,
  matchWord: false,
  matchCase: false,
};

export const defaultHighlights: HighlightState = {
  highlightSettings: ['default'],
  highlightSettingById: {
    default: defaultHighlightSetting,
  },
  // Compatibility fields retained for older server settings.
  highlightText: '',
  highlightColor: '#ffdd44',
};

export const settingsAtom = atom(defaultSettings);
export const highlightsAtom = atom(defaultHighlights);
export const settingsLoadedAtom = atom(false);

export const settingsVisibleAtom = atom(
  (get) => get(settingsAtom).view.visible,
  (get, set, next: boolean | ((current: boolean) => boolean)) =>
    set(settingsAtom, (previous) => ({
      ...previous,
      view: {
        ...previous.view,
        visible:
          typeof next === 'function' ? next(previous.view.visible) : next,
      },
    })),
);

export const activeSettingsTabAtom = atom(
  (get) => get(settingsAtom).view.activeTab,
  (get, set, activeTab: string) =>
    set(settingsAtom, (previous) => ({
      ...previous,
      view: { ...previous.view, activeTab },
    })),
);

export const storedSettingsAtom = atom((get) => ({
  ...get(settingsAtom),
  ...get(highlightsAtom),
}));
