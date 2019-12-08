-module(test).
-export([main/0]).
main() ->
    {ok,[[Name]]} = init:get_argument(sname),
    application:ensure_all_started(bobc),
    {ok, External} = application:get_env(bobc, external),
    {ok, Internal} = application:get_env(bobc, internal),
    {ok, Remote} = application:get_env(bobc, remote),
    io:format("Welcame to our app ~p!~nYour connection with desktop is on port ~p~nYour external port is ~p~nYou will try to connect to ~p~n",
    	[Name, Internal, External, Remote]).
%%    init:stop().