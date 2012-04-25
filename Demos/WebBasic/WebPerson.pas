unit WebPerson;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs,
  PressWebHandler;

type

  { TPersonRequestHandler }

  TPersonRequestHandler = class(TInterfacedObject, IPressWebRequestHandler)
  protected
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

implementation

uses
  PressOPF,
  PersonBO;

{ TPersonRequestHandler }

procedure TPersonRequestHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
var
  VPerson: TPerson;
begin
  AResponse.Contents.Add('<html><head><meta charset="UTF-8"></head><body>');
  if ARequest.PathInfo = '/person/save' then
  begin
    VPerson := TPerson.Create;
    try
      VPerson.Name := ARequest.ContentFields.Values['name'];
      PressOPFService.Store(VPerson);
      AResponse.Contents.Add(VPerson.Name + ' saved');
    finally
      VPerson.Free;
    end;
  end else if ARequest.PathInfo = '/person/ddl' then
  begin
    AResponse.Contents.Add('<textarea cols="60" rows="30">');
    AResponse.Contents.Add(PressOPFService.CreateDatabaseStatement);
    AResponse.Contents.Add('</textarea>');
  end else
  begin
    AResponse.Contents.Add('<form method="post" action="' + ARequest.ScriptName + '/person/save">');
    AResponse.Contents.Add('Name: <input type="text" name="name" value="">');
    AResponse.Contents.Add('<input type="submit" value="Save">');
    AResponse.Contents.Add('</form>');
    AResponse.Contents.Add('<a href="' + ARequest.ScriptName + '/person/ddl">DDL</a>');
  end;
  AResponse.Contents.Add('<body></html>');
end;

initialization
  TPressWebHandler.DefaultService.RegisterRequestHandler('/person/*', TPersonRequestHandler.Create);

end.

