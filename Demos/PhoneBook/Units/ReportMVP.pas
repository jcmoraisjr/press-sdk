unit ReportMVP;

{$I PhoneBook.inc}

interface

uses
  Classes, PressMVPModel, PressMVPCommand, CustomMVP;

type
  TReportGroupEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
  end;

  TReportItemEditModel = class(TPressMVPObjectModel)
  protected
    procedure InitCommands; override;
  end;

  TReportItemEditPresenter = class(TCustomEditPresenter)
  protected
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
  end;

  TDesignReportCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

implementation

uses
{$IFDEF FPC}
  LCLType,
{$ELSE}
  Windows,
{$ENDIF}
  PressReport, PressReportModel;

{ TReportGroupEditPresenter }

procedure TReportGroupEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Reports', 'ReportsStringGrid', 'Caption(160);Visible(32)');
end;

{ TReportItemEditModel }

procedure TReportItemEditModel.InitCommands;
begin
  inherited;
  AddCommands([nil, TDesignReportCommand]);
end;

{ TReportItemEditPresenter }

procedure TReportItemEditPresenter.InitPresenter;
begin
  inherited;
  CreateSubPresenter('Caption', 'CaptionEdit');
  CreateSubPresenter('Visible', 'VisibleCheckBox');
  BindCommand(TDesignReportCommand, 'DesignButton');
end;

class function TReportItemEditPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := TReportItemEditModel;
end;

{ TDesignReportCommand }

function TDesignReportCommand.GetCaption: string;
begin
  Result := 'Design report';
end;

function TDesignReportCommand.GetShortCut: TShortCut;
begin
  Result := VK_F8;
end;

procedure TDesignReportCommand.InternalExecute;
begin
  (Model.Subject as TPressCustomReportItem).Design;
end;

initialization
  TReportGroupEditPresenter.RegisterBO(TPressReportGroup);
  TReportItemEditPresenter.RegisterBO(TPressReportItem);

end.
