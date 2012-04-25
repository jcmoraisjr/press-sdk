unit WebBrokers;

{$mode objfpc}{$H+}

interface

uses
  PressMessages_ptbr,
  PressSubject,
  PressAttributes,
  PressSQLdbBroker,
  pqconnection,
  PressWebFCLCGIBroker;

implementation

initialization
  PressModel.DefaultKeyType := TPressInt64;
  PressModel.DefaultGeneratorName := 'gen_oid';
  PressModel.ClassIdType := TPressInt64;
  PressModel.ClassIdStorageName := 'Classes';

end.

