import { storage } from 'common/storage';

import { chatPagesRecordAtom } from '../chat/atom';
import { importChatState, saveChatToStorage } from '../chat/helpers';
import { store } from '../events/store';
import { currentStoredSettings, startSettingsMigration } from './migration';

export function exportChatSettings(): void {
  const settings = currentStoredSettings();
  const pages = store.get(chatPagesRecordAtom);
  const exportObject = { ...settings, chatPages: pages };
  const suggestedName = `ss13-chatsettings-${new Date()
    .toJSON()
    .slice(0, 10)}.json`;

  if (typeof window.showSaveFilePicker !== 'function') {
    const blob = new Blob([JSON.stringify(exportObject)], {
      type: 'application/json',
    });
    Byond.saveBlob(blob, suggestedName, '.json');
    return;
  }

  const opts: SaveFilePickerOptions = {
    id: `ss13-chatprefs-${Date.now()}`,
    suggestedName,
    types: [
      {
        description: 'SS13 file',
        accept: { 'application/json': ['.json'] },
      },
    ],
  };

  window
    .showSaveFilePicker(opts)
    .then(async (fileHandle) => {
      const writable = await fileHandle.createWritable();
      await writable.write(JSON.stringify(exportObject));
      await writable.close();
    })
    .catch((error) => {
      if (error?.name !== 'AbortError') {
        console.error('Failed to export chat settings:', error);
      }
    });
}

type FileSelection = string | string[] | File | File[] | FileList | null;

export function importChatSettings(selection: FileSelection): void {
  if (!selection) return;
  if (typeof selection === 'string') {
    applyImportedSettings(selection);
    return;
  }
  if (Array.isArray(selection)) {
    const first = selection[0];
    if (typeof first === 'string') {
      applyImportedSettings(first);
    } else if (first) {
      void first.text().then(applyImportedSettings);
    }
    return;
  }
  if (typeof FileList !== 'undefined' && selection instanceof FileList) {
    const first = selection.item(0);
    if (first) void first.text().then(applyImportedSettings);
    return;
  }
  if (typeof File !== 'undefined' && selection instanceof File) {
    void selection.text().then(applyImportedSettings);
  }
}

function applyImportedSettings(raw: string): void {
  try {
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== 'object' || !parsed.version) return;

    const { chatPages, ...settings } = parsed;
    startSettingsMigration(settings);
    if (chatPages && typeof chatPages === 'object') {
      importChatState(chatPages);
    }
    void storage.set('panel-settings', currentStoredSettings());
    void saveChatToStorage();
  } catch (error) {
    console.error('Failed to import chat settings:', error);
  }
}
