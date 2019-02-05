﻿{ This unit is a drop in replacement to build-in unit crt }
Unit MyCrt;
Interface
Uses Windows, Math;
Const
Black: Integer = 0;
Blue: Integer = 1;
Green: Integer = 2;
Red: Integer = 4;
Gray: Integer = 8;
Aqua: Integer = 3;
Purple: Integer = 5;
Yellow: Integer = 6;
LightGray: Integer = 7;
LightBlue: Integer = 9;
LightGreen: Integer = 10;
LightRed: Integer = 12;
LightAqua: Integer = 11;
LightPurple: Integer = 13;
LightYellow: Integer = 14;
White: Integer = 15;

Procedure InitConsole();
Procedure SetConsoleSize(Const Width: Integer; Const Height: Integer);
Procedure PollConsoleInput(Var irInBuf: Array Of INPUT_RECORD; Const bufSize: DWord; Var cNumRead: DWord);
Procedure ClrScr();
Procedure SetConsoleColor(Const color: Word);
Procedure TextBackground(Const color: Integer);
Procedure TextColor(Const color: Integer);
Procedure GoToXY(Const X: Integer; Const Y: Integer);
Procedure RestoreConsole();

Implementation
Var
hStdin: Handle;
hStdout: Handle;
fdwSaveOldMode: DWord;
CurrentInfo: CONSOLE_SCREEN_BUFFER_INFO;

Procedure InitConsole();
Var
fdwMode: DWord;
cursorInfo: CONSOLE_CURSOR_INFO;
Begin
	SetConsoleOutputCP(437);
	hStdin := GetStdHandle(STD_INPUT_HANDLE);
	hStdout := GetStdHandle(STD_OUTPUT_HANDLE);
	GetConsoleMode(hStdin, @fdwSaveOldMode);
	fdwMode := ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT;
	SetConsoleMode(hStdin, fdwMode);
	cursorInfo.bVisible := False;
	cursorInfo.dwSize := 100;
	SetConsoleCursorInfo(hStdout, cursorInfo);
	TextBackground(Black);
	TextColor(White);
	ClrScr();
End;

Procedure SetConsoleSize(Const Width: Integer; Const Height: Integer);
Var
BufferSize: Coord;
ConsoleSize: SMALL_RECT;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	{ Set a buffer size bigger than the console size }
	BufferSize.X := Max(CurrentInfo.dwSize.X, Width);
	BufferSize.Y := Max(CurrentInfo.dwSize.Y, Height);
	SetConsoleScreenBufferSize(hStdout, BufferSize);
	{ Then safely set the console size }
	ConsoleSize.Top := 0;
	ConsoleSize.Left := 0;
	ConsoleSize.Right := Width - 1;
	ConsoleSize.Bottom := Height - 1;
	SetConsoleWindowInfo(hStdout, True, ConsoleSize);
	{ Set the buffer size to be equal to the console size }
	BufferSize.X := Width;
	BufferSize.Y := Height;
	SetConsoleScreenBufferSize(hStdout, BufferSize);
End;

Procedure PollConsoleInput(Var irInBuf: Array Of INPUT_RECORD; Const bufSize: DWord; Var cNumRead: DWord);
Begin
	ReadConsoleInput(hStdin, irInBuf, bufSize, @cNumRead);
End;

Procedure ClrScr();
Var
screen: Coord;
cCharsWritten: DWord;
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	screen.X := 0;
	screen.Y := 0;
	FillConsoleOutputCharacter(hStdout, ' ', CurrentInfo.dwSize.X * CurrentInfo.dwSize.Y, screen, @cCharsWritten);
	FillConsoleOutputAttribute(hStdout, CurrentInfo.wAttributes, CurrentInfo.dwSize.X * CurrentInfo.dwSize.Y, screen, @cCharsWritten);
	GoToXY(0, 0);
End;

Procedure SetConsoleColor(Const color: Word);
Begin
	SetConsoleTextAttribute(hStdout, color);
End;

Procedure TextBackground(Const color: Integer);
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	SetConsoleColor(CurrentInfo.wAttributes And 15 + color * 16);
End;

Procedure TextColor(Const color: Integer);
Begin
	GetConsoleScreenBufferInfo(hStdout, @CurrentInfo);
	SetConsoleColor(CurrentInfo.wAttributes And 240 + color);
End;

Procedure GoToXY(Const X: Integer; Const Y: Integer);
Var
Loc: Coord;
Begin
	Loc.X := X;
	Loc.Y := Y;
	SetConsoleCursorPosition(hStdout, Loc);
End;

Procedure RestoreConsole();
Begin
	SetConsoleMode(hStdin, fdwSaveOldMode);
End;

End.