unit CustomEditPresenter;

{$I PhoneBook.inc}

interface

uses
  PressMVPModel, PressMVPPresenter;

type
  TCustomEditPresenter = class(TPressMVPFormPresenter)
  protected
    procedure InitPresenter; override;
    class function InternalModelClass: TPressMVPObjectModelClass; override;
  end;

implementation

uses
  PressMVPCommand, CustomEditModel;

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
