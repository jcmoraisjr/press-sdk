(*
  PressObjects, UIB Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUIBBroker;

{$I Press.inc}

interface

uses
  SysUtils,
  Classes,
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
  jvuib,
  jvuiblib,
  jvuibdataset;

type
  TPressUIBConnector = class;

  TPressUIBBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressUIBConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressUIBConnector read GetConnector;
  end;

  TPressUIBConnector = class(TPressOPFConnector)
  private
    FDatabase: TJvUIBDatabase;
    FTransaction: TJvUIBTransaction;
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
    property Database: TJvUIBDatabase read FDatabase;
    property Transaction: TJvUIBTransaction read FTransaction;
  end;

  TPressUIBDataset = class(TPressOPFDBDataset)
  private
    FQuery: TJvUIBDataSet;
    function GetQuery: TJvUIBDataSet;
    function GetConnector: TPressUIBConnector;
    procedure PopulateParams;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressUIBConnector read GetConnector;
    property Query: TJvUIBDataSet read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressUIBObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

  TPressUIBConnection = class(TPressOPFConnection)
  private
    FDatabase: TJvUIBDatabase;
    FTransaction: TJvUIBTransaction;
    function GetAfterConnect: TNotifyEvent;
    function GetAfterDisconnect: TNotifyEvent;
    function GetBeforeConnect: TNotifyEvent;
    function GetBeforeDisconnect: TNotifyEvent;
    function GetCharacterSet: TCharacterSet;
    function GetConnected: Boolean;
    function GetDatabaseName: TFileName;
    function GetLibraryName: TFileName;
    function GetOnConnectionLost: TNotifyEvent;
    function GetParams: TStrings;
    function GetPassWord: string;
    function GetSQLDialect: Integer;
    function GetUserName: string;
    procedure SetAfterConnect(AValue: TNotifyEvent);
    procedure SetAfterDisconnect(AValue: TNotifyEvent);
    procedure SetBeforeConnect(AValue: TNotifyEvent);
    procedure SetBeforeDisconnect(AValue: TNotifyEvent);
    procedure SetCharacterSet(AValue: TCharacterSet);
    procedure SetConnected(AValue: Boolean);
    procedure SetDatabaseName(AValue: TFileName);
    procedure SetLibraryName(AValue: TFileName);
    procedure SetOnConnectionLost(AValue: TNotifyEvent);
    procedure SetParams(AValue: TStrings);
    procedure SetPassWord(const AValue: string);
    procedure SetSQLDialect(AValue: Integer);
    procedure SetUserName(const AValue: string);
  protected
    function InternalBrokerClass: TPressOPFBrokerClass; override;
    property Database: TJvUIBDatabase read FDatabase;
    property Transaction: TJvUIBTransaction read FTransaction;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DatabaseName: TFileName read GetDatabaseName write SetDatabaseName;
    property UserName: string read GetUserName write SetUserName;
    property PassWord: string read GetPassWord write SetPassWord;
    property CharacterSet: TCharacterSet read GetCharacterSet write SetCharacterSet default csNONE;
    property Params: TStrings read GetParams write SetParams;
    property SQLDialect: Integer read GetSQLDialect write SetSQLDialect default 3;
    property LibraryName: TFileName read GetLibraryName write SetLibraryName;
    property Connected: Boolean read GetConnected write SetConnected default False;
    property AfterConnect: TNotifyEvent read GetAfterConnect write SetAfterConnect;
    property BeforeConnect: TNotifyEvent read GetBeforeConnect write SetBeforeConnect;
    property AfterDisconnect: TNotifyEvent read GetAfterDisconnect write SetAfterDisconnect;
    property BeforeDisconnect: TNotifyEvent read GetBeforeDisconnect write SetBeforeDisconnect;
    property OnConnectionLost: TNotifyEvent read GetOnConnectionLost write SetOnConnectionLost;
  end;

implementation

uses
  PressOPFClasses,
  PressIBFbBroker;

{ TPressUIBBroker }

function TPressUIBBroker.GetConnector: TPressUIBConnector;
begin
  Result := inherited Connector as TPressUIBConnector;
end;

function TPressUIBBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressUIBConnector;
end;

function TPressUIBBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressUIBObjectMapper;
end;

class function TPressUIBBroker.ServiceName: string;
begin
  Result := 'UIB';
end;

{ TPressUIBConnector }

constructor TPressUIBConnector.Create;
begin
  inherited;
  FDatabase := TJvUIBDatabase.Create(nil);
  FTransaction := TJvUIBTransaction.Create(nil);
  FTransaction.DataBase := FDatabase;
  FTransaction.Options := [tpReadCommitted];
end;

destructor TPressUIBConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressUIBConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressUIBConnector.InternalCommit;
begin
  Transaction.Commit;
end;

procedure TPressUIBConnector.InternalConnect;
begin
  Database.Connected := True;
end;

function TPressUIBConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressUIBDataset;
end;

function TPressUIBConnector.InternalDBMSName: string;
begin
  Result := 'InterBase/Firebird';
end;

procedure TPressUIBConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressUIBConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

{ TPressUIBDataset }

destructor TPressUIBDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressUIBDataset.GetConnector: TPressUIBConnector;
begin
  Result := inherited Connector as TPressUIBConnector;
end;

function TPressUIBDataset.GetQuery: TJvUIBDataSet;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TJvUIBDataSet.Create(nil);
    FQuery.Database := Connector.Database;
    FQuery.Transaction := Connector.Transaction;
    FQuery.FetchBlobs := True;
    FQuery.OnClose := etmStayIn;
    FQuery.OnError := etmStayIn;
    {$IFNDEF FPC}
    FQuery.UniDirectional := True;
    {$ENDIF}
  end;
  Result := FQuery;
end;

function TPressUIBDataset.InternalExecute: Integer;
begin
  PopulateParams;
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.Execute;
    Result := Query.RowsAffected;
  end;
end;

procedure TPressUIBDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

procedure TPressUIBDataset.PopulateParams;
var
  VParam: TPressOPFParam;
  VDBParams: TSQLParams;
  VBlobParam: string;
  I: Integer;
begin
  for I := 0 to Pred(Params.Count) do
  begin
    VParam := Params[I];
    VDBParams := Query.Params;
    if not VParam.IsNull then
    begin
      case VParam.DataType of
        oftString:
          VDBParams.ByNameAsString[VParam.Name] := VParam.AsString;
        oftInt16, oftInt32:
          VDBParams.ByNameAsInteger[VParam.Name] := VParam.AsInt32;
        oftInt64:
          VDBParams.ByNameAsInt64[VParam.Name] := VParam.AsInt64;
        oftFloat:
          VDBParams.ByNameAsDouble[VParam.Name] := VParam.AsFloat;
        oftCurrency:
          VDBParams.ByNameAsCurrency[VParam.Name] := VParam.AsCurrency;
        oftBoolean:
          VDBParams.ByNameAsBoolean[VParam.Name] := VParam.AsBoolean;
        oftDate:
          VDBParams.ByNameAsDate[VParam.Name] := Trunc(VParam.AsDate);
        oftTime, oftDateTime:
          VDBParams.ByNameAsDateTime[VParam.Name] := VParam.AsDateTime;
        oftMemo, oftBinary:
        begin
          VBlobParam := VParam.AsBinary;
          Query.ParamsSetBlob(VParam.Name, VBlobParam);
        end;
      end;
    end else if VParam.IsAssigned then
      VDBParams.ByNameIsNull[VParam.Name] := True;
  end;
end;

{ TPressUIBObjectMapper }

function TPressUIBObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

{ TPressUIBConnection }

constructor TPressUIBConnection.Create(AOwner: TComponent);
var
  VConnector: TPressUIBConnector;
begin
  inherited Create(AOwner);
  VConnector := Connector as TPressUIBConnector;
  FDatabase := VConnector.Database;
  FTransaction := VConnector.Transaction;
end;

function TPressUIBConnection.GetAfterConnect: TNotifyEvent;
begin
  Result := Database.AfterConnect;
end;

function TPressUIBConnection.GetAfterDisconnect: TNotifyEvent;
begin
  Result := Database.AfterDisconnect;
end;

function TPressUIBConnection.GetBeforeConnect: TNotifyEvent;
begin
  Result := Database.BeforeConnect;
end;

function TPressUIBConnection.GetBeforeDisconnect: TNotifyEvent;
begin
  Result := Database.BeforeDisconnect;
end;

function TPressUIBConnection.GetCharacterSet: TCharacterSet;
begin
  Result := Database.CharacterSet;
end;

function TPressUIBConnection.GetConnected: Boolean;
begin
  Result := Database.Connected;
end;

function TPressUIBConnection.GetDatabaseName: TFileName;
begin
  Result := Database.DatabaseName;
end;

function TPressUIBConnection.GetLibraryName: TFileName;
begin
  Result := Database.LibraryName;
end;

function TPressUIBConnection.GetOnConnectionLost: TNotifyEvent;
begin
  Result := Database.OnConnectionLost;
end;

function TPressUIBConnection.GetParams: TStrings;
begin
  Result := Database.Params;
end;

function TPressUIBConnection.GetPassWord: string;
begin
  Result := Database.PassWord;
end;

function TPressUIBConnection.GetSQLDialect: Integer;
begin
  Result := Database.SQLDialect;
end;

function TPressUIBConnection.GetUserName: string;
begin
  Result := Database.UserName;
end;

function TPressUIBConnection.InternalBrokerClass: TPressOPFBrokerClass;
begin
  Result := TPressUIBBroker;
end;

procedure TPressUIBConnection.SetAfterConnect(AValue: TNotifyEvent);
begin
  Database.AfterConnect := AValue;
end;

procedure TPressUIBConnection.SetAfterDisconnect(AValue: TNotifyEvent);
begin
  Database.AfterDisconnect := AValue;
end;

procedure TPressUIBConnection.SetBeforeConnect(AValue: TNotifyEvent);
begin
  Database.BeforeConnect := AValue;
end;

procedure TPressUIBConnection.SetBeforeDisconnect(AValue: TNotifyEvent);
begin
  Database.BeforeDisconnect := AValue;
end;

procedure TPressUIBConnection.SetCharacterSet(AValue: TCharacterSet);
begin
  Database.CharacterSet := AValue;
end;

procedure TPressUIBConnection.SetConnected(AValue: Boolean);
begin
  Database.Connected := AValue;
end;

procedure TPressUIBConnection.SetDatabaseName(AValue: TFileName);
begin
  Database.DatabaseName := AValue;
end;

procedure TPressUIBConnection.SetLibraryName(AValue: TFileName);
begin
  Database.LibraryName := AValue;
end;

procedure TPressUIBConnection.SetOnConnectionLost(AValue: TNotifyEvent);
begin
  Database.OnConnectionLost := AValue;
end;

procedure TPressUIBConnection.SetParams(AValue: TStrings);
begin
  Database.Params := AValue;
end;

procedure TPressUIBConnection.SetPassWord(const AValue: string);
begin
  Database.PassWord := AValue;
end;

procedure TPressUIBConnection.SetSQLDialect(AValue: Integer);
begin
  Database.SQLDialect := AValue;
end;

procedure TPressUIBConnection.SetUserName(const AValue: string);
begin
  Database.UserName := AValue;
end;

initialization
  TPressUIBBroker.RegisterService;

finalization
  TPressUIBBroker.UnregisterService;

end.
