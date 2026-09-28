import { atom } from 'jotai';

import { createMainPage } from './model';
import type { Page, StoredChatSettings } from './types';

export const mainPage = createMainPage();
export const versionAtom = atom(5);
export const scrollTrackingAtom = atom(true);
export const chatPagesAtom = atom<string[]>([mainPage.id]);
export const currentPageIdAtom = atom<string>(mainPage.id);
export const chatPagesRecordAtom = atom<Record<string, Page>>({
  [mainPage.id]: mainPage,
});
export const chatLoadedAtom = atom(false);

export const allChatAtom = atom<StoredChatSettings>((get) => ({
  version: get(versionAtom),
  currentPageId: get(currentPageIdAtom),
  scrollTracking: get(scrollTrackingAtom),
  pages: get(chatPagesAtom),
  pageById: get(chatPagesRecordAtom),
}));

export const currentPageAtom = atom((get) => {
  const pages = get(chatPagesRecordAtom);
  return pages[get(currentPageIdAtom)] ?? pages[mainPage.id] ?? mainPage;
});
