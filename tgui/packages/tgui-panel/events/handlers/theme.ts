import { storage } from 'common/storage';

import { highlightsAtom, settingsAtom } from '../../settings/atoms';
import { generalSettingsHandler } from '../../settings/helpers';
import { THEMES } from '../../themes';
import { store } from '../store';

//The server's theme preference (character setup) changed: follow it in chat and the client skin
export function handleThemeSet(payload: unknown): void {
  const theme = (payload as { theme?: string } | undefined)?.theme;
  if (!theme || !THEMES.includes(theme)) {
    return;
  }
  const settings = store.get(settingsAtom);
  if (settings.theme === theme) {
    return;
  }
  const next = { ...settings, theme };
  store.set(settingsAtom, next);
  generalSettingsHandler(next);
  void storage.set('panel-settings', {
    ...next,
    ...store.get(highlightsAtom),
  });
}
