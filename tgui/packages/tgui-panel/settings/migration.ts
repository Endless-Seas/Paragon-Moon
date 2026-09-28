import { storage } from 'common/storage';

import { setMusicVolume } from '../audio/handlers';
import { chatRenderer } from '../chat/renderer';
import { store } from '../events/store';
import {
  defaultHighlightSetting,
  defaultSettings,
  highlightsAtom,
  settingsAtom,
  storedSettingsAtom,
} from './atoms';
import { generalSettingsHandler } from './helpers';
import type { HighlightSetting, HighlightState, MergedSettings } from './types';

function isRecord(value: unknown): value is Record<string, any> {
  return Boolean(value && typeof value === 'object' && !Array.isArray(value));
}

function normalizeHighlightState(input: unknown): HighlightState {
  const source = isRecord(input) ? input : {};
  const rawById = isRecord(source.highlightSettingById)
    ? source.highlightSettingById
    : {};
  const byId: Record<string, HighlightSetting> = {};
  const ids: string[] = [];

  const rawIds = Array.isArray(source.highlightSettings)
    ? source.highlightSettings
    : Object.keys(rawById);
  for (const rawId of rawIds) {
    if (typeof rawId !== 'string' || ids.includes(rawId)) continue;
    const raw = isRecord(rawById[rawId]) ? rawById[rawId] : {};
    byId[rawId] = {
      ...defaultHighlightSetting,
      ...raw,
      id: rawId,
      highlightText:
        typeof raw.highlightText === 'string' ? raw.highlightText : '',
      highlightColor:
        typeof raw.highlightColor === 'string'
          ? raw.highlightColor
          : defaultHighlightSetting.highlightColor,
      highlightWholeMessage:
        raw.highlightWholeMessage === undefined
          ? true
          : Boolean(raw.highlightWholeMessage),
      matchWord: Boolean(raw.matchWord),
      matchCase: Boolean(raw.matchCase),
    };
    ids.push(rawId);
  }

  if (!byId.default) {
    byId.default = {
      ...defaultHighlightSetting,
      highlightText:
        typeof source.highlightText === 'string'
          ? source.highlightText
          : defaultHighlightSetting.highlightText,
      highlightColor:
        typeof source.highlightColor === 'string'
          ? source.highlightColor
          : defaultHighlightSetting.highlightColor,
    };
    ids.unshift('default');
  }
  if (!ids.length) ids.push('default');

  return {
    highlightSettings: ids,
    highlightSettingById: byId,
    highlightText: byId.default.highlightText,
    highlightColor: byId.default.highlightColor,
  };
}

function normalizeSettings(input: unknown) {
  const source = isRecord(input) ? input : {};
  return {
    ...defaultSettings,
    adminMusicVolume:
      typeof source.adminMusicVolume === 'number'
        ? Math.max(0, Math.min(1, source.adminMusicVolume))
        : defaultSettings.adminMusicVolume,
    fontFamily:
      typeof source.fontFamily === 'string'
        ? source.fontFamily
        : defaultSettings.fontFamily,
    fontSize:
      typeof source.fontSize === 'number'
        ? source.fontSize
        : defaultSettings.fontSize,
    lineHeight:
      typeof source.lineHeight === 'number'
        ? source.lineHeight
        : defaultSettings.lineHeight,
    statFontSize:
      typeof source.statFontSize === 'number'
        ? source.statFontSize
        : defaultSettings.statFontSize,
    statLinked:
      typeof source.statLinked === 'boolean'
        ? source.statLinked
        : defaultSettings.statLinked,
    statTabsStyle:
      typeof source.statTabsStyle === 'string'
        ? source.statTabsStyle
        : defaultSettings.statTabsStyle,
    // Paragon ships the dark chat stylesheet; do not import a donor theme
    // through a stale persisted preference.
    theme: 'dark',
    initialized: true,
    view: defaultSettings.view,
  };
}

export function startSettingsMigration(next: unknown): MergedSettings {
  const settings = normalizeSettings(next);
  const highlights = normalizeHighlightState(next);
  const merged = { ...settings, ...highlights };

  generalSettingsHandler(settings);
  setMusicVolume(settings.adminMusicVolume);
  store.set(settingsAtom, settings);
  store.set(highlightsAtom, highlights);
  chatRenderer.setHighlight(
    highlights.highlightSettings,
    highlights.highlightSettingById,
  );

  void storage.set('panel-settings', merged);
  return merged;
}

export function currentStoredSettings(): MergedSettings {
  return store.get(storedSettingsAtom);
}

export { normalizeHighlightState, normalizeSettings };
