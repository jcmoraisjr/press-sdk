(*
  PressObjects, DOA Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDOABroker;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressOPF,
  PressOPFConnector,
  PressOPFMapper,
  PressOPFSQLBuilder,
  PressDataSetBroker,
  Oracle,
  OracleData;

type
  TPressDOAConnector = class;

  TPressDOABroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressDOAConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressDOAConnector read GetConnector;
  end;

  TPressDOAConnector = class(TPressOPFConnector)
  private
    FSession: TOracleSession;
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
    property Session: TOracleSession read FSession;
  end;

  TPressDOADataset = class(TPressOPFDBDataset)
  private
    FLOBLocators: TObjectList;
    FQuery: TOracleDataSet;
    function CreateLOBLocator(AParamType: Integer): TLOBLocator;
    function GetQuery: TOracleDataSet;
    function GetConnector: TPressDOAConnector;
    procedure PopulateDOAParams;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressDOAConnector read GetConnector;
    property Query: TOracleDataSet read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressDOAObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

  TPressDOAConnection = class(TPressOPFConnection)
  private
    FSession: TOracleSession;
    function GetAfterLogOn: TOracleSessionEvent;
    function GetBeforeLogOn: TOracleSessionEvent;
    function GetConnected: Boolean;
    function GetIsolationLevel: TIsolationLevelOption;
    function GetLogonDatabase: string;
    function GetLogonPassword: string;
    function GetLogonUsername: string;
    procedure SetAfterLogOn(AValue: TOracleSessionEvent);
    procedure SetBeforeLogOn(AValue: TOracleSessionEvent);
    procedure SetConnected(AValue: Boolean);
    procedure SetIsolationLevel(AValue: TIsolationLevelOption);
    procedure SetLogonDatabase(const AValue: string);
    procedure SetLogonPassword(const AValue: string);
    procedure SetLogonUsername(const AValue: string);
  protected
    function InternalBrokerClass: TPressOPFBrokerClass; override;
    property Session: TOracleSession read FSession;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property LogonUsername: string read GetLogonUsername write SetLogonUsername;
    property LogonPassword: string read GetLogonPassword write SetLogonPassword;
    property LogonDatabase: string read GetLogonDatabase write SetLogonDatabase;
    property IsolationLevel: TIsolationLevelOption read GetIsolationLevel write SetIsolationLevel default ilUnchanged;
    property Connected: Boolean read GetConnected write SetConnected default False;
    property BeforeLogOn: TOracleSessionEvent read GetBeforeLogOn write SetBeforeLogOn;
    property AfterLogOn: TOracleSessionEvent read GetAfterLogOn write SetAfterLogOn;
  end;

implementation

uses
  PressOPFClasses,
  PressOracleBroker;

{ TPressDOABroker }

function TPressDOABroker.GetConnector: TPressDOAConnector;
begin
  Result := inherited Connector as TPressDOAConnector;
end;

function TPressDOABroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressDOAConnector;
end;

function TPressDOABroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressDOAObjectMapper;
end;

class function TPressDOABroker.ServiceName: string;
begin
  Result := 'DOA';
end;

{ TPressDOAConnector }

constructor TPressDOAConnector.Create;
begin
  inherited;
  FSession := TOracleSession.Create(nil);
  FSession.BytesPerCharacter := bcAutoDetect;
  FSession.IsolationLevel := ilReadCommitted;
end;

destructor TPressDOAConnector.Destroy;
begin
  FSession.Free;
  inherited;
end;

function TPressDOAConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressDOAConnector.InternalCommit;
begin
  Session.Commit;
end;

procedure TPressDOAConnector.InternalConnect;
begin
  if not Session.Connected then
    Session.LogOn;
end;

function TPressDOAConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressDOADataset;
end;

function TPressDOAConnector.InternalDBMSName: string;
begin
  Result := 'Oracle';
end;

procedure TPressDOAConnector.InternalRollback;
begin
  Session.Rollback;
end;

procedure TPressDOAConnector.InternalStartTransaction;
begin
end;

{ TPressDOADataset }

function TPressDOADataset.CreateLOBLocator(AParamType: Integer): TLOBLocator;
begin
  Result := TLOBLocator.CreateTemporary(Connector.Session, AParamType, True);
  try
    if not Assigned(FLOBLocators) then
      FLOBLocators := TObjectList.Create(True);
    FLOBLocators.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

destructor TPressDOADataset.Destroy;
begin
  FLOBLocators.Free;
  FQuery.Free;
  inherited;
end;

function TPressDOADataset.GetConnector: TPressDOAConnector;
begin
  Result := inherited Connector as TPressDOAConnector;
end;

function TPressDOADataset.GetQuery: TOracleDataSet;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TOracleDataSet.Create(nil);
    FQuery.Session := Connector.Session;
    FQuery.ReadOnly := True;
    FQuery.Unidirectional := True;
  end;
  Result := FQuery;
end;

function TPressDOADataset.InternalExecute: Integer;
begin
  PopulateDOAParams;
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    { TODO : Implement }
    Result := 1;  // Query.RowsAffected;
  end;
  if Assigned(FLOBLocators) then
    FLOBLocators.Clear;
end;

procedure TPressDOADataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
  Query.DeleteVariables;
end;

procedure TPressDOADataset.PopulateDOAParams;

  function OPFTypeToDOAType(AOPFType: TPressOPFFieldType): Integer;
  const
    CDOAType: array[TPressOPFFieldType] of Integer = (
     -1,           // oftUnknown
     otString,     // oftPlainString
     otString,     // oftAnsiString
     otInteger,    // oftInt16
     otInteger,    // oftInt32
     otInteger,    // oftInt64
     otFloat,      // oftDouble
     otFloat,      // oftCurrency
     otInteger,    // oftBoolean
     otDate,       // oftDate
     otTimeStamp,  // oftTime
     otTimeStamp,  // oftDateTime
     otClob,       // oftMemo
     otBlob);      // oftBinary
  begin
    Result := CDOAType[AOPFType];
  end;

var
  VQuery: TOracleDataSet;
  VParam: TPressOPFParam;
  VParamType: Integer;
  VLOB: TLOBLocator;
  VLOBValue: string;
  VVarName: string;
  VVarIndex: Integer;
  I: Integer;
begin
  VQuery := Query;
  for I := 0 to Pred(Params.Count) do
  begin
    VParam := Params[I];
    if VParam.IsAssigned then
    begin
      VParamType := OPFTypeToDOAType(VParam.DataType);
      VVarName := VParam.Name;
      VVarIndex := VQuery.VariableIndex(VVarName);
      if VVarIndex = -1 then
        VQuery.DeclareVariable(VVarName, VParamType);
      if VParam.DataType in [oftMemo, oftBinary] then
      begin
        VLOB := CreateLOBLocator(VParamType);
        if not VParam.IsNull then
        begin
          VLOBValue := VParam.AsString;
          VLOB.Write(VLOBValue[1], Length(VLOBValue));
        end else
          VLOB.Clear;
        VQuery.SetComplexVariable(VVarName, VLOB);
      end else
        VQuery.SetVariable(VVarName, VParam.AsVariant);
    end;
  end;
end;

{ TPressDOAObjectMapper }

function TPressDOAObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressOracleDDLBuilder;
end;

{ TPressDOAConnection }

constructor TPressDOAConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSession := (Connector as TPressDOAConnector).Session;
end;

function TPressDOAConnection.GetAfterLogOn: TOracleSessionEvent;
begin
  Result := Session.AfterLogOn;
end;

function TPressDOAConnection.GetBeforeLogOn: TOracleSessionEvent;
begin
  Result := Session.BeforeLogOn;
end;

function TPressDOAConnection.GetConnected: Boolean;
begin
  Result := Session.Connected;
end;

function TPressDOAConnection.GetIsolationLevel: TIsolationLevelOption;
begin
  Result := Session.IsolationLevel;
end;

function TPressDOAConnection.GetLogonDatabase: string;
begin
  Result := Session.LogonDatabase;
end;

function TPressDOAConnection.GetLogonPassword: string;
begin
  Result := Session.LogonPassword;
end;

function TPressDOAConnection.GetLogonUsername: string;
begin
  Result := Session.LogonUsername;
end;

function TPressDOAConnection.InternalBrokerClass: TPressOPFBrokerClass;
begin
  Result := TPressDOABroker;
end;

procedure TPressDOAConnection.SetAfterLogOn(AValue: TOracleSessionEvent);
begin
  Session.AfterLogOn := AValue;
end;

procedure TPressDOAConnection.SetBeforeLogOn(AValue: TOracleSessionEvent);
begin
  Session.BeforeLogOn := AValue;
end;

procedure TPressDOAConnection.SetConnected(AValue: Boolean);
begin
  Session.Connected := AValue;
end;

procedure TPressDOAConnection.SetIsolationLevel(AValue: TIsolationLevelOption);
begin
  Session.IsolationLevel := AValue;
end;

procedure TPressDOAConnection.SetLogonDatabase(const AValue: string);
begin
  Session.LogonDatabase := AValue;
end;

procedure TPressDOAConnection.SetLogonPassword(const AValue: string);
begin
  Session.LogonPassword := AValue;
end;

procedure TPressDOAConnection.SetLogonUsername(const AValue: string);
begin
  Session.LogonUsername := AValue;
end;

initialization
  TPressDOABroker.RegisterService;

finalization
  TPressDOABroker.UnregisterService;

end.
