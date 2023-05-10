import { Context, HttpRequest } from '@azure/functions';
import { defaultLogger } from '@tfj/shared/logging';
import {
  authorizeSignalRRequest,
  getTokenVerificationOptions,
} from './authentication';

const groupLogger = defaultLogger.child({
  context: 'Notification Hub',
});

export default async function groupSubscription(
  context: Context,
  req: HttpRequest,
  action: string,
) {
  if (
    (await authorizeSignalRRequest(
      req.headers.authorization,
      getTokenVerificationOptions(),
      groupLogger,
    )) === false
  ) {
    context.res = {
      status: 401,
    };
    return;
  }

  if (context.bindingData.caseId === undefined) {
    throw new Error('caseId is not defined');
  }

  if (req.body?.connectionId === undefined) {
    throw new Error('connectionId must be in body');
  }

  context.bindings.signalRGroupActions = [
    {
      connectionId: req.body.connectionId,
      groupName: context.bindingData.caseId,
      action,
    },
  ];
}
