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
      function GetAckModeAsString(Ackmode: TAckmode): string;
    public
      property Exchange: string read FExchange write FExchange;
      property Queue: string read FQueue write FQueue;
      property RoutingKey: string read FRoutingKey write FRoutingKey;
      property VHost: string read FVhost write FVhost;
      constructor Create(Ahost: string; AUSername: string; APassword: string);
      function Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
      function Consume(Ackmode: TAckMode=ackRequeueTrue; Count: integer=1; AsBase64: boolean=False; Truncate: integer = -1): string;
  end;


implementation

uses fphttpclient, StrUtils;

constructor TLazMqHttpClient.Create(Ahost: string; AUSername: string; APassword: string);
begin
  Fhost := Ahost;
  FPassword := APassword;
  FUSername := AUsername;
end;

function TLazMqHttpClient.GetAckModeAsString(AckMode: TAckmode): string;
var
  AsString: string;
begin
  case Ackmode of
    ackRequeueTrue : AsString := 'ack_requeue_true';
    rejectRequeueTrue : AsString := 'reject_requeue_true';
    ackRequeueFalse : AsString := 'ack_requeue_false';
    rejectRequeueFalse : AsString := 'reject_requeue_false';
  else
     AsString := 'reject_requeue_true';
  end;
  Result := AsString;
end;

function TLazMqHttpClient.DoRequest(AUrl, APayload: string): string;
var
  HttpClient: TFpHttpClient;
  StrStream: TStringStream;
  Response: string;
begin
  HttpClient := TFPHttpClient.Create(nil);
  HttpClient.UserName := FUsername;
  HttpClient.Password := FPassword;
  StrStream := TStringStream.Create(APayload);
  HttpClient.RequestBody := StrStream;
  HttpClient.AddHeader('Content-Type', 'application/json');
  try
    try
      Response := HttpClient.Post(FHost + '/api/' + AUrl);
    except
      Response := '';
    end;
  finally
    StrStream.Free;
    Httpclient.Free;
  end;
  Result := Response;
end;

function TLazMqHttpClient.Consume(Ackmode: TAckMode=ackRequeueTrue; Count: integer=1; AsBase64: boolean=False; Truncate: integer = -1): string;
var
  FullPayload: string;
  PostUrl: string;
  Encoding: string = 'auto';
begin
  PostUrl := 'queues/' + FVhost + '/' + FQueue + '/get';
  if AsBase64 then
    Encoding := 'base64';
  FullPayload := '{"count":' + IntToStr(Count) + ',"ackmode":"' + GetAckModeAsString(AckMode) + '","encoding":"' + Encoding + '"}';
  Result := DoRequest(PostUrl, FullPayload);
end;

function TLazMqHttpClient.Publish(Payload: string; PayloadEncodingIsString: boolean=True): boolean;
var
  Response, FullPayload: string;
  PayloadEncodingAsString: string = 'base64';
  PostUrl: string;
begin
  if PayloadencodingIsString then
    PayloadEncodingAsString := 'string';
  FullPayload := '{"properties": {}, "routing_key": "' + FRoutingKey + '", "payload": "' + ReplaceStr(Payload, '"', '\"') + '", "payload_encoding" : "' + PayloadEncodingAsString + '"}';
  PostUrl := 'exchanges/' + FVhost + '/' + FExchange + '/publish';
  Response := DoRequest(PostUrl, FullPayload);
  if Response = '{"routed":true}' then
    Result := True
  else
    Result := False;
end;

end.

