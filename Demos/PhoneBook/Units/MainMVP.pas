unit MainMVP;

{$I PhoneBook.inc}

interface

uses
  Classes, PressSubject,
{$IFDEF UseReport}
  PressReportManager,
{$ENDIF}
  PressMVP, PressMVPModel, PressMVPPresenter, PressMVPCommand;

type
  TMainModel = class(TPressMVPQueryModel)
  private
{$IFDEF UseReport}
    FReportManager: TPressReportManager;
{$ENDIF}
  protected
    procedure Finit; override;
    procedure SubjectChanged(AOldSubject: TPressSubject); override;
  end;

  TMainPresenter = class(TPressMVPMainFormPresenter)
  private
    FInternalCache: TPressObjectList;
  protected
    procedure Finit; override;
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
    procedure Running; override;
  end;

  TMainAddPersonCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalObjectClass: TPressObjectClass; override;
  end;

  TMainAddCompanyCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalObjectClass: TPressObjectClass; override;
  end;

  TMainConnectorCommand = class(TPressMVPCommand)
  protected
    procedure InternalExecute; override;
  end;

implementation

uses
{$IFDEF FPC}
  LCLType,
{$ELSE}
  Windows,
{$ENDIF}
  Menus,
  Clipbrd,
  PressUser,
  PressDialogs,
  PressOPF,
  MainFrm,
  ContactBO;

{ TMainModel }

procedure TMainModel.Finit;
begin
{$IFDEF UseReport}
  FReportManager.Free;
{$ENDIF}
  inherited;
end;

procedure TMainModel.SubjectChanged(AOldSubject: TPressSubject);
begin
  inherited;
{$IFDEF UseReport}
  FReportManager := TPressReportManager.Create(Self);
{$ENDIF}
end;

{ TMainPresenter }

procedure TMainPresenter.Finit;
begin
  FInternalCache.Free;
  inherited;
end;

procedure TMainPresenter.InitPresenter;
var
  VItems: TPressMVPPresenter;
begin
  inherited;
  VItems := CreateQueryItemsPresenter(
   'ItemsStringGrid', 'Name(240);Address.City.Name(160)');
  VItems.Model.InsertCommands(0, [TMainAddPersonCommand, TMainAddCompanyCommand]);
  BindCommand(TPressMVPExecuteQueryCommand, 'QuerySpeedButton');
  BindCommand(TMainConnectorCommand, 'ConnectorMenuItem');
  BindCommand(TPressMVPCloseApplicationCommand, 'CloseMenuItem');
  CreateSubPresenter('Name', 'NameQueryEdit');
end;

class function TMainPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := TMainModel;
end;

procedure TMainPresenter.Running;
begin
  inherited;
  PressUserData.Logon;
end;

{ TMainAddPersonCommand }

function TMainAddPersonCommand.GetCaption: string;
begin
  Result := 'Add Person';
end;

function TMainAddPersonCommand.GetShortCut: TShortCut;
begin
  Result := VK_F2;
end;

function TMainAddPersonCommand.InternalObjectClass: TPressObjectClass;
begin
  Result := TPerson;
end;

{ TMainAddCompanyCommand }

function TMainAddCompanyCommand.GetCaption: string;
begin
  Result := 'Add Company';
end;

function TMainAddCompanyCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F2, [ssCtrl]);
end;

function TMainAddCompanyCommand.InternalObjectClass: TPressObjectClass;
begin
  Result := TCompany;
end;

{ TMainConnectorCommand }

procedure TMainConnectorCommand.InternalExecute;
begin
  if PressDialog.ConfirmDlg(
   'Copy the database metadata to the clipboard?') then
    Clipboard.AsText := PressOPFService.CreateDatabaseStatement;
end;

initialization
  TMainPresenter.RegisterBO(TMainQuery);

end.
