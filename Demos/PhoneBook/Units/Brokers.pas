unit Brokers;

{$I PhoneBook.inc}

{$IFDEF UseInstantObjects}

(*******************************
   INSTANTOBJECTS DECLARATIONS
 *******************************)

interface

uses
  PressMessages_en,
{$IFDEF UseReport}
  PressFastReportBroker,
{$ENDIF}
  // NOTE: navigational brokers (like BDE) aren't supported
  InstantIBX,
  // insert other InstantObjects' brokers here
  PressInstantObjectsBroker;

implementation

{$ENDIF}
{$IFDEF UsePressOPF}

(****************************
   PRESSOJECTS DECLARATIONS
 ****************************)

interface

uses
  PressMessages_en,
  PressSubject, PressPersistence,
{$IFDEF UseReport}
  PressFastReportBroker,
{$ENDIF}
{$IFDEF FPC}
  PressSQLdbBroker,
  // Insert other Free Pascal connection brokers and SQLdb connections here
{$ELSE}
  PressIBXBroker,
  // Insert other Delphi connection brokers here
{$ENDIF}
  PressOPF;

type
  TPhoneBookPersistence = class(TPressOPF)
  protected
    procedure InternalShowConnectionManager; override;
  end;

  TPhoneBookGenerator = class(TPressOIDGenerator)
  protected
    function InternalGenerateOID(Sender: TPressPersistence; AObjectClass: TPressObjectClass; const AAttributeName: string): string; override;
  end;

implementation

uses
  SysUtils,
  Clipbrd,
  PressApplication,
  PressDialogs;

{ TPhoneBookPersistence }

procedure TPhoneBookPersistence.InternalShowConnectionManager;
begin
  if PressDialog.ConfirmDlg(
   'Copy the database metadata to the clipboard?') then
    Clipboard.AsText :=
     AdjustLineBreaks(PressOPFService.Mapper.CreateDatabaseStatement);
end;

{ TPhoneBookGenerator }

function TPhoneBookGenerator.InternalGenerateOID(
  Sender: TPressPersistence; AObjectClass: TPressObjectClass;
  const AAttributeName: string): string;
begin
  Result :=
   inherited InternalGenerateOID(Sender, AObjectClass, AAttributeName);
end;

initialization
  PressApp.ConfigFileName := 'PhoneBook.conf';
  TPhoneBookPersistence.RegisterService(True);
  TPhoneBookGenerator.RegisterService(True);

{$ENDIF}
{$IFDEF DontUsePersistence}

interface

uses
  PressMessages_en,
  PressSubject,
{$IFDEF UseReport}
  PressFastReportBroker,
{$ENDIF}
  PressPersistence;

type
  TPressPhoneBookPersistence = class(TPressPersistence)
  protected
    procedure InternalCommit; override;
    procedure InternalDispose(AClass: TPressObjectClass; const AId: string); override;
    function InternalExecuteStatement(const AStatement: string; AParams: TPressParamList): Integer; override;
    function InternalOQLQuery(const AOQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    function InternalRetrieve(AClass: TPressObjectClass; const AId: string; AMetadata: TPressObjectMetadata): TPressObject; override;
    function InternalRetrieveQuery(AQuery: TPressQuery): TPressProxyList; override;
    procedure InternalRollback; override;
    function InternalSQLProxy(const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    function InternalSQLQuery(AClass: TPressObjectClass; const ASQLStatement: string; AParams: TPressParamList): TPressProxyList; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
  end;

{ TPressPhoneBookPersistence }

implementation

procedure TPressPhoneBookPersistence.InternalCommit;
begin
end;

procedure TPressPhoneBookPersistence.InternalDispose(
  AClass: TPressObjectClass; const AId: string);
begin
end;

function TPressPhoneBookPersistence.InternalExecuteStatement(
  const AStatement: string; AParams: TPressParamList): Integer;
begin
  Result := 0;
end;

function TPressPhoneBookPersistence.InternalOQLQuery(
  const AOQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveQuery(nil);
end;

function TPressPhoneBookPersistence.InternalRetrieve(
  AClass: TPressObjectClass; const AId: string;
  AMetadata: TPressObjectMetadata): TPressObject;
begin
  Result := nil;
end;

function TPressPhoneBookPersistence.InternalRetrieveQuery(
  AQuery: TPressQuery): TPressProxyList;
begin
  { TODO : Improve }
  Result := TPressProxyList.Create(True, ptShared);
  if Assigned(AQuery) then
  begin
    try
      with Cache.CreateIterator do
      try
        BeforeFirstItem;
        while NextItem do
          if CurrentItem is AQuery.Metadata.ItemObjectClass then
            Result.AddInstance(CurrentItem);
      finally
        Free;
      end;
    except
      Result.Free;
      raise;
    end;
  end;
end;

procedure TPressPhoneBookPersistence.InternalRollback;
begin
end;

function TPressPhoneBookPersistence.InternalSQLProxy(
  const ASQLStatement: string; AParams: TPressParamList): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveQuery(nil);
end;

function TPressPhoneBookPersistence.InternalSQLQuery(
  AClass: TPressObjectClass; const ASQLStatement: string;
  AParams: TPressParamList): TPressProxyList;
begin
  { TODO : Implement }
  Result := InternalRetrieveQuery(nil);
end;

procedure TPressPhoneBookPersistence.InternalStartTransaction;
begin
end;

procedure TPressPhoneBookPersistence.InternalStore(AObject: TPressObject);
begin
  if AObject.Id = '' then
    AObject.Id := GenerateOID(AObject.ClassType, 'Id');
end;

initialization
  TPressPhoneBookPersistence.RegisterService;

{$ENDIF}

end.
