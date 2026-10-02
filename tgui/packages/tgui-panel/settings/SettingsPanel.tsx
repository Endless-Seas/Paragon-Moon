import { useAtomValue, useSetAtom } from 'jotai';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { ChatPageSettings } from '../chat/ChatPageSettings';
import { activeSettingsTabAtom } from './atoms';
import { SETTINGS_TABS } from './constants';
import { SettingsGeneral } from './SettingsGeneral';
import { TextHighlightSettings } from './TextHighlight';

export function SettingsPanel() {
  const activeTab = useAtomValue(activeSettingsTabAtom);
  const setActiveTab = useSetAtom(activeSettingsTabAtom);

  return (
    <Stack fill>
      <Stack.Item>
        <Section fitted fill minHeight="8em">
          <Tabs vertical>
            {SETTINGS_TABS.map((tab) => (
              <Tabs.Tab
                key={tab.id}
                selected={tab.id === activeTab}
                onClick={() => setActiveTab(tab.id)}
              >
                {tab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {activeTab === 'general' && <SettingsGeneral />}
        {activeTab === 'chatPage' && <ChatPageSettings />}
        {activeTab === 'textHighlight' && <TextHighlightSettings />}
      </Stack.Item>
    </Stack>
  );
}
