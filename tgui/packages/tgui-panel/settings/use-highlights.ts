import { storage } from 'common/storage';
import { useAtom, useAtomValue } from 'jotai';
import { createUuid } from 'tgui-core/uuid';

import { chatRenderer } from '../chat/renderer';
import { highlightsAtom, settingsAtom } from './atoms';
import type { HighlightSetting, HighlightState } from './types';

export function useHighlights() {
  const [highlights, setHighlights] = useAtom(highlightsAtom);
  const settings = useAtomValue(settingsAtom);

  function storeHighlights(next: HighlightState): void {
    setHighlights(next);
    chatRenderer.setHighlight(
      next.highlightSettings,
      next.highlightSettingById,
    );
    void storage.set('panel-settings', { ...settings, ...next });
  }

  function updateHighlight(
    update: Partial<HighlightSetting> & { id: string },
  ): void {
    const current = highlights.highlightSettingById[update.id];
    if (!current) return;
    storeHighlights({
      ...highlights,
      highlightSettingById: {
        ...highlights.highlightSettingById,
        [update.id]: { ...current, ...update },
      },
    });
  }

  function removeHighlight(id: string): void {
    if (id === 'default') {
      storeHighlights({
        ...highlights,
        highlightSettings: [
          'default',
          ...highlights.highlightSettings.filter((key) => key !== 'default'),
        ],
        highlightSettingById: {
          ...highlights.highlightSettingById,
          default: {
            id: 'default',
            highlightText: '',
            highlightColor: '#ffdd44',
            highlightWholeMessage: true,
            matchWord: false,
            matchCase: false,
          },
        },
      });
      return;
    }

    const nextIds = highlights.highlightSettings.filter((key) => key !== id);
    const nextById = { ...highlights.highlightSettingById };
    delete nextById[id];
    if (nextIds.length === 0) nextIds.push('default');
    storeHighlights({
      ...highlights,
      highlightSettings: nextIds,
      highlightSettingById: nextById,
    });
  }

  function addHighlight(): void {
    const setting: HighlightSetting = {
      id: createUuid(),
      highlightText: '',
      highlightColor: '#ffdd44',
      highlightWholeMessage: true,
      matchWord: false,
      matchCase: false,
    };
    storeHighlights({
      ...highlights,
      highlightSettings: [...highlights.highlightSettings, setting.id],
      highlightSettingById: {
        ...highlights.highlightSettingById,
        [setting.id]: setting,
      },
    });
  }

  return { highlights, updateHighlight, removeHighlight, addHighlight };
}
