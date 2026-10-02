import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';

import { useSettings } from './use-settings';

const TABS_VIEWS = ['default', 'classic', 'scrollable'];

export function SettingsStatPanel() {
  const { settings, updateSettings } = useSettings();

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Tabs" verticalAlign="middle">
              {TABS_VIEWS.map((view) => (
                <Button
                  key={view}
                  color="transparent"
                  selected={settings.statTabsStyle === view}
                  onClick={() => updateSettings({ statTabsStyle: view })}
                >
                  {capitalize(view)}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Font size">
              <Stack.Item grow>
                {settings.statLinked ? (
                  <NoticeBox color="red">
                    Unlink Stat Panel from chat!
                  </NoticeBox>
                ) : (
                  <Slider
                    width="100%"
                    step={1}
                    stepPixelSize={20}
                    minValue={8}
                    maxValue={32}
                    value={settings.statFontSize}
                    unit="px"
                    format={(value) => toFixed(value)}
                    onChange={(e, value) =>
                      updateSettings({ statFontSize: value })
                    }
                  />
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Divider mt={2.5} />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={settings.statLinked ? 'unlink' : 'link'}
            color={settings.statLinked ? 'bad' : 'good'}
            onClick={() => updateSettings({ statLinked: !settings.statLinked })}
          >
            {settings.statLinked ? 'Unlink from chat' : 'Link to chat'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
