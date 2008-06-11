unit Brokers;

{$I PhoneBook.inc}

interface

uses
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
  PressMessages_en;

implementation

uses
  PressApplication,
  PressSubject,
  PressAttributes;

initialization
  PressApp.ConfigFileName := 'PhoneBook.conf';
  PressModel.DefaultGeneratorName := 'gen_phonebook';
  PressModel.DefaultKeyType := TPressInteger;

end.
