import { storage } from 'common/storage';
import { useAtom, useAtomValue } from 'jotai';
import { useEffect } from 'react';

import { setMusicVolume } from '../audio/handlers';
import {
  highlightsAtom,
  settingsAtom,
  settingsLoadedAtom,
  settingsVisibleAtom,
} from './atoms';
import { generalSettingsHandler } from './helpers';
import { startSettingsMigration } from './migration';
import { setDisplayScaling } from './scaling';
import type { SettingsState } from './types';

export function useSettings() {
  const [settings, setSettings] = useAtom(settingsAtom);
  const highlights = useAtomValue(highlightsAtom);
  const [loaded, setLoaded] = useAtom(settingsLoadedAtom);
  const [visible, setVisible] = useAtom(settingsVisibleAtom);

  useEffect(() => {
    if (loaded) return;
    let active = true;

    async function load(): Promise<void> {
      try {
        const stored = await storage.get('panel-settings');
        startSettingsMigration(stored);
      } catch (error) {
        console.error('Failed to load panel settings:', error);
        startSettingsMigration(undefined);
      } finally {
        if (active) setLoaded(true);
      }
    }

    setDisplayScaling();
    void load();
    return () => {
      active = false;
    };
  }, [loaded, setLoaded]);

  function updateSettings<TKey extends keyof SettingsState>(
    update: Pick<SettingsState, TKey>,
  ): void {
    const nextSettings: SettingsState = {
      ...settings,
      ...update,
    };
    generalSettingsHandler(nextSettings);
    setMusicVolume(nextSettings.adminMusicVolume);
    setSettings(nextSettings);
    void storage.set('panel-settings', {
      ...nextSettings,
      ...highlights,
    });
  }

  const toggle = () => setVisible((current) => !current);
  return {
    settings,
    visible,
    updateSettings,
    // Compatibility aliases keep panel-only callers concise.
    update: updateSettings,
    toggle,
  };
}

export { settingsVisibleAtom } from './atoms';
