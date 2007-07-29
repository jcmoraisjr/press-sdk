(*
  PressObjects, IBX Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressIBXBroker;

{$I Press.inc}

interface

uses
  Classes,
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
  IBDatabase,
  IBQuery;

type
  TPressIBXConnector = class;

  TPressIBXBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressIBXConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressIBXConnector read GetConnector;
  end;

  TPressIBXConnector = class(TPressOPFConnector)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    procedure SetPassword(const Value: string);
    procedure SetUserName(const Value: string);
  protected
    function GetSupportTransaction: Boolean; override;
    procedure InternalCommit; override;
    procedure InternalConnect; override;
    function InternalDatasetClass: TPressOPFDatasetClass; override;
    function InternalDBMSName: string; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property Database: TIBDatabase read FDatabase;
    property Password: string write SetPassword;
    property Transaction: TIBTransaction read FTransaction;
    property UserName: string write SetUserName;
  end;

  TPressIBXDataset = class(TPressOPFDBDataset)
  private
    FQuery: TIBQuery;
    function GetQuery: TIBQuery;
    function GetConnector: TPressIBXConnector;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressIBXConnector read GetConnector;
    property Query: TIBQuery read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressIBXObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

  TPressIBXConnection = class(TPressOPFConnection)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    function GetAfterConnect: TNotifyEvent;
    function GetAfterDisconnect: TNotifyEvent;
    function GetBeforeConnect: TNotifyEvent;
    function GetBeforeDisconnect: TNotifyEvent;
    function GetConnected: Boolean;
    function GetDatabaseName: TIBFileName;
    function GetOnLogin: TIBDatabaseLoginEvent;
    function GetParams: TStrings;
    function GetPassword: string;
    function GetSQLDialect: Integer;
    function GetUserName: string;
    procedure SetAfterConnect(AValue: TNotifyEvent);
    procedure SetAfterDisconnect(AValue: TNotifyEvent);
    procedure SetBeforeConnect(AValue: TNotifyEvent);
    procedure SetBeforeDisconnect(AValue: TNotifyEvent);
    procedure SetConnected(AValue: Boolean);
    procedure SetDatabaseName(AValue: TIBFileName);
    procedure SetOnLogin(AValue: TIBDatabaseLoginEvent);
    procedure SetParams(AValue: TStrings);
    procedure SetPassword(const AValue: string);
    procedure SetSQLDialect(AValue: Integer);
    procedure SetUserName(const AValue: string);
  protected
    function InternalBrokerClass: TPressOPFBrokerClass; override;
    property Database: TIBDatabase read FDatabase;
    property Transaction: TIBTransaction read FTransaction;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DatabaseName: TIBFileName read GetDatabaseName write SetDatabaseName;
    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
    property Params: TStrings read GetParams write SetParams;
    property SQLDialect: Integer read GetSQLDialect write SetSQLDialect;
    property Connected: Boolean read GetConnected write SetConnected default False;
    property AfterConnect: TNotifyEvent read GetAfterConnect write SetAfterConnect;
    property AfterDisconnect: TNotifyEvent read GetAfterDisconnect write SetAfterDisconnect;
    property BeforeConnect: TNotifyEvent read GetBeforeConnect write SetBeforeConnect;
    property BeforeDisconnect: TNotifyEvent read GetBeforeDisconnect write SetBeforeDisconnect;
    property OnLogin: TIBDatabaseLoginEvent read GetOnLogin write SetOnLogin;
  end;

implementation

uses
  Db,
  PressOPFClasses,
  PressIBFbBroker;

{ TPressIBXBroker }

function TPressIBXBroker.GetConnector: TPressIBXConnector;
begin
  Result := inherited Connector as TPressIBXConnector;
end;

function TPressIBXBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressIBXConnector;
end;

function TPressIBXBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressIBXObjectMapper;
end;

class function TPressIBXBroker.ServiceName: string;
begin
  Result := 'IBX';
end;

{ TPressIBXConnector }

constructor TPressIBXConnector.Create;
begin
  inherited;
  FDatabase := TIBDatabase.Create(nil);
  FDatabase.SQLDialect := 3;
  FDatabase.LoginPrompt := False;
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.DefaultDatabase := FDatabase;
  FTransaction.Params.Text := 'read_committed';
end;

destructor TPressIBXConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressIBXConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressIBXConnector.InternalCommit;
begin
  Transaction.Commit;
end;

procedure TPressIBXConnector.InternalConnect;
begin
  Database.Open;
end;

function TPressIBXConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressIBXDataset;
end;

function TPressIBXConnector.InternalDBMSName: string;
begin
  Result := 'InterBase';
end;

procedure TPressIBXConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressIBXConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

procedure TPressIBXConnector.SetPassword(const Value: string);
begin
  Database.Params.Values['password'] := Value;  { do not localize }
end;

procedure TPressIBXConnector.SetUserName(const Value: string);
begin
  Database.Params.Values['user_name'] := Value;  { do not localize }
end;

{ TPressIBXDataset }

destructor TPressIBXDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressIBXDataset.GetConnector: TPressIBXConnector;
begin
  Result := inherited Connector as TPressIBXConnector;
end;

function TPressIBXDataset.GetQuery: TIBQuery;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TIBQuery.Create(nil);
    FQuery.Database := Connector.Database;
    FQuery.Transaction := Connector.Transaction;
    FQuery.UniDirectional := True;
  end;
  Result := FQuery;
end;

function TPressIBXDataset.InternalExecute: Integer;
begin
  PopulateParams(Query.Params);
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    Result := Query.RowsAffected;
  end;
end;

procedure TPressIBXDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

{ TPressIBXObjectMapper }

function TPressIBXObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

{ TPressIBXConnection }

constructor TPressIBXConnection.Create(AOwner: TComponent);
var
  VConnector: TPressIBXConnector;
begin
  inherited Create(AOwner);
  VConnector := Connector as TPressIBXConnector;
  FDatabase := VConnector.Database;
  FTransaction := VConnector.Transaction;
end;

function TPressIBXConnection.GetAfterConnect: TNotifyEvent;
begin
  Result := Database.AfterConnect;
end;

function TPressIBXConnection.GetAfterDisconnect: TNotifyEvent;
begin
  Result := Database.AfterDisconnect;
end;

function TPressIBXConnection.GetBeforeConnect: TNotifyEvent;
begin
  Result := Database.BeforeConnect;
end;

function TPressIBXConnection.GetBeforeDisconnect: TNotifyEvent;
begin
  Result := Database.BeforeDisconnect;
end;

function TPressIBXConnection.GetConnected: Boolean;
begin
  Result := Database.Connected;
end;

function TPressIBXConnection.GetDatabaseName: TIBFileName;
begin
  Result := Database.DatabaseName;
end;

function TPressIBXConnection.GetOnLogin: TIBDatabaseLoginEvent;
begin
  Result := Database.OnLogin;
end;

function TPressIBXConnection.GetParams: TStrings;
begin
  Result := Database.Params;
end;

function TPressIBXConnection.GetPassword: string;
begin
  Result := Database.Params.Values['password'];  { do not localize }
end;

function TPressIBXConnection.GetSQLDialect: Integer;
begin
  Result := Database.SQLDialect;
end;

function TPressIBXConnection.GetUserName: string;
begin
  Result := Database.Params.Values['user_name'];  { do not localize }
end;

function TPressIBXConnection.InternalBrokerClass: TPressOPFBrokerClass;
begin
  Result := TPressIBXBroker;
end;

procedure TPressIBXConnection.SetAfterConnect(AValue: TNotifyEvent);
begin
  Database.AfterConnect := AValue;
end;

procedure TPressIBXConnection.SetAfterDisconnect(AValue: TNotifyEvent);
begin
  Database.AfterDisconnect := AValue;
end;

procedure TPressIBXConnection.SetBeforeConnect(AValue: TNotifyEvent);
begin
  Database.BeforeConnect := AValue;
end;

procedure TPressIBXConnection.SetBeforeDisconnect(AValue: TNotifyEvent);
begin
  Database.BeforeDisconnect := AValue;
end;

procedure TPressIBXConnection.SetConnected(AValue: Boolean);
begin
  Database.Connected := AValue;
end;

procedure TPressIBXConnection.SetDatabaseName(AValue: TIBFileName);
begin
  Database.DatabaseName := AValue;
end;

procedure TPressIBXConnection.SetOnLogin(AValue: TIBDatabaseLoginEvent);
begin
  Database.OnLogin := AValue;
end;

procedure TPressIBXConnection.SetParams(AValue: TStrings);
begin
  Database.Params := AValue;
end;

procedure TPressIBXConnection.SetPassword(const AValue: string);
begin
  Database.Params.Values['password'] := AValue;  { do not localize }
end;

procedure TPressIBXConnection.SetSQLDialect(AValue: Integer);
begin
  Database.SQLDialect := AValue;
end;

procedure TPressIBXConnection.SetUserName(const AValue: string);
begin
  Database.Params.Values['user_name'] := AValue;  { do not localize }
end;

initialization
  TPressIBXBroker.RegisterService;

finalization
  TPressIBXBroker.UnregisterService;

end.
