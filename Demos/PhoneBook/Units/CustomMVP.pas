unit CustomMVP;

{$I PhoneBook.inc}

interface

uses
  PressSubject,
{$IFDEF UseReport}
  PressReportManager,
{$ENDIF}
  PressMVPModel, PressMVPPresenter;

type
  TCustomEditModel = class(TPressMVPObjectModel)
  private
{$IFDEF UseReport}
    FReportManager: TPressReportManager;
{$ENDIF}
  protected
    procedure Finit; override;
    procedure SubjectChanged(AOldSubject: TPressSubject); override;
  end;

  TCustomEditPresenter = class(TPressMVPFormPresenter)
  protected
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
  end;

implementation

uses
  PressMVPCommand;

{ TCustomEditModel }

procedure TCustomEditModel.Finit;
begin
{$IFDEF UseReport}
  FReportManager.Free;
{$ENDIF}
  inherited;
end;

procedure TCustomEditModel.SubjectChanged(AOldSubject: TPressSubject);
begin
  inherited;
{$IFDEF UseReport}
  try
    FReportManager := TPressReportManager.Create(Self);
  except
    // no problem, database metadata doesn't have report classes
  end;
{$ENDIF}
end;

{ TCustomEditPresenter }

procedure TCustomEditPresenter.InitPresenter;
begin
  inherited;
  BindCommand(TPressMVPSaveObjectCommand, 'OkButton');
  BindCommand(TPressMVPCancelObjectCommand, 'CancelButton');
end;

class function TCustomEditPresenter.InternalModelClass: TPressMVPObjectModelClass;
begin
  Result := TCustomEditModel;
end;

end.
