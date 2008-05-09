unit MainFrm;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface

uses
  {$ifdef fpc}LResources,{$endif}
  Forms, StdCtrls, Controls, Classes;

type
  TMainForm = class(TForm)
    GenerateDBMetaButton: TButton;
    IncludeNameButton: TButton;
    NameEdit: TEdit;
    NameLabel: TLabel;
    ListNamesButton: TButton;
    OIDEdit: TEdit;
    IDLabel: TLabel;
    RemoveNameButton: TButton;
    ClearButton: TButton;
    OutputMemo: TMemo;
    CloseButton: TButton;
    WhereEdit: TEdit;
    WhereLabel: TLabel;
    procedure GenerateDBMetaButtonClick(Sender: TObject);
    procedure IncludeNameButtonClick(Sender: TObject);
    procedure ListNamesButtonClick(Sender: TObject);
    procedure RemoveNameButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  SysUtils, PressMessages_en, PressSubject, PressOPF,
{$IFDEF FPC}
  PressSQLdbBroker, // include sqldb connection units here
{$ELSE}
  PressIBXBroker,
{$ENDIF}
  PersonBO;

{$IFNDEF FPC}
{$R *.DFM}
{$ENDIF}

procedure TMainForm.GenerateDBMetaButtonClick(Sender: TObject);
begin
  OutputMemo.Lines.Text := AdjustLineBreaks(
   PressOPFService.Mapper.CreateDatabaseStatement);
end;

procedure TMainForm.IncludeNameButtonClick(Sender: TObject);
var
  VPerson: TPerson;
begin
  if NameEdit.Text <> '' then
  begin
    VPerson := TPerson.Create;
    try
      VPerson.Name := NameEdit.Text;
      VPerson.Store;
      OutputMemo.Lines.Add('One object stored');
    finally
      VPerson.Free;
    end;
  end else
    OutputMemo.Lines.Add('Please enter a name');
end;

procedure TMainForm.ListNamesButtonClick(Sender: TObject);

  function BuildWhereClause: string;
  begin
    if WhereEdit.Text <> '' then
      Result := 'where ' + WhereEdit.Text
    else
      Result := '';
  end;

var
  VPerson: TPerson;
  VPersonList: TPressProxyList;
  I: Integer;
begin
  VPersonList := PressOPFService.OQLQuery(Format(
   'select * from TPerson %s order by Name', [BuildWhereClause]));
  try
    for I := 0 to Pred(VPersonList.Count) do
    begin
      VPerson := VPersonList[I].Instance as TPerson;
      OutputMemo.Lines.Add(Format('%s => %s', [VPerson.Id, VPerson.Name]));
    end;
    OutputMemo.Lines.Add(Format('%d object(s) found', [VPersonList.Count]));
  finally
    VPersonList.Free;
  end;
end;

procedure TMainForm.RemoveNameButtonClick(Sender: TObject);
var
  VPerson: TPerson;
begin
  VPerson := PressOPFService.Retrieve(TPerson, OIDEdit.Text) as TPerson;
  if Assigned(VPerson) then
  begin
    try
      VPerson.Dispose;
      OutputMemo.Lines.Add('One object removed');
    finally
      VPerson.Free;
    end;
  end else
    OutputMemo.Lines.Add(Format('Object %s was not found', [OIDEdit.Text]));
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  OutputMemo.Lines.Clear;
end;

procedure TMainForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

{$IFDEF FPC}
initialization
  {$i MainFrm.lrs}
{$ENDIF}

end.
