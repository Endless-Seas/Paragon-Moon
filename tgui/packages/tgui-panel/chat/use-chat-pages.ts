import { useAtom, useAtomValue } from 'jotai';

import {
  chatPagesAtom,
  chatPagesRecordAtom,
  currentPageAtom,
  currentPageIdAtom,
  mainPage,
} from './atom';
import { createPage } from './model';
import { chatRenderer } from './renderer';
import type { Page } from './types';

export function useChatPages() {
  const [pages, setPages] = useAtom(chatPagesAtom);
  const [pagesRecord, setPagesRecord] = useAtom(chatPagesRecordAtom);
  const [currentPageId, setCurrentPageId] = useAtom(currentPageIdAtom);
  const page = useAtomValue(currentPageAtom);

  function addChatPage(): void {
    const draft = createPage();
    setCurrentPageId(draft.id);
    setPages((previous) => [...previous, draft.id]);
    setPagesRecord((previous) => ({ ...previous, [draft.id]: draft }));
    chatRenderer.changePage(draft);
  }

  function changeChatPage(nextPage: Page): void {
    const current = pagesRecord[nextPage.id];
    if (!current) return;

    const draft = { ...current, unreadCount: 0 };
    setCurrentPageId(nextPage.id);
    setPagesRecord({ ...pagesRecord, [nextPage.id]: draft });
    chatRenderer.changePage(draft);
  }

  function moveChatLeft(): void {
    const fromIndex = pages.indexOf(currentPageId);
    const toIndex = fromIndex - 1;
    if (fromIndex <= 0 || toIndex <= 0) return;

    const nextPages = [...pages];
    [nextPages[fromIndex], nextPages[toIndex]] = [
      nextPages[toIndex],
      nextPages[fromIndex],
    ];
    setPages(nextPages);
  }

  function moveChatRight(): void {
    const fromIndex = pages.indexOf(currentPageId);
    const toIndex = fromIndex + 1;
    if (fromIndex <= 0 || toIndex >= pages.length) return;

    const nextPages = [...pages];
    [nextPages[fromIndex], nextPages[toIndex]] = [
      nextPages[toIndex],
      nextPages[fromIndex],
    ];
    setPages(nextPages);
  }

  function removeChatPage(): void {
    const nextPages = pages.filter((id) => id !== currentPageId);
    const finalPages = nextPages.length ? nextPages : [mainPage.id];
    const finalRecord = nextPages.length
      ? Object.fromEntries(finalPages.map((id) => [id, pagesRecord[id]]))
      : { [mainPage.id]: mainPage };

    const nextCurrentPageId = finalPages[0];
    setPagesRecord(finalRecord);
    setPages(finalPages);
    setCurrentPageId(nextCurrentPageId);
    chatRenderer.changePage(finalRecord[nextCurrentPageId]);
  }

  function toggleAcceptedType(type: string): void {
    const current = pagesRecord[currentPageId];
    if (!current) return;

    setPagesRecord({
      ...pagesRecord,
      [currentPageId]: {
        ...current,
        acceptedTypes: {
          ...current.acceptedTypes,
          [type]: !current.acceptedTypes[type],
        },
      },
    });
  }

  function updateChatPage(update: Partial<Page>): void {
    const current = pagesRecord[currentPageId];
    if (!current) return;
    setPagesRecord({
      ...pagesRecord,
      [currentPageId]: { ...current, ...update },
    });
  }

  return {
    page,
    pages,
    pagesRecord,
    currentPageId,
    addChatPage,
    changeChatPage,
    moveChatLeft,
    moveChatRight,
    removeChatPage,
    toggleAcceptedType,
    updateChatPage,
  };
}
