(*
  PressObjects, FBLib Connection Broker
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressFBLibBroker;

{$I Press.inc}

interface

uses
  SysUtils,
  Classes,
  PressOPF,
  PressOPFClasses,
  PressOPFConnector,
  PressOPFMapper,
  PressOPFSQLBuilder,
  FBLDatabase,
  FBLTransaction,
  FBLParamDsql;

type
  TPressFBLibConnector = class;

  TPressFBLibBroker = class(TPressOPFBroker)
  private
    function GetConnector: TPressFBLibConnector;
  protected
    function InternalConnectorClass: TPressOPFConnectorClass; override;
    function InternalMapperClass: TPressOPFObjectMapperClass; override;
  public
    class function ServiceName: string; override;
  published
    property Connector: TPressFBLibConnector read GetConnector;
  end;

  TPressFBLibConnector = class(TPressOPFConnector)
  private
    FDatabase: TFBLDatabase;
    FTransaction: TFBLTransaction;
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
    property Database: TFBLDatabase read FDatabase;
    property Transaction: TFBLTransaction read FTransaction;
  end;

  TPressFBLibDataset = class(TPressOPFDataset)
  private
    FQuery: TFBLParamDsql;
    function FBLTypeToOPFType(AFBLType, ASubType, AScale: Smallint): TPressOPFFieldType;
    function GetQuery: TFBLParamDsql;
    function GetConnector: TPressFBLibConnector;
    procedure PopulateOPFDataset;
    procedure PopulateParams;
    procedure ReadFBLField(ADataRow: TPressOPFDataRow; AIndex: Integer);
  protected
    function InternalExecute: Integer; override;
    procedure InternalSQLChanged; override;
    property Connector: TPressFBLibConnector read GetConnector;
    property Query: TFBLParamDsql read GetQuery;
  public
    destructor Destroy; override;
  end;

  TPressFBLibObjectMapper = class(TPressOPFObjectMapper)
  protected
    function InternalDDLBuilderClass: TPressOPFDDLBuilderClass; override;
  end;

implementation

uses
  TypInfo,
  PressConsts,
{$ifdef d5down}
  PressUtils,
{$endif}
  PressIBFbBroker,
  ibase_h;

{ TPressFBLibBroker }

function TPressFBLibBroker.GetConnector: TPressFBLibConnector;
begin
  Result := inherited Connector as TPressFBLibConnector;
end;

function TPressFBLibBroker.InternalConnectorClass: TPressOPFConnectorClass;
begin
  Result := TPressFBLibConnector;
end;

function TPressFBLibBroker.InternalMapperClass: TPressOPFObjectMapperClass;
begin
  Result := TPressFBLibObjectMapper;
end;

class function TPressFBLibBroker.ServiceName: string;
begin
  Result := 'FBLib';
end;

{ TPressFBLibConnector }

constructor TPressFBLibConnector.Create;
begin
  inherited Create;
  FDatabase := TFBLDatabase.Create(nil);
  FTransaction := TFBLTransaction.Create(nil);
  FTransaction.IsolationLevel := ilReadCommitted_rec_version;
  FTransaction.LockResolution := lrWait;
  FTransaction.Database := FDatabase;
end;

destructor TPressFBLibConnector.Destroy;
begin
  FDatabase.Free;
  FTransaction.Free;
  inherited;
end;

function TPressFBLibConnector.GetSupportTransaction: Boolean;
begin
  Result := True;
end;

procedure TPressFBLibConnector.InternalCommit;
begin
  Transaction.Commit;
end;

procedure TPressFBLibConnector.InternalConnect;
begin
  Database.Connect;
end;

function TPressFBLibConnector.InternalDatasetClass: TPressOPFDatasetClass;
begin
  Result := TPressFBLibDataset;
end;

function TPressFBLibConnector.InternalDBMSName: string;
begin
  Result := 'InterBase/Firebird';
end;

procedure TPressFBLibConnector.InternalRollback;
begin
  Transaction.Rollback;
end;

procedure TPressFBLibConnector.InternalStartTransaction;
begin
  Transaction.StartTransaction;
end;

{ TPressFBLibDataset }

destructor TPressFBLibDataset.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TPressFBLibDataset.FBLTypeToOPFType(
  AFBLType, ASubType, AScale: SmallInt): TPressOPFFieldType;
begin
  case AFBLType of
    SQL_TEXT, SQL_VARYING:
      Result := oftAnsiString;
    SQL_SHORT:
      if AScale = 0 then
        Result := oftInt16
      else
        Result := oftCurrency;
    SQL_LONG:
      if AScale = 0 then
        Result := oftInt32
      else
        Result := oftCurrency;
    SQL_INT64:
      if AScale = 0 then
        Result := oftInt64
      else
        Result := oftCurrency;
    SQL_FLOAT, SQL_DOUBLE, SQL_D_FLOAT:
      if AScale = 0 then
        Result := oftDouble
      else
        Result := oftCurrency;
    SQL_DATE, SQL_TYPE_DATE, SQL_TYPE_TIME:  // SQL_TIMESTAMP
      Result := oftDateTime;
    SQL_BLOB:
      if ASubType = 1 then
        Result := oftMemo
      else
        Result := oftBinary;
    else  // SQL_ARRAY, SQL_QUAD
      raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [IntToStr(AFBLType)]);
  end;
end;

function TPressFBLibDataset.GetConnector: TPressFBLibConnector;
begin
  Result := inherited Connector as TPressFBLibConnector;
end;

function TPressFBLibDataset.GetQuery: TFBLParamDsql;
begin
  if not Assigned(FQuery) then
  begin
    FQuery := TFBLParamDsql.Create(nil);
    FQuery.Transaction := Connector.Transaction;
  end;
  Result := FQuery;
end;

function TPressFBLibDataset.InternalExecute: Integer;
begin
  Query.Prepare;
  PopulateParams;
  if IsSelectStatement then
  begin
    PopulateOPFDataset;
    Result := Count;
  end else
  begin
    Query.ExecSQL;
    Result := Query.RowsAffected;
  end;
end;

procedure TPressFBLibDataset.InternalSQLChanged;
begin
  inherited;
  Query.SQL.Text := SQL;
end;

procedure TPressFBLibDataset.PopulateOPFDataset;
var
  VQuery: TFBLParamDsql;
  VDataRow: TPressOPFDataRow;
  I: Integer;
begin
  ClearFields;
  VQuery := Query;
  VQuery.ExecSQL;
  try
    for I := 0 to Pred(VQuery.FieldCount) do
      with FieldDefs.Add do
      begin
        Name := VQuery.FieldName(I);
        FieldType := FBLTypeToOPFType(
         VQuery.FieldType(I), VQuery.FieldSubType(I), VQuery.FieldScale(I));
      end;
    while not VQuery.Eof do
    begin
      VDataRow := AddRow;
      for I := 0 to Pred(VDataRow.Count) do
        ReadFBLField(VDataRow, I);
      VQuery.Next;
    end;
  finally
    VQuery.Close;
  end;
end;

procedure TPressFBLibDataset.PopulateParams;
var
  VQuery: TFBLParamDsql;
  VParam: TPressOPFParam;
  I: Integer;
begin
  VQuery := Query;
  for I := 0 to Pred(Params.Count) do
  begin
    VParam := Params[I];
    if not VParam.IsNull then
    begin
      case VParam.DataType of
        oftPlainString, oftAnsiString:
          VQuery.ParamByNameAsString(VParam.Name, VParam.AsString);
        oftInt16:
          VQuery.ParamByNameAsShort(VParam.Name, VParam.AsInt16);
        oftInt32:
          VQuery.ParamByNameAsLong(VParam.Name, VParam.AsInt32);
        oftInt64:
          VQuery.ParamByNameAsInt64(VParam.Name, VParam.AsInt64);
        oftDouble, oftCurrency:  // what about currency?
          VQuery.ParamByNameAsDouble(VParam.Name, VParam.AsDouble);
        oftBoolean:
          VQuery.ParamByNameAsShort(VParam.Name, VParam.AsInt16);
        oftDate, oftTime, oftDateTime:
          VQuery.ParamByNameAsDateTime(VParam.Name, VParam.AsDateTime);
        oftMemo, oftBinary:
          VQuery.BlobParamByNameAsString(VParam.Name, VParam.AsBinary);
      end;
    end else if VParam.IsAssigned then
      VQuery.ParamByNameAsNull(VParam.Name);
  end;
end;

procedure TPressFBLibDataset.ReadFBLField(
  ADataRow: TPressOPFDataRow; AIndex: Integer);
begin
  if Query.FieldIsNull(AIndex) then
    ADataRow[AIndex].Clear
  else
    case FieldDefs[AIndex].FieldType of
      oftPlainString, oftAnsiString:
        ADataRow[AIndex].Value := Query.FieldAsString(AIndex);
      oftInt16, oftInt32:
        ADataRow[AIndex].Value := Query.FieldAsLong(AIndex);
      oftInt64:
        ADataRow[AIndex].Value :=
{$ifdef d5down}
         PressD5Int64ToVariant(Query.FieldAsInt64(AIndex));
{$else}
         Query.FieldAsInt64(AIndex);
{$endif}
      oftDouble, oftCurrency:
        ADataRow[AIndex].Value := Query.FieldAsDouble(AIndex);
      oftDate, oftTime, oftDateTime:
        ADataRow[AIndex].Value := Query.FieldAsDateTime(AIndex);
      oftMemo, oftBinary:
        ADataRow[AIndex].Value := Query.BlobFieldAsString(AIndex);
      else
        raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [
         GetEnumName(TypeInfo(TPressOPFFieldType), Ord(FieldDefs[AIndex].FieldType))]);
    end;
end;

{ TPressFBLibObjectMapper }

function TPressFBLibObjectMapper.InternalDDLBuilderClass: TPressOPFDDLBuilderClass;
begin
  Result := TPressIBFbDDLBuilder;
end;

initialization
  TPressFBLibBroker.RegisterService;

finalization
  TPressFBLibBroker.UnregisterService;

end.
