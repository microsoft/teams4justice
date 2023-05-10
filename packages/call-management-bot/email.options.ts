export default class EmailOptions {
  public static hearingOrganiserCheckOverride(organiserEmail: string): string {
    if (process.env.NODE_ENV === 'production') return organiserEmail;
    const override = process.env.HEARING_ORGANISER_EMAIL_ADDRESS_OVERRIDE;
    return override === undefined || override.length === 0
      ? organiserEmail
      : override;
  }

  public static hearingAttendeesCheckOverride(
    attendeeEmails: string[],
  ): string[] {
    if (process.env.NODE_ENV === 'production') return attendeeEmails;
    const override = process.env.HEARING_ATTENDEE_EMAIL_ADDRESS_OVERRIDE;
    return override === undefined || override.length === 0
      ? attendeeEmails
      : override.split(';');
  }
}
