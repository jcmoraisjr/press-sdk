unit WebInfo;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs,
  PressWebHandler;

type

  { TInfoRequestHandler }

  TInfoRequestHandler = class(TInterfacedObject, IPressWebRequestHandler)
  protected
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse);
  end;

implementation

uses
  SysUtils;

{ TInfoRequestHandler }

procedure TInfoRequestHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
const
  CBool: array[Boolean] of string = ('False', 'True');
var
  I: Integer;
begin
  AResponse.Contents.Add('<h2>hello</h2>');
  AResponse.Contents.Add('<form method="post" enctype="multipart/form-data" action="' + ARequest.ScriptName + ARequest.PathInfo + '">');
  AResponse.Contents.Add('<input type="file" name="f">');
  AResponse.Contents.Add('<input type="text" name="a" value="b">');
  AResponse.Contents.Add('<input type="text" name="c" value="d">');
  AResponse.Contents.Add('<input type="submit" value="Ok"');
  AResponse.Contents.Add('</form>');
  AResponse.Contents.Add('<hr/>');
  AResponse.Contents.Add('QueryString: ' + ARequest.QueryString);
  AResponse.Contents.Add('QueryFields:');
  for I := 0 to Pred(ARequest.QueryFields.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.QueryFields[I]);
  AResponse.Contents.Add('ContentFields:');
  for I := 0 to Pred(ARequest.ContentFields.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.ContentFields[I]);
  AResponse.Contents.Add('Files:');
  for I := 0 to Pred(ARequest.Files.Count) do
  begin
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.Files.Files[I].FileName + ' - ' +
     ARequest.Files.Files[I].LocalFileName + ' - ' + ARequest.Files.Files[I].ContentType);
  end;
  AResponse.Contents.Add('Host: ' + ARequest.Host);
  AResponse.Contents.Add('ScriptName: ' + ARequest.ScriptName);
  AResponse.Contents.Add('PathInfo: ' + ARequest.PathInfo);
  AResponse.Contents.Add('Method: ' + ARequest.Method);
  AResponse.Contents.Add('URL: ' + ARequest.URL);
  AResponse.Contents.Add('<hr/>');
  AResponse.Contents.Add('ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('1-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('2-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('3-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('4-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('5-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('6-GetNextPathInfo: ' + ARequest.GetNextPathInfo + ' - ReturnedPathInfo: ' + ARequest.ReturnedPathInfo);
  AResponse.Contents.Add('LocalPathPrefix: ' + ARequest.LocalPathPrefix);
  AResponse.Contents.Add('CommandLine: ' + ARequest.CommandLine);
  AResponse.Contents.Add('Command: ' + ARequest.Command);
  AResponse.Contents.Add('URI: ' + ARequest.URI);
  AResponse.Contents.Add('QueryString: ' + ARequest.QueryString);
  AResponse.Contents.Add('HeaderLine: ' + ARequest.HeaderLine);
  AResponse.Contents.Add('HandleGetOnPost: ' + CBool[ARequest.HandleGetOnPost]);
  AResponse.Contents.Add('Files:');
  for I := 0 to Pred(ARequest.Files.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.Files.Files[I].FileName + ' - ' +
     ARequest.Files.Files[I].LocalFileName + ' - ' + ARequest.Files.Files[I].ContentType);
  AResponse.Contents.Add('Fields:');
  for I := 0 to Pred(ARequest.FieldCount) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.Fields[I] + ' - ' + ARequest.FieldNames[I] + ' - ' + ARequest.FieldValues[I]);
  AResponse.Contents.Add('CookieFields:');
  for I := 0 to Pred(ARequest.CookieFields.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.CookieFields[I]);
  AResponse.Contents.Add('ContentFields:');
  for I := 0 to Pred(ARequest.ContentFields.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.ContentFields[I]);
  AResponse.Contents.Add('QueryFields:');
  for I := 0 to Pred(ARequest.QueryFields.Count) do
    AResponse.Contents.Add(IntToStr(I) + ': ' + ARequest.QueryFields[I]);
  AResponse.Contents.Add('');

  AResponse.Contents.Add('HttpVersion: ' + ARequest.HttpVersion);
  AResponse.Contents.Add('ProtocolVersion: ' + ARequest.ProtocolVersion);
  AResponse.Contents.Add('Accept: ' + ARequest.Accept);
  AResponse.Contents.Add('AcceptCharset: ' + ARequest.AcceptCharset);
  AResponse.Contents.Add('AcceptEncoding: ' + ARequest.AcceptEncoding);
  AResponse.Contents.Add('AcceptLanguage: ' + ARequest.AcceptLanguage);
  AResponse.Contents.Add('Authorization: ' + ARequest.Authorization);
  AResponse.Contents.Add('Connection: ' + ARequest.Connection);
  AResponse.Contents.Add('ContentEncoding: ' + ARequest.ContentEncoding);
  AResponse.Contents.Add('ContentLanguage: ' + ARequest.ContentLanguage);
  AResponse.Contents.Add('ContentLength: ' + IntToStr(ARequest.ContentLength));
  AResponse.Contents.Add('ContentType: ' + ARequest.ContentType);
  AResponse.Contents.Add('Cookie: ' + ARequest.Cookie);
  AResponse.Contents.Add('Date: ' + ARequest.Date);
  AResponse.Contents.Add('Expires: ' + ARequest.Expires);
  AResponse.Contents.Add('From: ' + ARequest.From);
  AResponse.Contents.Add('IfModifiedSince: ' + ARequest.IfModifiedSince);
  AResponse.Contents.Add('LastModified: ' + ARequest.LastModified);
  AResponse.Contents.Add('Location: ' + ARequest.Location);
  AResponse.Contents.Add('Pragma: ' + ARequest.Pragma);
  AResponse.Contents.Add('Referer: ' + ARequest.Referer);
  AResponse.Contents.Add('RetryAfter: ' + ARequest.RetryAfter);
  AResponse.Contents.Add('Server: ' + ARequest.Server);
  AResponse.Contents.Add('SetCookie: ' + ARequest.SetCookie);
  AResponse.Contents.Add('UserAgent: ' + ARequest.UserAgent);
  AResponse.Contents.Add('WWWAuthenticate: ' + ARequest.WWWAuthenticate);
  AResponse.Contents.Add('PathInfo: ' + ARequest.PathInfo);
  AResponse.Contents.Add('PathTranslated: ' + ARequest.PathTranslated);
  AResponse.Contents.Add('RemoteAddress: ' + ARequest.RemoteAddress);
  AResponse.Contents.Add('RemoteHost: ' + ARequest.RemoteHost);
  AResponse.Contents.Add('ScriptName: ' + ARequest.ScriptName);
  AResponse.Contents.Add('ServerPort: ' + IntToStr(ARequest.ServerPort));
  AResponse.Contents.Add('HTTPAccept: ' + ARequest.HTTPAccept);
  AResponse.Contents.Add('HTTPAcceptCharset: ' + ARequest.HTTPAcceptCharset);
  AResponse.Contents.Add('HTTPAcceptEncoding: ' + ARequest.HTTPAcceptEncoding);
  AResponse.Contents.Add('HTTPIfModifiedSince: ' + ARequest.HTTPIfModifiedSince);
  AResponse.Contents.Add('HTTPReferer: ' + ARequest.HTTPReferer);
  AResponse.Contents.Add('HTTUserAgent: ' + ARequest.HTTPUserAgent);
  AResponse.Contents.Add('Method: ' + ARequest.Method);
  AResponse.Contents.Add('URL: ' + ARequest.URL);
  AResponse.Contents.Add('Host: ' + ARequest.Host);
  AResponse.Contents.Add('HTTPXRequestedWith: ' + ARequest.HTTPXRequestedWith);

  for I := 2 to Pred(AResponse.Contents.Count) do
    AResponse.Contents[I] := AResponse.Contents[I] + '<br>';
end;

initialization
  TPressWebHandler.DefaultService.RegisterRequestHandler('/info*', TInfoRequestHandler.Create);

end.

