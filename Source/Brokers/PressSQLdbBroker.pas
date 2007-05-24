(*
  PressObjects, SQLdb Connection Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressSQLdbBroker;

{$I Press.inc}

interface

uses
  PressOPFBroker,
  PressOPFConnector,
  PressOPFMapper,
  PressDataSetBroker,
  sqldb;

type
  TPressSQLdbConnector = class;

  TPressSQLdbBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressSQLdbConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    property Connector: TPressSQLdbConnector read GetConnector;
  end;

  TPressSQLdbConnector = class(TPressOPFConnector)
  private
    FDatabase: TSQLConnection;
    FTransaction: TSQLTransaction;
    function GetDatabase: TSQLConnection;
  protected
    function GetSupportTransaction: Boolean; override;
    procedure InternalCommit; override;
    function InternalDatasetClass: TPressOPFDatasetClass; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignConnection(AConnectionClass: TSQLConnectionClass);
    property Database: TSQLConnection read GetDatabase;
    property Transaction: TSQLTransaction read FTransaction;
  end;

  TPressSQLdbDataset = class(TPressOPFDBDataset)
  private
    FQuery: TSQLQuery;
    function GetQuery: TSQLQuery;
    function GetConnector: TPressSQLdbConnector;
    procedure PopulateParams;
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressSQLdbConnector read GetConnector;
    property Query: TSQLQuery read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressSQLdbObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

implementation

uses
  db,
  PressConsts,
  PressOPFClasses,
  PressIBFbBroker;

{ TPressSQLdbBroker }

function TPressSQLdbBroker.GetConnector: TPressSQLdbConnector;
begin
  Result := inherited Connector as TPressSQLdbConnector;
end;

function TPressSQLdbBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressSQLdbConnector;
end;

function TPressSQLdbBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressSQLdbObjectMapper;
end;

{ TPressSQLdbConnector }

procedure TPressSQLdbConnector.AssignConnection(AConnectionClass: TSQLConnectionClass);
begin
  FDatabase.Free;
  FDatabase := AConnectionClass.Create(nil);
  FTransaction.Database := FDatabase;
end;

constructor TPressSQLdbConnector.Create;
begin
  inherited;
  FTransaction := TSQLTransaction.Create(nil);
end;

destructor TPressSQLdbConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressSQLdbConnector.GetDatabase: TSQLConnection;
begin
  if not Assigned(FDatabase) then
    raise EPressOPFError.Create(SUnassignedDatabase);
  Result := FDatabase;
end;

function TPressSQLdbConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressSQLdbConnector.InternalCommit;
begin
  Transaction.Commit;
end;

function TPressSQLdbConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressSQLdbDataset;
end;

procedure TPressSQLdbConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressSQLdbConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

{ TPressSQLdbDataset }

destructor TPressSQLdbDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressSQLdbDataset.GetConnector: TPressSQLdbConnector;
begin
  Result := inherited Connector as TPressSQLdbConnector;
end;

function TPressSQLdbDataset.GetQuery: TSQLQuery;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TSQLQuery.Create(nil);
    FQuery.Database := Connector.Database;
    FQuery.Transaction := Connector.Transaction;
//    FQuery.FetchBlobs := True;
//    FQuery.IsUniDirectional := True;
    FQuery.ReadOnly := True;
  end;
  Result := FQuery;
end;

function TPressSQLdbDataset.InternalExecute: Integer;
begin
  PopulateParams;
  if IsSelectStatement then
  begin
    PopulateOPFDataset(Query);
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    Result := 0; //Query.RowsAffected;
  end;
end;

procedure TPressSQLdbDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

procedure TPressSQLdbDataset.PopulateParams;
var
  VParam: TPressOPFParam;
  VDBParams: TParams;
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
          VDBParams.ParamByName(VParam.Name).AsString := VParam.AsString;
        oftInt16, oftInt32:
          VDBParams.ParamByName(VParam.Name).AsInteger := VParam.AsInt32;
        oftInt64:
          VDBParams.ParamByName(VParam.Name).AsLargeInt := VParam.AsInt64;
        oftFloat:
          VDBParams.ParamByName(VParam.Name).AsFloat := VParam.AsFloat;
        oftCurrency:
          VDBParams.ParamByName(VParam.Name).AsCurrency := VParam.AsCurrency;
        oftBoolean:
          VDBParams.ParamByName(VParam.Name).AsBoolean := VParam.AsBoolean;
        oftDate:
          VDBParams.ParamByName(VParam.Name).AsDate := VParam.AsDate;
        oftTime:
          VDBParams.ParamByName(VParam.Name).AsTime := VParam.AsTime;
        oftDateTime:
          VDBParams.ParamByName(VParam.Name).AsDateTime := VParam.AsDateTime;
        oftMemo:
          VDBParams.ParamByName(VParam.Name).AsMemo := VParam.AsMemo;
        oftBinary:
          VDBParams.ParamByName(VParam.Name).AsBlob := VParam.AsBinary;
      end;
    end else if VParam.IsAssigned then
      VDBParams.ParamByName(VParam.Name).Value := Null;
  end;
end;

{ TPressSQLdbObjectMapper }

function TPressSQLdbObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

initialization
  TPressSQLdbBroker.RegisterService;

end.
