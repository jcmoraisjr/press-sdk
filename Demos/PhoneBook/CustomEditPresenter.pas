unit CustomEditPresenter;

{$I PhoneBook.inc}

interface

uses
  PressMVPPresenter;

type
  TCustomEditPresenter = class(TPressMVPFormPresenter)
  protected
    procedure InitPresenter; override;
  end;

implementation

uses
  PressMVPCommand;

{ TCustomEditPresenter }

procedure TCustomEditPresenter.InitPresenter;
begin
  inherited;
  BindCommand(TPressMVPSaveObjectCommand, 'OkButton');
  BindCommand(TPressMVPCancelObjectCommand, 'CancelButton');
end;

end.
