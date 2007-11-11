unit PersonBO;

{$ifdef fpc}{$mode objfpc}{$h+}{$endif}

interface

uses
  PressSubject, PressAttributes;

type
  TPerson = class(TPressObject)
    _Name: TPressString;
  private
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    class function InternalMetadataStr: string; override;
  published
    property Name: string read GetName write SetName;
  end;

implementation

{ TPerson }

function TPerson.GetName: string;
begin
  Result := _Name.Value;
end;

class function TPerson.InternalMetadataStr: string;
begin
  Result := 'TPerson IsPersistent (Name: String(60))';
end;

procedure TPerson.SetName(const Value: string);
begin
  _Name.Value := Value;
end;

initialization
  PressModel.ClassIdStorageName := 'ModelClass';
  //PressModel.ClassIdType := TPressInteger;
  TPerson.RegisterClass;

end.
