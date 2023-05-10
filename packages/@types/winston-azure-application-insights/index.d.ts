// Type definitions for winston-azure-application-insights 3.0
// Project: https://github.com/willmorgan/winston-azure-application-insights

/// <reference types="node" />

declare module 'winston-azure-application-insights' {
  import TransportStream = require('winston-transport');
  import applicationInsights = require('applicationinsights');

  export interface AzureApplicationInsightsOptions
    extends TransportStream.TransportStreamOptions {
    key?: string;
    sendErrorsAsExceptions?: boolean;
    client?: applicationInsights.TelemetryClient;
  }

  export class AzureApplicationInsightsLogger extends TransportStream {
    constructor(userOptions: AzureApplicationInsightsOptions);
  }
}
