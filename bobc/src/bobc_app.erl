%%%-------------------------------------------------------------------
%% @doc bobc public API
%% @end
%%%-------------------------------------------------------------------

-module(bobc_app).

-behaviour(application).

-export([start/2, stop/1]).
-record(state, {pid_server}).
-record(message, {msg_id, msg, from, time}).
-define(ChatId, 123).

start(_StartType, _StartArgs) ->
    {ok, Port} = application:get_env(bobc, port),
    {ok, User} = application:get_env(bobc, user),
    {ok, Back} = application:get_env(bobc, back),
    {ok,Pid_server} = local_back:start_link(Back, User),
    State = #state{pid_server = Pid_server},
    init_database(?ChatId),
    Dispatch = cowboy_router:compile([
            {'_', [
                {"/", bobc_handler, []},
                {"/websocket", websocket_handler, State}
            ]}
        ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
        ),    

    bobc_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
init_database(ChatId) ->
    case mnesia:create_schema([node()]) of
        {error,
            {_, {already_exists, _}}} ->
            ok;
        ok -> ok
    end,
    mnesia:start(),
    case mnesia:create_table(list_to_atom(ChatId),
        [{attributes, record_info(fields, message)},
            {disc_copies, [node()]}, {type, ordered_set},
            {record_name, message}])
    of
        {aborted, {already_exists, _}} -> ok;
        {atomic, ok} ->
            Row = #message{from = system, msg  = "Welcome to chat " ++ ChatId, msg_id = 0, time = calendar:local_time()},
            F = fun() -> mnesia:write(list_to_atom(ChatId),Row, write) end,
            mnesia:transaction(F),
            ok
    end,
    mnesia:wait_for_tables([list_to_atom(ChatId)], 20000).