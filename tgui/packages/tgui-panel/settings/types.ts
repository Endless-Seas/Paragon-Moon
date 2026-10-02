import type { ChatPages } from '../chat/types';

export type SettingsView = {
  visible: boolean;
  activeTab: string;
};

export type SettingsState = {
  adminMusicVolume: number;
  fontFamily: string;
  fontSize: number;
  initialized: boolean;
  lineHeight: number;
  statFontSize: number;
  statLinked: boolean;
  statTabsStyle: string;
  theme: string;
  version: number;
  view: SettingsView;
};

export type HighlightSetting = {
  highlightColor: string;
  highlightText: string;
  highlightWholeMessage: boolean;
  id: string;
  matchCase: boolean;
  matchWord: boolean;
};

export type HighlightState = {
  highlightSettings: string[];
  highlightSettingById: Record<string, HighlightSetting>;
  highlightText: string;
  highlightColor: string;
};

export interface MergedSettings extends SettingsState, HighlightState {}
export interface ExportedSettings extends MergedSettings, ChatPages {}
