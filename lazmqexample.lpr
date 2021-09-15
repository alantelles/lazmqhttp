program lazmqexample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, lazmqhttp
  { you can add units after this };
var
  Cli: TLazMqHttpClient;
begin
  //Cli := TLazMqHttpClient.Create('lazmqdevexc', 'local.libdev.queue', 'local_lazmq_route', 'lazmqdevhost');
  Cli := TLazMqHttpClient.Create('http://localhost:15672', 'guest', 'guest');
  Cli.RoutingKey := 'local_lazmq_route';
  Cli.Queue := 'local.libdev.queue';
  Cli.Exchange := 'lazmqdevexc';
  Cli.VHost := 'lazmqdevhost';
  writeln(Cli.Publish('now time is any'));
  Cli.Free;
end.

