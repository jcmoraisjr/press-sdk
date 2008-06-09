unit Brokers;

{$I PhoneBook.inc}

interface

uses
  PressMessages_en,
  PressSubject, PressSession,
{$IFDEF UseReport}
  PressFastReportBroker,
{$ENDIF}
{$IFDEF FPC}
  PressSQLdbBroker, ibconnection,
  // Add other Free Pascal connection brokers and SQLdb connections here
{$ELSE}
  PressIBXBroker,
  // Add other Delphi connection brokers here
{$ENDIF}
  PressOPF;

implementation

uses
  PressApplication;

initialization
  PressApp.ConfigFileName := 'PhoneBook.conf';

end.
