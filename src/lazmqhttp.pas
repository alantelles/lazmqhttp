unit LazMqHttp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TAckMode = (ackRequeueTrue, rejectRequeueTrue, ackRequeueFalse, rejectRequeueFalse);

  TLazMqHttpClient = class
    private
      FExchange: string;
      FQueue: string;
      FRoutingKey: string;
      FVhost: string;
      FUsername: string;
      FPassword: string;
      FHost: string;
      function DoRequest(AUrl, APayload: string):string;
    public
      property Exchange: string read FExchange write FExchange;
      property Queue: string read FQueue write FQueue;
      property RoutingKey: string read FRoutingKey write FRoutingKey;
      property VHost: string read FVhost write FVhost;
      constructor Create(Ahost: string; AUSername: string; APassword: string);
      function Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
      function Consume(Ackmode: TAckMode; Count: integer; AsBase64: boolean=False; Truncate: integer = -1): string;
  end;


implementation

uses fphttpclient, StrUtils;

constructor TLazMqHttpClient.Create(Ahost: string; AUSername: string; APassword: string);
begin
  Fhost := Ahost;
  FPassword := APassword;
  FUSername := AUsername;
end;

function TLazMqHttpClient.Consume(Ackmode: TAckMode; Count: integer; AsBase64: boolean=False; Truncate: integer = -1): string;
begin

end;

function TLazMqHttpClient.Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
var
  HttpClient: TFpHttpClient;
  StrStream: TStringStream;
  Response, FullPayload: string;
  PayloadAsString: string = 'base64';
  PostUrl: string;
begin
  HttpClient := TFPHttpClient.Create(nil);
  HttpClient.UserName := FUsername;
  HttpClient.Password := FPassword;
  if PayloadencodingIsString then
    PayloadAsString := 'string';
  FullPayload := '{"properties": {}, "routing_key": "' + FRoutingKey + '", "payload": "' + ReplaceStr(Payload, '"', '\"') + '", "payload_encoding" : "' + PayloadAsString + '"}';
  StrStream := TStringStream.Create(FullPayload);
  HttpClient.RequestBody := StrStream;
  HttpClient.AddHeader('Content-Type', 'application/json');
  PostUrl := FHost + '/api/exchanges/' + FVhost + '/' + FExchange + '/publish';
  Response := HttpClient.Post(PostUrl);
  StrStream.Free;
  Httpclient.Free;
  if Response = '{"routed":true}' then
    Result := True
  else
    Result := False;
end;

end.

