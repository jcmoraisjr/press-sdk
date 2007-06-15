unit ReportItemEditModel;

{$I PhoneBook.inc}

interface

uses
  Classes, PressMVPModel, PressMVPCommand;

type
  TReportItemEditModel = class(TPressMVPObjectModel)
  protected
    procedure InitCommands; override;
  end;

  TDesignReportCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

implementation

uses
  Windows, Dialogs, PressReport;

{ TReportItemEditModel }

procedure TReportItemEditModel.InitCommands;
begin
  inherited;
  AddCommands([nil, TDesignReportCommand]);
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
  (Model.Subject as TPressReportItem).Design;
end;

end.
