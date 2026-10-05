import { useAtom, useAtomValue } from 'jotai';
import { useEffect, useRef } from 'react';
import { Button } from 'tgui-core/components';

import {
  chatPagesRecordAtom,
  currentPageIdAtom,
  scrollTrackingAtom,
} from './atom';
import { chatRenderer } from './renderer';
import type { Page } from './types';

type Props = {
  fontSize?: string | number;
  lineHeight: string | number;
};

export function ChatPanel({ fontSize, lineHeight }: Props) {
  const ref = useRef<HTMLDivElement>(null);
  const scrollTracking = useAtomValue(scrollTrackingAtom);
  const currentPageId = useAtomValue(currentPageIdAtom);
  const [pagesRecord, setPagesRecord] = useAtom(chatPagesRecordAtom);

  useEffect(() => {
    if (ref.current) {
      chatRenderer.mount(ref.current);
    }
  }, []);

  useEffect(() => {
    if (!scrollTracking) return;
    const page = pagesRecord[currentPageId];
    if (!page?.unreadCount) return;
    const nextPage: Page = { ...page, unreadCount: 0 };
    setPagesRecord({ ...pagesRecord, [currentPageId]: nextPage });
  }, [currentPageId, pagesRecord, scrollTracking, setPagesRecord]);

  useEffect(() => {
    chatRenderer.assignStyle({
      width: '100%',
      'white-space': 'pre-wrap',
      'font-size': fontSize,
      'line-height': lineHeight,
    });
  }, [fontSize, lineHeight]);

  return (
    <>
      <div className="Chat" ref={ref} />
      {!scrollTracking && (
        <Button
          className="Chat__scrollButton"
          icon="arrow-down"
          onClick={() => chatRenderer.scrollToBottom()}
        >
          Scroll to bottom
        </Button>
      )}
    </>
  );
}
