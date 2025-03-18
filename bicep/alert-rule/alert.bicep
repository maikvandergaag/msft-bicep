targetScope = 'subscription'

@description('The name for the scheduled action. This name is used in the resource ID. Default: AnomalyAlert.')
param name string = 'AnomalyAlert'

@description('The display name to show in the portal when viewing the list of alerts. Default: (scheduled action name).')
param displayName string = name

@description('Email address of the person or team responsible for this scheduled action.')
param notificationEmail string

@description('List of email addresses that should receive emails.')
param emailRecipients array

@description('The body of the email. Default: Anomaly detected in your subscription. Please review the Cost Management dashboard for more details.')
@maxLength(250)
param emailBody string = 'Anomaly detected in your subscription. Please review the Cost Management dashboard for more details.'

@description('The subject of the email. Default: (Anomaly alert: [subscription displayname]).')
@maxLength(70)
param emailSubject string = 'Anomaly alert: ${subscription().displayName}'

@description('The first day the schedule should run. Default = Now.')
param scheduleStartDate string = utcNow('yyyy-MM-ddTHH:00Z')

@description('The last day the schedule should run. Default = 1 year from start date.')
param scheduleEndDate string = dateTimeAdd(scheduleStartDate, 'P1Y')

@description('The view ID to use for the scheduled action (should not be adjust but is defined as param to comply to best practices). Default: DailyAnomalyByResourceGroup.')
param viewId string = '${subscription().id}/providers/Microsoft.CostManagement/views/ms:DailyAnomalyByResourceGroup'

resource sa 'Microsoft.CostManagement/scheduledActions@2024-08-01' = {
  name: name
  kind: 'InsightAlert'
  properties: {
    displayName: displayName
    viewId: viewId
    notificationEmail: notificationEmail
    status: 'enabled'
    notification: {
      subject: emailSubject
      to: emailRecipients
      message: emailBody
    }
    schedule: {
      frequency: 'Daily'
      startDate: scheduleStartDate
      endDate: scheduleEndDate
    }
  }
}
