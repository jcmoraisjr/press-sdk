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
  PressOPFBroker,
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
    property Connector: TPressIBXConnector read GetConnector;
  end;

  TPressIBXConnector = class(TPressOPFConnector)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
  protected
    function GetSupportTransaction: Boolean; override;
    procedure InternalCommit; override;
    procedure InternalConnect; override;
    function InternalDatasetClass: TPressOPFDatasetClass; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property Database: TIBDatabase read FDatabase;
    property Transaction: TIBTransaction read FTransaction;
  end;

  TPressIBXDataset = class(TPressOPFDBDataset)
  private
    FQuery: TIBQuery;
    function GetQuery: TIBQuery;
    function GetConnector: TPressIBXConnector;
    procedure PopulateParams;
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

{ TPressIBXConnector }

constructor TPressIBXConnector.Create;
begin
  inherited;
  FDatabase := TIBDatabase.Create(nil);
  FDatabase.SQLDialect := 3;
  FDatabase.LoginPrompt := False;
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.DefaultDatabase := FDatabase;
  FTransaction.Params.Add('read_committed');
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

procedure TPressIBXConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressIBXConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
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
  PopulateParams;
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

procedure TPressIBXDataset.PopulateParams;
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
          { TODO : Unsupported }
          VDBParams.ParamByName(VParam.Name).AsInteger := VParam.AsInt64;
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

{ TPressIBXObjectMapper }

function TPressIBXObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

initialization
  TPressIBXBroker.RegisterService;

end.
