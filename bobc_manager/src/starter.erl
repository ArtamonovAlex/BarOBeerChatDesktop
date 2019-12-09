%%%-------------------------------------------------------------------
%%% @author User
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. дек. 2019 0:50
%%%-------------------------------------------------------------------
-module(starter).
-author("User").

%% API
-export([start/0]).


start() ->
    application:ensure_all_started(bobc_manager).