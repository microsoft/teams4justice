import { readEnvironmentValueAndThrowIfMissing } from '@tfj/shared/utilities';

export interface OnlineMeetingLifecycleConfiguration {
  joinBeforeStartDateMins: number;
}

let onlineMeetingLifecycleConfiguration:
  | OnlineMeetingLifecycleConfiguration
  | undefined;

export function getOnlineMeetingLifecycleConfiguration(): OnlineMeetingLifecycleConfiguration {
  if (onlineMeetingLifecycleConfiguration !== undefined) {
    return onlineMeetingLifecycleConfiguration;
  }

  onlineMeetingLifecycleConfiguration = {
    joinBeforeStartDateMins: parseInt(
      readEnvironmentValueAndThrowIfMissing(
        'ONLINE_MEETING_LIFECYCLE_MANAGEMENT_JOIN_BEFORE_START_DATE_MINUTES',
      ),
      10,
    ),
  };

  return onlineMeetingLifecycleConfiguration;
}
