program project;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse, System.JSON;

var
  App: THorse;

begin

  App := THorse.Create();

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Listen(9000);
end.
