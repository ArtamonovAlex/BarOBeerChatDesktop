%%%-------------------------------------------------------------------
%% @doc bobc public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
            {'_', [
                {"/", bobc_handler, []},
                {"/websocket", websocket_handler, []}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
        ),    

    bobc_sup:start_link().

stop(_State) ->
    ok.

%% internal functions