-module(bobc_manager_connect_handler).

-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    {Code, Body} = case cowboy_req:binding(chat_id, Req0, undefined) of
        undefined ->
            {400, bad_request};
        ChatId ->
            case get_online_users(ChatId) of
                undefined ->
                    {200, #{status => chat_not_found}};
                UserList ->
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
get_online_users(_ChatId) ->
    [].