(*
  PressObjects, DB-DataSet Broker
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDataSetBroker;

{$I Press.inc}

interface

uses
  Db,
  PressOPFClasses,
  PressOPFConnector;

type

  { TPressOPFDBDataset }

  TPressOPFDBDataset = class(TPressOPFDataset)
  private
    function DBTypeToOPFType(AFieldType: TFieldType): TPressOPFFieldType;
    function OPFTypeToDBType(AFieldType: TPressOPFFieldType): TFieldType;
  protected
    procedure PopulateOPFDataset(ADataSet: TDataSet);
    procedure PopulateParams(AParams: TParams);
  end;

implementation

uses
  {$IFDEF D6Up}Variants,{$ENDIF}
  SysUtils,
  TypInfo,
  PressConsts;

{ TPressOPFDBDataset }

function TPressOPFDBDataset.DBTypeToOPFType(AFieldType: TFieldType): TPressOPFFieldType;
begin
  case AFieldType of
    ftString, ftWideString:
      Result := oftAnsiString;
    ftSmallint:
      Result := oftInt16;
    ftInteger, ftWord:
      Result := oftInt32;
    ftLargeint:
      Result := oftInt64;
    ftFloat:
      Result := oftFloat;
    ftCurrency, ftBCD:
      Result := oftCurrency;
    ftBoolean:
      Result := oftBoolean;
    ftDate:
      Result := oftDate;
    ftTime:
      Result := oftTime;
    ftDateTime:
      Result := oftDateTime;
    ftMemo, ftOraClob:
      Result := oftMemo;
    ftBlob, ftOraBlob, ftGraphic:
      Result := oftBinary;
    else
      raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [
       GetEnumName(TypeInfo(TFieldType), Ord(AFieldType))]);
  end;
end;

function TPressOPFDBDataset.OPFTypeToDBType(AFieldType: TPressOPFFieldType): TFieldType;
const
  CFieldType: array[TPressOPFFieldType] of TFieldType = (
   ftUnknown,   //  oftUnknown
   ftString,    //  oftPlainString
   ftString,    //  oftAnsiString
   ftSmallint,  //  oftInt16
   ftInteger,   //  oftInt32
   ftLargeint,  //  oftInt64
   ftFloat,     //  oftFloat
   ftCurrency,  //  oftCurrency
   ftBoolean,   //  oftBoolean
   ftDate,      //  oftDate
   ftTime,      //  oftTime
   ftDateTime,  //  oftDateTime
   ftMemo,      //  oftMemo
   ftBlob);     //  oftBinary
begin
  Result := CFieldType[AFieldType];
  if Result = ftUnknown then
    raise EPressOPFError.CreateFmt(SUnsupportedFieldType, [
     GetEnumName(TypeInfo(TPressOPFFieldType), Ord(AFieldType))]);
end;

procedure TPressOPFDBDataset.PopulateOPFDataset(ADataSet: TDataSet);
var
  VDataRow: TPressOPFDataRow;
  I: Integer;
begin
  ClearFields;
  ADataSet.DisableControls;
  ADataSet.Active := True;
  try
    for I := 0 to Pred(ADataSet.FieldDefs.Count) do
      with FieldDefs.Add do
      begin
        Name := ADataSet.FieldDefs[I].Name;
        FieldType := DBTypeToOPFType(ADataSet.FieldDefs[I].DataType);
      end;
    while not ADataSet.Eof do
    begin
      VDataRow := AddRow;
      for I := 0 to Pred(VDataRow.Count) do
        if I < ADataSet.Fields.Count then
          VDataRow[I].Value := ADataSet.Fields[I].Value;
      ADataSet.Next;
    end;
  finally
    ADataset.Active := False;
  end;
end;

procedure TPressOPFDBDataset.PopulateParams(AParams: TParams);
var
  VDBParam: TParam;
  VParam: TPressOPFParam;
  I: Integer;
begin
  for I := 0 to Pred(Params.Count) do
  begin
    VParam := Params[I];
    if not VParam.IsNull then
    begin
      case VParam.DataType of
        oftPlainString, oftAnsiString:
          AParams.ParamByName(VParam.Name).AsString := VParam.AsString;
        oftInt16:
          AParams.ParamByName(VParam.Name).AsSmallInt := VParam.AsInt16;
        oftInt32:
          AParams.ParamByName(VParam.Name).AsInteger := VParam.AsInt32;
        oftInt64:
{$ifdef fpc}
          AParams.ParamByName(VParam.Name).AsLargeInt := VParam.AsInt64;
{$else}
          AParams.ParamByName(VParam.Name).AsInteger := VParam.AsInt64;
{$endif}
        oftFloat:
          AParams.ParamByName(VParam.Name).AsFloat := VParam.AsFloat;
        oftCurrency:
          AParams.ParamByName(VParam.Name).AsCurrency := VParam.AsCurrency;
        oftBoolean:
          AParams.ParamByName(VParam.Name).AsBoolean := VParam.AsBoolean;
        oftDate:
          AParams.ParamByName(VParam.Name).AsDate := VParam.AsDate;
        oftTime:
          AParams.ParamByName(VParam.Name).AsTime := VParam.AsTime;
        oftDateTime:
          AParams.ParamByName(VParam.Name).AsDateTime := VParam.AsDateTime;
        oftMemo:
          AParams.ParamByName(VParam.Name).AsMemo := VParam.AsMemo;
        oftBinary:
          AParams.ParamByName(VParam.Name).AsBlob := VParam.AsBinary;
      end;
    end else if VParam.IsAssigned then
    begin
      VDBParam := AParams.ParamByName(VParam.Name);
      VDBParam.DataType := OPFTypeToDBType(VParam.DataType);
      VDBParam.Value := Null;
    end;
  end;
end;

end.
