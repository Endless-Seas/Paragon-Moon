import { useAtom } from 'jotai';
import { Box, Button, Stack, Tabs } from 'tgui-core/components';

import { settingsVisibleAtom } from '../settings/atoms';
import { useChatPages } from './use-chat-pages';

function UnreadCountWidget({ value }: { value: number }) {
  return <Box className="UnreadCount">{Math.min(value, 99)}</Box>;
}

export function ChatTabs() {
  const { addChatPage, changeChatPage, pages, pagesRecord, currentPageId } =
    useChatPages();
  const [, setSettingsVisible] = useAtom(settingsVisibleAtom);

  return (
    <Stack align="center">
      <Stack.Item>
        <Tabs textAlign="center">
          {pages.map((id) => {
            const page = pagesRecord[id];
            if (!page) return null;
            return (
              <Tabs.Tab
                key={id}
                selected={id === currentPageId}
                onClick={() => changeChatPage(page)}
              >
                {page.name}
                {!page.hideUnreadCount && page.unreadCount > 0 && (
                  <UnreadCountWidget value={page.unreadCount} />
                )}
              </Tabs.Tab>
            );
          })}
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="plus"
          onClick={() => {
            addChatPage();
            setSettingsVisible(true);
          }}
        />
      </Stack.Item>
    </Stack>
  );
}
