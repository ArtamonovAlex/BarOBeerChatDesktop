-module(bobc_manager_connect_handler).

-behavior(cowboy_handler).

-export([init/2]).


-include_lib("stdlib/include/qlc.hrl").

-record(our_user, {our_port, blank}).

init(Req0, State) ->
    {Code, Body} = case cowboy_req:binding(chat_id, Req0, undefined) of
        undefined ->
            {400, bad_request};
        ChatId ->
            case get_online_users(binary_to_list(ChatId)) of
                undefined ->
                    {200, #{status => chat_not_found}};
                UserList ->
                    User = cowboy_req:binding(port, Req0),
                    io:format("~nAAAAAAAAAAAAAAAAAAAAAAAA   ~p~n AAAAAAAAAAAAAAAAAAAAAAAAAAA~n", [User]),
                    save_new_user(binary_to_list(ChatId), User),
                    {200, #{status => ok, user_list => UserList}}

            end
    end,
   	Req = cowboy_req:reply(Code,
        #{<<"content-type">> => <<"text/plain; charset=utf-8">>},
        jsone:encode(Body),
        Req0),
    {ok, Req, State}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  TODO Returns the list of online users in the chatroom    %%
%%  or 'undefined' if chatroom doesn't exist                 %%
%%  Also puts current user to the list of online users       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_online_users(ChatId)->
    io:format("~p~n", [ChatId]),
    init_database(ChatId),
    do(qlc:q([list_to_integer(binary_to_list(X#our_user.our_port)) || X <- mnesia:table(list_to_atom(ChatId))])).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

save_new_user(ChatId, User) ->
    mnesia:start(),
    Row = #our_user{our_port = User, blank = blank},
    F = fun() -> mnesia:write(list_to_atom(ChatId),Row, write) end,
    mnesia:transaction(F),
    Row.

init_database(ChatId) ->
    case mnesia:create_schema([node()]) of
        {error,
            {_, {already_exists, _}}} ->
            ok;
        ok -> ok
    end,
    mnesia:start(),
    case mnesia:create_table(list_to_atom(ChatId),
        [{attributes, record_info(fields, our_user)},
            {disc_copies, [node()]}, {type, ordered_set},
            {record_name, our_user}])
    of
        {aborted, {already_exists, _}} ->
            ok;
        {atomic, ok} ->
            ok
    end,
    mnesia:wait_for_tables([list_to_atom(ChatId)], 20000).